import Foundation
import Darwin

/// Snapshot of the foreground process attached to a terminal surface.
///
/// `name` is the basename reported by `proc_name(2)` normalized to lowercase so
/// that equality comparisons stay stable across ticks. `isCLI` is derived from
/// `name` by matching against the curated set of tracked CLI commands.
struct ForegroundProcessInfo: Equatable {
    let pid: pid_t
    let name: String
    let isCLI: Bool
    let updatedAt: Date

    /// Commands we classify as "CLI" foreground processes.
    ///
    /// Keep this in sync with the tracked-agent list surfaced elsewhere in the
    /// app; callers depend on `isCLI` as the single classification signal.
    static let cliCommands: Set<String> = ["claude", "codex", "gemini"]

    init(pid: pid_t, name: String, updatedAt: Date) {
        let normalized = name.lowercased()
        self.pid = pid
        self.name = normalized
        self.isCLI = Self.cliCommands.contains(normalized)
        self.updatedAt = updatedAt
    }
}

/// Polls the foreground process of a terminal surface and reports changes.
///
/// The probe owns a dedicated serial `DispatchQueue` and a `DispatchSourceTimer`
/// that fires every 200ms. Each tick asks the owner (on the main actor) for the
/// current foreground PID via the supplied `onTick` closure, then resolves the
/// process name off-main before emitting `onUpdate` when the PID transitions.
///
/// Invariants:
/// - `onUpdate` is only invoked when the PID changes (including
///   `nil` <-> non-nil transitions). Identical PIDs are debounced; the callback
///   does not fire simply because time has passed.
/// - `onUpdate` is delivered on the probe's internal serial queue. Callers are
///   responsible for bouncing back to the main actor if they need to mutate
///   `@Published` state (e.g. `DispatchQueue.main.async { surface.foregroundProcess = info }`).
/// - `stop()` is idempotent and may also be called during `deinit`.
///
/// Threading model:
/// - `onTick` runs on the main actor (pid must be read through
///   `liveSurfaceForGhosttyAccess(reason:)` per `ghostty_surface_t` contract).
/// - Name resolution and classification happen on the internal queue so the
///   typing hot path stays untouched.
final class ForegroundProcessProbe {
    /// Serial queue that drives the timer and serializes state access.
    private let queue: DispatchQueue

    /// Timer currently driving the poll loop. `nil` when stopped.
    private var timer: DispatchSourceTimer?

    /// Last pid we reported through `onUpdate`. `nil` means "reported nothing"
    /// or "reported absence". Only touched on `queue`.
    private var lastReportedPid: pid_t?

    /// Update callback. Captured by `start(...)`; cleared by `stop()`.
    private var onUpdate: ((ForegroundProcessInfo?) -> Void)?

    /// PID-source callback. Captured by `start(...)`; cleared by `stop()`.
    private var onTick: (@MainActor () -> pid_t?)?

    /// Polling interval. Matches the 200ms cadence used by PortScanner's
    /// coalesce window so we do not over-sample the surface.
    private static let pollInterval: DispatchTimeInterval = .milliseconds(200)
    private static let pollLeeway: DispatchTimeInterval = .milliseconds(10)

    init() {
        // Suffix the label with a random tag so concurrent probes
        // (e.g. per-surface) are distinguishable in Instruments without us
        // having to thread a user-provided id through every call site.
        let uniq = String(UInt.random(in: 0...UInt.max), radix: 36)
        self.queue = DispatchQueue(label: "com.cmux.foregroundProbe.\(uniq)", qos: .utility)
    }

    deinit {
        // `stop()` is safe to call multiple times and safe during deinit:
        // we never retain `self` inside the timer event handler (weak self).
        stop()
    }

    /// Begin polling. Safe to call only once per probe instance; subsequent
    /// calls replace the previous timer and callbacks.
    ///
    /// - Parameters:
    ///   - onTick: Returns the current foreground pid (or `nil` / `-1` when
    ///     unavailable). Invoked on the main actor per socket-command
    ///     threading policy. Callers typically implement this as
    ///     `surface.liveSurfaceForGhosttyAccess(reason:) |> ghostty_surface_foreground_pid`.
    ///   - onUpdate: Invoked on the probe's internal serial queue whenever the
    ///     foreground pid transitions. Receives `nil` when the foreground
    ///     becomes unavailable.
    func start(
        onTick: @escaping @MainActor () -> pid_t?,
        onUpdate: @escaping (ForegroundProcessInfo?) -> Void
    ) {
        queue.async { [weak self] in
            guard let self else { return }
            // Replace any previous session cleanly before installing new state.
            self.cancelTimerLocked()
            self.lastReportedPid = nil
            self.onTick = onTick
            self.onUpdate = onUpdate

            let timer = DispatchSource.makeTimerSource(queue: self.queue)
            timer.schedule(
                deadline: .now() + Self.pollInterval,
                repeating: Self.pollInterval,
                leeway: Self.pollLeeway
            )
            // `[weak self]` is essential: the timer is attached to `self.queue`
            // and holds its event handler for the lifetime of the source. A
            // strong capture would leak the probe past `deinit`.
            timer.setEventHandler { [weak self] in
                self?.requestTick()
            }
            self.timer = timer
            timer.resume()
        }
    }

    /// Stop polling and release retained callbacks. Idempotent.
    func stop() {
        queue.async { [weak self] in
            guard let self else { return }
            self.cancelTimerLocked()
            self.onTick = nil
            self.onUpdate = nil
            self.lastReportedPid = nil
        }
    }

    // MARK: - Tick pipeline

    /// Bridge one tick from the probe queue to the main actor (for pid read)
    /// and back. Runs on `queue`.
    private func requestTick() {
        guard let onTick else { return }
        // Hop to main for the pid read. The main-actor contract around
        // `ghostty_surface_t` forbids touching the surface from arbitrary
        // threads, so we cannot inline this on `queue`. We use `Task { @MainActor in }`
        // (same pattern as `PortScanner.runScan`) rather than
        // `DispatchQueue.main.async` so the `@MainActor`-isolated `onTick`
        // closure is called from a properly isolated context under Swift 6
        // strict concurrency.
        Task { @MainActor [weak self] in
            let pid = onTick()
            guard let self else { return }
            self.queue.async { [weak self] in
                self?.handleTick(rawPid: pid)
            }
        }
    }

    /// Handle a single pid observation on the probe queue. Debounces identical
    /// pids and emits `onUpdate` only on transitions.
    private func handleTick(rawPid: pid_t?) {
        // Normalize: treat -1 ("no foreground") as absence, same as `nil`.
        let normalized: pid_t?
        if let rawPid, rawPid > 0 {
            normalized = rawPid
        } else {
            normalized = nil
        }

        // Debounce: identical to last reported pid -> nothing to do.
        if normalized == lastReportedPid {
            return
        }

        guard let onUpdate else {
            // Probe was stopped between the main hop and now; drop.
            lastReportedPid = normalized
            return
        }

        guard let pid = normalized else {
            // Transition to "no foreground".
            lastReportedPid = nil
            onUpdate(nil)
            return
        }

        // New pid: resolve its process name off-main (we are on `queue`).
        let resolved = Self.resolveProcessName(pid: pid) ?? ""
        let info = ForegroundProcessInfo(
            pid: pid,
            name: resolved,
            updatedAt: Date()
        )
        lastReportedPid = pid
        onUpdate(info)
    }

    // MARK: - Timer lifecycle

    /// Cancel and drop the timer. Must be called on `queue`.
    private func cancelTimerLocked() {
        timer?.cancel()
        timer = nil
    }

    // MARK: - proc_name resolution

    /// Resolve the short process name for `pid` using `proc_name(2)` from
    /// `libproc`. Returns `nil` when the kernel reports an empty name or the
    /// call fails (e.g. the process exited between pid capture and lookup).
    ///
    /// Unchecked assumption: `Darwin` re-exports `libproc.h` and `sys/param.h`,
    /// so `proc_name` and `MAXCOMLEN` are both visible without a bridging
    /// header. This matches how `AppDelegate.swift` calls `libproc`-adjacent
    /// APIs today. If a future SDK stops re-exporting these symbols we will
    /// need an explicit `@_silgen_name` shim, mirroring the pattern used for
    /// `ghostty_surface_clear_selection` at the top of `GhosttyTerminalView.swift`.
    static func resolveProcessName(pid: pid_t) -> String? {
        // `MAXCOMLEN` is 16 on Darwin. `proc_name` writes a NUL-terminated
        // short name, so `MAXCOMLEN + 1` is the minimum safe buffer.
        let capacity = Int(MAXCOMLEN) + 1
        var buffer = [CChar](repeating: 0, count: capacity)
        let written = buffer.withUnsafeMutableBufferPointer { bufPtr -> Int32 in
            guard let base = bufPtr.baseAddress else { return -1 }
            return proc_name(pid, base, UInt32(bufPtr.count))
        }
        // `proc_name` returns the number of bytes written on success and
        // a negative value on failure. Defensive check: also bail on empty
        // strings (observed for zombie/exited pids).
        guard written > 0 else { return nil }
        let name = String(cString: buffer)
        return name.isEmpty ? nil : name
    }
}

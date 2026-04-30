import SwiftUI
import Foundation
import AppKit
import Bonsplit

/// View for rendering a terminal panel
struct TerminalPanelView: View {
    @ObservedObject var panel: TerminalPanel
    @AppStorage(NotificationPaneRingSettings.enabledKey)
    private var notificationPaneRingEnabled = NotificationPaneRingSettings.defaultEnabled
    @AppStorage(PaneAffordanceSettings.modeKey)
    private var paneAffordanceModeRaw = PaneAffordanceSettings.defaultMode.rawValue
    @AppStorage(PaneFocusBorderSettings.colorHexKey)
    private var paneFocusBorderColorHex = PaneFocusBorderSettings.defaultColorHex
    @AppStorage(PaneAffordanceSettings.activeBackgroundColorHexKey)
    private var paneAffordanceActiveBackgroundHex = PaneAffordanceSettings.defaultActiveBackgroundColorHex
    @AppStorage(PaneAffordanceSettings.inactiveBackgroundColorHexKey)
    private var paneAffordanceInactiveBackgroundHex = PaneAffordanceSettings.defaultInactiveBackgroundColorHex
    @AppStorage(PaneAffordanceSettings.activeForegroundColorHexKey)
    private var paneAffordanceActiveForegroundHex = PaneAffordanceSettings.defaultActiveForegroundColorHex
    @AppStorage(PaneAffordanceSettings.inactiveForegroundColorHexKey)
    private var paneAffordanceInactiveForegroundHex = PaneAffordanceSettings.defaultInactiveForegroundColorHex
    let paneId: PaneID
    let isFocused: Bool
    let isVisibleInUI: Bool
    let portalPriority: Int
    let isSplit: Bool
    let appearance: PanelAppearance
    let hasUnreadNotification: Bool
    let onFocus: () -> Void
    let onTriggerFlash: () -> Void

    var body: some View {
        // Layering contract: terminal find UI is mounted in GhosttySurfaceScrollView (AppKit portal layer)
        // via `searchState`. Rendering `SurfaceSearchOverlay` in this SwiftUI container can hide it.
        GhosttyTerminalView(
            terminalSurface: panel.surface,
            paneId: paneId,
            isActive: isFocused,
            isVisibleInUI: isVisibleInUI,
            portalZPriority: portalPriority,
            showsInactiveOverlay: isSplit && !isFocused,
            showsUnreadNotificationRing: hasUnreadNotification && notificationPaneRingEnabled,
            focusedBorderEnabled: isFocused && isSplit && (PaneAffordanceMode(rawValue: paneAffordanceModeRaw) ?? PaneAffordanceSettings.defaultMode) != .off,
            focusedBorderColorHex: paneFocusBorderColorHex,
            paneAffordanceModeRaw: isSplit ? paneAffordanceModeRaw : PaneAffordanceMode.off.rawValue,
            paneAffordanceActiveBackgroundHex: paneAffordanceActiveBackgroundHex,
            paneAffordanceInactiveBackgroundHex: paneAffordanceInactiveBackgroundHex,
            paneAffordanceActiveForegroundHex: paneAffordanceActiveForegroundHex,
            paneAffordanceInactiveForegroundHex: paneAffordanceInactiveForegroundHex,
            inactiveOverlayColor: appearance.unfocusedOverlayNSColor,
            inactiveOverlayOpacity: appearance.unfocusedOverlayOpacity,
            searchState: panel.searchState,
            reattachToken: panel.viewReattachToken,
            onFocus: { _ in onFocus() },
            onTriggerFlash: onTriggerFlash
        )
        // Keep the NSViewRepresentable identity stable across bonsplit structural updates.
        // This prevents transient teardown/recreate that can momentarily detach the hosted terminal view.
        .id(panel.id)
        .background(Color.clear)
    }
}

/// Shared appearance settings for panels
struct PanelAppearance {
    let dividerColor: Color
    let unfocusedOverlayNSColor: NSColor
    let unfocusedOverlayOpacity: Double

    static func fromConfig(_ config: GhosttyConfig) -> PanelAppearance {
        PanelAppearance(
            dividerColor: Color(nsColor: config.resolvedSplitDividerColor),
            unfocusedOverlayNSColor: config.unfocusedSplitOverlayFill,
            unfocusedOverlayOpacity: config.unfocusedSplitOverlayOpacity
        )
    }
}

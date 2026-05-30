import Foundation

/// Settings under the dotted-id prefix `paneAppearance.*`.
public struct PaneAppearanceCatalogSection: SettingCatalogSection {
    public let mode = DefaultsKey<String>(
        id: "paneAppearance.mode",
        defaultValue: "borderOnly",
        userDefaultsKey: "paneAffordanceMode",
        legacyUserDefaultsKeys: ["paneFocusBorderEnabled"]
    )

    public let borderColor = DefaultsKey<String>(
        id: "paneAppearance.borderColor",
        defaultValue: "#5AC8FA",
        userDefaultsKey: "paneFocusBorderColorHex"
    )

    public let activeBackgroundColor = DefaultsKey<String>(
        id: "paneAppearance.activeBackgroundColor",
        defaultValue: "#0E1116",
        userDefaultsKey: "paneAffordanceActiveBackgroundColorHex"
    )

    public let inactiveBackgroundColor = DefaultsKey<String>(
        id: "paneAppearance.inactiveBackgroundColor",
        defaultValue: "#1A1D24",
        userDefaultsKey: "paneAffordanceInactiveBackgroundColorHex"
    )

    public let activeForegroundColor = DefaultsKey<String>(
        id: "paneAppearance.activeForegroundColor",
        defaultValue: "#FFFFFF",
        userDefaultsKey: "paneAffordanceActiveForegroundColorHex"
    )

    public let inactiveForegroundColor = DefaultsKey<String>(
        id: "paneAppearance.inactiveForegroundColor",
        defaultValue: "#7B7E85",
        userDefaultsKey: "paneAffordanceInactiveForegroundColorHex"
    )

    public init() {}
}

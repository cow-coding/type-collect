import Foundation

/// Compile-time flags that let Debug (dev) and Release (prod) builds
/// coexist on the same Mac without sharing save data.
///
/// - `storageFolderName` is used by every on-disk writer so Debug
///   builds write to `~/Library/Application Support/Tapistry-Dev`
///   while Release builds stay on `~/Library/Application Support/Tapistry`.
/// - `isDebugBuild` / `titleSuffix` let the UI show a small "Dev"
///   marker when you're running a local build next to the installed
///   release.
enum AppEnvironment {
    static let storageFolderName: String = {
        #if DEBUG
        return "Tapistry-Dev"
        #else
        return "Tapistry"
        #endif
    }()

    static let isDebugBuild: Bool = {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }()

    /// Optional short suffix shown next to the product name in UI when
    /// running a Debug build. `nil` in Release.
    static let titleSuffix: String? = {
        #if DEBUG
        return "Dev"
        #else
        return nil
        #endif
    }()
}

#if canImport(CarPlay)
import CarPlay

/// Namespace for CxCarPlay reactive extensions.
public struct CxCarPlayExtension<Base> {
    public let base: Base
    public init(_ base: Base) { self.base = base }
}

/// Protocol adopted by CarPlay types that expose Combine extensions.
public protocol CxCarPlayCompatible: AnyObject {}

extension CxCarPlayCompatible {
    public var cx: CxCarPlayExtension<Self> { CxCarPlayExtension(self) }
}

// Declare conformances — implementations added in per-type files
extension CPListTemplate: CxCarPlayCompatible {}
extension CPGridTemplate: CxCarPlayCompatible {}
extension CPTabBarTemplate: CxCarPlayCompatible {}
#endif

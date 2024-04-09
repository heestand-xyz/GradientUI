import SwiftUI
import PixelColor

public struct GradientColorStop: Equatable {

    public var location: CGFloat
    public var color: PixelColor
    
    /// Gradient Color Stop
    /// - Parameters:
    ///   - location: A fractional value between `0.0` and `1.0`
    public init(at location: CGFloat, color: PixelColor) {
        self.location = location
        self.color = color
    }
}

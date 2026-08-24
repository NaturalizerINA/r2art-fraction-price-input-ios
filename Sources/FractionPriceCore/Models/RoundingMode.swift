import Foundation

/// Rounding modes for fraction price snapping.
public enum RoundingMode: String, CaseIterable, Sendable {
    /// Round to nearest valid tick.
    case nearest
    /// Round down to nearest valid tick (<= price).
    case floor
    /// Round up to nearest valid tick (>= price).
    case ceil
}

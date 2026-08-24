import Foundation

/// Represents a single price tier interval with a specific tick size.
public struct TickTier: Equatable, Sendable {
    /// The inclusive minimum price of this tier.
    public let minPrice: Double
    
    /// The exclusive (or inclusive for top tier) maximum price of this tier.
    public let maxPrice: Double
    
    /// The price increment/decrement (fraksi) within this tier.
    public let tickSize: Double
    
    /// Maximum allowed step jump in ticks (optional regulatory limit, e.g. 10 ticks).
    public let maxPriceStep: Int?
    
    /// Optional label or name for this tier (e.g. "< Rp 200").
    public let label: String?
    
    public init(
        minPrice: Double,
        maxPrice: Double,
        tickSize: Double,
        maxPriceStep: Int? = nil,
        label: String? = nil
    ) {
        precondition(minPrice < maxPrice, "minPrice (\(minPrice)) must be less than maxPrice (\(maxPrice))")
        precondition(tickSize > 0, "tickSize (\(tickSize)) must be greater than 0")
        
        self.minPrice = minPrice
        self.maxPrice = maxPrice
        self.tickSize = tickSize
        self.maxPriceStep = maxPriceStep
        self.label = label
    }
    
    /// Checks if a given price falls within this tier.
    /// `isTopTier` controls whether `maxPrice` is inclusive.
    public func contains(price: Double, isTopTier: Bool = false) -> Bool {
        if isTopTier {
            return price >= minPrice && price <= maxPrice
        }
        return price >= minPrice && price < maxPrice
    }
}

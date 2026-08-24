import Foundation

/// Concrete implementation of `TickRule` based on tiered price intervals.
public final class TieredTickRule: TickRule, @unchecked Sendable {
    /// Array of ordered price tiers.
    public let tiers: [TickTier]
    
    /// Minimum global price.
    public let minPrice: Double?
    
    /// Maximum global price.
    public let maxPrice: Double?
    
    private let epsilon: Double = 1e-7
    
    public init(
        tiers: [TickTier],
        minPrice: Double? = nil,
        maxPrice: Double? = nil
    ) {
        precondition(!tiers.isEmpty, "TieredTickRule requires at least one TickTier")
        
        let sortedTiers = tiers.sorted { $0.minPrice < $1.minPrice }
        self.tiers = sortedTiers
        self.minPrice = minPrice ?? sortedTiers.first?.minPrice
        self.maxPrice = maxPrice ?? (sortedTiers.last?.maxPrice == Double.greatestFiniteMagnitude ? nil : sortedTiers.last?.maxPrice)
    }
    
    /// Factory for Indonesia Stock Exchange (IDX / BEI) official 5-tier fraction rule.
    public static func idx(
        minPrice: Double = 1.0,
        maxPrice: Double? = nil
    ) -> TieredTickRule {
        let tiers = [\
            TickTier(minPrice: 1.0, maxPrice: 200.0, tickSize: 1.0, maxPriceStep: 10, label: "< Rp 200"),
            TickTier(minPrice: 200.0, maxPrice: 500.0, tickSize: 2.0, maxPriceStep: 10, label: "Rp 200 – Rp 500"),
            TickTier(minPrice: 500.0, maxPrice: 2000.0, tickSize: 5.0, maxPriceStep: 10, label: "Rp 500 – Rp 2.000"),
            TickTier(minPrice: 2000.0, maxPrice: 5000.0, tickSize: 10.0, maxPriceStep: 10, label: "Rp 2.000 – Rp 5.000"),
            TickTier(minPrice: 5000.0, maxPrice: Double.greatestFiniteMagnitude, tickSize: 25.0, maxPriceStep: 10, label: "≥ Rp 5.000")
        ]
        return TieredTickRule(tiers: tiers, minPrice: minPrice, maxPrice: maxPrice)
    }
    
    /// Finds the corresponding `TickTier` for a given price.
    public func findTier(for price: Double) -> TickTier {
        if price <= (tiers.first?.minPrice ?? 0.0) + epsilon {
            return tiers.first!
        }
        if price >= (tiers.last?.minPrice ?? 0.0) - epsilon {
            return tiers.last!
        }
        
        for (index, tier) in tiers.enumerated() {
            let isLast = index == tiers.count - 1
            if tier.contains(price: price, isTopTier: isLast) {
                return tier
            }
        }
        
        return tiers.last!
    }
    
    public func getTickSize(for price: Double) -> Double {
        findTier(for: price).tickSize
    }
    
    public func getPrevTickSize(for price: Double) -> Double {
        // If price is exactly on a tier's minPrice boundary (within epsilon), and not the first tier,
        // stepping down uses the tick size of the tier below!
        for (index, tier) in tiers.enumerated() where index > 0 {
            if abs(price - tier.minPrice) < epsilon {
                return tiers[index - 1].tickSize
            }
        }
        return getTickSize(for: price)
    }
    
    public func nextTick(price: Double, ticks: Int = 1) -> Double {
        guard ticks > 0 else { return snapToTick(price: price, mode: .nearest) }
        
        var current = snapToTick(price: price, mode: .nearest)
        for _ in 0..<ticks {
            let step = getTickSize(for: current)
            current = cleanPrecision(current + step)
            
            if let max = maxPrice, current > max {
                current = max
                break
            }
        }
        return current
    }
    
    public func prevTick(price: Double, ticks: Int = 1) -> Double {
        guard ticks > 0 else { return snapToTick(price: price, mode: .nearest) }
        
        var current = snapToTick(price: price, mode: .nearest)
        for _ in 0..<ticks {
            let step = getPrevTickSize(for: current)
            current = cleanPrecision(current - step)
            
            if let min = minPrice, current < min {
                current = min
                break
            }
        }
        return current
    }
    
    public func snapToTick(price: Double, mode: RoundingMode = .nearest) -> Double {
        if let min = minPrice, price <= min + epsilon {
            return min
        }
        if let max = maxPrice, price >= max - epsilon {
            return max
        }
        
        let tier = findTier(for: price)
        let offset = price - tier.minPrice
        let tick = tier.tickSize
        let quotient = offset / tick
        
        let snappedQuotient: Double
        switch mode {
        case .nearest:
            snappedQuotient = (quotient).rounded()
        case .floor:
            snappedQuotient = floor(quotient + epsilon)
        case .ceil:
            snappedQuotient = ceil(quotient - epsilon)
        }
        
        var result = cleanPrecision(tier.minPrice + (snappedQuotient * tick))
        if let min = minPrice, result < min { result = min }
        if let max = maxPrice, result > max { result = max }
        return result
    }
    
    public func isValidTick(price: Double) -> Bool {
        if let min = minPrice, price < min - epsilon { return false }
        if let max = maxPrice, price > max + epsilon { return false }
        
        let snapped = snapToTick(price: price, mode: .nearest)
        return abs(price - snapped) < epsilon
    }
    
    public func getTickDifference(basePrice: Double, targetPrice: Double) -> Int {
        if abs(basePrice - targetPrice) < epsilon { return 0 }
        
        var count = 0
        if basePrice < targetPrice {
            var curr = basePrice
            while curr < targetPrice - epsilon {
                let next = nextTick(price: curr)
                if next <= curr { break }
                curr = next
                count += 1
            }
            return count
        } else {
            var curr = basePrice
            while curr > targetPrice + epsilon {
                let prev = prevTick(price: curr)
                if prev >= curr { break }
                curr = prev
                count -= 1
            }
            return count
        }
    }
    
    public func formatPrice(_ price: Double, locale: Locale = .current, currencySymbol: String? = nil) -> String {
        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        
        // If whole number, 0 decimals. If fractional, up to 4 decimals.
        let isWholeNumber = abs(price.rounded() - price) < epsilon
        formatter.maximumFractionDigits = isWholeNumber ? 0 : 4
        
        let formattedNumber = formatter.string(from: NSNumber(value: price)) ?? String(format: "%.0f", price)
        if let symbol = currencySymbol, !symbol.isEmpty {
            return "\(symbol) \(formattedNumber)"
        }
        return formattedNumber
    }
    
    public func parsePrice(_ text: String, locale: Locale = .current) -> Double? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return nil }
        
        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.numberStyle = .decimal
        
        if let number = formatter.number(from: trimmed) {
            return number.doubleValue
        }
        
        // Fallback: Remove non-numeric characters except decimal/grouping separators
        let groupingSeparator = locale.groupingSeparator ?? ","
        let decimalSeparator = locale.decimalSeparator ?? "."
        
        let cleaned = trimmed
            .replacingOccurrences(of: "Rp", with: "")
            .replacingOccurrences(of: "$", with: "")
            .replacingOccurrences(of: "IDR", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: groupingSeparator, with: "")
            .replacingOccurrences(of: decimalSeparator, with: ".")
        
        return Double(cleaned)
    }
    
    public func validatePrice(_ price: Double?, localization: FractionPriceLocalization? = nil) -> PriceValidationResult {
        let loc = localization ?? .id
        
        guard let p = price else {
            return .empty(errorMessage: loc.emptyPriceError())
        }
        
        if let min = minPrice, p < min - epsilon {
            let minFormatted = formatPrice(min, locale: loc.locale)
            return .belowMin(minPrice: min, errorMessage: loc.belowMinError(minFormatted))
        }
        
        if let max = maxPrice, p > max + epsilon {
            let maxFormatted = formatPrice(max, locale: loc.locale)
            return .aboveMax(maxPrice: max, errorMessage: loc.aboveMaxError(maxFormatted))
        }
        
        let step = getTickSize(for: p)
        if !isValidTick(price: p) {
            let nearest = snapToTick(price: p, mode: .nearest)
            let stepFormatted = formatPrice(step, locale: loc.locale)
            let nearestFormatted = formatPrice(nearest, locale: loc.locale)
            return .invalidTick(
                step: step,
                nearest: nearest,
                errorMessage: loc.invalidTickError(stepFormatted, nearestFormatted)
            )
        }
        
        return .valid(currentStep: step)
    }
    
    private func cleanPrecision(_ value: Double) -> Double {
        (value * 1e7).rounded() / 1e7
    }
}

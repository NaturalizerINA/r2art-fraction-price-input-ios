import Foundation
import Combine

/// State holder and controller for fraction tick price input.
@MainActor
public final class FractionPriceController: ObservableObject {
    /// Active numeric price value.
    @Published public private(set) var price: Double?
    
    /// Formatted text representation of the price.
    @Published public private(set) var formattedPrice: String = ""
    
    /// Current tick size (fraksi) for the active price.
    @Published public private(set) var currentTickSize: Double?
    
    /// Current validation status result.
    @Published public private(set) var validationResult: PriceValidationResult
    
    /// The active tick rule engine.
    public var rule: TickRule {
        didSet {
            revalidate()
        }
    }
    
    /// The localization preset and error suppliers.
    public var localization: FractionPriceLocalization {
        didSet {
            revalidate()
        }
    }
    
    public init(
        initialPrice: Double? = nil,
        rule: TickRule = TieredTickRule.idx(),
        localization: FractionPriceLocalization = .id
    ) {
        self.rule = rule
        self.localization = localization
        self.price = initialPrice
        self.validationResult = rule.validatePrice(initialPrice, localization: localization)
        
        if let p = initialPrice {
            self.formattedPrice = rule.formatPrice(p, locale: localization.locale)
            self.currentTickSize = rule.getTickSize(for: p)
        } else {
            self.formattedPrice = ""
            self.currentTickSize = nil
        }
    }
    
    /// Sets the price value programmatically.
    public func setPrice(
        _ newPrice: Double?,
        updateText: Bool = true,
        snap: Bool = false,
        mode: RoundingMode = .nearest
    ) {
        let finalPrice: Double?
        if let p = newPrice, snap {
            finalPrice = rule.snapToTick(price: p, mode: mode)
        } else {
            finalPrice = newPrice
        }
        
        self.price = finalPrice
        self.validationResult = rule.validatePrice(finalPrice, localization: localization)
        
        if let p = finalPrice {
            self.currentTickSize = rule.getTickSize(for: p)
            if updateText {
                self.formattedPrice = rule.formatPrice(p, locale: localization.locale)
            }
        } else {
            self.currentTickSize = nil
            if updateText {
                self.formattedPrice = ""
            }
        }
    }
    
    /// Sets the price from raw string input.
    public func setText(_ text: String) {
        let parsed = rule.parsePrice(text, locale: localization.locale)
        self.price = parsed
        self.formattedPrice = text
        self.validationResult = rule.validatePrice(parsed, localization: localization)
        if let p = parsed {
            self.currentTickSize = rule.getTickSize(for: p)
        } else {
            self.currentTickSize = nil
        }
    }
    
    /// Advances price by a number of ticks.
    public func stepUp(ticks: Int = 1) {
        let base = price ?? rule.minPrice ?? 0.0
        let next = rule.nextTick(price: base, ticks: ticks)
        setPrice(next, updateText: true, snap: false)
    }
    
    /// Decrements price by a number of ticks.
    public func stepDown(ticks: Int = 1) {
        let base = price ?? rule.minPrice ?? 0.0
        let prev = rule.prevTick(price: base, ticks: ticks)
        setPrice(prev, updateText: true, snap: false)
    }
    
    /// Snaps current price to a valid tick.
    public func snap(mode: RoundingMode = .nearest) {
        guard let p = price else { return }
        let snapped = rule.snapToTick(price: p, mode: mode)
        setPrice(snapped, updateText: true, snap: false)
    }
    
    /// Re-evaluates current price validation and formatting.
    public func revalidate() {
        self.validationResult = rule.validatePrice(price, localization: localization)
        if let p = price {
            self.currentTickSize = rule.getTickSize(for: p)
            self.formattedPrice = rule.formatPrice(p, locale: localization.locale)
        } else {
            self.currentTickSize = nil
            self.formattedPrice = ""
        }
    }
}

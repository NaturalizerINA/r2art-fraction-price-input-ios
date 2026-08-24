#if canImport(UIKit)
import UIKit
import FractionPriceCore

/// Delegate protocol for `FractionPriceView` events.
public protocol FractionPriceViewDelegate: AnyObject {
    /// Called when the active price changes.
    func fractionPriceView(_ view: FractionPriceView, didChangePrice price: Double?)
    
    /// Called when the return/submit action is triggered.
    func fractionPriceView(_ view: FractionPriceView, didSubmitPrice price: Double?)
    
    /// Called when price validation is updated.
    func fractionPriceView(_ view: FractionPriceView, didValidate result: PriceValidationResult)
}

public extension FractionPriceViewDelegate {
    func fractionPriceView(_ view: FractionPriceView, didChangePrice price: Double?) {}
    func fractionPriceView(_ view: FractionPriceView, didSubmitPrice price: Double?) {}
    func fractionPriceView(_ view: FractionPriceView, didValidate result: PriceValidationResult) {}
}
#endif

import XCTest
@testable import FractionPriceCore

final class FractionPriceLocalizationTests: XCTestCase {
    
    func testIndonesianPreset() {
        let loc = FractionPriceLocalization.id
        XCTAssertEqual(loc.locale.identifier, "id_ID")
        XCTAssertEqual(loc.currencySymbol, "Rp")
        XCTAssertEqual(loc.labelText, "Fraksi Harga")
        XCTAssertEqual(loc.emptyPriceError(), "Harga tidak boleh kosong")
        XCTAssertEqual(loc.belowMinError("Rp 50"), "Harga tidak boleh kurang dari Rp 50")
        XCTAssertEqual(loc.aboveMaxError("Rp 5.000"), "Harga tidak boleh melebihi Rp 5.000")
        XCTAssertEqual(
            loc.invalidTickError("Rp 25", "Rp 2.450"),
            "Harga tidak sesuai dengan fraksi (Rp 25). Terdekat: Rp 2.450"
        )
    }
    
    func testEnglishPreset() {
        let loc = FractionPriceLocalization.en
        XCTAssertEqual(loc.locale.identifier, "en_US")
        XCTAssertEqual(loc.currencySymbol, "")
        XCTAssertEqual(loc.labelText, "Tick Size")
        XCTAssertEqual(loc.emptyPriceError(), "Price cannot be empty")
        XCTAssertEqual(loc.belowMinError("50"), "Price cannot be below 50")
        XCTAssertEqual(loc.aboveMaxError("5,000"), "Price cannot exceed 5,000")
        XCTAssertEqual(
            loc.invalidTickError("25", "2,450"),
            "Price is not aligned to tick step (25). Nearest: 2,450"
        )
    }
    
    func testCustomOverrides() {
        let custom = FractionPriceLocalization.id.copyWith(
            emptyPriceError: { "Custom Empty Error" },
            invalidTickError: { step, nearest in "Wrong step: \(step), use \(nearest)" }
        )
        
        XCTAssertEqual(custom.emptyPriceError(), "Custom Empty Error")
        XCTAssertEqual(custom.invalidTickError("25", "100"), "Wrong step: 25, use 100")
        // Untouched belowMinError should remain default
        XCTAssertEqual(custom.belowMinError("50"), "Harga tidak boleh kurang dari 50")
    }
}

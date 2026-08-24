import XCTest
@testable import FractionPriceCore

final class TieredTickRuleTests: XCTestCase {
    
    var rule: TieredTickRule!
    
    override func setUp() {
        super.setUp()
        rule = TieredTickRule.idx()
    }
    
    // MARK: - Tick Size Determination
    
    func testTickSizesAcrossAllTiers() {
        // Tier 1 (< 200): Tick 1
        XCTAssertEqual(rule.getTickSize(for: 1), 1.0)
        XCTAssertEqual(rule.getTickSize(for: 50), 1.0)
        XCTAssertEqual(rule.getTickSize(for: 199), 1.0)
        
        // Tier 2 (200 - 500): Tick 2
        XCTAssertEqual(rule.getTickSize(for: 200), 2.0)
        XCTAssertEqual(rule.getTickSize(for: 350), 2.0)
        XCTAssertEqual(rule.getTickSize(for: 498), 2.0)
        
        // Tier 3 (500 - 2000): Tick 5
        XCTAssertEqual(rule.getTickSize(for: 500), 5.0)
        XCTAssertEqual(rule.getTickSize(for: 1200), 5.0)
        XCTAssertEqual(rule.getTickSize(for: 1995), 5.0)
        
        // Tier 4 (2000 - 5000): Tick 10
        XCTAssertEqual(rule.getTickSize(for: 2000), 10.0)
        XCTAssertEqual(rule.getTickSize(for: 3500), 10.0)
        XCTAssertEqual(rule.getTickSize(for: 4990), 10.0)
        
        // Tier 5 (>= 5000): Tick 25
        XCTAssertEqual(rule.getTickSize(for: 5000), 25.0)
        XCTAssertEqual(rule.getTickSize(for: 10000), 25.0)
    }
    
    // MARK: - Boundary Crossing (Step Up & Down)
    
    func testStepUpBoundaryCrossing() {
        // Step Up from Tier 1 to Tier 2
        XCTAssertEqual(rule.nextTick(price: 199), 200.0)
        XCTAssertEqual(rule.nextTick(price: 200), 202.0)
        
        // Step Up from Tier 2 to Tier 3
        XCTAssertEqual(rule.nextTick(price: 498), 500.0)
        XCTAssertEqual(rule.nextTick(price: 500), 505.0)
        
        // Step Up from Tier 3 to Tier 4
        XCTAssertEqual(rule.nextTick(price: 1995), 2000.0)
        XCTAssertEqual(rule.nextTick(price: 2000), 2010.0)
        
        // Step Up from Tier 4 to Tier 5
        XCTAssertEqual(rule.nextTick(price: 4990), 5000.0)
        XCTAssertEqual(rule.nextTick(price: 5000), 5025.0)
    }
    
    func testStepDownBoundaryCrossing() {
        // Step Down from Tier 2 boundary to Tier 1 (takes tick size 1 of Tier 1)
        XCTAssertEqual(rule.prevTick(price: 202), 200.0)
        XCTAssertEqual(rule.prevTick(price: 200), 199.0)
        
        // Step Down from Tier 3 boundary to Tier 2 (takes tick size 2 of Tier 2)
        XCTAssertEqual(rule.prevTick(price: 505), 500.0)
        XCTAssertEqual(rule.prevTick(price: 500), 498.0)
        
        // Step Down from Tier 4 boundary to Tier 3 (takes tick size 5 of Tier 3)
        XCTAssertEqual(rule.prevTick(price: 2010), 2000.0)
        XCTAssertEqual(rule.prevTick(price: 2000), 1995.0)
        
        // Step Down from Tier 5 boundary to Tier 4 (takes tick size 10 of Tier 4)
        XCTAssertEqual(rule.prevTick(price: 5025), 5000.0)
        XCTAssertEqual(rule.prevTick(price: 5000), 4990.0)
    }
    
    func testMultipleTicksStepping() {
        // 5 ticks up from 195: 196, 197, 198, 199, 200
        XCTAssertEqual(rule.nextTick(price: 195, ticks: 5), 200.0)
        
        // 5 ticks down from 206: 204, 202, 200, 199, 198
        XCTAssertEqual(rule.prevTick(price: 206, ticks: 5), 198.0)
    }
    
    // MARK: - Snapping Modes
    
    func testSnappingModes() {
        // Nearest
        XCTAssertEqual(rule.snapToTick(price: 201.0, mode: .nearest), 202.0)
        XCTAssertEqual(rule.snapToTick(price: 200.9, mode: .nearest), 200.0)
        XCTAssertEqual(rule.snapToTick(price: 503.0, mode: .nearest), 505.0)
        XCTAssertEqual(rule.snapToTick(price: 502.0, mode: .nearest), 500.0)
        
        // Floor
        XCTAssertEqual(rule.snapToTick(price: 201.0, mode: .floor), 200.0)
        XCTAssertEqual(rule.snapToTick(price: 503.0, mode: .floor), 500.0)
        
        // Ceil
        XCTAssertEqual(rule.snapToTick(price: 201.0, mode: .ceil), 202.0)
        XCTAssertEqual(rule.snapToTick(price: 502.0, mode: .ceil), 505.0)
    }
    
    // MARK: - Validation & Tick Validity
    
    func testIsValidTick() {
        XCTAssertTrue(rule.isValidTick(price: 199.0))
        XCTAssertTrue(rule.isValidTick(price: 200.0))
        XCTAssertFalse(rule.isValidTick(price: 201.0))
        XCTAssertTrue(rule.isValidTick(price: 202.0))
        XCTAssertFalse(rule.isValidTick(price: 502.0))
        XCTAssertTrue(rule.isValidTick(price: 505.0))
        XCTAssertFalse(rule.isValidTick(price: 5010.0))
        XCTAssertTrue(rule.isValidTick(price: 5025.0))
    }
    
    func testValidatePriceResults() {
        // Empty
        let emptyRes = rule.validatePrice(nil)
        XCTAssertFalse(emptyRes.isValid)
        XCTAssertEqual(emptyRes.status, .empty)
        
        // Below Min
        let belowMinRes = rule.validatePrice(0.5)
        XCTAssertFalse(belowMinRes.isValid)
        XCTAssertEqual(belowMinRes.status, .belowMin)
        
        // Invalid Tick
        let invalidRes = rule.validatePrice(201.0)
        XCTAssertFalse(invalidRes.isValid)
        XCTAssertEqual(invalidRes.status, .invalidTick)
        XCTAssertEqual(invalidRes.nearestPrice, 202.0)
        XCTAssertEqual(invalidRes.currentStep, 2.0)
        
        // Valid
        let validRes = rule.validatePrice(2450.0)
        XCTAssertTrue(validRes.isValid)
        XCTAssertEqual(validRes.status, .valid)
        XCTAssertEqual(validRes.currentStep, 10.0)
    }
    
    // MARK: - Tick Difference
    
    func testTickDifference() {
        XCTAssertEqual(rule.getTickDifference(basePrice: 198.0, targetPrice: 202.0), 3) // 198->199->200->202
        XCTAssertEqual(rule.getTickDifference(basePrice: 202.0, targetPrice: 198.0), -3)
        XCTAssertEqual(rule.getTickDifference(basePrice: 500.0, targetPrice: 500.0), 0)
    }
    
    // MARK: - Formatting & Parsing
    
    func testFormattingAndParsing() {
        let idLocale = Locale(identifier: "id_ID")
        let formattedID = rule.formatPrice(2450.0, locale: idLocale, currencySymbol: "Rp")
        XCTAssertEqual(formattedID, "Rp 2.450")
        
        let parsed = rule.parsePrice("2.450", locale: idLocale)
        XCTAssertEqual(parsed, 2450.0)
        
        let enLocale = Locale(identifier: "en_US")
        let formattedEN = rule.formatPrice(2450.0, locale: enLocale, currencySymbol: "$")
        XCTAssertEqual(formattedEN, "$ 2,450")
        
        let parsedEN = rule.parsePrice("2,450", locale: enLocale)
        XCTAssertEqual(parsedEN, 2450.0)
    }
}

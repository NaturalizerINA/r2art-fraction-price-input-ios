import XCTest
@testable import FractionPriceCore

@MainActor
final class FractionPriceControllerTests: XCTestCase {
    
    func testInitialState() {
        let controller = FractionPriceController(initialPrice: 2450.0)
        XCTAssertEqual(controller.price, 2450.0)
        XCTAssertEqual(controller.formattedPrice, "2.450")
        XCTAssertEqual(controller.currentTickSize, 10.0)
        XCTAssertTrue(controller.validationResult.isValid)
    }
    
    func testSetPriceWithSnap() {
        let controller = FractionPriceController(initialPrice: nil)
        XCTAssertNil(controller.price)
        XCTAssertEqual(controller.formattedPrice, "")
        XCTAssertFalse(controller.validationResult.isValid)
        
        // Set invalid tick with snap = true
        controller.setPrice(201.0, updateText: true, snap: true)
        XCTAssertEqual(controller.price, 202.0)
        XCTAssertEqual(controller.formattedPrice, "202")
        XCTAssertTrue(controller.validationResult.isValid)
    }
    
    func testStepUpAndStepDown() {
        let controller = FractionPriceController(initialPrice: 198.0)
        
        // 198 -> 199 -> 200 -> 202
        controller.stepUp(ticks: 1)
        XCTAssertEqual(controller.price, 199.0)
        
        controller.stepUp(ticks: 1)
        XCTAssertEqual(controller.price, 200.0)
        
        controller.stepUp(ticks: 1)
        XCTAssertEqual(controller.price, 202.0)
        
        // Step Down: 202 -> 200 -> 199
        controller.stepDown(ticks: 1)
        XCTAssertEqual(controller.price, 200.0)
        
        controller.stepDown(ticks: 1)
        XCTAssertEqual(controller.price, 199.0)
    }
    
    func testSetText() {
        let controller = FractionPriceController()
        controller.setText("2.450")
        XCTAssertEqual(controller.price, 2450.0)
        XCTAssertTrue(controller.validationResult.isValid)
        
        controller.setText("201")
        XCTAssertEqual(controller.price, 201.0)
        XCTAssertFalse(controller.validationResult.isValid)
        XCTAssertEqual(controller.validationResult.status, .invalidTick)
        
        controller.snap(mode: .nearest)
        XCTAssertEqual(controller.price, 202.0)
        XCTAssertTrue(controller.validationResult.isValid)
    }
}

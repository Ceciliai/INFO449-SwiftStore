//
//  StoreTests.swift
//  StoreTests
//
//  Created by Ted Neward on 2/29/24.
//

import XCTest

final class StoreTests: XCTestCase {

    var register = Register()

    override func setUpWithError() throws {
        register = Register()
    }

    override func tearDownWithError() throws { }

    func testBaseline() throws {
        XCTAssertEqual("0.1", Store().version)
        XCTAssertEqual("Hello world", Store().helloWorld())
    }
    
    func testOneItem() {
        register.scan(Item(name: "Beans (8oz Can)", priceEach: 199))
        XCTAssertEqual(199, register.subtotal())
        
        let receipt = register.total()
        XCTAssertEqual(199, receipt.total())

        let expectedReceipt = """
Receipt:
Beans (8oz Can): $1.99
------------------
TOTAL: $1.99
"""
        XCTAssertEqual(expectedReceipt, receipt.output())
    }
    
    func testThreeSameItems() {
        register.scan(Item(name: "Beans (8oz Can)", priceEach: 199))
        register.scan(Item(name: "Beans (8oz Can)", priceEach: 199))
        register.scan(Item(name: "Beans (8oz Can)", priceEach: 199))
        XCTAssertEqual(199 * 3, register.subtotal())
    }
    
    func testThreeDifferentItems() {
        register.scan(Item(name: "Beans (8oz Can)", priceEach: 199))
        XCTAssertEqual(199, register.subtotal())
        register.scan(Item(name: "Pencil", priceEach: 99))
        XCTAssertEqual(298, register.subtotal())
        register.scan(Item(name: "Granols Bars (Box, 8ct)", priceEach: 499))
        XCTAssertEqual(797, register.subtotal())
        
        let receipt = register.total()
        XCTAssertEqual(797, receipt.total())

        let expectedReceipt = """
Receipt:
Beans (8oz Can): $1.99
Pencil: $0.99
Granols Bars (Box, 8ct): $4.99
------------------
TOTAL: $7.97
"""
        XCTAssertEqual(expectedReceipt, receipt.output())
    }
    
    //extra credit test
    func testTwoForOneDiscount() {
        register.scan(Item(name: "Beans", priceEach: 199))
        register.scan(Item(name: "Beans", priceEach: 199))
        register.scan(Item(name: "Beans", priceEach: 199))
        register.scan(Item(name: "Beans", priceEach: 199))
        register.scan(Item(name: "Pencil", priceEach: 99))

        let receipt = register.total()

        let promo = TwoForOnePricingScheme(itemName: "Beans")
        let discountedOutput = promo.outputReceipt(for: receipt.items())

        let expectedReceipt = """
Receipt:
Beans: $1.99
Beans: $1.99
Beans: $0.00
Beans: $1.99
Pencil: $0.99
------------------
TOTAL: $6.96
"""
        XCTAssertEqual(discountedOutput, expectedReceipt)
    }
    
    
    func testGroupedPricingDiscountWithDetails() {
        register.scan(Item(name: "Ketchup", priceEach: 349))
        register.scan(Item(name: "Beer", priceEach: 599))
        register.scan(Item(name: "Beer", priceEach: 599))
        register.scan(Item(name: "Ketchup", priceEach: 349))
        register.scan(Item(name: "Pencil", priceEach: 99))

        // get receipt
        let receipt = register.total()

        // Create the GroupedPricingScheme rule (buying Beer and Ketchup simultaneously triggers a discount)
        let promo = GroupedPricingScheme(itemNames: ["Ketchup", "Beer"])
        let discountedOutput = promo.outputReceipt(for: receipt.items())

        // Expected receipt content
        let expectedReceipt = """
Receipt:
Ketchup: $3.49
→ Discount: -$0.35
Beer: $5.99
→ Discount: -$0.60
Beer: $5.99
→ Discount: -$0.60
Ketchup: $3.49
→ Discount: -$0.35
Pencil: $0.99
------------------
TOTAL: $18.05
"""

        print(discountedOutput)
        XCTAssertEqual(discountedOutput, expectedReceipt)
    }
    
    func testWeighedItemReceiptOutput() {
        //Scan a WeighedItem: banana $0.89/lb, weighing 1.25lb
        register.scan(WeighedItem(name: "Bananas", pricePerPound: 89, weight: 1.25))

        let receipt = register.total()
        let expectedReceipt = """
    Receipt:
    Bananas @ $0.89/lb x 1.25lb: $1.11
    ------------------
    TOTAL: $1.11
    """

        print(receipt.output())

        XCTAssertEqual(receipt.output(), expectedReceipt)
    }

}

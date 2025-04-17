//
//  main.swift
//  Store
//
//  Created by Ted Neward on 2/29/24.
//  implemented by Haiyi Luo on 4/16/2025

import Foundation

protocol SKU {
    var name: String { get }
    func price() -> Int
}

class Item: SKU {
    let name: String
    private let itemPrice: Int

    init(name: String, priceEach: Int) {
        self.name = name
        self.itemPrice = priceEach
    }

    func price() -> Int {
        return itemPrice
    }
}


class Receipt {
    private var scannedItems: [SKU] = []

    func add(_ item: SKU) {
        scannedItems.append(item)
    }

    func items() -> [SKU] {
        return scannedItems
    }

    func output() -> String {
        var result = "Receipt:\n"
        for item in scannedItems {
            if let weighed = item as? WeighedItem {
                let totalDollars = Double(weighed.price()) / 100.0
                let perPound = weighed.pricePerPoundDescription()
                let weight = weighed.weightDescription()
                result += "\(weighed.name) @ $\(perPound)/lb x \(weight)lb: $\(String(format: "%.2f", totalDollars))\n"
            } else {
                let dollars = Double(item.price()) / 100.0
                result += "\(item.name): $\(String(format: "%.2f", dollars))\n"
            }
        }
        result += "------------------\n"
        result += "TOTAL: $\(String(format: "%.2f", Double(subtotal()) / 100.0))"
        return result
    }

    func subtotal() -> Int {
        return scannedItems.map { $0.price() }.reduce(0, +)
    }

    func total() -> Int {
        return subtotal()
    }
}


class Register {
    private var currentReceipt = Receipt()

    func scan(_ item: SKU) {
        currentReceipt.add(item)
    }

    func subtotal() -> Int {
        return currentReceipt.subtotal()
    }

    func total() -> Receipt {
        let completed = currentReceipt
        currentReceipt = Receipt()
        return completed
    }
}


class Store {
    let version = "0.1"
    func helloWorld() -> String {
        return "Hello world"
    }
}

//extra credit 1
class TwoForOnePricingScheme {
    let targetName: String
    
    public init(itemName: String) {
        self.targetName = itemName
    }

    // Calculate the amount payable after the discount
    public func apply(to items: [SKU]) -> Int {
        let matched = items.filter { $0.name == targetName }
        let fullGroups = matched.count / 3
        let remainder = matched.count % 3
        let paidItems = fullGroups * 2 + remainder
        guard let pricePerItem = matched.first?.price() else { return 0 }
        return paidItems * pricePerItem
    }

    // Generate the output of the receipt
    public func outputReceipt(for items: [SKU]) -> String {
        let matched = items.filter { $0.name == targetName }
        let fullGroups = matched.count / 3
        let remainder = matched.count % 3
        let totalFree = fullGroups  // One out of every three items is free

        var result = "Receipt:\n"
        var matchedPrinted = 0
        var freeGiven = 0
        var totalCents = 0

        for item in items {
            if item.name == targetName {
                matchedPrinted += 1
                if matchedPrinted % 3 == 0 && freeGiven < totalFree {
                    result += "\(item.name): $0.00\n"
                    freeGiven += 1
                } else {
                    let price = item.price()
                    totalCents += price
                    result += String(format: "%@: $%.2f\n", item.name, Double(price) / 100.0)
                }
            } else {
                let price = item.price()
                totalCents += price
                result += String(format: "%@: $%.2f\n", item.name, Double(price) / 100.0)
            }
        }

        result += "------------------\n"
        result += String(format: "TOTAL: $%.2f", Double(totalCents) / 100.0)
        return result
    }
}

//extra credit2
class GroupedPricingScheme {
    let eligibleNames: Set<String>
    
    init(itemNames: [String]) {
        self.eligibleNames = Set(itemNames)
    }

    func outputReceipt(for items: [SKU]) -> String {
        var result = "Receipt:\n"
        var total = 0

        // First, count the SKUs that meet the discount conditions (grouped by name)
        var buckets: [String: [SKU]] = [:]
        for item in items {
            if eligibleNames.contains(item.name) {
                buckets[item.name, default: []].append(item)
            }
        }

        // Find out the number of pairable combinations
        let eligibleGroupCount = buckets.values.map { $0.count }.min() ?? 0
        var discountedCounts: [String: Int] = [:]
        for name in eligibleNames {
            discountedCounts[name] = eligibleGroupCount
        }

        for item in items {
            if let remaining = discountedCounts[item.name], remaining > 0 {
                let discount = Int(round(Double(item.price()) * 0.1))
                let finalPrice = item.price() - discount
                result += String(format: "%@: $%.2f\n", item.name, Double(item.price()) / 100.0)
                result += String(format: "→ Discount: -$%.2f\n", Double(discount) / 100.0)
                total += finalPrice
                discountedCounts[item.name]! -= 1
            } else {
                result += String(format: "%@: $%.2f\n", item.name, Double(item.price()) / 100.0)
                total += item.price()
            }
        }

        result += "------------------\n"
        result += String(format: "TOTAL: $%.2f", Double(total) / 100.0)
        return result
    }
    
}
//extra credit3
class WeighedItem: SKU {
    let name: String
    private let pricePerPound: Int  // e.g., 899 means $8.99 per pound
    private let weight: Double      // in pounds, e.g., 1.25 lbs

    init(name: String, pricePerPound: Int, weight: Double) {
        self.name = name
        self.pricePerPound = pricePerPound
        self.weight = weight
    }

    func price() -> Int {
        let total = Double(pricePerPound) * weight
        return Int(round(total)) // rounded to nearest cent
    }

    func weightDescription() -> String {
        return String(format: "%.2f", weight)
    }

    func pricePerPoundDescription() -> String {
        return String(format: "%.2f", Double(pricePerPound) / 100.0)
    }
}


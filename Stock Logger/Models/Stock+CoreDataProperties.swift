//
//  Stock+CoreDataProperties.swift
//  Stock Logger
//
//  Created by Ibrahim Torabek on 2021-10-19.
//
//

import Foundation
import CoreData


extension Stock {

    @nonobjc public class func createFetchRequest() -> NSFetchRequest<Stock> {
        return NSFetchRequest<Stock>(entityName: "Stock")
    }

    @NSManaged public var symbol: String?
    @NSManaged public var companyName: String?
    @NSManaged public var price: Double
    @NSManaged public var worth: Double
    @NSManaged public var quantity: Int16
    @NSManaged public var activeStocks: NSSet?
    @NSManaged public var soldStocks: NSSet?

}

// MARK: Generated accessors for activeStocks
extension Stock {

    @objc(addActiveStocksObject:)
    @NSManaged public func addToActiveStocks(_ value: ActiveStock)

    @objc(removeActiveStocksObject:)
    @NSManaged public func removeFromActiveStocks(_ value: ActiveStock)

    @objc(addActiveStocks:)
    @NSManaged public func addToActiveStocks(_ values: NSSet)

    @objc(removeActiveStocks:)
    @NSManaged public func removeFromActiveStocks(_ values: NSSet)

}

// MARK: Generated accessors for soldStocks
extension Stock {

    @objc(addSoldStocksObject:)
    @NSManaged public func addToSoldStocks(_ value: SoldStock)

    @objc(removeSoldStocksObject:)
    @NSManaged public func removeFromSoldStocks(_ value: SoldStock)

    @objc(addSoldStocks:)
    @NSManaged public func addToSoldStocks(_ values: NSSet)

    @objc(removeSoldStocks:)
    @NSManaged public func removeFromSoldStocks(_ values: NSSet)

}

//
//  SoldStock+CoreDataProperties.swift
//  Stock Logger
//
//  Created by Ibrahim Torabek on 2021-10-19.
//
//

import Foundation
import CoreData


extension SoldStock {

    @nonobjc public class func createFetchRequest() -> NSFetchRequest<SoldStock> {
        return NSFetchRequest<SoldStock>(entityName: "SoldStock")
    }

    @NSManaged public var symbol: String?
    @NSManaged public var soldPrice: Double
    @NSManaged public var quantity: Int16
    @NSManaged public var soldDate: Date?
    @NSManaged public var earnings: Double
    @NSManaged public var stock: Stock?

}

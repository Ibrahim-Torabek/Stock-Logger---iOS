//
//  ActiveStock+CoreDataProperties.swift
//  Stock Logger
//
//  Created by Ibrahim Torabek on 2021-10-19.
//
//

import Foundation
import CoreData


extension ActiveStock {

    @nonobjc public class func createFetchRequest() -> NSFetchRequest<ActiveStock> {
        return NSFetchRequest<ActiveStock>(entityName: "ActiveStock")
    }

    @NSManaged public var symbol: String?
    @NSManaged public var boughtPrice: Double
    @NSManaged public var quantity: Int16
    @NSManaged public var worth: Double
    @NSManaged public var boughtDate: Date?
    @NSManaged public var stock: Stock?

}

//
//  Stock.swift
//  Stock Logger
//
//  Created by Ibrahim Torabek on 2021-10-19.
//

import Foundation

// Got more information for the future.
struct StockInfo: Codable {
    var symbol: String
    var companyName: String
    var price: Double
    var open: Double
    var high: Double
    var change: Double
    var currency: String
    
    enum CodingKeys: String, CodingKey{
        case symbol = "01. symbol"
        case companyName = "2. name"
        case price = "05. price"
        case open = "02. open"
        case high = "03. high"
        case change = "09. change"
        case currency = "8. currency"
    }
    
}

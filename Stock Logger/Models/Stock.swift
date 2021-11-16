//
//  Stock.swift
//  Stock Logger
//
//  Created by Ibrahim Torabek on 2021-10-19.
//

import Foundation

struct GlobalQuote: Codable {
    var stockDetail: StockDetail
    var note: String?
    
    enum CodingKeys: String, CodingKey{
        case stockDetail = "Global Quote"
    }
}

struct BestMetches: Codable {
    var bestMatches: [StockDetail]
}


// Got more information for the future.
struct StockDetail: Codable {
    var symbol: String?
    var keywords: String?
    var companyName: String?
    var price: String?
    var open: String?
    var high: String?
    var change: String?
    var currency: String?
    
    enum CodingKeys: String, CodingKey{
        case symbol = "01. symbol"
        case keywords = "1. symbol"
        case companyName = "2. name"
        case price = "05. price"
        case open = "02. open"
        case high = "03. high"
        case change = "09. change"
        case currency = "8. currency"
    }
    
}

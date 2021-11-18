//
//  Stock.swift
//  Stock Logger
//
//  Created by Ibrahim Torabek on 2021-10-19.
//

import Foundation


/// Global Quote Struct is the Stock API's root object
/// This structure recievies an object of JSON format information that include Stck details
struct GlobalQuote: Codable {
    var stockDetail: StockDetail
    var note: String?
    
    enum CodingKeys: String, CodingKey{
        case stockDetail = "Global Quote"
    }
}

/// BestMeces used to autocomplete searach
/// This structure retrieves a list of stock which matches a specific characther(s) to search stocks
struct BestMetches: Codable {
    var bestMatches: [StockDetail]
}



/// StockDetail recieve a stock's detail information.
/// These information come from different search results, So the properties are combined together
/// This structure gathering more information than this project needs for future usage.
struct StockDetail: Codable {
    var symbol: String?
    var keywords: String?  // Used to get symbol from BestMetches result to auto complete
    var companyName: String?
    var price: String?
    var open: String?
    var high: String?
    var change: String?
    var currency: String?
    
    enum CodingKeys: String, CodingKey{
        case symbol = "01. symbol"
        case keywords = "1. symbol"  // The API provider gives different names for symbol, I used different property name for tham.
        case companyName = "2. name"
        case price = "05. price"
        case open = "02. open"
        case high = "03. high"
        case change = "09. change"
        case currency = "8. currency"
    }
    
}

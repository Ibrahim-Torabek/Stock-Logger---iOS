//
//  Stock.swift
//  Stock Logger
//
//  Created by Ibrahim Torabek on 2021-10-19.
//

import Foundation

struct Stock: Codable {
    var symbol: String
    var price: Double
    var open: Double
    var high: Double
    var change: Double
    
    enum CodingKeys: String, CodingKey{
        case symbol = "01. symbol"
        case price = "05. price"
        case open = "02. open"
        case high = "03. high"
        case change = "09. change"
    }
    
}

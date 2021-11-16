//
//  Currency.swift
//  Stock Logger
//
//  Created by Ibrahim Torabek on 2021-11-15.
//

import Foundation

struct CurrencyExchange: Codable{
    var currency: Currency
    
    enum CodingKeys: String, CodingKey{
        case currency = "Realtime Currency Exchange Rate"
    }
}


struct Currency: Codable{

    var rate: String?
    
    enum CodingKeys: String, CodingKey{
        case rate = "5. Exchange Rate"
    }
}

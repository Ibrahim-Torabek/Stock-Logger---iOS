//
//  Currency.swift
//  Stock Logger
//
//  Created by Ibrahim Torabek on 2021-11-15.
//

import Foundation


/// CurrencyExchange class used to retrieve USD-CAD exchange rate
/// This class gets only USD to CAD excange rate
struct CurrencyExchange: Codable{
    var currency: Currency
    
    enum CodingKeys: String, CodingKey{
        case currency = "Realtime Currency Exchange Rate"
    }
}


/// Currency class gets the exact currency rate from USD to CAD
struct Currency: Codable{

    var rate: String?
    
    enum CodingKeys: String, CodingKey{
        case rate = "5. Exchange Rate"
    }
}

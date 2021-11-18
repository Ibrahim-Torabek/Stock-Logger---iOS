//
//  CurrencyLabel.swift
//  Stock Logger
//
//  Created by Ibrahim Torabek on 2021-10-29.
//

import UIKit



/// This Currency Class is used to display currency
/// This class inhherints UILable and all currency Labels used this class
/// This class will appear the given number as curency type by placing $ sign in the fron of the number
/// This class display the currency as 4 decimal digits becouse stock prices are setted as 4 decimal digits.
class CurrencyLabel: UILabel {

    override func draw(_ rect: CGRect) {
        // if the text is exist and it can be converted to double
        if let text = text, let amount = Double(text) {
            
            // if the amount more than 0, display blue text
            if amount >= 0.0 {
                self.textColor = UIColor.blue
            }
            // if the amount less than 0, display red text
            if amount < 0.0 {
                self.textColor = UIColor.red
            }
            
            // I didn't use else statemnt becase I want to get three different 0 color
        
            self.text = "$"  + String(format: "%.4f", amount)
        }
        
        super.draw(rect)
    }
    
    
}



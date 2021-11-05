//
//  CurrencyLabel.swift
//  Stock Logger
//
//  Created by Ibrahim Torabek on 2021-10-29.
//

import UIKit

class CurrencyLabel: UILabel {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    override func draw(_ rect: CGRect) {
        if let text = text, let amount = Double(text) {
            
            if amount > 0.0 {
                self.textColor = UIColor.blue
            }
            if amount < 0.0 {
                self.textColor = UIColor.red
            }
            
            
            self.text = "$"  + String(format: "%.4f", amount)
        }
        
        super.draw(rect)
    }
    
    
}



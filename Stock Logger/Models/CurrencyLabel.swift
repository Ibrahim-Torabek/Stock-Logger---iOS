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

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!

        initCustomFont()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        initCustomFont()
    }
    
    
    private func initCustomFont() {
        
        print("Custom Font")
        if let textStyle = font.fontDescriptor.object(forKey: UIFontDescriptor.AttributeName.textStyle) as? UIFont.TextStyle {
            let fontMetrics = UIFontMetrics(forTextStyle: textStyle)
            var customFont: UIFont?

            switch textStyle {
            case .body:
                customFont = UIFont(name: "MyAwesomeBODYFont", size: 21)

            case .headline:
                customFont = UIFont(name: "MyAwesomeHeadlineFont", size: 48)

            // all other cases...

            default:
                return
            }

            guard let font = customFont else {
                fatalError("Failed to load a custom font! Make sure the font file is included in the project and the font is added to the Info.plist.")
            }

            self.font = fontMetrics.scaledFont(for: font)
        }
    }
}



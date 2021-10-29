//
//  StockDetailViewController.swift
//  Stock Logger
//
//  Created by Ibrahim Torabek on 2021-10-29.
//

import UIKit

class StockDetailViewController: UIViewController {
    //MARK: - Properties
    var stock: Stock!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = stock.symbol
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

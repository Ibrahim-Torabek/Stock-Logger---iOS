//
//  SoldStockViewController.swift
//  Stock Logger
//
//  Created by Ibrahim Torabek on 2021-11-09.
//

import UIKit

class SoldStockViewController: UIViewController {
    //MARK: - Properties
    var coreDataStack = ViewController.coreDataStack
    var soldStocks = [SoldStock]()
    var total = 0.0

    //MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var totalEarnings: CurrencyLabel!
    
    
    //MARK: - View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadSoldStocks()
    }
    
    
    //MARK: - Functions
    /// Load all Sold Stock from SoldStock Core Data Model
    func loadSoldStocks(){
                
        let request = SoldStock.fetchRequest()
        
        do {
            soldStocks = try ViewController.coreDataStack.managedContext.fetch(request)

        } catch {
            print("Fetching Error!!!")
        }
        
        calculateTotalEarnings()
        
        tableView.reloadData()
        
    }
    
    
    
    /// Calculate and display on top of the view total earnings
    func calculateTotalEarnings(){
        
        // add all earnings from each sold stock
        let _ = soldStocks.map{
            total += $0.earnings
        }

        // Display on the top of the view
        totalEarnings.text = "\(total)"
    }
    

}


extension SoldStockViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Sold Stocks' List"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return soldStocks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell",for: indexPath) as! SoldTableCell
        
        // Get current stock from array
        let soldStock = soldStocks[indexPath.row]
        
        // Format date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, y"
        
        // Place all information into current cell by TableViewCell Class
        cell.symbol.text = soldStock.symbol
        cell.companyName.text = soldStock.companyName
        cell.soldPrice.text = "\(soldStock.soldPrice)"
        cell.soldDate.text = "\(dateFormatter.string(from: soldStock.soldDate!))"
        cell.earnings.text = "\(soldStock.earnings)"
        
        return cell
    }
    
    
}
extension SoldStockViewController: UITableViewDelegate {
    
}


/// TableViewCell Class to declare all Outlets in the cell
class SoldTableCell: UITableViewCell{
    //MARK: - Sold Table Cell Outlets
    @IBOutlet weak var symbol: UILabel!
    @IBOutlet weak var companyName: UILabel!
    @IBOutlet weak var soldPrice: CurrencyLabel!
    @IBOutlet weak var earnings: CurrencyLabel!
    @IBOutlet weak var soldDate: UILabel!
}

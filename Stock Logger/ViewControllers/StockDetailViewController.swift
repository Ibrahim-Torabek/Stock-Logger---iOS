//
//  StockDetailViewController.swift
//  Stock Logger
//
//  Created by Ibrahim Torabek on 2021-10-29.
//

import UIKit

class StockDetailViewController: UIViewController {
    //MARK: - Properties
    var stock: Stock! // Get value from ViewController
    var activeStocks = [ActiveStock]()
    
    
    //MARK: - Outlets
    @IBOutlet weak var companyNameLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var priceLabel: CurrencyLabel!
    @IBOutlet weak var earningsLabel: CurrencyLabel!
    @IBOutlet weak var flagImage: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var inCreaseButton: UIButton!
    @IBOutlet weak var worthLabel: CurrencyLabel!
    @IBOutlet weak var deCreaseButton: UIButton!
    



    
    
    //MARK: - View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()

        // St title as stock's symbol
        title = stock.symbol
        
        loadStatistics()
        
        // Launch US or Canada Flag
        flagImage.image = stock.isUSD ? UIImage(named: "us.square") : UIImage(named: "canada.square")
        
        //Set tabel view delegate and datasource
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    //MARK: - Prepare Segue
    /// Prepare to Open AddStockViewCOntroller to  increase or decrease stock amount
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Test if Increase or Decrease button touched
        guard let button = sender as? UIButton else { return }
        
        // Get AddStockViewController as destination
        let vc = segue.destination as? AddStockViewController
        
        // Set stock of AddStockViewConroller
        vc?.stock = stock
        
        // Check witch button touched
        switch button {
        case inCreaseButton:
            vc?.inCreaseDeCrease = 1
            
            vc?.title = "Increasing \(self.stock.symbol!)"
            
        case deCreaseButton:
            vc?.inCreaseDeCrease = -1
            vc?.title = "Decreasing \(self.stock.symbol!)"

        default:
            break
        }
        
        
    }
    
    
    //MARK: - Funcitons
    /// Load Statistics from given stock
    func loadStatistics(){
        companyNameLabel.text = stock.companyName
        quantityLabel.text = "\(stock.quantity)"
        worthLabel.text = "\(stock.worth)"
        priceLabel.text = "\(stock.price)"
        earningsLabel.text = "\(stock.earnings)"
    }
    

}

//MARK: - Table View Delegate
extension StockDetailViewController: UITableViewDelegate{
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Get all stock transactions from Stock CoreData
        activeStocks = (stock.activeStocks?.allObjects as? [ActiveStock])!
        
        // Sort stock activity by date, place newest transaction on the top
        activeStocks.sort{
            $0.boughtDate! > $1.boughtDate!
        }
        quantityLabel.text = "\(stock.quantity)"
        worthLabel.text = "\(stock.worth)"
        earningsLabel.text = "\(stock.earnings)"
        tableView.reloadData()
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        // Delete a transaction
        switch editingStyle {
        case .delete:
            
            // Delete from Core Data
            ViewController.coreDataStack.managedContext.delete(activeStocks[indexPath.row])
            // Remove from array
            activeStocks.remove(at: indexPath.row)
            
            // Recalculate total quantity and total worth
            var totalQuantity = Int16(0)
            // Calculate all quantities by mapping
            let _ = activeStocks.map{
                totalQuantity += $0.quantity
            }
            
            
            var worth = 0.0
            // Re-calculate all wieghts and total worth
            for active in activeStocks {
                let weight = active.worth * Double(active.quantity) / Double(totalQuantity)
                print("Weight is \(weight)")
                worth = worth + weight
            }
            stock.quantity = totalQuantity
            stock.worth = worth
            stock.earnings = (stock.price - stock.worth) * Double(totalQuantity)
            
            
            tableView.deleteRows(at: [indexPath], with: .automatic)
            loadStatistics()
            
            ViewController.coreDataStack.saveContext()
            
        default:
            break
        }
    }
}



//MARK: - Table View Data Source
extension StockDetailViewController: UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Traiding History"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activeStocks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DetailCell", for: indexPath) as! DetailCell
        
        // Set date formatter
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, y"

        // Display All transactions
        let activeStock = activeStocks[indexPath.row]
        cell.boutDateLabel.text = "\(dateFormatter.string(from: activeStock.boughtDate!))"
        cell.quantityLabel.text = "\(activeStock.quantity)"
        cell.priceLabel.text = "\(activeStock.boughtPrice)"
        
        
        return cell
    }
    
    
}



//MARK: - Custom Table View Cell
/// This class is TableViewClass to declare all outlet properties for each cell
class DetailCell: UITableViewCell{
    //MARK: - Cell Outlets
    @IBOutlet weak var boutDateLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
}

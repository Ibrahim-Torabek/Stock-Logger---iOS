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
    
    
    //MARK: - Actions
    @IBAction func deCreaseButton(_ sender: UIButton) {
    }
    
    @IBAction func inCreaseButton(_ sender: UIButton) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let button = sender as? UIButton else { return }
        
        let vc = segue.destination as? AddStockViewController
        vc?.stock = stock

//        vc?.stock =
        
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
    
    
    //MARK: - View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()

        title = stock.symbol
        
        companyNameLabel.text = stock.companyName
        quantityLabel.text = "\(stock.quantity)"
        worthLabel.text = "\(stock.worth)"
        priceLabel.text = "\(stock.price)"
        earningsLabel.text = "\(stock.earnings)"
        
        flagImage.image = stock.isUSD ? UIImage(named: "us.square") : UIImage(named: "canada.square")
        
        //Set tabel view delegate and datasource
        tableView.delegate = self
        tableView.dataSource = self
        
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

//MARK: - Table View Delegate
extension StockDetailViewController: UITableViewDelegate{
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        activeStocks = (stock.activeStocks?.allObjects as? [ActiveStock])!
        quantityLabel.text = "\(stock.quantity)"
        worthLabel.text = "\(stock.worth)"
        earningsLabel.text = "\(stock.earnings)"
        tableView.reloadData()
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
        
        
        //TODO: - Put data formatter a better place
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, y"

        
        let activeStock = activeStocks[indexPath.row]
        cell.boutDateLabel.text = "\(dateFormatter.string(from: activeStock.boughtDate!))"
        cell.quantityLabel.text = "\(activeStock.quantity)"
        cell.priceLabel.text = "\(activeStock.boughtPrice)"
        
        
        return cell
    }
    
    
}



//MARK: - Custom Table View Cell
class DetailCell: UITableViewCell{
    //MARK: - Cell Outlets
    @IBOutlet weak var boutDateLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
}

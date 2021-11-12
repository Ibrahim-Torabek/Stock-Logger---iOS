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

    //MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    
    
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
    func loadSoldStocks(){
                
        let request = SoldStock.fetchRequest()
        
        do {
            soldStocks = try ViewController.coreDataStack.managedContext.fetch(request)

        } catch {
            print("Fetching Error!!!")
        }
        
        
        tableView.reloadData()
        
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


extension SoldStockViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return soldStocks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell",for: indexPath) as! SoldTableCell
        
        let soldStock = soldStocks[indexPath.row]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, y"
        
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


class SoldTableCell: UITableViewCell{
    //MARK: - Sold Table Cell Outlets
    @IBOutlet weak var symbol: UILabel!
    @IBOutlet weak var companyName: UILabel!
    @IBOutlet weak var soldPrice: CurrencyLabel!
    @IBOutlet weak var earnings: CurrencyLabel!
    @IBOutlet weak var soldDate: UILabel!
}

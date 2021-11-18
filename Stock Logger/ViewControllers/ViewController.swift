//
//  ViewController.swift
//  Stock Logger
//
//  Created by Ibrahim Torabek on 2021-09-26.
//

import UIKit
import CoreData


class ViewController: UIViewController {
    //MARK: - Properties
    let APIKey = "WMHZQM8S5LZ9EB4W"
    // Set the initial currency rating. It will change when JSON retieved data successfully
    var currencyRating = 1.25
    
    // Core Data Stack to get and save Stock and SoldStock entries
    // CoreDataStack declared as static to use it in other ViewControllers
    static var coreDataStack = CoreDataStack(modelName: "StockModel")
    var stocks = [Stock]()
    var soldStocks = [SoldStock]()
    
    // Refresh controller for refresh the tableView when the user swipe down the table rows
    var refreshControl = UIRefreshControl()
    
    
    //MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    
    // Dash board elements to display statistics of the stock ernings
    @IBOutlet weak var totalStockLabel: UILabel!
    @IBOutlet weak var activeEarningsLabel: CurrencyLabel!
    @IBOutlet weak var soldEarningsLabel: CurrencyLabel!
    @IBOutlet weak var totalEarningsLabel: CurrencyLabel!
    
    
    //MARK: - View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // Set refresh method when user swipe down rows of tableView
        refreshControl.attributedTitle = NSAttributedString(string: "Refreshing the table")
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: UIControl.Event.valueChanged)
        tableView.addSubview(refreshControl)
        
    }
    
    
    //MARK: - Functions
    
    /// This class load Core Data used CoreDataStack clas
    /// - This function retrieves  stock and sold stock from StockModel asynchronously
    /// - It will fetch all active stocks' recent price from StockAPI in main thread after retrieved core data successfully
    /// - This function also calculates earnings depend on fetched prices
    /// - This funciton also reload the table view when fetched successfully
    /// - Warning: Only can fetch 5 stocks' information per minute due to free API
    func loadStockData(){
        
        DispatchQueue.global().async{
            [weak self] in
            
            // Get core data of Stock and SoldStock entries
            do {
                self?.stocks = try ViewController.coreDataStack.managedContext.fetch(Stock.fetchRequest())
                self?.soldStocks = try ViewController.coreDataStack.managedContext.fetch(SoldStock.fetchRequest())
            } catch {
                print("Fetching Error!!!")
            }
            
            // fetch current price
            DispatchQueue.main.async {
                [weak self] in
                
                for stock in self!.stocks {
                    if let url = self?.createStockUrl(for: stock.symbol!) {
                        self?.fetchStock(from: url, to: stock)
                    }
                }
                
                self?.calculateEarnings()
                
                self?.tableView.reloadData()
            }
        }

        
        
        
    }
    
    /// Calculae earnings depend on current stock price and owned stock worth
    /// - This function calculates total earnings of both active and sold stocks
    /// - This fucntion also refresh statistics in dashboard
    func calculateEarnings(){
        var activeEarnings = 0.0
        var soldStockEarnings = 0.0
        
        // Calculate each active stocks earnings
        for stock in stocks {
            // Just display in CAD currentcy
            let rating = stock.isUSD ? currencyRating : 1.0
            activeEarnings += (stock.earnings * rating)
        }
        
        // Calculate each sold stocks earnings
        for stock in soldStocks {
            // Just display in CAD currentcy
            let rating = stock.isUSD ? currencyRating : 1.0
            soldStockEarnings += (stock.earnings * rating)
        }
        
        // refresh dash board
        activeEarningsLabel.text = "\(activeEarnings)"
        soldEarningsLabel.text = "\(soldStockEarnings)"
        
        totalEarningsLabel.text = "\(activeEarnings + soldStockEarnings)"
    }

    
    
    //MARK: - Sold Stock Function
    /// Calculate the final earnings and store in Sold Stock entry of CoreData
    /// - Parameters:
    ///   - stock: The stock information. This information will be saved into SoldStock entry.
    ///   - soldPrice: The sold price that user entered. Calculate earnings depend on sold price
    ///   - indexPath: The index path that user selected.
    func soldStock(sold stock: Stock, at soldPrice: Double, from indexPath: IndexPath){
        
        // Create a sold stock
        let sold = SoldStock(context: ViewController.coreDataStack.managedContext)
        
        // Assign all fields
        sold.symbol = stock.symbol
        sold.companyName = stock.companyName
        sold.soldPrice = soldPrice
        // Calculate earnings
        sold.earnings = (soldPrice - stock.worth) * Double(stock.quantity)
        sold.soldDate = Date()
        sold.quantity = stock.quantity
        
        // append to soldStock entry
        soldStocks.append(sold)
        
        // Save core date
        ViewController.coreDataStack.saveContext()
        
        // Delete stock from both active stock and tableView
        deleteStok(delete: stock, at: indexPath)


    }
    
    //MARK: - Delete Stock Function
    /// Delete stock from active stock and table view
    /// - Parameters:
    ///   - stock: The Given stock to delete
    ///   - indexPath: The indexPath of the table view which the stock displayed
    func deleteStok(delete stock: Stock, at indexPath: IndexPath){
        // Delete from active stock CoreData
        ViewController.coreDataStack.managedContext.delete(stock)
        ViewController.coreDataStack.saveContext()
        // Remove from active stock array
        self.stocks.remove(at: indexPath.row)
        // Delete selected stock row from table view
        self.tableView.deleteRows(at: [indexPath], with: .automatic)
    }
    
    //MARK: - Fetch CAD Currency Rating
    /// Fetch currency exchange rate from API
    /// - Fetch only the exchange rate from USD to CAD
    func fetchCurrency(){
        // Prepare the API url
        var urlString = "https://www.alphavantage.co/query?"
        urlString = urlString.appending("function=CURRENCY_EXCHANGE_RATE&")
        urlString = urlString.appending("from_currency=USD&")
        urlString = urlString.appending("to_currency=CAD&")
        urlString = urlString.appending("apikey=\(APIKey)")
        
        if let url = URL(string: urlString){
            URLSession.shared.dataTask(with: url){
                data, response, error in
                
                var currency: Currency?
                
                if let error = error {
                    print("Failed to fetch CAD: \(error.localizedDescription)")
                } else {
                    do {
                        guard let someData = data else { return }
                        
                        let jSonDecoder = JSONDecoder()
                        
                        let downloadExchange = try jSonDecoder.decode(CurrencyExchange.self, from: someData)

                        currency = downloadExchange.currency
                                                
                    } catch let error {
                        print("Currency fetching error: \(error.localizedDescription)")
                    }
                    
                    DispatchQueue.main.async {
                        if let currency = currency {
                            if let rate = currency.rate {
                                // Get currency rating
                                self.currencyRating = (rate as NSString).doubleValue
                                // Calculate the earnings depend on the exchange rate
                                self.calculateEarnings()
                            }
                        }
                    }
                }
                
            }.resume()
        }
    }
    
    
    //MARK: - Objcs
    /// Refresh the Table View when user swipe down the table
    /// - Parameter sender: sender of OBJC
    @objc func refresh(_ sender: AnyObject){
        loadStockData()
        refreshControl.endRefreshing()
    }
    

}


//MARK: - Table View Delegate
extension ViewController: UITableViewDelegate{
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Fetch currency and CoreData when the table will display
        fetchCurrency()
        loadStockData()
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        // Display the stocks header text
        return "Stocks in Stock"
    }
    
    
    //MARK: - Edit Action
    /// Leading swipe for EDIT operation
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // Declare an action
        let action = UIContextualAction(style: .normal, title: "Edit", handler: {
            action, view, perormed in
            // Get AddEditStock View Contrller from Main Story board
            let stoyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = stoyboard.instantiateViewController(identifier: "AddEditStock") as! AddStockViewController
            
            // Set stock information and inCreaseDeCrease as 2 for editing
            vc.stock = self.stocks[indexPath.row]
            vc.inCreaseDeCrease = 2 //Edit
            // Show AddStockViewController
            self.present(vc, animated: true, completion: nil)
            
            // Set performed as success
            perormed(true)
        })
        
        // Set action's backcolor and image
        action.backgroundColor = UIColor.systemBlue
        action.image = UIImage(systemName: "square.and.pencil")
        

        // return the performed action
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    
    
    //MARK: - Delete / Sold Actions
    /// Tailing swipe for SOLD and DELETE operations
    /// - This will display two action in the row trailing when user swipe the row to the left
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        // Get selecte stock
        let selectedStock = self.stocks[indexPath.row]
        
        // Prepare delete action
        let deleteAction = UIContextualAction(style: .normal, title: "Delete", handler: {
            action, view, perormed in

            // Display alert controller when user delete a stock
            let ac = UIAlertController(title: "Warning!!!", message: "Are you sure to delete \(selectedStock.companyName!)?", preferredStyle: .alert)
            
            ac.addAction(UIAlertAction(title: "Yes", style: .default, handler: {_ in
                DispatchQueue.main.async {
                    self.deleteStok(delete: selectedStock, at: indexPath)
                    self.calculateEarnings()
                    perormed(true)
                }
            }))
            
            ac.addAction(UIAlertAction(title: "No", style: .default, handler: {_ in
                perormed(false)
            }))
            
            self.present(ac, animated: true)
            
            
        })
        
        // Prepare Sold Action
        let soldAction = UIContextualAction(style: .normal, title: "Sold", handler: {
            action, view, performed in
            
            // Display alert controller to get sold price
            let ac = UIAlertController(title: selectedStock.symbol, message: "Please enter the sold price?", preferredStyle: .alert)
            
            // TextField to get the sold price
            ac.addTextField(configurationHandler: {
                textField in
                
                textField.placeholder = "123.32"
                textField.keyboardType = .decimalPad
            })
            
            
            ac.addAction(UIAlertAction(title: "Sold", style: .default, handler: {
                [weak self, weak ac] action in
                guard let text = ac?.textFields?[0].text else { return }
                
                let soldPrice = (text as NSString).doubleValue
                
                self?.soldStock(sold: selectedStock, at: soldPrice, from: indexPath)
                self?.calculateEarnings()
                performed(true)
            }))
            
            ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            self.present(ac, animated: true)
            
            
        })
        
        soldAction.backgroundColor = UIColor.systemCyan
        soldAction.image = UIImage(named: "Sold-White")
        
        
        
        deleteAction.backgroundColor = UIColor.systemRed
        deleteAction.image = UIImage(named: "Delete")
        
        // Set two actions in the trailing of the row
        let config = UISwipeActionsConfiguration(actions: [soldAction ,deleteAction])
        
        // Disable full swipe
        config.performsFirstActionWithFullSwipe = false
        
        return config
    }
}


//MARK: - Table View Data Source
extension ViewController:UITableViewDataSource{
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stocks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "stockListCell", for: indexPath) as! StockCell
        

        // Get current stock to the cell
        let stock = stocks[indexPath.row]
        
        // Place all information to the cell
        cell.symbolLabel.text = stock.symbol
        cell.companyNameLabel.text = stock.companyName
        cell.priceLabel.text = "\(stock.price)"
        cell.erningsLabel.text = "\(stock.earnings)"
        
        // Display US flag if the stock is in the US; otherwise, display Canada flag
        cell.flagImage.image = stock.isUSD ? UIImage(named: "us.square") : UIImage(named: "canada.square")
        


        // Change image according to the earnings (Up or Down)
        let image = stock.earnings >= 0 ? UIImage(named: "High"): UIImage(named: "Low")
        
        cell.highLowImage.image = image
        
        return cell;
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let index = tableView.indexPathForSelectedRow else { return }
        
        // Prepare stock detail for StockDetailViewController
        let vc = segue.destination as! StockDetailViewController
        vc.stock = stocks[index.row]
    }
    
    
    //MARK: - Fetch Stock Functions
    /// Create stock url according to given stock symbol
    /// - Parameter stock: Stock Symbol
    /// - Returns: Fetchable  API URL
    func createStockUrl(for stock: String) -> URL?{
        
        guard let cleanURL = stock.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { fatalError("Can't create a valid URL") }
        
        // Create fetchable API url
        var urlString = "https://www.alphavantage.co/query?"
        urlString = urlString.appending("function=GLOBAL_QUOTE&")
        urlString = urlString.appending("symbol=\(cleanURL)&")
        urlString = urlString.appending("apikey=\(APIKey)")
        
        
        return URL(string: urlString)
    }
    
    
    /// Fetch stock from API
    /// - Parameters:
    ///   - url: Fetchable stock API URL
    ///   - stock: The stock that receives the fetched results
    func fetchStock(from url: URL, to stock: Stock){
        
        let stockTask = URLSession.shared.dataTask(with: url){
            data, response, error in
            
            var stockDetail: StockDetail?
            
            if let error = error {
                print("Failed to fetch: \(error.localizedDescription)")
            } else {
                do {
                    guard let someData = data else { return }
                    
                    
                    let jSonDecoder = JSONDecoder()
                    
                    // Download JSON result from Global Quote
                    let donwloadGlobalquote = try jSonDecoder.decode(GlobalQuote.self, from: someData)
                    
                    // Get stok detail
                    stockDetail = donwloadGlobalquote.stockDetail
                    
                    
                } catch  {
                    print("Only can fetch 5 stocks per minute due to free API key.")
                }
                
                DispatchQueue.main.async {
                    if let newStock = stockDetail {
                        // Save stock price
                        stock.price = Double(newStock.price!)!
                        
                        // calculate and save stock earnings
                        stock.earnings = (stock.price - stock.worth) * Double(stock.quantity)
                        
                        // Reload table view and refresh dashboard
                        self.tableView.reloadData()
                        self.calculateEarnings()
                    }
                }
            }
        }
        
        stockTask.resume()
    }
    
    
}


//MARK: - Stock Cell
/// This is TabelViewCell to declare all Outlet properties for custom tableCell
class StockCell: UITableViewCell {
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var companyNameLabel: UILabel!
    @IBOutlet weak var priceLabel: CurrencyLabel!
    @IBOutlet weak var erningsLabel: CurrencyLabel!
    @IBOutlet weak var highLowImage: UIImageView!
    @IBOutlet weak var flagImage: UIImageView!
}



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
    static var coreDataStack = CoreDataStack(modelName: "StockModel")
    var stocks = [Stock]()
    var soldStocks = [SoldStock]()
    
    var fetchedResultsController: NSFetchedResultsController<Stock>!
    
    var stocksDetail = [StockDetail?](repeating: nil, count: 20)
    
    var refreshControl = UIRefreshControl()
    
    
    //MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var totalStockLabel: UILabel!
    @IBOutlet weak var activeEarningsLabel: CurrencyLabel!
    @IBOutlet weak var soldEarningsLabel: CurrencyLabel!
    @IBOutlet weak var totalEarningsLabel: CurrencyLabel!
    
    
    //MARK: - View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        tableView.delegate = self
        tableView.dataSource = self
        
        refreshControl.attributedTitle = NSAttributedString(string: "Refreshing the table")
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: UIControl.Event.valueChanged)
        tableView.addSubview(refreshControl)
        
    }
    
    
    //MARK: - Functions
    func loadStockData(){
        
        DispatchQueue.global().async{
            [weak self] in
            
            do {
                self?.stocks = try ViewController.coreDataStack.managedContext.fetch(Stock.fetchRequest())
                self?.soldStocks = try ViewController.coreDataStack.managedContext.fetch(SoldStock.fetchRequest())

            } catch {
                print("Fetching Error!!!")
            }
            
            DispatchQueue.main.async {
                [unowned self] in
                
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
    
    func calculateEarnings(){
        var activeEarnings = 0.0
        var soldStockEarnings = 0.0
        
        for stock in stocks {
            activeEarnings += stock.earnings
        }
        
        for stock in soldStocks {
            soldStockEarnings += stock.earnings
        }
        
        activeEarningsLabel.text = "\(activeEarnings)"
        soldEarningsLabel.text = "\(soldStockEarnings)"
        
        totalEarningsLabel.text = "\(activeEarnings + soldStockEarnings)"
        
    }
    
    
    //MARK: - Sold Stock Function
    func soldStock(sold stock: Stock, at soldPrice: Double, from indexPath: IndexPath){
        
            
        let sold = SoldStock(context: ViewController.coreDataStack.managedContext)
        
        sold.symbol = stock.symbol
        sold.companyName = stock.companyName
        sold.soldPrice = soldPrice
        sold.earnings = (soldPrice - stock.worth) * Double(stock.quantity)
        sold.soldDate = Date()
        sold.quantity = stock.quantity
        
        soldStocks.append(sold)
        
        ViewController.coreDataStack.saveContext()
        
        deleteStok(delete: stock, at: indexPath)


    }
    
    //MARK: - Delete Stock Function
    func deleteStok(delete stock: Stock, at indexPath: IndexPath){
        ViewController.coreDataStack.managedContext.delete(stock)
        ViewController.coreDataStack.saveContext()
        self.stocks.remove(at: indexPath.row)
        self.tableView.deleteRows(at: [indexPath], with: .automatic)
    }
    
    
    //MARK: - Objcs
    @objc func refresh(_ sender: AnyObject){

        loadStockData()
        refreshControl.endRefreshing()
    }
    

}


//MARK: - Table View Delegate
extension ViewController: UITableViewDelegate{
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadStockData()
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Stocks in Stock"
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle{
        case .delete:
            let selectedStock = stocks[indexPath.row]
            ViewController.coreDataStack.managedContext.delete(selectedStock)
            ViewController.coreDataStack.saveContext()
            stocks.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
            
        default:
            break
        }
    }
    
    //MARK: - Edit Action
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .normal, title: "Edit", handler: {
            action, view, perormed in
            

            let stoyboard = UIStoryboard(name: "Main", bundle: nil)
            
            let vc = stoyboard.instantiateViewController(identifier: "AddEditStock") as! AddStockViewController
            
            vc.stock = self.stocks[indexPath.row]
            vc.inCreaseDeCrease = 2 //Edit
            self.present(vc, animated: true, completion: nil)
            
            perormed(true)
            print(indexPath.row)
        })
        
        action.backgroundColor = UIColor.systemBlue
        action.image = UIImage(systemName: "square.and.pencil")
        

        
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    
    
    //MARK: - Delete / Sold Actions
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let selectedStock = self.stocks[indexPath.row]
        
        let deleteAction = UIContextualAction(style: .normal, title: "Delete", handler: {
            action, view, perormed in
            
            
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
        
        let soldAction = UIContextualAction(style: .normal, title: "Sold", handler: {
            action, view, performed in
            
            let ac = UIAlertController(title: selectedStock.symbol, message: "Please enter the sold price?", preferredStyle: .alert)
            
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
        
        let config = UISwipeActionsConfiguration(actions: [soldAction ,deleteAction])
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
        

        let stock = stocks[indexPath.row]
        
        
        cell.symbolLabel.text = stock.symbol
        cell.companyNameLabel.text = stock.companyName
        cell.priceLabel.text = "\(stock.price)"
        cell.erningsLabel.text = "\(stock.earnings)"
        


        // TODO: - Change image according to the earnings
        let image = stock.earnings >= 0 ? UIImage(named: "High"): UIImage(named: "Low")
        
        cell.highLowImage.image = image
        
        return cell;
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let index = tableView.indexPathForSelectedRow else { return }
        
        let vc = segue.destination as! StockDetailViewController
        vc.stock = stocks[index.row]
    }
    
    
    //MARK: - Fetch Stock Functions
    func createStockUrl(for stock: String) -> URL?{
        
        guard let cleanURL = stock.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { fatalError("Can't create a valid URL") }
        
        var urlString = "https://www.alphavantage.co/query?"
        urlString = urlString.appending("function=GLOBAL_QUOTE&")
        urlString = urlString.appending("symbol=\(cleanURL)&")
        urlString = urlString.appending("apikey=WMHZQM8S5LZ9EB4W")
        
        
        return URL(string: urlString)
    }
    
    
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
                    
                    let donwloadGlobalquote = try jSonDecoder.decode(GlobalQuote.self, from: someData)
                    
                    if let symbol = donwloadGlobalquote.stockDetail.price {
                        print(symbol)
                    }
                    
                    stockDetail = donwloadGlobalquote.stockDetail
                    
                    
                } catch  {
                    print("Only can fetch 5 stocks per minute due to free API key.")
                }
                
                DispatchQueue.main.async {
                    if let newStock = stockDetail {
                        stock.price = Double(newStock.price!)!
                        
                        stock.earnings = (stock.price - stock.worth) * Double(stock.quantity)
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
class StockCell: UITableViewCell {
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var companyNameLabel: UILabel!
    @IBOutlet weak var priceLabel: CurrencyLabel!
    @IBOutlet weak var erningsLabel: CurrencyLabel!
    @IBOutlet weak var highLowImage: UIImageView!
}



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
    var coreDataStack = CoreDataStack(modelName: "StockModel")
    var stocks = [Stock]()
    var fetchedResultsController: NSFetchedResultsController<Stock>!
    
    var stocksDetail = [StockDetail?](repeating: nil, count: 20)
    
    
    //MARK: - Outlets
    @IBOutlet weak var stockListTableView: UITableView!
    
    
    //MARK: - View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        stockListTableView.delegate = self
        stockListTableView.dataSource = self
        
        //loadStockData()
        
        
    }
    
    //MARK: - Functions
    func loadStockData(){
                
        let request = Stock.fetchRequest()
        
        do {
            stocks = try coreDataStack.managedContext.fetch(request)

        } catch {
            print("Fating Error!!!")
        }
        
        for stock in stocks {
            if let url = createStockUrl(for: stock.symbol!) {
                fetchStock(from: url, to: stock)
            }
            
        }
        
        stockListTableView.reloadData()
        
    }
    
    

    
    func loadStockDetail(){
        
    }
    
    


}


//MARK: - Table View Delegate
extension ViewController: UITableViewDelegate{
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadStockData()
        loadStockDetail()
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle{
        case .delete:
            let selected = stocks[indexPath.row]
            coreDataStack.managedContext.delete(selected)
            coreDataStack.saveContext()
            stocks.remove(at: indexPath.row)
            stockListTableView.deleteRows(at: [indexPath], with: .automatic)
        default:
            break
        }
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
        cell.erningsLabel.text = "\(round(stock.earnings * 10000) / 10000)"
        


        // TODO: - Change image according to the earnings
        let image = stock.earnings >= 0 ? UIImage(named: "High-Icon"): UIImage(named: "Low-Icon")
        
        cell.highLowImage.image = image
        
        return cell;
    }
    
    
    //MARK: - Fetch Stock Functions
    func createStockUrl(for stock: String) -> URL?{
        
        guard let cleanURL = stock.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { fatalError("Can't create a valid URL") }
        
        var urlString = "https://www.alphavantage.co/query?"
        urlString = urlString.appending("function=GLOBAL_QUOTE&")
        urlString = urlString.appending("symbol=\(cleanURL)&")
        urlString = urlString.appending("apikey=WMHZQM8S5LZ9EB4W")
        
        //print(urlString)
        
        
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
                    
                    
                } catch let error {
                    print("Problem decoding: \(error)")
                }
                
                DispatchQueue.main.async {
                    if let newStock = stockDetail {
                        stock.price = Double(newStock.price!)!
                        
                        stock.earnings = (stock.price - stock.worth) * Double(stock.quantity)
                        self.stockListTableView.reloadData()
                    }
                }
            }
            
            
        }
        
        stockTask.resume()
    }
    
    func fetchStock(from url: URL, to cell: StockCell){
        
        
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
                    
                    
                } catch let error {
                    print("Problem decoding: \(error)")
                }
                
                DispatchQueue.main.async {
                    if let stock = stockDetail {
                        cell.priceLabel.text = stock.price
                        self.stockListTableView.reloadData()
                    }
                }
            }
            
            
        }
        
        stockTask.resume()
    }
    
    
    func fetchStock(from url: URL, into index: Int){
        
        
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
                    
                    
                } catch let error {
                    print("Problem decoding: \(error)")
                }
                
                DispatchQueue.main.async {
                    if let stock = stockDetail {
                        self.stocksDetail[index] = stock
                        self.stockListTableView.reloadData()
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
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var erningsLabel: UILabel!
    @IBOutlet weak var highLowImage: UIImageView!
}


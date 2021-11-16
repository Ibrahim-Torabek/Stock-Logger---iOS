//
//  SearchViewController.swift
//  Stock Logger
//
//  Created by Ibrahim Torabek on 2021-11-13.
//

import UIKit

class SearchViewController: UIViewController {
    //MARK: - Properties
    var addStockViewController: AddStockViewController!
    
    
    var detailedStocks = [StockDetail]()

    //MARK: - Outlets
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: - View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        searchTextField.delegate = self
        searchTextField.becomeFirstResponder()
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
extension SearchViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = addStockViewController {
            vc.companyNameTextField.text = detailedStocks[indexPath.row].companyName
            vc.symbolTextField.text = detailedStocks[indexPath.row].keywords
            
            vc.isUsdSwitch.isOn = detailedStocks[indexPath.row].currency == "USD" ? true : false
        }
        self.dismiss(animated: true, completion: nil)
    }
}

//MARK: - Table View Data Source
extension SearchViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return detailedStocks.count
    }
    

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.textLabel?.text = detailedStocks[indexPath.row].keywords
        cell.detailTextLabel?.text = detailedStocks[indexPath.row].companyName
        
        cell.imageView?.image = detailedStocks[indexPath.row].currency == "CAD" ? UIImage(named: "canada.circle") : UIImage(named: "us.circle")

        return cell
    }
    
    
}

extension SearchViewController: UITextFieldDelegate{
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if let text = textField.text {
            print(text)
            
            if let url = createStockUrl(for: text) {
                fetchStock(from: url)
            }
            
        }
    }
    

    // MARK: - Fetch Stock API
    func createStockUrl(for keywords: String) -> URL?{
        
        guard let cleanURL = keywords.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { fatalError("Can't create a valid URL") }
        
        var urlString = "https://www.alphavantage.co/query?"
        urlString = urlString.appending("function=SYMBOL_SEARCH&")
        urlString = urlString.appending("keywords=\(cleanURL)&")
        urlString = urlString.appending("apikey=WMHZQM8S5LZ9EB4W")
        
        
        return URL(string: urlString)
    }
    
    
    func fetchStock(from url: URL){
        
        
        let stockTask = URLSession.shared.dataTask(with: url){
            data, response, error in
            
            
            if let error = error {
                print("Failed to fetch: \(error.localizedDescription)")
            } else {
                do {
                    guard let someData = data else { return }
                    
                    
                    let jSonDecoder = JSONDecoder()
                    
                    let donwloadBestMetches = try jSonDecoder.decode(BestMetches.self, from: someData)
                    
                    let fetchedstocks = donwloadBestMetches.bestMatches
                    
                    self.detailedStocks = fetchedstocks.filter{
                        $0.currency == "USD" || $0.currency == "CAD"
                    }
                    
                    
                } catch {
                    print("Only can fetch 5 stocks per minute due to free API key.")
//                    print("Searhc symbol failed: \(error.localizedDescription)")
                }
                
                DispatchQueue.main.async {

                    self.tableView.reloadData()

                }
            }
            
            
        }
        
        stockTask.resume()
    }
}


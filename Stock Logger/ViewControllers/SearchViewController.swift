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
            vc.symbolTextField.text = detailedStocks[indexPath.row].symbol
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
        
        cell.textLabel?.text = detailedStocks[indexPath.row].symbol
        cell.detailTextLabel?.text = detailedStocks[indexPath.row].companyName
        cell.imageView?.image = UIImage(systemName: "folder.circle")
        
        return cell
    }
    
    
}

extension SearchViewController: UITextFieldDelegate{
    override class func didChangeValue(forKey key: String) {
//        var stock = StockDetail()
//
//        stock.companyName = "Zomedica Pharma"
//        stock.symbol = "ZOM"
//
//        self.detailedStocks.append(stock)
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if let text = textField.text {
            print(text)
            var stock = StockDetail()
    
            stock.companyName = "Zomedica Pharma"
            stock.symbol = text
            detailedStocks.append(stock)
            
            tableView.reloadData()
        }
    }
    

}


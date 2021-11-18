//
//  AddStockViewController.swift
//  Stock Logger
//
//  Created by Ibrahim Torabek on 2021-10-17.
//

import UIKit
import CoreData

class AddStockViewController: UITableViewController, UITextFieldDelegate {
    //MARK: - Properties
    // Get coreDataStack from ViewController
    var coreDataStack = ViewController.coreDataStack
    var stocks = [Stock]()
    
    // Current stock
    var stock: Stock!
    var inCreaseDeCrease = 0
    
    
    //MARK: - Outlets
    @IBOutlet weak var symbolTextField: UITextField!
    @IBOutlet weak var companyNameTextField: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var quantityTextField: UITextField!
    @IBOutlet weak var boughtDatePicker: UIDatePicker!
    @IBOutlet weak var isUsdSwitch: UISwitch!
    

    //MARK: - Actions - Save Button
    @IBAction func save(_ sender: Any) {
        
        // Resign First Reponder
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        
        // To check wich field is empty, used sperated guard statements.
        // Set the TextFields border as red and return false if the TextField is empty
        guard
            let symbol = isEmpty(symbolTextField),
            let companyName = isEmpty(companyNameTextField),
            let price = isDouble(priceTextField),
            let quantityDouble = isDouble(quantityTextField)
        else{
            return
        }
        
        
        // got quantity as double when check it to use same method with price.
        // Convert it to Int know.
        var quantity = Int16(quantityDouble)
        
        // Initiate an ActiveStock entry of core data
        let activeStock = ActiveStock(context: coreDataStack.managedContext)
        
        // olace bought price abd bought data first
        activeStock.boughtPrice = price
        activeStock.boughtDate = boughtDatePicker.date
        
        // Proced Add / Edit / Increase and Decrease amounts according to given inCreaseDeCrease value
        switch inCreaseDeCrease {
        case 0: // Add new Stock
            let stock = Stock(context: coreDataStack.managedContext)
            
            stock.symbol = symbol
            stock.companyName = companyName
            stock.isUSD = isUsdSwitch.isOn
            // calculate worth of stock by adding twice of promotion
            // calculate first commition as twice to concider sell price
            let worth = price  + 2.0 * 5.95 / Double(quantity)
            
            
            stock.quantity = quantity
            
            stock.price = price
            stock.worth = worth
            
            // Save results
            activeStock.quantity = quantity
            activeStock.worth = worth
            activeStock.stock = stock
            // Save as child
            stock.addToActiveStocks(activeStock)
            stocks.append(stock)
            
        case 2: // Edit symbol and company name
            
            // get stock from stocks array by given symbol
            if let stock = stocks.first(where: {$0.symbol == symbol}) {
                // Change symbol and company name from TextField
                stock.companyName = companyName
                stock.symbol = symbol
            }
            
        default: // Increase Stock if value = 1, or Decrease Stock if value = -1

            // get stock from stocks array by given symbol
            if let stock = stocks.first(where: {$0.symbol == symbol}) {
                // add(1) or remove(-1) quantity from total quantity
                quantity = Int16(inCreaseDeCrease) * quantity
                let totalQuantity = quantity + stock.quantity

                // Recalculate total worth of stock according to all active stocks weights.
                // 5.95 is the dealer promotion
                let activeStockWorth = price + 5.95 / Double(quantity)
                activeStock.worth = activeStockWorth
                activeStock.quantity = quantity

                activeStock.stock = stock
                stock.addToActiveStocks(activeStock)

                // calculate worth of whole stock
                var worth = 0.0

                let activeStocks = (stock.activeStocks?.allObjects as? [ActiveStock])!
                for active in activeStocks {
                    let weight = active.worth * Double(active.quantity) / Double(totalQuantity)
                    print("Weight is \(weight)")
                    worth = worth + weight
                }

                stock.worth = worth
                stock.quantity = totalQuantity
                stock.earnings = (stock.price - stock.worth) * Double(stock.quantity)


                //print(self.stocks)
            } else {
                print("Not Found!!!")
            }
            
            
            break
        }
        

        coreDataStack.saveContext()

        
        
//        for stock in stocks {
//            print(stock.companyName!)
//        }
        // First try to popViewController
        navigationController?.popViewController(animated: true)
        // If it does not pop, it means opened by edit buton, just dismiss current view
        self.dismiss(animated: true, completion: nil)
        return
    }
    
    
    //MARK: - Search action
    /// Open search View to search a stock by symbol
    @IBAction func search(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "SearchStock") as! SearchViewController
        vc.addStockViewController = self
        present(vc, animated: true)
    }
    
    
    
    /// Prepare to back StockDeail ViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? StockDetailViewController {
            if let stock = stocks.first(where: {$0.symbol == self.stock.symbol}){
                vc.stock = stock
            }
        }
        
    }
    
    
    /// Hide red border when user clicked missed text field
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.layer.borderWidth = 0.0
    }
    
    
    //MARK: - View Did Laod
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set delegate for UITextFields
        symbolTextField.delegate = self
        companyNameTextField.delegate = self
        priceTextField.delegate = self
        quantityTextField.delegate = self
        
        
        if inCreaseDeCrease == 2 {
            // If edit mode, just edit symbol and company name
            symbolTextField.text = stock.symbol
            companyNameTextField.text = stock.companyName
            priceTextField.text = "\(stock.price)"
            priceTextField.isEnabled = false
            quantityTextField.text = "\(stock.quantity)"
            quantityTextField.isEnabled = false
        } else if inCreaseDeCrease != 0 {
            // if increase or decrease, just put new price and quantity
            symbolTextField.text = stock.symbol
            symbolTextField.isEnabled = false
            companyNameTextField.text = stock.companyName
            companyNameTextField.isEnabled = false
            
        }
        
        
        
        // Add search button to the symbol text field
        let searchButton = UIButton(type: .custom)
        searchButton.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
        searchButton.addTarget(self, action: #selector(self.search), for: .touchUpInside)
        
        symbolTextField.rightViewMode = .always
        symbolTextField.rightView = searchButton

        //Load
        loadSavedData()
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 12
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // Just for constraint warning
        return 44.5
    }
    
    //MARK: - Functions
    /// Check if a UITextField is empty. if it is empty, return nil and set its border's color as red, else return the text
    /// - Parameter textField: The UITextField that needs to check
    /// - Returns: nil if empty, optional text if not empty.
    func isEmpty(_ textField: UITextField) -> String?{
        
        guard let text = textField.text, !text.isEmpty else {
            alertBorder(textField)
            print("Opps!!!")
            return nil
        }
        
        return text
    }
    
    /// Check if a UITextField is double. if it is empty, return nil; if it is not a doubleable text, retun nil and set its border's color as red, else return the double value
    /// - Parameter textField: The UITextField that needs to check
    /// - Returns: nil if empty or cannot convert to double value, optional double value if doubleable
    func isDouble(_ textField: UITextField) -> Double? {
        
        guard let text = textField.text else {
            // set border as red if missed
            alertBorder(textField)
            return nil
        }
        
        // get double value
        let doubleValue = (text as NSString).doubleValue
        
        // if text not empty and not numeric.
        if doubleValue == 0.0 {
            alertBorder(textField)
            return nil
        }
        
        return doubleValue
    }
    
    
    /// Set missed textfield's border as red
    func alertBorder(_ textField: UITextField){
        textField.layer.borderColor = CGColor.init(red: 1, green: 0, blue: 0, alpha: 1)
        textField.layer.borderWidth = 0.5
    }
    
    
    /// Load Stocks from Core Data
    func loadSavedData(){
            
        let request = Stock.fetchRequest()
        
        do {
            stocks = try coreDataStack.managedContext.fetch(request)

        } catch {
            print("Fating Error!!!")
        }
    }


}


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
    var coreDataStack = CoreDataStack(modelName: "StockModel")
    var stocks = [Stock]()
    var fetchedResultsController: NSFetchedResultsController<Stock>!
    
    var stock: Stock!
    var inCreaseDeCrease = 0
    
    
    //MARK: - Outlets
    @IBOutlet weak var symbolTextField: UITextField!
    @IBOutlet weak var companyNameTextField: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var quantityTextField: UITextField!
    @IBOutlet weak var boughtDatePicker: UIDatePicker!
    @IBOutlet weak var isUsdSwitch: UISwitch!
    

    @IBAction func save(_ sender: Any) {
        
        // Resign First Reponder
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        //.resignFirstResponder()
        
        // To check wich field is empty, used sperated guard statements.
        guard let symbol = isEmpty(symbolTextField),
           let companyName = isEmpty(companyNameTextField),
           let price = isDouble(priceTextField),
           let quantityDouble = isDouble(quantityTextField) else{
            return
        }
        
        // got quantity as double when check it. Convert to Int know.
        let quantity = Int16(quantityDouble)
        
        
        let stock = Stock(context: coreDataStack.managedContext)
        let activeStock = ActiveStock(context: coreDataStack.managedContext)
        let worth = price  + 2.0 * 5.59 / Double(quantity)

        
        stock.symbol = symbol
        stock.quantity = quantity
        stock.companyName = companyName
        stock.price = price
        stock.worth = worth
         
        
        activeStock.quantity = quantity
        activeStock.boughtDate = boughtDatePicker.date
        activeStock.boughtPrice = price
        activeStock.worth = worth
        activeStock.stock = stock
        stock.addToActiveStocks(activeStock)
        
        
        
        coreDataStack.saveContext()
        stocks.append(stock)
        
        
        navigationController?.popViewController(animated: true)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.layer.borderWidth = 0.0
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set delegate for UITextFields
        symbolTextField.delegate = self
        companyNameTextField.delegate = self
        priceTextField.delegate = self
        quantityTextField.delegate = self
        
        
        if inCreaseDeCrease != 0 {
            symbolTextField.text = stock.symbol!
            symbolTextField.isEnabled = false
            companyNameTextField.text = stock.companyName!
            companyNameTextField.isEnabled = false
            
            
        }

        //Load
        loadSavedData()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
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
    
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */
    
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
            alertBorder(textField)
            return nil
        }
        
        let doubleValue = (text as NSString).doubleValue
        
        if doubleValue == 0.0 {
            alertBorder(textField)
            return nil
        }
        
        return doubleValue
    }
    
    
    func alertBorder(_ textField: UITextField){
        textField.layer.borderColor = CGColor.init(red: 1, green: 0, blue: 0, alpha: 1)
        textField.layer.borderWidth = 0.5
    }
    
    func loadSavedData(){
            
        let request = Stock.fetchRequest()
        
        do {
            stocks = try coreDataStack.managedContext.fetch(request)
            
            //TODO: - Delete following sentence
//            stocks.map({
//                e in
//
//                if let active = e.activeStocks?.allObjects as? [ActiveStock], !active.isEmpty {
//
//                    print("Symbol: \(active[0].boughtPrice)")
//
//                }
//            })


        } catch {
            print("Fating Error!!!")
        }
    }




    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

//MARK: - Fetch Reqeust Delegate
extension AddStockViewController: NSFetchedResultsControllerDelegate{
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .delete:
            print(tableView.numberOfRows(inSection: 0))
            
        default:
            break
        }
    }
}

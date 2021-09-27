//
//  ViewController.swift
//  Stock Logger
//
//  Created by Ibrahim Torabek on 2021-09-26.
//

import UIKit

class ViewController: UIViewController {

    //MARK: - Outlets
    @IBOutlet weak var stockListTableView: UITableView!
    
    //MARK: - View Did Load
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        stockListTableView.delegate = self
        stockListTableView.dataSource = self
    }


}

//MARK: - Table View Delegate
extension ViewController: UITableViewDelegate{
    
}


//MARK: - Table View Data Source
extension ViewController:UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "stockListCell", for: indexPath)
        
        return cell;
    }
    
    
}

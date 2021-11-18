//
//  CreditViewController.swift
//  Stock Logger
//
//  Created by Ibrahim Torabek on 2021-11-17.
//

import UIKit
import SafariServices

class CreditViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        switch section{
        case 0:
            return 4
        default:
            return 1
        }
    }

    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 { // If selected rows in Icons secsion
            switch indexPath.row{
            case 0:
                // Canada Circle Flag
                if indexPath.section == 0 {
                    showSite("https://www.flaticon.com/free-icon/canada_330442?term=canada%20flag&page=1&position=11&page=1&position=11&related_id=330442")
                }
            case 1:
                // Canada Square Flag
                showSite("https://www.flaticon.com/free-icon/canada_197430?term=canada%20flag&page=1&position=5&page=1&position=5&related_id=197430")
            case 2:
                // US Circle Flag
                showSite("https://www.flaticon.com/free-icon/united-states_330459?term=us%20flag&page=1&position=5&page=1&position=5&related_id=330459")
            default:
                // US Square Flag
                showSite("https://www.flaticon.com/free-icon/united-states_197484?term=us%20flag&page=1&position=6&page=1&position=6&related_id=197484")
            }
        } else if indexPath.section == 2{ // If selected API Credit
            showSite("https://www.alphavantage.co/documentation/")
        }
    }
    
    //MARK: - Show Site Function
    func showSite(_ url: String){
        if let url = URL(string: url) {
            let config = SFSafariViewController.Configuration()
            config.entersReaderIfAvailable = true

            let destinationVC = SFSafariViewController(url: url, configuration: config)
            present(destinationVC, animated: true)
        }
    }
    

}

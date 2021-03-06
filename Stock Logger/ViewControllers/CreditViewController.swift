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
        // I used only three sections and hard coded all sections
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section{
        case 0: // first section is Icons, has four icons, used 4 cells
            return 4
        default: // Second and third sections only have one cell
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
    /// Open the source's web page of the credits by SafariViewController
    /// - Parameter url: The address of the source's web page.
    func showSite(_ url: String){
        // Turn url string into URL format
        if let url = URL(string: url) {
            let config = SFSafariViewController.Configuration()
            config.entersReaderIfAvailable = true

            // Configurate SafariViewController
            let destinationVC = SFSafariViewController(url: url, configuration: config)
            
            // Open webpage
            present(destinationVC, animated: true)
        }
    }
    

}

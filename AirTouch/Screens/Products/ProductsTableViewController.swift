//
//  ProductsTableViewController.swift
//  AirTouch
//
//  Created by Robert Tanase on 07/07/2018.
//  Copyright © 2018 AirTouch. All rights reserved.
//

import Foundation
import UIKit
import ProgressHUD

class ProductsViewController: UIViewController {

    @IBOutlet weak var productsTableView: UITableView!

    var products = [String]()
    var selectedIndexInTableView: Int = 0

    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self,
                                 action: #selector(handleRefresh(_:)),
                                 for: UIControlEvents.valueChanged)
        refreshControl.tintColor = #colorLiteral(red: 0.9882352941, green: 0.3333333333, blue: 0.1803921569, alpha: 1)
        return refreshControl
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        productsTableView.addSubview(self.refreshControl)

        self.products = DatabaseManager.shared.getAllProducts()
        self.products.sort { (prod1, prod2) -> Bool in
            prod1 < prod2
        }
    }

    @IBAction func didPressBackButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toProductScreen" {
            if let destinationViewController = segue.destination as? ProductViewController {
                destinationViewController.productCode = products[selectedIndexInTableView]
            }
        }
    }

    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        DatabaseUpdaterService.shared.updateProductsTransactions {
            self.products = DatabaseManager.shared.getAllProducts()
            self.products.sort { (prod1, prod2) -> Bool in
                prod1 < prod2
            }

            self.productsTableView.reloadData()
            refreshControl.endRefreshing()
        }
    }
}

// TABLEVIEW DELEGATE
extension ProductsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let productCode = products[indexPath.row]
        cell.textLabel?.text = "Code \(productCode)"
        cell.textLabel?.textAlignment = .center
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndexInTableView = indexPath.row
        performSegue(withIdentifier: "toProductScreen", sender: self)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}

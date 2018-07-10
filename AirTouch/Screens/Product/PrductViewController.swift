//
//  PrductViewController.swift
//  AirTouch
//
//  Created by Robert Tanase on 07/07/2018.
//  Copyright © 2018 AirTouch. All rights reserved.
//

import Foundation
import ProgressHUD
import UIKit

class ProductViewController: UIViewController {

    @IBOutlet weak var productCodeLabel: UILabel!
    @IBOutlet weak var transactionsTableView: UITableView!
    @IBOutlet weak var currencyTextField: UITextField!
    @IBOutlet weak var totalValueLabel: UILabel!

    var productCode: String!
    var transactions = [ProductTransaction]()
    var conversions = [ConversionRate]()
    var totalValue: Double?

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

        transactionsTableView.addSubview(self.refreshControl)
        transactionsTableView.delegate = self
        transactionsTableView.dataSource = self
        currencyTextField.resignFirstResponder()

        productCodeLabel.text = productCode

        transactions = DatabaseManager.shared.getTransactionsForProduct(withCode: productCode)
        conversions = DatabaseManager.shared.getConversionRates()
        let currencies = DatabaseManager.shared.getAllCurrencies()
        let extensionCurrencies = [""] + currencies

        currencyTextField.loadDropdownData(data: extensionCurrencies, delegate: self, currencyUsage: .from)
    }

    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        DatabaseUpdaterService.shared.updateConversionRates {
            DatabaseUpdaterService.shared.updateProductsTransactions {
                self.transactions = DatabaseManager.shared.getTransactionsForProduct(withCode: self.productCode)
                self.conversions = DatabaseManager.shared.getConversionRates()

                self.transactionsTableView.reloadData()
                refreshControl.endRefreshing()
            }
        }
    }

    private func calculateTotalAmount() {
        guard let selectedCurrency = currencyTextField.text, !selectedCurrency.isEmpty else {
            totalValueLabel.text?.removeAll()
            return
        }

        totalValue = transactions.reduce(0, { previousAmount, transaction -> Double in
            if transaction.currency == selectedCurrency {
                return previousAmount + transaction.amount
            }

            guard let matchcCnversion = conversions.first(where: { conversion -> Bool in
                conversion.fromCurrency == selectedCurrency && conversion.toCurrency == transaction.currency
            }) else {
                let newAmount = ConversionsBrain.calculateTrading(from: transaction, inCurrency: selectedCurrency)
                return previousAmount + newAmount
            }
            let ratio = matchcCnversion.rate
            let amountToAdd = ratio * transaction.amount
            return previousAmount + amountToAdd
        })

        if totalValue != nil {
            let roundValue = totalValue!.roundHalfToEven()
            totalValueLabel.text = "\(String(describing: roundValue))"
        } else {
            totalValueLabel.text?.removeAll()
        }
    }

    @IBAction func didPressBackButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

// TABLEVIEW EXTENSION
extension ProductViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transactions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionCellView") as? TransactionCellView else {
            return UITableViewCell()
        }
        cell.configure(withTransaction: transactions[indexPath.row])
        return cell
    }
}

// DROPDOWN DELEGATE EXTENSION
extension ProductViewController: DropDownDelegate {
    func didSelectOption(_ option: String, forUsage usage: CurrencyUsage) {
        currencyTextField.text = option
        calculateTotalAmount()
    }
}

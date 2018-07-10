//
//  TransactionCellView.swift
//  AirTouch
//
//  Created by Robert Tanase on 09/07/2018.
//  Copyright © 2018 AirTouch. All rights reserved.
//

import Foundation
import UIKit

class TransactionCellView: UITableViewCell {
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var currencyLabel: UILabel!

    func configure(withTransaction transaction: ProductTransaction) {
        amountLabel.text = "Amount: \(transaction.amount)"
        currencyLabel.text = "Currency: \(transaction.currency)"
    }
}

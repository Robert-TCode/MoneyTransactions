//
//  ViewController.swift
//  AirTouch
//
//  Created by Robert Tanase on 05/07/2018.
//  Copyright © 2018 AirTouch. All rights reserved.
//

import ProgressHUD
import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var syncingLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        ProgressHUD.show()
        syncingLabel.isHidden = false
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        dispatchGroup.enter()
        DatabaseUpdaterService.shared.updateConversionRates() {
            dispatchGroup.leave()
        }
        DatabaseUpdaterService.shared.updateProductsTransactions() {
            dispatchGroup.leave()
        }

        dispatchGroup.notify(queue: .main) {
            ProgressHUD.dismiss()
            self.syncingLabel.isHidden = true
        }
    }
}


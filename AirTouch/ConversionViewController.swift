//
//  ConversionViewController.swift
//  AirTouch
//
//  Created by Robert Tanase on 05/07/2018.
//  Copyright © 2018 AirTouch. All rights reserved.
//

import Foundation
import UIKit

class ConversionViewController: UIViewController {
    @IBOutlet weak var pickerTextField : UITextField!

    let salutations = ["", "Mr.", "Ms.", "Mrs."]

    override func viewDidLoad() {
        super.viewDidLoad()

        pickerTextField.loadDropdownData(data: salutations, delegate: self)
    }
}

extension ConversionViewController: DropDownDelegate {
    func didSelectOption(_ option: String) {
        pickerTextField.text = option
    }
}

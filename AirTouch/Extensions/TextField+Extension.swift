//
//  Extensions.swift
//  AirTouch
//
//  Created by Robert Tanase on 05/07/2018.
//  Copyright © 2018 AirTouch. All rights reserved.
//

import Foundation
import UIKit

extension UITextField {
    func loadDropdownData(data: [String]) {
        self.inputView = DropDownPickerView(pickerData: data,
                                            dropdownField: self)
    }
    func loadDropdownData(data: [String], delegate: DropDownDelegate, currencyUsage: CurrencyUsage) {
        self.inputView = DropDownPickerView(pickerData: data,
                                            dropdownField: self,
                                            currencyUsage: currencyUsage,
                                            delegate: delegate)
    }
}

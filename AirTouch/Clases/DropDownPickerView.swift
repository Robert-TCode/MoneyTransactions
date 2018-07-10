//
//  DropDownPickerView.swift
//  AirTouch
//
//  Created by Robert Tanase on 05/07/2018.
//  Copyright © 2018 AirTouch. All rights reserved.
//

import Foundation
import UIKit

public enum CurrencyUsage {
    case from
    case to
}

protocol DropDownDelegate: class {
    func didSelectOption(_ option: String, forUsage usage: CurrencyUsage)
}

class DropDownPickerView : UIPickerView, UIPickerViewDataSource, UIPickerViewDelegate {

    var currencyUsage: CurrencyUsage!
    var pickerData: [String]!
    var pickerTextField: UITextField!
    weak var dropDownDelegate: DropDownDelegate?

    init(pickerData: [String], dropdownField: UITextField) {
        super.init(frame: CGRect.zero)

        self.pickerData = pickerData
        self.pickerTextField = dropdownField

        self.delegate = self
        self.dataSource = self

        DispatchQueue.main.async {
            if pickerData.count > 0 {
                let initialOption = self.pickerData.first(where: { option -> Bool in
                    option == "EUR"
                })
                self.pickerTextField.text = initialOption ?? pickerData[0]
                self.pickerTextField.isEnabled = true
            } else {
                self.pickerTextField.text = nil
                self.pickerTextField.isEnabled = false
            }
            if self.pickerTextField.text != nil {
                self.dropDownDelegate?.didSelectOption(self.pickerTextField.text!, forUsage: self.currencyUsage)
            }
        }
    }

    convenience init(pickerData: [String], dropdownField: UITextField, currencyUsage: CurrencyUsage, delegate: DropDownDelegate) {
        self.init(pickerData: pickerData, dropdownField: dropdownField)
        self.currencyUsage = currencyUsage
        dropDownDelegate = delegate
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return pickerData.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickerTextField.text = pickerData[row]
        pickerTextField.resignFirstResponder()

        if self.pickerTextField.text != nil {
            dropDownDelegate?.didSelectOption(pickerTextField.text!, forUsage: currencyUsage)
        }
    }

}

//
//  DropDownPickerView.swift
//  AirTouch
//
//  Created by Robert Tanase on 05/07/2018.
//  Copyright © 2018 AirTouch. All rights reserved.
//

import Foundation
import UIKit

protocol DropDownDelegate: class {
    func didSelectOption(_ option: String)
}

class DropDownPickerView : UIPickerView, UIPickerViewDataSource, UIPickerViewDelegate {

    var pickerData : [String]!
    var pickerTextField : UITextField!
    weak var dropDownDelegate: DropDownDelegate?
    var selectionHandler : ((_ selectedText: String) -> Void)?

    init(pickerData: [String], dropdownField: UITextField) {
        super.init(frame: CGRect.zero)

        self.pickerData = pickerData
        self.pickerTextField = dropdownField

        self.delegate = self
        self.dataSource = self

        DispatchQueue.main.async {
            if pickerData.count > 0 {
                self.pickerTextField.text = self.pickerData[0]
                self.pickerTextField.isEnabled = true
            } else {
                self.pickerTextField.text = nil
                self.pickerTextField.isEnabled = false
            }
        }
        if self.pickerTextField.text != nil {
            dropDownDelegate?.didSelectOption(pickerTextField.text!)
        }
    }

    convenience init(pickerData: [String], dropdownField: UITextField, delegate: DropDownDelegate) {
        self.init(pickerData: pickerData, dropdownField: dropdownField)
        dropDownDelegate = delegate
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Sets number of columns in picker view
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    // Sets the number of rows in the picker view
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return pickerData.count
    }

    // This function sets the text of the picker view to the content of the "salutations" array
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    return pickerData[row]
    }

    // When user selects an option, this function will set the text of the text field to reflect
    // the selected option.
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickerTextField.text = pickerData[row]
        pickerTextField.resignFirstResponder()

        if self.pickerTextField.text != nil {
            dropDownDelegate?.didSelectOption(pickerTextField.text!)
        }
    }

}

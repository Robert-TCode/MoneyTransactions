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
    @IBOutlet weak var fromCurrencyPickerTextField : UITextField!
    @IBOutlet weak var toCurrencyPickerTextField: UITextField!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var resultLabel: UILabel!

    var currency = [String]()
    var tradeRates = [ConversionRate]()

    override func viewDidLoad() {
        super.viewDidLoad()

        amountTextField.delegate = self
        amountTextField.text = "1"

        tradeRates = DatabaseManager.shared.getConversionRates()
        currency = DatabaseManager.shared.getAllCurrencies()

        fromCurrencyPickerTextField.loadDropdownData(data: currency, delegate: self, currencyUsage: .from)
        toCurrencyPickerTextField.loadDropdownData(data: currency, delegate: self, currencyUsage: .to)
    }

    @IBAction func didPressBackButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func didChangeValue(_ sender: Any) {
        calculateTotal()
    }

    @IBAction func didPressSwitchCurrencies(_ sender: Any) {
        let fromCurrency = fromCurrencyPickerTextField.text
        fromCurrencyPickerTextField.text = toCurrencyPickerTextField.text
        toCurrencyPickerTextField.text = fromCurrency
        calculateTotal()
    }
}

// TEXTFIELD DELEGATE EXTENSION
extension ConversionViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.count > 9 {
            return false
        }
        var isNumber = true
        let digitSet = CharacterSet.decimalDigits
        for character in string.unicodeScalars {
            if var previous = textField.text, !previous.isEmpty {
                previous.removeLast()
                if character == "." && previous.contains(".") {
                    isNumber = false
                    continue
                }
            }
            if !digitSet.contains(character) && character != "." {
                isNumber = false
            }
        }
        if isNumber {
            calculateTotal()
        }
        return isNumber
    }

    func calculateTotal() {
        guard let fromCurrency = fromCurrencyPickerTextField.text,
            let toCurrency = toCurrencyPickerTextField.text,
            let amountString = amountTextField.text
            else {
                return
        }
        if let correspondentTradeRate = tradeRates.first(where: {
            $0.fromCurrency == fromCurrency && $0.toCurrency == toCurrency
        }) {
            let tradeRatio: Double = correspondentTradeRate.rate
            if let amount = Double(amountString) {
                var total = amount * tradeRatio
                let rounded = total.roundHalfToEven()
                resultLabel.text = "\(rounded)"
            } else {
                resultLabel.text = ""
            }
        } else {
            if let amount = Double(amountString) {
                let transaction = ProductTransaction(code: "", currency: fromCurrency, amount: amount)
                var value = ConversionsBrain.calculateTrading(from: transaction,
                                                              inCurrency: toCurrency)
                let rounded = value.roundHalfToEven()
                resultLabel.text = "\(rounded)"
            } else {
                resultLabel.text = ""
            }
        }
    }
}

// DROPDOWN DELEGATE EXTENSION
extension ConversionViewController: DropDownDelegate {
    func didSelectOption(_ option: String, forUsage usage: CurrencyUsage) {
        if usage == .from {
            fromCurrencyPickerTextField.text = option
            calculateTotal()
        } else {
            toCurrencyPickerTextField.text = option
            calculateTotal()
        }
    }
}

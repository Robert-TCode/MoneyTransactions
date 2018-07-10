//
//  TradeRate.swift
//  AirTouch
//
//  Created by Robert Tanase on 06/07/2018.
//  Copyright © 2018 AirTouch. All rights reserved.
//

import Foundation
import RealmSwift

class ConversionRate: Object {
    @objc dynamic private(set) var rate: Double = 0
    @objc dynamic private(set) var fromCurrency: String = ""
    @objc dynamic private(set) var toCurrency: String = ""
    @objc dynamic var compoundKey: String = ""

    convenience init(fromCurrency: String,
                     toCurrency: String,
                     rate: Double) {
        self.init()
        self.fromCurrency = fromCurrency
        self.toCurrency = toCurrency
        self.compoundKey = compoundKeyValue()
        self.rate = rate
    }

    func setCompoundFromCurrency(fromCurrency: String) {
        self.fromCurrency = fromCurrency
        compoundKey = compoundKeyValue()
    }

    func setCompoundToCurrency(toCurrency: String) {
        self.toCurrency = toCurrency
        compoundKey = compoundKeyValue()
    }

    func compoundKeyValue() -> String {
        return "\(fromCurrency)\(toCurrency)"
    }

    override static func primaryKey() -> String? {
        return "compoundKey"
    }
}

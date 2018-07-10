//
//  ProductTransaction.swift
//  AirTouch
//
//  Created by Robert Tanase on 09/07/2018.
//  Copyright © 2018 AirTouch. All rights reserved.
//

import Foundation
import RealmSwift

class ProductTransaction: Object {
    @objc dynamic private(set) var uuid: String = ""
    @objc dynamic private(set) var code: String = ""
    @objc dynamic private(set) var amount: Double = 0
    @objc dynamic private(set) var currency: String = ""

    convenience init(code: String,
                     currency: String,
                     amount: Double) {
        self.init()
        self.uuid = UUID().uuidString
        self.currency = currency
        self.code = code
        self.amount = amount
    }

    override static func primaryKey() -> String? {
        return "uuid"
    }
}

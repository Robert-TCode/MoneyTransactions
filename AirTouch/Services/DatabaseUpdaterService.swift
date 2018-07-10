//
//  DatabaseUpdaterService.swift
//  AirTouch
//
//  Created by Robert Tanase on 09/07/2018.
//  Copyright © 2018 AirTouch. All rights reserved.
//

import Alamofire
import Foundation
import RealmSwift

class DatabaseUpdaterService {
    private init() { }
    public static let shared = DatabaseUpdaterService()

    let databaseManager = DatabaseManager.shared

    public func updateConversionRates(completion: @escaping () -> Void) {

        // url
        guard let url = URL(string: "http://gnb.dev.airtouchmedia.com/rates.json") else {
            print("Conversion Rate has an unvalid url")
            completion()
            return
        }

        // request
        let request = Alamofire.SessionManager.default.request(url,
                                                               parameters: nil,
                                                               encoding: JSONEncoding.default,
                                                               headers: nil)
            .validate()

        request.responseJSON(queue: DispatchQueue.global(qos: .background)) { response -> Void in
            guard response.result.isSuccess else {
                completion()
                return
            }
            guard let objects = response.result.value as? [[String: AnyObject]] else {
                print("Unexpected response format in JSON")
                completion()
                return
            }

            let dispatchGroup = DispatchGroup()
            for object in objects {
                dispatchGroup.enter()

                guard let from = object["from"] as? String,
                    let to = object["to"] as? String,
                    let rateString = object["rate"] as? String,
                    let rate = Double(rateString) else {
                        print("Unexpected object format")
                        print(object)
                        dispatchGroup.leave()
                        continue
                }
                self.databaseManager.internalQueue.async {
                    let conversionRate = ConversionRate(fromCurrency: from,
                                                        toCurrency: to,
                                                        rate: rate)
                    self.databaseManager.add(conversionRate)
                    let reverseConverionRate = ConversionRate(fromCurrency: to,
                                                              toCurrency: from,
                                                              rate: 1/rate)
                    self.databaseManager.add(reverseConverionRate)
                }
                dispatchGroup.leave()
            }

            dispatchGroup.notify(queue: .main) {
                completion()
            }
        }
    }

    public func updateProductsTransactions(completion: @escaping () -> Void) {
        // url
        guard let url = URL(string: "http://gnb.dev.airtouchmedia.com/transactions.json") else {
            print("Conversion Rate has an unvalid url")
            completion()
            return
        }

        // request
        let request = Alamofire.SessionManager.default.request(url,
                                                               parameters: nil,
                                                               encoding: JSONEncoding.default,
                                                               headers: nil)
            .validate()

        request.responseJSON(queue: DispatchQueue.global(qos: .background)) { response -> Void in
            guard response.result.isSuccess else {
                completion()
                return
            }
            guard let objects = response.result.value as? [[String: AnyObject]] else {
                print("Unexpected response format in JSON")
                completion()
                return
            }

            self.databaseManager.internalQueue.async {
                let previousTransactions = self.databaseManager.getProductsTransactions()
                self.databaseManager.delete(previousTransactions)
            }

            let dispatchGroup = DispatchGroup()
            for object in objects {
                dispatchGroup.enter()

                guard let code = object["sku"] as? String,
                    let amountString = object["amount"] as? String,
                    let amount = Double(amountString),
                    let currency = object["currency"] as? String else {
                        print("Unexpected object format")
                        print(object)
                        dispatchGroup.leave()
                        continue
                }

                self.databaseManager.internalQueue.async {
                    let transation = ProductTransaction(code: code,
                                                        currency: currency,
                                                        amount: amount)
                    self.databaseManager.add(transation)
                }
                dispatchGroup.leave()
            }

            dispatchGroup.notify(queue: .main) {
                completion()
            }
        }
    }
}

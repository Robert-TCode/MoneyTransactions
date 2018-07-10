//
//  DatabaseManager.swift
//  AirTouch
//
//  Created by Robert Tanase on 09/07/2018.
//  Copyright © 2018 AirTouch. All rights reserved.
//

import Foundation
import RealmSwift

class DatabaseManager {
    private init() { }
    public static let shared = DatabaseManager()

    var realm: Realm! {
        do {
            return try Realm()
        } catch let error as NSError {
            print(error)
            preconditionFailure("Could not instanciate Realm")
        }
    }

    let internalQueue = DispatchQueue(label: "DatabaseManager::internal")
    let externalQueue = DispatchQueue(label: "DatabaseManager::external")
}

// BASE OPERATIONS
extension DatabaseManager {
    func write(_ block: @escaping () -> Void, completion: (() -> Void)? = nil ) {
        internalQueue.async {
            do {
                try self.realm.write {
                    block()
                }
            } catch let error as NSError {
                print(error)
            }

            self.externalQueue.async {
                completion?()
            }
        }
    }

    func add(_ object: Object, completion: (() -> Void)? = nil) {
        write({
            self.realm.add(object, update: true)
        }, completion: completion)
    }

    func add(_ objects: [Object], completion: (() -> Void)? = nil) {
        write({
            objects.forEach { self.realm.add($0, update: true) }
        }, completion: completion)
    }

    func delete(_ object: Object, completion: (() -> Void)? = nil) {
        write({
            self.realm.delete(object)
        }, completion: completion)
    }

    func delete(_ objects: [Object], completion: (() -> Void)? = nil) {
        write({
            self.realm.delete(objects)
        }, completion: completion)
    }
}

// OBJECTS FUNCTIONS
extension DatabaseManager {
    func getConversionRates() -> [ConversionRate] {
        let conversions = realm.objects(ConversionRate.self).sorted(byKeyPath: "fromCurrency", ascending: true)
        return Array(conversions)
    }

    func getAllCurrencies() -> [String] {
        let conversions = Array(realm.objects(ConversionRate.self).sorted(byKeyPath: "fromCurrency", ascending: true))
        var currencies = [String]()
        for conversion in conversions {
            if !currencies.contains(conversion.fromCurrency) {
                currencies.append(conversion.fromCurrency)
            }
            if !currencies.contains(conversion.toCurrency) {
                currencies.append(conversion.toCurrency)
            }
        }
        return currencies
    }

    func getProductsTransactions() -> [ProductTransaction] {
        let transactions = realm.objects(ProductTransaction.self).sorted(byKeyPath: "code", ascending: true)
        return Array(transactions)
    }

    func getAllProducts() -> [String] {
        let transactions = realm.objects(ProductTransaction.self).sorted(byKeyPath: "code", ascending: true)
            .map { $0.code }
        return transactions.reduce(into: []) { uniqueElements, element in
            if !uniqueElements.contains(element) {
                uniqueElements.append(element)
            }
        }
    }

    func getTransactionsForProduct(withCode code: String) -> [ProductTransaction] {
        let transactions = realm.objects(ProductTransaction.self).filter { $0.code == code }
        return Array(transactions)
    }
}





















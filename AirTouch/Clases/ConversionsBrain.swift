//
//  ConversionsBrain.swift
//  AirTouch
//
//  Created by Robert Tanase on 09/07/2018.
//  Copyright © 2018 AirTouch. All rights reserved.
//

import Foundation

class ConversionsBrain {
    public static func calculateTrading(from transaction: ProductTransaction, inCurrency finalCurrency: String) -> Double {
        let tradeCurrency = transaction.currency
        let conversions = DatabaseManager.shared.getConversionRates()

        var queue: [ConversionRate] = []
        var k = 0
        while k < conversions.count {
            k += 1
            for conversion in conversions {
                if queue.isEmpty {
                    if conversion.fromCurrency == tradeCurrency {
                        queue.append(conversion)
                        if conversion.toCurrency == finalCurrency {
                            break
                        }
                    }
                } else {
                    if conversion.fromCurrency == queue.last?.toCurrency &&
                        conversion.toCurrency == finalCurrency {
                        queue.append(conversion)
                        if conversion.toCurrency == finalCurrency {
                            break
                        }
                    }
                }
            }
        }

        if queue.isEmpty {
            print("Cannot fount a conversion between \(tradeCurrency) and \(finalCurrency)")
            return 0
        }

        var currentValue = transaction.amount
        for conversion in queue {
            currentValue = currentValue * conversion.rate
        }

        return currentValue
    }
}

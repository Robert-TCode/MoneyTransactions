//
//  Double+Extension.swift
//  AirTouch
//
//  Created by Robert Tanase on 10/07/2018.
//  Copyright © 2018 AirTouch. All rights reserved.
//

import Foundation

// ROUNDING EXTENSION
extension Double {
    mutating func roundHalfToEven() -> Double {
        let remainder = self.truncatingRemainder(dividingBy: 1) * 100
        let integer = Int(self)
        let goodRemainder = lrint(remainder)
        let sum = integer * 100 + goodRemainder
        let rounded = Double (sum) / 100 + 0.001
        return rounded.truncate(places: 2)
    }

    func truncate(places : Int) -> Double {
        return Double(floor(pow(10.0, Double(places)) * self)/pow(10.0, Double(places)))
    }
}

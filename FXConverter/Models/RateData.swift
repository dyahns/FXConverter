//
//  RateData.swift
//  FXConverter
//
//  Created by D Yahns on 12/10/2018.
//

import Foundation

struct RateData: Codable {
    let base: String
    private let rates: [String: Double]
    
    var currencyCodes: [String] {
        return [base] + rates.keys.sorted()
    }

    var allRates: [String: Double] {
        return rates.merging([base: 1], uniquingKeysWith: { $1 })
    }

}

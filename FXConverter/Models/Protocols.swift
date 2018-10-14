//
//  Protocols.swift
//  FXConverter
//
//  Created by D Yahns on 12/10/2018.
//

import Foundation

protocol RateDataConsumer: class {
    // push new rates
    func updateRates(with rateData: RateData)
}

protocol ConversionProvider {
    func converting(amount: Double, from currencyCode: String)
    func converted(to currencyCode: String) -> Double?
}

protocol ConversionConsumer: class {
    // notify consumer that data have changed
    // passing in the list of currencies in case it changed
    func dataChanged(with codes: [String])
}

//
//  Converter.swift
//  FXConverter
//
//  Created by D Yahns on 12/10/2018.
//

import Foundation

class Converter {
    weak var delegate: ConversionConsumer?
    
    private var rates: [String: Double] = [:]
    private var amount: Double = 1
    private var sourceCurrencyCode = ""
}

extension Converter: RateDataConsumer {
    func updateRates(with rateData: RateData) {
        rates = rateData.allRates
        if sourceCurrencyCode.isEmpty {
            sourceCurrencyCode = rateData.base
        }
        
        DispatchQueue.main.async {
            self.delegate?.dataChanged(with: rateData.currencyCodes)
        }
    }
}

extension Converter: ConversionProvider {
    func converting(amount: Double, from currencyCode: String) {
        self.amount = amount
        self.sourceCurrencyCode = currencyCode
    }
    
    func converted(to currencyCode: String) -> Double? {
        guard let targetRate = rates[currencyCode], let sourceRate = rates[sourceCurrencyCode], sourceRate != 0 else {
            return nil
        }
        
        return amount * targetRate / sourceRate
    }
}

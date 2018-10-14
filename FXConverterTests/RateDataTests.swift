//
//  RateDataTests.swift
//  FXConverterTests
//
//  Created by D Yahns on 12/10/2018.
//

import XCTest
@testable import FXConverter

class RateDataTests: XCTestCase {
    static let apiResponse = "{\"base\":\"EUR\",\"date\":\"2018-09-06\",\"rates\":{\"AUD\":1.6135,\"BGN\":1.9523,\"BRL\":4.7832,\"CAD\":1.5311,\"CHF\":1.1255,\"CNY\":7.9309,\"CZK\":25.669,\"DKK\":7.4433,\"GBP\":0.89663,\"HKD\":9.116,\"HRK\":7.4208,\"HUF\":325.9,\"IDR\":17292.0,\"ILS\":4.1631,\"INR\":83.567,\"ISK\":127.57,\"JPY\":129.32,\"KRW\":1302.4,\"MXN\":22.325,\"MYR\":4.8034,\"NOK\":9.7585,\"NZD\":1.7601,\"PHP\":62.48,\"PLN\":4.3106,\"RON\":4.6302,\"RUB\":79.432,\"SEK\":10.572,\"SGD\":1.5971,\"THB\":38.062,\"TRY\":7.6145,\"USD\":1.1613,\"ZAR\":17.791}}".data(using: .utf8)!
    
    static let rateData: RateData! = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try? decoder.decode(RateData.self, from: RateDataTests.apiResponse)
    }()
    
    var rateData: RateData! = RateDataTests.rateData
    
    func testRateDataCanInitialiseFromApi() {
        XCTAssertNotNil(rateData)
        XCTAssertEqual(rateData?.base, "EUR")
        XCTAssertEqual(rateData?.allRates["USD"], 1.1613)
    }

    func testRateDataReturnsCurrencyCodes() {
        let codes = rateData.currencyCodes
        XCTAssertEqual(codes.count, rateData.allRates.count)
        XCTAssertNotNil(codes.contains(rateData.base))
    }

    func testRateDataReturnsAllRates() {
        let rates = rateData.allRates
        let baseRate = rates[rateData.base]
        XCTAssertEqual(rates.count, rateData.currencyCodes.count)
        XCTAssertNotNil(baseRate)
        XCTAssertEqual(baseRate, 1)
    }
    
}

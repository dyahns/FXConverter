//
//  ConverterTests.swift
//  FXConverterTests
//
//  Created by D Yahns on 13/10/2018.
//

import XCTest
@testable import FXConverter

class ConverterTests: XCTestCase {
    var converter: Converter!
    
    override func setUp() {
        converter = Converter()
        converter.updateRates(with: RateDataTests.rateData)
    }
    
    func testConvertingWithoutSourceToBaseReturnsOne() {
        let amount = converter.converted(to: RateDataTests.rateData.base)
        XCTAssertEqual(amount, 1)
    }

    func testConvertingWithoutSourceReturnsRate() {
        let amount = converter.converted(to: "USD")
        XCTAssertEqual(amount, 1.1613)
    }
    
    func testConvertingFromInvalidCurrencyReturnsNil() {
        converter.converting(amount: 10, from: "XXX")
        let amount = converter.converted(to: "GBP")
        XCTAssertNil(amount)
    }

    func testConvertingToInvalidCurrencyReturnsNil() {
        converter.converting(amount: 10, from: "GBP")
        let amount = converter.converted(to: "XXX")
        XCTAssertNil(amount)
    }
    
    func testConvertingZeroAmountReturnsZero() {
        converter.converting(amount: 0, from: "USD")
        let amount = converter.converted(to: "GBP")
        XCTAssertEqual(amount, 0)
    }
    
    func testConvertingFromBaseCurrencyReturnsCorrectAmount() {
        converter.converting(amount: 10, from: RateDataTests.rateData.base)
        let amount = converter.converted(to: "GBP")
        XCTAssertEqual(amount, 8.9663)
    }

    func testConvertingToBaseCurrencyReturnsCorrectAmount() {
        let sourceAmount = 10.0
        converter.converting(amount: sourceAmount, from: "GBP")
        let amount = converter.converted(to: RateDataTests.rateData.base)
        XCTAssertEqual(amount, sourceAmount / 0.89663)
    }

    func testConvertingBetweenNonBaseCurrenciesReturnsCorrectAmount() {
        let sourceAmount = 10.0
        converter.converting(amount: sourceAmount, from: "GBP")
        let amount = converter.converted(to: "USD")
        XCTAssertEqual(amount, sourceAmount * 1.1613 / 0.89663)
    }

    func testUpdatingRateDataConsumerNotifiesConversionConsumer() {
        let notified = XCTestExpectation(description: "Conversion consumer notified")
        let conversionConsumer = TestConversionConsumer(expectation: notified)
        converter.delegate = conversionConsumer
        
        // after assigning delegate
        converter.updateRates(with: RateDataTests.rateData)
        wait(for: [notified], timeout: 1.0)
    }
}

class ConverterWithNoRateDataTests: XCTestCase {
    var converter: Converter!
    
    override func setUp() {
        converter = Converter()
    }
    
    func testConvertingWithoutRateDataReturnsNil() {
        let eur = converter.converted(to: "EUR")
        XCTAssertNil(eur)

        let usd = converter.converted(to: "USD")
        XCTAssertNil(usd)

        let xxx = converter.converted(to: "XXX")
        XCTAssertNil(xxx)
    }
}

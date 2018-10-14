//
//  TestConversionConsumer.swift
//  FXConverterTests
//
//  Created by D Yahns on 13/10/2018.
//

import XCTest
@testable import FXConverter

class TestConversionConsumer: ConversionConsumer {
    let expectation: XCTestExpectation
    
    init(expectation: XCTestExpectation) {
        self.expectation = expectation
    }
    
    func dataChanged(with codes: [String]) {
        expectation.fulfill()
    }
}

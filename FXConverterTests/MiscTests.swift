//
//  MiscTests.swift
//  FXConverterTests
//
//  Created by D Yahns on 12/10/2018.
//

import XCTest
@testable import FXConverter

class MiscTests: XCTestCase {

    func testArrayCanMoveElementToTop() {
        var array = [1, 2, 3]
        array.moveToTop(from: 2)
        XCTAssertEqual(array, [3, 1, 2])
    }

}

//
//  ArrayExtension.swift
//  FXConverter
//
//  Created by D Yahns on 12/10/2018.
//

import Foundation

extension Array {
    mutating func moveToTop(from index: Int) {
        let element = self.remove(at: index)
        self.insert(element, at: 0)
    }
}

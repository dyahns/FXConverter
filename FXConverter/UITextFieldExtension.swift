//
//  UITextFieldExtension.swift
//  FXConverter
//
//  Created by D Yahns on 13/10/2018.
//

import UIKit

extension UITextField {
    func becomeInput(in delegate: UITextFieldDelegate) {
        guard !isFirstResponder else {
            return
        }
        
        self.delegate = delegate
        addTarget(delegate, action: #selector(ViewController.inputChanged(textField:)), for: UIControl.Event.editingChanged)
        becomeFirstResponder()
    }
}

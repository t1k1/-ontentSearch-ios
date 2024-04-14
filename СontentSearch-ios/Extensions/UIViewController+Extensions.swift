//
//  UIViewController+Extensions.swift
//  СontentSearch-ios
//
//  Created by Aleksey Kolesnikov on 08.04.2024.
//

import UIKit

extension UIViewController {
    
    func hideKeyboardWhenTappedAround(cancelsTouchesInView: Bool = false) {
        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(UIViewController.dismissKeyboard)
        )
        tap.cancelsTouchesInView = cancelsTouchesInView
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

//
//  AlertPresenter.swift
//  СontentSearch-ios
//
//  Created by Aleksey Kolesnikov on 14.04.2024.
//

import UIKit

protocol AlertPresentableDelagate: AnyObject {
    func present(alert: UIAlertController, animated flag: Bool)
}

protocol AlertPresenterProtocol: AnyObject {
    func show(_ alertArgs: AlertModel)
}

final class AlertPresenter {
    private weak var delagate: AlertPresentableDelagate?
    
    init(delagate: AlertPresentableDelagate?) {
        self.delagate = delagate
    }
}

extension AlertPresenter: AlertPresenterProtocol {
    func show(_ alertArgs: AlertModel) {
        let alert = UIAlertController(title: alertArgs.title,
                                      message: alertArgs.message,
                                      preferredStyle: .alert)
        
        let action = UIAlertAction(title: alertArgs.buttonText, style: .default)
        
        alert.addAction(action)
        delagate?.present(alert: alert, animated: true)
    }
}

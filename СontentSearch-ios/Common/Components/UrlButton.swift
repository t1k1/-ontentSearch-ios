//
//  UrlButton.swift
//  СontentSearch-ios
//
//  Created by Aleksey Kolesnikov on 14.04.2024.
//

import UIKit

final class UrlButton: UIButton {
    init(
        title: String = ""
    ) {
        
        super.init(frame: .zero)
        setupLabel(title: title)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLabel(title: String) {
        translatesAutoresizingMaskIntoConstraints = false
        
        setTitle(title, for: .normal)
        setTitleColor(.systemBlue, for: .normal)
        titleLabel?.font = .systemFont(ofSize: 15, weight: .regular)
        titleLabel?.textAlignment = .left
        titleLabel?.adjustsFontSizeToFitWidth = true
    }
}

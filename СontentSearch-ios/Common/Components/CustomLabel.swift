//
//  CustomLabel.swift
//  СontentSearch-ios
//
//  Created by Aleksey Kolesnikov on 13.04.2024.
//

import UIKit

final class CustomLabel: UILabel {
    init(text: String = "", fontSize: CGFloat = 14, numberOfLines: Int = 1) {
        super.init(frame: .zero)
        setupLabel(text: text, fontSize: fontSize, numberOfLines: numberOfLines)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLabel(text: String, fontSize: CGFloat, numberOfLines: Int) {
        translatesAutoresizingMaskIntoConstraints = false
        
        textColor = .black
        font = .systemFont(ofSize: fontSize)
        textAlignment = .left
        self.text = text
        self.numberOfLines = numberOfLines
    }
}

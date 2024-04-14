//
//  CustomFlowLayout.swift
//  СontentSearch-ios
//
//  Created by Aleksey Kolesnikov on 08.04.2024.
//

import UIKit

final class CustomFlowLayout: UICollectionViewFlowLayout {
    override func prepare() {
        super.prepare()
        
        guard let collectionView = collectionView else { return }
        
        minimumInteritemSpacing = 10
        minimumLineSpacing = 10
        sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        let sideSize = (collectionView.frame.width - 30) / 2
        itemSize = CGSize(width: sideSize, height: sideSize + 80)
    }
}

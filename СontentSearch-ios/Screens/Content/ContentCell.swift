//
//  ContentCell.swift
//  СontentSearch-ios
//
//  Created by Aleksey Kolesnikov on 08.04.2024.
//

import UIKit

final class ContentCell: UICollectionViewCell {
    
    //MARK: Public functions
    
    static let cellName = "contentCell"
    weak var delegate: ContentViewControllerDelegate?
    
    //MARK: Layout variables
    
    private lazy var previewImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.image = UIImage(named: "Placeholder")
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 16
        imageView.clipsToBounds = true
        
        return imageView
    }()
    private lazy var kindLAbel = CustomLabel()
    private lazy var durationLabel = CustomLabel()
    private lazy var nameLabel = CustomLabel(numberOfLines: 2)
    private lazy var costLabel = CustomLabel()
    
    //MARK: Private variables
    
    private var contentService = ContentService.shared
    
    //MARK: Public functions
    
    func configureCell(contentItem: ContentModel) {
        backgroundColor = .white
        layer.cornerRadius = 16
        layer.borderWidth = 1
        layer.borderColor = UIColor(named: "CellBorderColor")?.cgColor
        
        if let artworkUrl100 = contentItem.artworkUrl100 {
            contentService.fetchImage(urlString: artworkUrl100) { [weak self] result in
                guard let self = self else {return }
                
                switch result {
                    case .success(let image):
                        DispatchQueue.main.async {
                            self.previewImageView.image = image
                        }
                    case .failure(let error):
                        DispatchQueue.main.async { [weak self] in
                            self?.delegate?.searchErrorAlert(error: error.localizedDescription)
                        }
                }
            }
        }
        
        kindLAbel.text = (contentItem.kind == "feature-movie" ? "MOVIE" : contentItem.kind)?.uppercased()
        nameLabel.text = contentItem.trackName
        costLabel.text = "\(contentItem.trackPrice ?? 0)$"
        durationLabel.text = TimeConverter.convertMillis(contentItem.trackTimeMillis ?? 0, contentKind: kindLAbel.text)
        
        addSubviews()
        configureConstraints()
    }
}

//MARK: Private functions

private extension ContentCell {
    func addSubviews() {
        addSubview(previewImageView)
        addSubview(kindLAbel)
        addSubview(durationLabel)
        addSubview(nameLabel)
        addSubview(costLabel)
    }
    
    func configureConstraints() {
        NSLayoutConstraint.activate([
            previewImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            previewImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            previewImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            previewImageView.widthAnchor.constraint(equalToConstant: contentView.bounds.width),
            previewImageView.heightAnchor.constraint(equalToConstant: contentView.bounds.width),
            
            kindLAbel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            kindLAbel.widthAnchor.constraint(equalToConstant: 70),
            kindLAbel.topAnchor.constraint(equalTo: previewImageView.bottomAnchor),
            
            durationLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            durationLabel.topAnchor.constraint(equalTo: kindLAbel.topAnchor),
            
            nameLabel.leadingAnchor.constraint(equalTo: kindLAbel.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            nameLabel.topAnchor.constraint(equalTo: kindLAbel.bottomAnchor, constant: 4),
            nameLabel.widthAnchor.constraint(equalToConstant: contentView.bounds.width),
            
            costLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            costLabel.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor, constant: -4)
        ])
    }
}

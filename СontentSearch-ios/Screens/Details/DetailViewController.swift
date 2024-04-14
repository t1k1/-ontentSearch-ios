//
//  DetailViewController.swift
//  СontentSearch-ios
//
//  Created by Aleksey Kolesnikov on 12.04.2024.
//

import UIKit

final class DetailViewController: UIViewController {   
    
    //MARK: Layout variables
    
    private lazy var posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.image = UIImage(named: "Placeholder")
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        return scrollView
    }()
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 12
        
        return stackView
    }()
    private lazy var nameLabel = CustomLabel(fontSize: 18, numberOfLines: 0, weight: .bold, textAlignment: .center)
    private lazy var authorNameLabel = CustomLabel()
    private lazy var contentTypeLabel = CustomLabel()
    private lazy var durationLabel = CustomLabel()
    private lazy var contentPageButton = UrlButton(title: "Перейти на страницу медиаконтента")
    private lazy var authorPageButton = UrlButton(title: "Перейти на страницу автора")
    private lazy var descriptionTextView = CustomLabel(numberOfLines: 0)
    
    //MARK: Private variables
    
    private var alertPresenter: AlertPresenterProtocol?
    private let contentService = ContentService.shared
    private let contentItem: ContentModel
    private var urlContentPage: String?
    private var urlAuthorPage: String?
    
    //MARK: Initialization
    
    init(contentItem: ContentModel) {
        self.contentItem = contentItem
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Lyfecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        alertPresenter = AlertPresenter(delagate: self)
        configureView()
    }
}

//MARK: AlertPresentableDelagate

extension DetailViewController: AlertPresentableDelagate {
    func present(alert: UIAlertController, animated flag: Bool) {
        present(alert, animated: flag)
    }
}

//MARK: Private functions

private extension DetailViewController {
    func configureView() {
        view.backgroundColor = .white
        
        getImage()
        nameLabel.text = contentItem.trackName
        authorNameLabel.text = "Author: \(contentItem.artistName ?? "")"
        
        var kind = contentItem.kind ?? ""
        kind = kind == "feature-movie" ? "movie" : kind
        contentTypeLabel.text = "Type: \(kind)"
        
        let duration = TimeConverter.convertMillis(contentItem.trackTimeMillis ?? 0, contentKind: kind.uppercased())
        durationLabel.text = "Duration: \(duration)"
        
        urlContentPage = contentItem.trackViewUrl
        if let _ = urlContentPage {
            contentPageButton.addTarget(self, action: #selector(openContentPage), for: .touchUpInside)
        } else {
            contentPageButton.isHidden = true
        }
        
        urlAuthorPage = contentItem.artistViewUrl
        if let _ = urlAuthorPage {
            authorPageButton.addTarget(self, action: #selector(openAutorPage), for: .touchUpInside)
        } else {
            authorPageButton.isHidden = true
        }
        
        if let description = contentItem.longDescription {
            descriptionTextView.text = "Description: \(description)"
        } else if let description = contentItem.description {
            descriptionTextView.text = "Description: \(description)"
        } else if let description = contentItem.shortDescription {
            descriptionTextView.text = "Description: \(description)"
        }
        
        addSubViews()
        configureConstrains()
        scrollView.contentSize = CGSize(width: view.frame.width, height: stackView.frame.height)
    }
    
    func getImage() {
        if let artworkUrl100 = contentItem.artworkUrl100 {
            contentService.fetchImage(urlString: artworkUrl100) { [weak self] result in
                guard let self = self else {return }
                
                switch result {
                    case .success(let image):
                        DispatchQueue.main.async {
                            self.posterImageView.image = image
                        }
                    case .failure(let error):
                        DispatchQueue.main.async { [weak self] in
                            guard let self = self else { return }
                            self.alertPresenter?.show(
                                AlertModel(
                                    title: "Error!",
                                    message: error.localizedDescription,
                                    buttonText: "OK")
                            )
                        }
                }
            }
        }
    }
    
    @objc
    func openContentPage() {
        guard let urlContentPage = urlContentPage else { return }
        let webViewViewController = WebViewViewController(urlString: urlContentPage)
        webViewViewController.hidesBottomBarWhenPushed = true
        
        navigationController?.pushViewController(webViewViewController, animated: true)
    }
    
    @objc
    func openAutorPage() {
        guard let urlAuthorPage = urlAuthorPage else { return }
        let webViewViewController = WebViewViewController(urlString: urlAuthorPage)
        webViewViewController.hidesBottomBarWhenPushed = true
        
        navigationController?.pushViewController(webViewViewController, animated: true)
    }
    
    func addSubViews() {
        view.addSubview(posterImageView)
        view.addSubview(scrollView)
        
        scrollView.addSubview(stackView)
        
        stackView.addArrangedSubview(nameLabel)
        stackView.addArrangedSubview(authorNameLabel)
        stackView.addArrangedSubview(contentTypeLabel)
        stackView.addArrangedSubview(durationLabel)
        stackView.addArrangedSubview(contentPageButton)
        stackView.addArrangedSubview(authorPageButton)
        stackView.addArrangedSubview(descriptionTextView)
    }
    
    func configureConstrains() {
        NSLayoutConstraint.activate([
            posterImageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            posterImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            posterImageView.heightAnchor.constraint(equalToConstant: 300),
            
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            scrollView.topAnchor.constraint(equalTo: posterImageView.bottomAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            nameLabel.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
            nameLabel.topAnchor.constraint(equalTo: stackView.topAnchor),
            
            authorNameLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            authorNameLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            authorNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor),
            
            contentTypeLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            contentTypeLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            contentTypeLabel.topAnchor.constraint(equalTo: authorNameLabel.bottomAnchor),
            
            durationLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            durationLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            durationLabel.topAnchor.constraint(equalTo: contentTypeLabel.bottomAnchor),
            
            contentPageButton.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            contentPageButton.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            contentPageButton.topAnchor.constraint(equalTo: durationLabel.bottomAnchor),
            
            authorPageButton.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            authorPageButton.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            authorPageButton.topAnchor.constraint(equalTo: contentPageButton.bottomAnchor),
            
            descriptionTextView.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            descriptionTextView.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            descriptionTextView.topAnchor.constraint(equalTo: authorPageButton.bottomAnchor)
        ])
    }
}

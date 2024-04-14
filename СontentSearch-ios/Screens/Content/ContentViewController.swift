//
//  ContentViewController.swift
//  СontentSearch-ios
//
//  Created by Aleksey Kolesnikov on 06.04.2024.
//

import UIKit

protocol ContentViewControllerDelegate: AnyObject {
    func search(_ searchStr: String)
}

final class ContentViewController: UIViewController {
    
    private lazy var collectionView: UICollectionView = {
        let collectionViewLayout = CustomFlowLayout()
        
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: collectionViewLayout
        )
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .white
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.alwaysBounceVertical = true
        
        return collectionView
    }()
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let loadingIndicator = UIActivityIndicatorView(style: .medium)
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        loadingIndicator.hidesWhenStopped = true
        
        return loadingIndicator
    }()
    
    private var searchController: UISearchController?
    private var content: [ContentModel] = []
    private var searchHistory: [String] = []
    private let userDefaultsManager = UserDefaultsService.shared
    private let contentService = ContentService.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
}

//MARK: UISearchResultsUpdating

extension ContentViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchBarText = searchController.searchBar.text,
              let searchResultsController = searchController.searchResultsController as? SearchHistoryViewController else {
            return
        }
        searchResultsController.updateSearchHistory(
            with: searchHistory.filter { $0.lowercased().contains(searchBarText.lowercased()) }
        )
    }
}

extension ContentViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchBarText = searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines), !searchBarText.isEmpty {
            
            loadContent(with: searchBarText)
            
            if !searchHistory.contains(where: { $0.lowercased() == searchBarText.lowercased() }) {
                searchHistory.insert(searchBarText, at: 0)
                if searchHistory.count > 5 {
                    searchHistory.removeLast()
                }
                saveSearchHistory()
            }
            searchController?.dismiss(animated: true)
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        content.removeAll()
        collectionView.reloadData()
    }
}

extension ContentViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        showDetails()
    }
}

extension ContentViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return content.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ContentCell.cellName,
            for: indexPath
        ) as? ContentCell
        
        guard let cell = cell else { return UICollectionViewCell() }
        
        cell.configureCell(contentItem: content[indexPath.row])
        
        return cell
    }
}

extension ContentViewController: ContentViewControllerDelegate {
    func search(_ searchStr: String) {
        searchController?.searchBar.text = searchStr
        loadContent(with: searchStr)
    }
}

private extension ContentViewController {
    func loadContent(with searchText: String) {
        showloadingIndicator()
        
        contentService.fetchContent(searchText: searchText) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
                case .success(let contentResult):
                    self.content = contentResult.results
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
                case .failure(let error):
                    //TODO: вывод ошибки
                    print(error)
            }
            DispatchQueue.main.async {
                self.hideloadingIndicator()
            }
        }
    }
    
    func setupView() {
        view.backgroundColor = .white
        
        loadSearch()
        setupSearchController()
        hideKeyboardWhenTappedAround()
        
        collectionView.register(
            ContentCell.self,
            forCellWithReuseIdentifier: ContentCell.cellName
        )
        addSubViews()
        activateConstraints()
    }
    
    func setupSearchController() {
        let searchResultsController = SearchHistoryViewController()
        searchResultsController.delegate = self
        searchController = UISearchController(searchResultsController: searchResultsController)
        
        searchController?.searchResultsUpdater = self
        searchController?.obscuresBackgroundDuringPresentation = false
        searchController?.searchBar.placeholder = "Что будем искать?"
        searchController?.searchBar.delegate = self
        searchController?.searchBar.showsSearchResultsButton = false
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.searchController = searchController
    }
    
    func showDetails() {
        let detailViewController = DetailViewController()
        navigationController?.pushViewController(detailViewController, animated: true)
    }
    
    func saveSearchHistory() {
        userDefaultsManager.saveSearch(searchHistory)
    }
    
    func loadSearch() {
        searchHistory = userDefaultsManager.loadSearch()
    }
    
    func showloadingIndicator() {
        view.isUserInteractionEnabled = false
        loadingIndicator.startAnimating()
        searchController?.searchBar.isUserInteractionEnabled = false
    }
    
    func hideloadingIndicator() {
        loadingIndicator.stopAnimating()
        view.isUserInteractionEnabled = true
        searchController?.searchBar.isUserInteractionEnabled = true
    }
    
    func addSubViews() {
        view.addSubview(collectionView)
        view.addSubview(loadingIndicator)
    }
    
    func activateConstraints() {
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 4),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
        ])
    }
}

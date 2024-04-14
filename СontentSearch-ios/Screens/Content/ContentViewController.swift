//
//  ContentViewController.swift
//  СontentSearch-ios
//
//  Created by Aleksey Kolesnikov on 06.04.2024.
//

import UIKit

// MARK: - ContentViewControllerDelegate

protocol ContentViewControllerDelegate: AnyObject {
    func search(_ searchStr: String)
    func searchErrorAlert(error: String)
}

// MARK: - ContentViewController

final class ContentViewController: UIViewController {
    
    // MARK: - Layout variables
    
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
    
    // MARK: - Private variables
    
    private var searchController: UISearchController?
    private var content: [ContentModel] = []
    private var searchHistory: [String] = []
    private var alertPresenter: AlertPresenterProtocol?
    private let userDefaultsManager = UserDefaultsService.shared
    private let contentService = ContentService.shared
    
    // MARK: - Lyfecycle variables
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        alertPresenter = AlertPresenter(delagate: self)
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

//MARK: UISearchBarDelegate

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

//MARK: UICollectionViewDelegate

extension ContentViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        showDetails(item: content[indexPath.row])
    }
}

//MARK: UICollectionViewDataSource

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
        
        cell.delegate = self
        cell.configureCell(contentItem: content[indexPath.row])
        
        return cell
    }
}

//MARK: ContentViewControllerDelegate

extension ContentViewController: ContentViewControllerDelegate {
    func search(_ searchStr: String) {
        searchController?.searchBar.text = searchStr
        loadContent(with: searchStr)
    }
    
    func searchErrorAlert(error: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.alertPresenter?.show(
                AlertModel(
                    title: "Error!",
                    message: error,
                    buttonText: "OK")
            )
        }
    }
}

extension ContentViewController: AlertPresentableDelagate {
    func present(alert: UIAlertController, animated flag: Bool) {
        present(alert, animated: flag)
    }
}

//MARK: Private functions

private extension ContentViewController {
    func loadContent(with searchText: String) {
        UIBlockingProgressHUD.show()
        
        contentService.fetchContent(searchText: searchText) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
                case .success(let contentResult):
                    self.content = contentResult.results
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
                case .failure(let error):
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        self.searchErrorAlert(error: error.localizedDescription)
                    }
            }
            DispatchQueue.main.async {
                UIBlockingProgressHUD.dismiss()
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
    
    func showDetails(item: ContentModel) {
        let detailViewController = DetailViewController(contentItem: item)
        navigationController?.pushViewController(detailViewController, animated: true)
    }
    
    func saveSearchHistory() {
        userDefaultsManager.saveSearch(searchHistory)
    }
    
    func loadSearch() {
        searchHistory = userDefaultsManager.loadSearch()
    }
    
    func addSubViews() {
        view.addSubview(collectionView)
    }
    
    func activateConstraints() {
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 4),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}

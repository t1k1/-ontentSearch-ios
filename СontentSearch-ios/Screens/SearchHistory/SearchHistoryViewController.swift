//
//  SearchHistoryViewController.swift
//  СontentSearch-ios
//
//  Created by Aleksey Kolesnikov on 12.04.2024.
//

import UIKit

final class SearchHistoryViewController: UIViewController {
    
    //MARK: Public variables
    
    static let cellName = "SearchHistoryCell"
    weak var delegate: ContentViewControllerDelegate?
    
    //MARK: Private variables
    
    private let tableView = UITableView()
    private var suggestions: [String] = []
    
    //MARK: Lyfecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    //MARK: Public functions
    
    func updateSearchHistory(with suggestions: [String]) {
        self.suggestions = suggestions
        tableView.reloadData()
    }
    
    //MARK: Private functions
    
    private func configure() {
        view.addSubview(tableView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(
            UITableViewCell.self,
            forCellReuseIdentifier: SearchHistoryViewController.cellName
        )
        tableView.dataSource = self
        tableView.delegate = self
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

//MARK: UITableViewDelegate, UITableViewDataSource

extension SearchHistoryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return suggestions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: SearchHistoryViewController.cellName,
            for: indexPath
        )
        cell.selectionStyle = .none
        cell.textLabel?.text = suggestions[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedSuggestion = suggestions[indexPath.row]
        if let delegate = delegate {
            delegate.search(selectedSuggestion)
        }
        
        dismiss(animated: true, completion: nil)
    }
}

//
//  WebViewViewController.swift
//  СontentSearch-ios
//
//  Created by Aleksey Kolesnikov on 14.04.2024.
//

import UIKit
import WebKit

// MARK: - WebViewViewController

final class WebViewViewController: UIViewController {
    // MARK: - Private variables
    
    private let webView = WKWebView()
    private var urlString: String?
    
    // MARK: - Initialization
    
    init(urlString: String) {
        self.urlString = urlString.lowercased()
        super.init(nibName: nil, bundle: nil)
        hidesBottomBarWhenPushed = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        webView.navigationDelegate = self
        UIBlockingProgressHUD.show()
        let url = URL(string: checkUrlString())
        if let url {
            webView.load(URLRequest(url: url))
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}

// MARK: - WKNavigationDelegate

extension WebViewViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        UIBlockingProgressHUD.dismiss()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        UIBlockingProgressHUD.dismiss()
    }
}

// MARK: - Private methods

private extension WebViewViewController {
    @objc func backButtonCLicked() {
        webView.stopLoading()
        UIBlockingProgressHUD.dismiss()
        dismiss(animated: true)
    }
}

// MARK: - Private methods to configure UI

private extension WebViewViewController {
    
    func configureUI() {
        configureViews()
        configureConstraints()
    }
    
    func configureViews() {
        view.backgroundColor = .systemBackground
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)
    }
    
    func checkUrlString() -> String {
        let urlProtocol = "https://"
        let mockWebsite = "https://www.apple.com/itunes/"
        guard let urlString else { return mockWebsite }
        var currentUrlString = urlString
        if currentUrlString.isEmpty {
            currentUrlString = mockWebsite
        }
        if !currentUrlString.contains(urlProtocol) {
            currentUrlString = urlProtocol + currentUrlString
        }
        return currentUrlString
    }
    
    func configureConstraints() {
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
}

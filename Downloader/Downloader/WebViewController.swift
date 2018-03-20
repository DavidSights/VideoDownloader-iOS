//
//  WebViewController.swift
//  Downloader
//
//  Created by ndot on 9/26/15.
//  Copyright (c) 2015 iSolutionsApps. All rights reserved.
//
//  Updated by David Seitz Jr on 3/20/18.
//


// http://stackoverflow.com/questions/8518719/how-to-receive-nsnotifications-from-uiwebview-embedded-youtube-video-playback

import UIKit
import MediaPlayer
import AVFoundation
import AVKit

class WebViewController: UIViewController {

    @IBOutlet private var webView: UIWebView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    private var searchBar: UISearchBar!
    private var searchURL: URL!

    private var initialUrlAddress = "https://youtube.com/"

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
//        setUpSearchBar()

        webView.delegate = self

        activityIndicator.hidesWhenStopped = true
        activityIndicator.stopAnimating()

        guard let url = URL(string: initialUrlAddress) else { return }
        let request = URLRequest(url: url)
        webView.loadRequest(request)
    }

    // MARK: - Convenience Methods

    private func setUpNotificationObservers() {

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(WebViewController.movieLoaded),
                                               name: NSNotification.Name(rawValue: "AVPlayerItemBecameCurrentNotification"),
                                               object:nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(WebViewController.moviePlayerLoaded),
                                               name: .UIWindowDidBecomeKey,
                                               object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(WebViewController.movieClosed),
                                               name: .UIWindowDidBecomeHidden,
                                               object: nil)
    }

    private func setUpSearchBar() {

        let searchBarRect = CGRect(x: 0,
                                   y: 0,
                                   width: 250,
                                   height: 40)

        searchBar = UISearchBar(frame: searchBarRect)
        searchBar.tintColor = .white
        searchBar.placeholder = "Search or enter web address"
        searchBar.showsScopeBar = true
        searchBar.tintColor = .black
        searchBar.delegate = self
        searchBar.searchBarStyle = .minimal

        navigationItem.titleView = searchBar
    }

    // MARK: - Notification Handling

    @objc func moviePlayerLoaded(notification: NSNotification) {

        guard let window = notification.object as? UIWindow else { return }

        if window != view.window {

            let lableDownloadButton: UIButton=UIButton(type: UIButtonType.custom)

            let downloadButtonFrame = CGRect(x: 15,
                                             y: view.frame.size.height - 60,
                                             width: 100,
                                             height: 35)

            lableDownloadButton.frame = downloadButtonFrame
            lableDownloadButton.layer.cornerRadius = 5
            lableDownloadButton.clipsToBounds = true
            lableDownloadButton.backgroundColor = .white
            lableDownloadButton.backgroundColor = .orange
            lableDownloadButton.setTitle("Download", for: .normal)
            window.addSubview(lableDownloadButton)
        }
    }

    @objc func movieLoaded(notification: NSNotification) {

        if let playerItem = notification.object as? AVPlayerItem,
            let urlValue = playerItem.asset.value(forKey: "URL") {
            print("Movie loaded with value: \(urlValue)")
        }
    }

    @objc func movieClosed(notification: NSNotification) {

        if let window = notification.object as? UIWindow,
            let childViewControllers =  window.rootViewController?.childViewControllers {
            print("Movie closed with child view controllers: \(childViewControllers)")
        }
    }
}

// MARK: - UISearchBarDelegate

extension WebViewController: UISearchBarDelegate {

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {

        searchBar.showsCancelButton = true
        searchBar.placeholder = "Search or enter web address"

        if searchURL != nil {
            searchBar.text = searchURL.absoluteString
        }
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.showsCancelButton = false
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {

        if let text = searchBar.text {
            searchURL = URL(string: text)
        }

        searchBar .resignFirstResponder()
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.placeholder = searchURL.host

        // Load the url into webview
        let request = URLRequest(url: searchURL)
        webView?.loadRequest(request)
    }
}

// MARK: - UIWebViewDelegate

extension WebViewController: UIWebViewDelegate {

    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {

        if navigationType == .linkClicked {
            guard let url = request.url else { return true }
            print("Web view should start load with request URL: \(url.absoluteString)")
        }

        return true
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {

        if let keyPath = keyPath {
            print("keyPath: \(keyPath)")
        }
    }

    func webViewDidStartLoad(_ webView: UIWebView) {
        activityIndicator.startAnimating()
    }

    func webViewDidFinishLoad(_ webView: UIWebView) {
        activityIndicator.stopAnimating()
    }
}

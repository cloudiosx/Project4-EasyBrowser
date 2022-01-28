//
//  ViewController.swift
//  Project4 - Easy Browser
//
//  Created by John Kim on 1/24/22.
//

import UIKit
import WebKit

class ViewController: UITableViewController, WKNavigationDelegate {
    
    var webView: WKWebView!
    var progressView: UIProgressView!
    var websiteToLoadInitially = ["apple.com"]
    var websitesToLoadAsOptions = ["apple.com", "google.com", "hackingwithswift.com"]
    
//    override func loadView() {
//        webView = WKWebView()
//        webView.navigationDelegate = self
//        view = webView
//    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // UIBarButtonItem
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Open", style: .plain, target: self, action: #selector(openTapped))
        
        // UIProgressView
        
        progressView = UIProgressView(progressViewStyle: .default)
        progressView.sizeToFit()
        let progressButton = UIBarButtonItem(customView: progressView)
        
        // UIToolbar
        
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let refresh = UIBarButtonItem(barButtonSystemItem: .refresh, target: webView, action: #selector(webView.reload))
        let back = UIBarButtonItem(barButtonSystemItem: .rewind, target: webView, action: #selector(webView.goBack))
        let forward = UIBarButtonItem(barButtonSystemItem: .fastForward, target: webView, action: #selector(webView.goForward))
        
        toolbarItems = [progressButton, spacer, refresh, spacer, back, forward]
        navigationController?.isToolbarHidden = false
        
//        let url = URL(string: "https://www.apple.com")!
//        let url = URL(string: "https://" + websiteToLoadInitially[0])!
//        webView.load(URLRequest(url: url))
        
    }
    
    // UITableViewController
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return websitesToLoadAsOptions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Website", for: indexPath)
        cell.textLabel?.text = websitesToLoadAsOptions[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Set WKWebView to be the root view of the view controller's view hierarchy
        
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
        
        // KVO
        
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        
        let url = URL(string: "https://" + websitesToLoadAsOptions[indexPath.row])!
        webView.load(URLRequest(url: url))
        webView.allowsBackForwardNavigationGestures = true
    }
    
    @objc func openTapped() {
        let ac = UIAlertController(title: "Open page...", message: nil, preferredStyle: .actionSheet)
//        ac.addAction(UIAlertAction(title: "hackingwithswift.com", style: .default, handler: openPage))
//        ac.addAction(UIAlertAction(title: "google.com", style: .default, handler: openPage))
        for website in websitesToLoadAsOptions {
            ac.addAction(UIAlertAction(title: website, style: .default, handler: openPage))
        }
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        ac.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem
        present(ac, animated: true)
    }
    
    func openPage(action: UIAlertAction) {
        let url = URL(string: "https://" + action.title!)!
        webView.load(URLRequest(url: url))
    }
    
    // WKNavigationDelegate methods
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        title = webView.title
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let url = navigationAction.request.url
        
        if let host = url?.host {
            for website in websitesToLoadAsOptions {
                if host.contains(website) {
                    decisionHandler(.allow)
                    return
                }
            }
        } else {
            decisionHandler(.cancel)
            return
        }
        
        let ac = UIAlertController(title: "This URL isn't allowed", message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Go back", style: .cancel))
        present(ac, animated: true)
        decisionHandler(.cancel)
    }
    
    // KVO method
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            progressView.progress = Float(webView.estimatedProgress)
        }
    }
}


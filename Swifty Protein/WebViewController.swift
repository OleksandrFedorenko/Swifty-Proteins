//
//  WebViewController.swift
//  Swifty Protein
//
//  Created by MacBook Pro on 9/19/19.
//  Copyright © 2019 MacBook Pro. All rights reserved.
//

import UIKit
import WebKit
import SVProgressHUD

class WebViewController: UIViewController, WKNavigationDelegate {

    var webView: WKWebView!
    let baceUrl = "https://www.rcsb.org/ligand/"
    var name: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = URL(string: baceUrl + name)!
        webView.load(URLRequest(url: url))
        webView.scrollView.alwaysBounceVertical = true
        webView.scrollView.showsHorizontalScrollIndicator = false
        
        let refresh = UIBarButtonItem(barButtonSystemItem: .refresh, target: webView, action: #selector(webView.reload))
        let share = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareButtonPressed))
        
        navigationItem.rightBarButtonItems = [refresh, share]
    }
    
    @objc func shareButtonPressed(){
        let url = baceUrl + name
        let activityController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        self.present(activityController, animated: true, completion: nil)
    }
    
    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        title = webView.title
    }
    
}

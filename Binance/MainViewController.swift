//
//  MainViewController.swift
//  Binance
//
//  Created by Canius.Chu on 2018/8/26.
//  Copyright © 2018 Canius.Chu. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import RealmSwift

class MainViewController: ButtonBarPagerTabStripViewController,UISearchBarDelegate {

    private lazy var searchBar = UISearchBar()
    private lazy var searchButton = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.search, target: self, action: #selector(search))
    private lazy var cancelButton = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.cancel, target: self, action: #selector(cancel))
    
    private lazy var productController = ProductController(client: ApiClient())
    private lazy var currencies = productController.allCurrencies()
    private var notificationToken: NotificationToken?
    
    override func viewDidLoad() {
        self.settings.style.selectedBarBackgroundColor = Theme.highlightedColor
        self.settings.style.buttonBarBackgroundColor = Theme.darkColor
        self.settings.style.buttonBarItemBackgroundColor = Theme.darkColor
        self.settings.style.buttonBarItemTitleColor = Theme.foregroundColor
        super.viewDidLoad()
        
        self.title = "Markets"
        searchBar.placeholder = "Search Coin Name"
        searchBar.delegate = self
        self.navigationItem.rightBarButtonItem = searchButton
        self.changeCurrentIndexProgressive = { (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            oldCell?.label.textColor = self.settings.style.buttonBarItemTitleColor
            newCell?.label.textColor = self.settings.style.selectedBarBackgroundColor
        }
        notificationToken = currencies.observe { [weak self] (changes: RealmCollectionChange) in
            guard let strongSelf = self else { return }
            if case .error(let error)  = changes {
                fatalError("\(error)")
            }
            else {
                strongSelf.reloadPagerTabStripView()
            }
        }
    }
    
    deinit {
        notificationToken?.invalidate()
    }
    
    @objc func search() {
        self.navigationItem.titleView = searchBar
        self.navigationItem.rightBarButtonItem = cancelButton
    }
    
    @objc func cancel() {
        self.navigationItem.titleView = nil
        self.navigationItem.rightBarButtonItem = searchButton
        searchBar.text = nil
        self.productController.searchPattern = nil
        self.executeSearch()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(executeSearch), object: nil)
        self.productController.searchPattern = searchText.uppercased()
        self.perform(#selector(executeSearch), with: nil, afterDelay: 0.3)
    }
    
    @objc func executeSearch() {
        let currentVC = self.viewControllers[self.currentIndex] as! ProductTableViewController
        currentVC.reload()
    }
    
    override public func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        return self.currencies.map({ (currency) -> ProductTableViewController in
            let productsVC = self.storyboard?.instantiateViewController(withIdentifier: "Products") as! ProductTableViewController
            productsVC.productController = self.productController
            productsVC.currency = currency
            return productsVC
        })
    }
}


//
//  ProductTableViewController.swift
//  Binance
//
//  Created by Canius.Chu on 2018/8/26.
//  Copyright © 2018 Canius.Chu. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import RealmSwift
import PullToRefresh

class ProductTableViewController: UITableViewController,IndicatorInfoProvider {
    
    var productController: ProductController!
    var currency: Currency!
    
    private var products: Results<Product>!
    private var notificationToken: NotificationToken?
    
    let refresher = PullToRefresh()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.reload()
        tableView.addPullToRefresh(refresher) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.productController.refreshRemote().done {
                strongSelf.reload()
                }.catch { (error) in
                    print(error)
                }.finally {
                    strongSelf.tableView.endRefreshing(at: .top)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.reload()
        self.tableView.startRefreshing(at: .top)
    }
    
    deinit {
        notificationToken?.invalidate()
        if let t = self.tableView {
            t.removeAllPullToRefresh()
        }
    }

    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: currency.key)
    }
    
    func reload() {
        if let pattern = self.productController.searchPattern, !pattern.isEmpty {
            self.products = productController.search(by: self.currency.key, pattern: pattern)
        }
        else {
            self.products = productController.search(by: self.currency.key)
        }
        
        notificationToken?.invalidate()
        notificationToken = products.observe { [weak self] (changes: RealmCollectionChange) in
            guard let tableView = self?.tableView else { return }
            switch changes {
            case .initial:
                tableView.reloadData()
            case .update(_, let deletions, let insertions, let modifications):
                tableView.beginUpdates()
                tableView.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0) }), with: .automatic)
                tableView.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0)}), with: .automatic)
                tableView.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0) }), with: .automatic)
                tableView.endUpdates()
            case .error(let error):
                fatalError("\(error)")
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.products.count
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55.0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCell", for: indexPath)
        let product = self.products[indexPath.row]
        let quoteLabel = cell.contentView.viewWithTag(1) as? UILabel
        let baseLabel = cell.contentView.viewWithTag(2) as? UILabel
        let volumeLabel = cell.contentView.viewWithTag(3) as? UILabel
        let priceLabel = cell.contentView.viewWithTag(4) as? UILabel
        let moneyLabel = cell.contentView.viewWithTag(5) as? UILabel
        quoteLabel?.text = product.quoteAsset
        baseLabel?.text = "/ \(product.baseAsset)"
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0;
        formatter.currencySymbol = ""
        let volume = Decimal.init(string: product.volume) ?? 0
        
        volumeLabel?.text = formatter.string(from: volume as NSDecimalNumber)
        priceLabel?.text = product.close
        moneyLabel?.text = product.close
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

//
//  ProductController.swift
//  Binance
//
//  Created by Canius.Chu on 2018/8/26.
//  Copyright © 2018 Canius.Chu. All rights reserved.
//

import Foundation
import PromiseKit
import RealmSwift

class ProductController: BaseController {
    
    var searchPattern: String?
    
    @discardableResult
    func refreshRemote() -> Promise<Void> {
        return self.client.queryProducts().done { (dataModel) in
            guard let products = dataModel?.data else { return }
            let realm = try! Realm()
            var quotes = Set<String>()
            var created = [Product]()
            var deleted = [Product]()
            for productModel in products {
                guard let symbol = productModel.symbol, symbol.count > 0 else {
                    continue
                }
                guard let baseAssert = productModel.baseAsset, baseAssert.count > 0 else {
                    continue
                }
                guard let quoteAsset = productModel.quoteAsset, quoteAsset.count > 0 else {
                    continue
                }
                quotes.insert(quoteAsset)
                if productModel.active {
                    let product = Product()
                    product.key = symbol
                    product.baseAsset = productModel.baseAsset ?? ""
                    product.quoteAsset = productModel.quoteAsset ?? ""
                    product.high = productModel.high ?? "0"
                    product.low = productModel.low ?? "0"
                    product.open = productModel.open ?? "0"
                    product.close = productModel.close ?? "0"
                    product.volume = productModel.volume ?? "0"
                    created.append(product)
                }
                else {
                    if let product = realm.object(ofType: Product.self, forPrimaryKey: symbol) {
                        deleted.append(product)
                    }
                }
            }
            let currencies = quotes.map({ (quote) -> Currency in
                let currency = Currency()
                currency.key = quote
                return currency
            })
            
            try! realm.write {
                realm.add(currencies, update: true)
                realm.add(created, update: true)
                realm.delete(deleted)
            }
        }
    }
    
    func allCurrencies() -> Results<Currency> {
        let realm = try! Realm()
        return realm.objects(Currency.self)
    }
    
    func search(by currency: String) -> Results<Product> {
        let realm = try! Realm()
        return realm.objects(Product.self).filter("quoteAsset = %@", currency)
    }
    
    func search(by currency: String, pattern: String) -> Results<Product> {
        let realm = try! Realm()
        return realm.objects(Product.self).filter("quoteAsset = %@ and baseAsset contains %@", currency, pattern)
    }
}

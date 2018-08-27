//
//  LocalModels.swift
//  Binance
//
//  Created by Canius.Chu on 2018/8/26.
//  Copyright © 2018 Canius.Chu. All rights reserved.
//

import Foundation
import RealmSwift

class Currency: Object {
    
    @objc dynamic var key: String = ""
    
    override static func primaryKey() -> String? {
        return "key"
    }
    
}

class Product: Object {
    
    @objc dynamic var key: String = ""
    @objc dynamic var baseAsset: String = ""
    @objc dynamic var quoteAsset: String = ""
    @objc dynamic var high: String = ""
    @objc dynamic var low: String = ""
    @objc dynamic var open: String = ""
    @objc dynamic var close: String = ""
    @objc dynamic var volume: String = ""
    
    override static func primaryKey() -> String? {
        return "key"
    }
    
}

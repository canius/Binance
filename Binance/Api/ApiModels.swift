//
//  ApiModels.swift
//  Binance
//
//  Created by Canius.Chu on 2018/8/26.
//  Copyright © 2018 Canius.Chu. All rights reserved.
//

import Foundation

class ProductDataModel: Codable {
    var data: [ProductModel] = []
}

class ProductModel: Codable {
    
    var symbol: String?
    var baseAsset: String?
    var high: String?
    var low: String?
    var close: String?
    var quoteAsset: String?
    var active: Bool = false
    var volume: String?
    var open: String?
}

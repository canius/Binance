//
//  ApiClient.swift
//  Binance
//
//  Created by Canius.Chu on 2018/8/26.
//  Copyright © 2018 Canius.Chu. All rights reserved.
//

import Foundation
import BeyovaNet
import PromiseKit

class ApiClient: Client {
    
    init() {
        super.init(baseURL: "https://www.binance.com")
    }
    
    func queryProducts() -> Promise<ProductDataModel?> {
        let _url = "exchange/public/product"
        return self.request(relativeURL: _url, method: .get, parameters: [:], tokenReqiured: false)
    }

}

//
//  BaseController.swift
//  Binance
//
//  Created by Canius.Chu on 2018/8/26.
//  Copyright © 2018 Canius.Chu. All rights reserved.
//

import Foundation

class BaseController {
    
    let client: ApiClient

    required init(client: ApiClient) {
        self.client = client
    }
}

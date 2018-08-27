//
//  LoadingViewController.swift
//  Binance
//
//  Created by Canius.Chu on 2018/8/26.
//  Copyright © 2018 Canius.Chu. All rights reserved.
//

import UIKit

class LoadingViewController: UIViewController {

    @IBOutlet weak var reloadButton: UIButton?
    @IBOutlet weak var indicator: UIActivityIndicatorView?
    
    lazy var productController = ProductController(client: ApiClient())
    
    override func viewDidLoad() {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        super.viewDidLoad()
        self.reload()
    }
    
    @IBAction func reload(sender: UIButton) {
      self.reload()
    }
    
    func reload() {
        self.reloadButton?.isHidden = true
        self.indicator?.isHidden = false
        let mainVC = (self.storyboard?.instantiateViewController(withIdentifier: "Main"))!
        if productController.allCurrencies().isEmpty {
            productController.refreshRemote().done {
                self.navigationController?.viewControllers = [mainVC]
                }.catch { (error) in
                    print(error)
                    self.reloadButton?.isHidden = false
                    self.indicator?.isHidden = true
                }
        }
        else {
            DispatchQueue.main.async {
                self.navigationController?.viewControllers = [mainVC]
            }
        }
    }
}

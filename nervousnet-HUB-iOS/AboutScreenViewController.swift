//
//  AboutScreenViewController.swift
//  nervousnet-HUB-iOS
//
//  Created by Enz  Andreas on 22.05.17.
//  Copyright © 2017 ETH Zurich - COSS. All rights reserved.
//

import UIKit
import StoreKit

class AboutScreenViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func openAppRating() {
        //TODO: open apple store, use storeproductviewcontroller?
        if #available(iOS 10.3, *) {
            SKStoreReviewController.requestReview()
        } else {
            let storeViewController = SKStoreProductViewController()
            storeViewController.delegate = self as? SKStoreProductViewControllerDelegate
            
            let parameters = [SKStoreProductParameterITunesItemIdentifier :
                NSNumber(value: 1000599804)] //TODO: change and move hardcoded value
            
            storeViewController.loadProduct(withParameters: parameters,
                                            completionBlock: {success, error in
                                                if success {
                                                    log.debug("Presenting app in AppStore")
                                                    self.present(storeViewController, animated: true)
                                                    //TODO: Properly return to about screen
                                                } else {
                                                    log.error("Unable to open appstore to requested app")
                                                    log.error(error?.localizedDescription)
                                                    
                                                    let alert = UIAlertController(title: "Appstore currentyl unavailable",
                                                                                  message: "Please try again at a later time or consider trying to open the AppStore in a different app",
                                                                                  preferredStyle: UIAlertControllerStyle.alert)
                                                    self.present(alert, animated: true)
                                                    //TODO: this else does not happen when no internet connection available
                                                }
            })
        }
    }
    
    //TODO: show popup with terms of use

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

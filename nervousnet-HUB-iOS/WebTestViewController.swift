//
//  WebTestViewController.swift
//  nervousnet-HUB-iOS
//
//  Created by Lewin Könemann on 13.03.17.
//  Copyright © 2017 ETH Zurich - COSS. All rights reserved.
//

import UIKit

class WebTestViewController: UIViewController {

    @IBOutlet weak var testWebView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        testWebView.loadRequest(URLRequest(url: URL(string: "google.ca")!))

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

//
//  SensorPageViewController.swift
//  nervousnet
//
//  Created by Lewin Könemann on 07.10.16.
//  Copyright © 2016 coss. All rights reserved.
//

import UIKit

class SensorPageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    
    let sensorPageNames = Constants.PREINSTALLED_AXON_NAMES
    let numberOfPreinstalledAxons = Constants.PREINSTALLED_AXON_NAMES.count
    var sensorPageCache = [UIViewController?](repeating: nil, count: Constants.PREINSTALLED_AXON_NAMES.count)

    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        self.delegate = self
        
        //needed to make sure the webview is not hidden behinde navigation bar
        self.edgesForExtendedLayout = UIRectEdge.init(rawValue: 0)
        
        self.setViewControllers([pageAtIndex(index: 0)!], direction: .forward, animated: true, completion: nil)
        
        
        
        //self.didMove(toParentViewController: <#T##UIViewController?#>)
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Data Source
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController?{
        
        if let index = sensorPageNames.index(of: viewController.restorationIdentifier!) {
            if index >= 0 && index < numberOfPreinstalledAxons {
                let targetIndex = (index + 1) % numberOfPreinstalledAxons
                return pageAtIndex(index: targetIndex)
            }
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController?{
        
        if let index = sensorPageNames.index(of: viewController.restorationIdentifier!) {
            if index >= 0 && index < numberOfPreinstalledAxons {
                let targetIndex = (index + 1) % numberOfPreinstalledAxons
                return pageAtIndex(index: targetIndex)
            }
        }
        return nil
    }
    
    func pageAtIndex (index : Int) -> UIViewController?{
        
        if let sensorPage = sensorPageCache[index] {
            return sensorPage //cached result
        } else {
            let retVC = storyboard?.instantiateViewController(withIdentifier: sensorPageNames[index])
            
            
            //WEBVIEW
            let myWebView : UIWebView = UIWebView(frame: CGRect(x:0, y:0, width: UIScreen.main.bounds.width, height:UIScreen.main.bounds.height))
            
            retVC?.view.addSubview(myWebView)
            
            //1. Load web site into my web view
            let req = URLRequest(url: URL(string: "http://localhost:8080/axon-res/\(sensorPageNames[index])/axon.html")!)

            myWebView.loadRequest(req)
            
            
            self.sensorPageCache[index] = retVC
            return retVC
        }

    }
    
    //MARK: Delegate
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

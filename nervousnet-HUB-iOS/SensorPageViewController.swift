//
//  SensorPageViewController.swift
//  nervousnet
//
//  Created by Lewin Könemann on 07.10.16.
//  Copyright © 2016 coss. All rights reserved.
//

import UIKit

class SensorPageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    let sensorPageNames = ["page1", "page2", "page3"]

    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        self.delegate = self
        
        self.setViewControllers([pageAtIndex(index: 0)!], direction: .forward, animated: true, completion: nil)
        
        self.navigationController?.navigationBar.tintColor = UIColor.orange
        
        
        var barButton: UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 32))
        barButton.setTitle(self.restorationIdentifier!, for: .normal)
        barButton.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 20.0)
        barButton.setTitleColor(UIColor.orange, for: .normal)
        self.navigationItem.titleView = barButton
        self.navigationItem.backBarButtonItem?.tintColor = UIColor.orange
        self.navigationController?.navigationItem.titleView = barButton
        

        
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
            if index == 0 {return pageAtIndex(index:1)}
            else if index == 1 {return pageAtIndex(index:2)}
            else if index == 2 {return pageAtIndex(index:0)}

        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController?{
        
        if let index = sensorPageNames.index(of: viewController.restorationIdentifier!) {
            if index == 0 {return pageAtIndex(index:2)}
            else if index == 1 {return pageAtIndex(index:0)}
            else if index == 2 {return pageAtIndex(index:1)}
        }
        return nil
    }
    
    func pageAtIndex (index : Int) -> UIViewController?{
        let retVC = storyboard?.instantiateViewController(withIdentifier: sensorPageNames[index])
        return retVC
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

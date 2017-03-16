//
//  AxonDetailViewController.swift
//  nervousnet-HUB-iOS
//
//  Created by Lewin Könemann on 10.03.17.
//  Copyright © 2017 ETH Zurich - COSS. All rights reserved.
//

import UIKit

class AxonDetailViewController: UIViewController {
    
    var axon: Array<String> = []
    
    @IBOutlet weak var axonImageView: UIImageView!
    @IBOutlet weak var downloadButton: UIButton!
    
    @IBOutlet weak var axonTextView: UITextView!
    @IBOutlet weak var axonSubtitle: UILabel!
    @IBOutlet weak var axonTitle: UILabel!
    
    @IBOutlet weak var axonURL: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        log.debug("opened details of: ")
        log.debug(self.axon[0])
        
        //let arrayOfStrings: [String] = [axon["name"].stringValue, axon["title"].stringValue, axon["description"].stringValue, axon["icon"].stringValue, axon["repository"]["url"].stringValue, axon["author"].stringValue]
        
        
        axonTitle.text = axon[1]
        axonSubtitle.text = axon[5]
        axonTextView.text = axon[2]
        axonURL.text = "GitHub: \(axon[4])"
        
        axonImageView.image = UIImage(data: NSData(base64Encoded: axon[3], options: NSData.Base64DecodingOptions(rawValue: 0))! as Data)
        
        
        for localaxon in AxonStore.getInstalledAxonsList() {
            
            if(localaxon.title == axon[1]){
                downloadButton.titleLabel?.text = "downloaded"
                
            }
            
        }
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */

    @IBAction func downloadPressed(_ sender: UIButton) {
        log.debug("downloadPressed")
//        switch (sender.titleLabel!.text!) {
//            
//            case "download":
//                self.downloadButton. = PKDownloadButtonState.Downloading;
//            
//            
//            let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
//            dispatch_async(dispatch_get_global_queue(priority, 0)) {
//                
//                if(AxonStore.downloadAndInstall(AxonStore.getRemoteAxonIndexByName(self.axon[0]))){
//                    log.debug("installed successfully")
//                }else{
//                    log.debug("couldn't install")
//                }
//                
//                dispatch_async(dispatch_get_main_queue()) {
//                    // update some UI
//                    self.downloadButton.state = PKDownloadButtonState.Downloaded;
//                }
//            }
//            
//            break;
//        case PKDownloadButtonState.Downloading:
//            log.debug("cancelling download not yet implemented")
//            break;
//            
//            
//        case PKDownloadButtonState.Downloaded:
//            self.downloadButton.state =  PKDownloadButtonState.StartDownload
//            
//            //remove the axon from device
//            if(AxonStore.removeLocalAxon(axon[0])){
//                log.debug("removed axon:")
//                log.debug(axon[0])
//            }
//            
//            
//            
//            break;
//        default:
//            break;
//        }

    }
    
   
   
    
}



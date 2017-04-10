//
//  AxonDetailViewController.swift
//  nervousnet-HUB-iOS
//
//  Created by Lewin Könemann on 10.03.17.
//  Copyright © 2017 ETH Zurich - COSS. All rights reserved.
//

import UIKit

class AxonDetailViewController: UIViewController {
    
    var axonDetails : AxonDetails?
    
    @IBOutlet weak var axonImageView: UIImageView!
    @IBOutlet weak var downloadButton: AxonDownloadButton!
    
    @IBOutlet weak var axonTextView: UITextView!
    @IBOutlet weak var axonSubtitle: UILabel!
    @IBOutlet weak var axonTitle: UILabel!
    
    @IBOutlet weak var axonURL: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let axon = axonDetails else {
            return
        }

        axonTitle.text = axon.title
        axonSubtitle.text = axon.author
        axonTextView.text = axon.description
        if let repo = axon.repository_url {
            axonURL.text = "GitHub: " + repo
        } else {
            axonURL.text = "Github: unavailable"
        }
        
        axonImageView.image = UIImage(data: NSData(base64Encoded: axon.icon, options: NSData.Base64DecodingOptions(rawValue: 0))! as Data)
      
        downloadButton.axonDetail = axon
        downloadButton.updateState()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
    
//      THIS WAS REWRiTTEN IN NEW BUTTONCLASS
//    @IBAction func downloadPressed(_ sender: UIButton) {
//        log.debug("downloadPressed")
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

//    }

   
   
    




//
//  AxonDownloadButton.swift
//  nervousnet-HUB-iOS
//
//  Created by Lewin Könemann on 10.04.17.
//  Copyright © 2017 ETH Zurich - COSS. All rights reserved.
//

import UIKit

enum DownloadState : String {
    case download = "Download"
    case working = "Working"
    case downloaded = "Uninstall"
    case initializing = "Initializing"
}

class AxonDownloadButton: UIButton {
    
    var axonDetail : AxonDetails?
    var buttonState : DownloadState = DownloadState.initializing
    var openButton : UIButton?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.updateState()
        log.debug("I awoke")
        self.addTarget(nil, action: #selector(AxonDownloadButton.pressed), for: UIControlEvents.primaryActionTriggered)    
    }
    
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    //TODO: Interrupt Download
    func pressed () -> Void {
       
        switch buttonState {
            //TODO: This has to be asynchronous in AxonStore (we should NOT handle this in the UI like last time)
            case DownloadState.download:
                //TODO: this needs to throw
                if(AxonStore.downladAndInstall(axonName: axonDetail!.name)){
                        log.debug("installed successfully")
                    }else{
                        log.debug("couldn't install")
                    }
            case DownloadState.downloaded:
                AxonStore.removeLocalAxon(axonName: axonDetail!.name)
            default:
                break
        }
        self.updateState()
    }
    
    func updateState()->Void{
        self.buttonState = DownloadState.download
        for localaxon in AxonStore.getInstalledAxonsList() {
            
            if(localaxon.title == self.axonDetail?.title){
                self.buttonState = DownloadState.downloaded
                self.openButton?.isEnabled = true
                self.setTitle(buttonState.rawValue, for: UIControlState.normal)
                break
            }
            
        }
        self.setTitle(buttonState.rawValue, for: UIControlState.normal)
        if self.buttonState == DownloadState.downloaded {
            self.openButton?.isEnabled = true
        }
        else {self.openButton?.isEnabled = false}
    }
}

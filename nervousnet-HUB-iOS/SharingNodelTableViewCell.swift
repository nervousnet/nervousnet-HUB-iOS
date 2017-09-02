//
//  SharingNodeCellTableViewCell.swift
//  nervousnet-HUB-iOS
//
//  Created by Lewin Könemann on 02.09.17.
//  Copyright © 2017 ETH Zurich - COSS. All rights reserved.
//

import UIKit

class SharingNodeTableViewCell: UITableViewCell {

    @IBOutlet weak var addressField: UITextField!
    @IBOutlet weak var toggle: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if let text = UserDefaults.standard.dictionary(forKey: Constants.SERVER_CONFIG_KEY) {
            addressField.text = text["server"] as! String
        }
        
        if let state = UserDefaults.standard.value(forKey: Constants.SERVER_STATE_KEY) as? Int{
            toggle.isEnabled = true
            if state == VMConstants.STATE_RUNNING {
                toggle.setOn(true, animated: true)
            }
            else {toggle.setOn(false, animated: true)}
        }
        
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func toggled(_ sender: Any, forEvent event: UIEvent) {
        if let source = sender as? UISwitch{
            UserDefaults.standard.set(source.isOn ? VMConstants.STATE_RUNNING : VMConstants.STATE_PAUSED, forKey: Constants.SERVER_STATE_KEY)
        }
    }
    
    @IBAction func apply(_ sender: Any) {
        if let button = sender as? UIButton{
            log.debug(UserDefaults.standard.value(forKey: Constants.SERVER_CONFIG_KEY))
        }
        if var configDict = UserDefaults.standard.dictionary(forKey: Constants.SERVER_CONFIG_KEY){
            configDict[Constants.SERVER_CONFIG_VALUES[1]] = addressField.text
            UserDefaults.standard.set(configDict, forKey: Constants.SERVER_CONFIG_KEY)
        }
    }

    @IBAction func defaultPressed(_ sender: Any) {
    }
}

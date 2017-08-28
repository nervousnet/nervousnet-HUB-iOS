//
//  SettingsTableViewCell.swift
//  nervousnet
//
//  Created by Lewin Könemann on 10.10.16.
//  Copyright © 2016 coss. All rights reserved.
//

import UIKit

class SettingsTableViewCell: UITableViewCell {
   
    

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var imageLeft: UIImageView!
    var parentViewController : SettingsTableViewController = SettingsTableViewController()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        if let label = sender.superview?.subviews[1] as? UILabel {
            switch label.text! {
                case "Collection Rate":
                    let vc = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier: "Frequency") as! FrequencyTableViewController
                    
                    self.parentViewController.navigationController?.pushViewController(vc, animated:true)
                
                case "Sharing Nodes":
                    let vc = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier: "SharingNodes") as! SharingNodesTableViewController
                    
                    self.parentViewController.navigationController?.pushViewController(vc, animated:true)
                
                default: print("pleaseInsertViewcontroller" + label.text!)
                
                
            }

        }
    }

}

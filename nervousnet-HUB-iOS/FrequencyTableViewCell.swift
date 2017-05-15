//
//  FrequencyTableViewCell.swift
//  nervousnet
//
//  Created by Lewin Könemann on 11.10.16.
//  Copyright © 2016 coss. All rights reserved.
//

import UIKit

class FrequencyTableViewCell: UITableViewCell, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var rightLabel: UILabel!
    @IBOutlet weak var leftImage: UIImageView!
    @IBOutlet weak var spinnerRight: UIPickerView!
    var frequencies : [String] = ["None", "Low", "Medium", "High", "Max"]
    var frequencySettings: [Int64] = [0,1,2,3,4]
    var currentState = 0
   
    override func awakeFromNib() {
        
        super.awakeFromNib()
        spinnerRight.delegate = self
        spinnerRight.dataSource = self
        // Initialization code
        do {
            try frequencySettings = VM.sharedInstance.getFrequencySettings(for: rightLabel.text!)
            
        }
        catch {}
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        return frequencySettings.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?{
        return String(frequencySettings[row])
    }
    
//    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UILabel {
//        
//        var label = UILabel.init()
//        label.font = UIFont(name: "HelveticaNeue", size: 14)
//        label.text = "trial"
//        return label
//    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //TODO: doesnt make sense yet
        log.debug(self.rightLabel.text.debugDescription)

        do {
            try VM.sharedInstance.setSensorFrequency(for: String(row), to: row)
        }
        catch {}
    }

}

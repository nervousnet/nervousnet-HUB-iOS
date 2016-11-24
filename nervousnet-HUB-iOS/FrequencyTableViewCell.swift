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
    let frequencies : [String] = ["None", "Low", "Medium", "High", "Max"]
   
    override func awakeFromNib() {
        
        super.awakeFromNib()
        spinnerRight.delegate = self
        spinnerRight.dataSource = self
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        return frequencies.count
    }
    
//    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?{
//        return frequencies[row]
//    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UILabel {
        
        var label = UILabel.init()
        label.font = UIFont(name: "HelveticaNeue", size: 14)
        label.text = "trial"
        return label
    }

}

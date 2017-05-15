//
//  FrequencyTableViewController.swift
//  nervousnet
//
//  Created by Lewin Könemann on 07.10.16.
//  Copyright © 2016 coss. All rights reserved.
//

import UIKit

class FrequencyTableViewController: UITableViewController {
    
    var subSettings : [String] = []
    
    let subImages: [String : UIImage] = ["Accelerometer" : #imageLiteral(resourceName: "ic_accel"), "Battery" : #imageLiteral(resourceName: "ic_batt"), "Location" : #imageLiteral(resourceName: "ic_conn"), "Magnetometer" : #imageLiteral(resourceName: "ic_light"), "Noise" : #imageLiteral(resourceName: "ic_noise"), "Proximity" : #imageLiteral(resourceName: "proximity_orange"), "Gyroscope" : #imageLiteral(resourceName: "ic_accel")]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
       
        
        
        self.subSettings = VM.sharedInstance.sensorList

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return subSettings.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : FrequencyTableViewCell = tableView.dequeueReusableCell(withIdentifier: "frequencySetting", for: indexPath) as! FrequencyTableViewCell
        cell.rightLabel.text = subSettings[indexPath.row]
        cell.leftImage.image = subImages[subSettings[indexPath.row]]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return (tableView.frame.height - navigationController!.navigationBar.frame.height) / 7.0
        }
        return (tableView.frame.height - navigationController!.navigationBar.frame.height) / 5.0

    }
    
//    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int  ) -> UIView? {
//        if section == 0 {return tableView.dequeueReusableCell(withIdentifier: "topcell")!}
//        return tableView.dequeueReusableCell(withIdentifier: "")
//    }
    
//    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat{
//        return (tableView.bounds.height - navigationController!.navigationBar.bounds.height)/10.0
//    }
    
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

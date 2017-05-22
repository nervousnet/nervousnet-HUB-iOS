//
//  RootTableViewController.swift
//  nervousnet
//
//  Created by Lewin Könemann on 07.10.16.
//  Copyright © 2016 coss. All rights reserved.
//

import UIKit

class RootTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
//        var barButton: UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 32))
//        barButton.setTitle(self.restorationIdentifier!, for: .normal)
//        barButton.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 36.0)
//        barButton.setTitleColor(UIColor.orange, for: .normal)
//        barButton.addTarget(self, action: #selector(titlePressed(sender:)), for: .touchUpInside)
//        self.navigationItem.titleView = barButton
        
        self.navigationController?.navigationBar.tintColor = self.view.tintColor
        
        self.navigationController?.navigationBar.titleTextAttributes = [ NSForegroundColorAttributeName: self.view.tintColor]

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    @IBAction func killSwitchPressed(_ sender: UISegmentedControl) {
        let switchState = sender.selectedSegmentIndex
        if switchState == 0 { //toggle ON
            log.info("Sensor service toggled ON.")
            let event = NNEvent(eventType: VMConstants.EVENT_START_NERVOUSNET_REQUEST)
            
            NotificationCenter.default.post(name: NNEvent.name, object: nil, userInfo: event.info)
        } else if switchState == 1 { //toggle OFF
            log.info("Sensor service toggled OFF.")
            let event = NNEvent(eventType: VMConstants.EVENT_PAUSE_NERVOUSNET_REQUEST)
            
            NotificationCenter.default.post(name: NNEvent.name, object: nil, userInfo: event.info)
        } else {
            log.warning("Unhandled toggle state: There is something seriously wrong with the on off toggle.")
        }
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
        if section == 0 {return 3}
        return 3
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell1", for: indexPath)
            return cell
        }
        else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell2", for: indexPath)
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell3", for: indexPath)
            return cell
        }
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return (tableView.frame.height - navigationController!.navigationBar.frame.height) / 4.0
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int  ) -> UIView? {
        if section == 0 {return tableView.dequeueReusableCell(withIdentifier: "topcell")!}
        return tableView.dequeueReusableCell(withIdentifier: "")
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat{
        return (tableView.bounds.height - navigationController!.navigationBar.bounds.height)/10.0
    }
    
    func titlePressed (sender: UIButton!){
        log.debug("Hello, it worked")
        
        
        
        let dbManager = DBManager.sharedInstance
        
        let sID : Int64 = 6544654
        let sName = "accelerometer"
        let paramDef = ["accX" : "double",
                        "accY" : "double",
                        "accZ" : "double"]
        
        //let vm = VM() //TODO: initializing needs to handle DB connections (make sure they are available)
        
        let config = BasicSensorConfiguration(sensorID: sID, sensorName: sName, parameterDef: paramDef, samplingrates: [1, 2, 3], state: 1)
        
        
        let list = try! dbManager.getReadings(with: config)
        
        for r in list {
            log.debug("\(r.values.debugDescription)")
        }
    }
    
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

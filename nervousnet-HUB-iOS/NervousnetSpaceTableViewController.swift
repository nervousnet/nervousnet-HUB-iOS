//
//  NervousnetSpaceTableViewController.swift
//  nervousnet-HUB-iOS
//
//  Created by Lewin Könemann on 10.03.17.
//  Copyright © 2017 ETH Zurich - COSS. All rights reserved.
//

import UIKit
import SwiftyJSON
import Zip

class NervousnetSpaceTableViewController: UITableViewController {
    
    
    var TableData = [AxonDetails]()
    let operationQueue = OperationQueue.init()

    
    override func viewDidLoad() {
        super.viewDidLoad()

        //self.navigationController?.navigationBar.viewWithTag(97)?.isHidden = true
        
        //MRProgressOverlayView.showOverlayAddedTo(self.view, title: "Getting Axons..", mode: MRProgressOverlayViewMode.Indeterminate, animated: true)
        
        // download app store listing in the background and hide progress bar
        operationQueue.addOperation {
            self.TableData = AxonStore.getRemoteAxonList()
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.tableView.reloadRows(at: self.tableView.indexPathsForVisibleRows!, with: UITableViewRowAnimation.right)
            }
//            let refreshCell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0))
//            let refreshLabel = refreshCell?.viewWithTag(47) as! UILabel
//            log.debug(refreshLabel.text.debugDescription)
//            refreshLabel.text = "Current List of Axons On Github"
        }
        
        
    }
        
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        return TableData.count
    }
    
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            return tableView.dequeueReusableCell(withIdentifier: "reloadingCell")!
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "appstoreCell", for: indexPath)
        
        let imageData = NSData(base64Encoded: TableData[indexPath.row].icon, options: NSData.Base64DecodingOptions(rawValue: 0))
        let image = UIImage(data: imageData! as Data)
        
        
        //get labels within the cell
        let lbl : UILabel? = cell.contentView.viewWithTag(1) as? UILabel
        lbl?.text = TableData[indexPath.row].name
        
        let txtv : UILabel? = cell.contentView.viewWithTag(2) as? UILabel
        txtv?.text = TableData[indexPath.row].description
        
        let imgview : UIImageView? = cell.contentView.viewWithTag(3) as? UIImageView
        imgview?.image = image
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        log.info("preparing for segue")
        
        if segue.identifier == "axonDetailViewControllerSegue" {
            let idxPath = self.tableView.indexPathForSelectedRow
            if let idx = idxPath?.row, let nextVC = segue.destination as? AxonDetailViewController {
                nextVC.axonDetails = TableData[idx]
            } else {
                log.error("Error. Cannot send information to segue receiver")
            }
        }
        
        if segue.identifier == "testWebViewControllerSegue" {
            
            var idxPath : IndexPath?
            
            if let senderButton = sender as? UIButton {
                if let superview = senderButton.superview {
                    if let cell = superview.superview as? UITableViewCell {
                        idxPath = self.tableView.indexPath(for: cell)!
                    }
                }
            }
            
            let urlHandler = segue.destination as! WebTestViewController
            
            if let idx = idxPath?.row {
                urlHandler.req = URLRequest(url: URL(string: "http://localhost:8080/axon-res/\(TableData[idx].name)/axon.html")!)
                //url: AxonStore.getLocalAxonURL(axonName: "axon-acctest") as! URL)
            }
            else {log.debug("STOP ABUSING OPTIONALS U MORONS")}
        }
    }

    
    
        
    
}
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    
    /*
     override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
     let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)
     // Configure the cell...
     return cell
     }
     */
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
     if editingStyle == .Delete {
     // Delete the row from the data source
     tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
     } else if editingStyle == .Insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    

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

//This class controls the front end of the Axonstore and dispatches the fetches from github

class NervousnetSpaceTableViewController: UITableViewController {
    
    
    var TableData = [AxonDetails]()
    
    //Just an operationQueue for the tasks we are going to do to keep the main queue clean
    let operationQueue = OperationQueue.init()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //self.navigationController?.navigationBar.viewWithTag(97)?.isHidden = true
        
        
        //Deprecated library for displaying a progressview
        
        //MRProgressOverlayView.showOverlayAddedTo(self.view, title: "Getting Axons..", mode: MRProgressOverlayViewMode.Indeterminate, animated: true)
        
        //get the list of available axons from github and refresh the tableview accordingly
        operationQueue.addOperation {
            self.TableData = AxonStore.getRemoteAxonList()
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.tableView.reloadRows(at: self.tableView.indexPathsForVisibleRows!, with: UITableViewRowAnimation.right)
                let refreshCell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0))
                let refreshLabel = refreshCell?.viewWithTag(47) as! UILabel
                refreshLabel.text = "Current List of Axons On Github"
            }
            
            
            
        }
        
        
    }
        
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    
    //Section 0 for indicating status, Section 1 for diplaying actual list of axons
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    //One Indicator cell, otherwise all axons that are available. Blacklisting is handled by the AxonStore
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 || section == 1{
            return 1
        }
        return TableData.count
    }
    
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //Prototypes from Main.Storyboard for populating the tableView
        if indexPath.section == 0 {
            return tableView.dequeueReusableCell(withIdentifier: "reloadingCell")!
        }
        
        if indexPath.section == 1 {
            return tableView.dequeueReusableCell(withIdentifier: "swarmPulse")!
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "appstoreCell", for: indexPath)
        
        //Get encoded image from Data and make it usable as UIImage
        let imageData = NSData(base64Encoded: TableData[indexPath.row].icon, options: NSData.Base64DecodingOptions(rawValue: 0))
        let image = UIImage(data: imageData! as Data)
        
        
        //get contents of the cell and assign values to objects
        let lbl : UILabel? = cell.contentView.viewWithTag(1) as? UILabel
        lbl?.text = TableData[indexPath.row].name
        
        let txtv : UILabel? = cell.contentView.viewWithTag(2) as? UILabel
        txtv?.text = TableData[indexPath.row].description
        
        let imgview : UIImageView? = cell.contentView.viewWithTag(3) as? UIImageView
        imgview?.image = image
        
        //debugging only
        let installedAxons = AxonStore.getInstalledAxonsList()
        
        
        //Check whether axon is available to decide whether to allow opening or not
        for localaxon in AxonStore.getInstalledAxonsList() {
            if(localaxon.title == TableData[indexPath.row].title) {
                if let openButton = cell.contentView.viewWithTag(4) as? UIButton{
                openButton.isEnabled = true
            
                }
            }
        }
        
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        log.info("preparing for segue")
        
        
        //This is triggered by clicking any of the appstoreCells and presents a more detailed view by passing the axonDetails stored in TableData
        if segue.identifier == "axonDetailViewControllerSegue" {
            
            let idxPath = self.tableView.indexPathForSelectedRow
            
            if let idx = idxPath?.row, let nextVC = segue.destination as? AxonDetailViewController {
                nextVC.axonDetails = TableData[idx]
            } else {
                log.error("Error. Cannot send information to segue receiver")
            }
        }
        
        //Extracts the URL for the locally stored axon and passes it to the WebView on WebTestViewcontroller
        //TODO: Make a nicer ViewController for presenting Axons, maybe even with API controls
        if segue.identifier == "openAxonSegue" {
            
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
                //Sample of what this may look like:
                //url: AxonStore.getLocalAxonURL(axonName: "axon-acctest") as! URL)
            }
            else {log.debug("STOP ABUSING OPTIONALS")}
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
    

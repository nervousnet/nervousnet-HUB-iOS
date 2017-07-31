//
//  ConfigurationManager.swift
//  nervousnet-HUB-iOS
//
//  Created by Lewin Könemann on 27.05.17
//  Copyright © 2017 ETH Zurich - COSS. All rights reserved.
//

import UIKit
import CoreMotion

class SensorStatisticsViewController : UIViewController {
    
    @IBOutlet var webView: UIWebView!
    var sensorId : String = "Accelerometer"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let currentTimeA :NSDate = NSDate()
        let timestamp = UInt64(currentTimeA.timeIntervalSince1970*1000)
        
        let date = Date()
        log.debug(date.debugDescription)
        let calendar = Calendar.current
        
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        let second = calendar.component(.second, from: date)
        
        print("hours = \(hour):\(minute):\(second)")
        
        switch sensorId {
            
            
        case "Accelerometer":
            
            //get the current frequency
            do{
                
                do{
                    //let lastAcc = try nVM.getLatestReading(sensorID: 1000)
                    
                    let lastAcc = try SensorReading(config: ConfigurationManager().getConfiguration(sensorID: 1000), values: [Float(1), Float(2), Float(3) ], timestamp: Int64(timestamp) )
            
                    let javascript_global_variables =
                        "var unit_of_meas = " + "'latlongms';" +
                        "var first_curve_name = " + "'lat';" +
                        "var second_curve_name = " + "'long';" +
                        "var third_curve_name = " + "'speed';" +
                        "var x_axis_title = " + "'Date';" +
                        "var y_axis_title = " + "'latlongms';" +
                        "var plot_title = " + "'lat,long,m/s';" +
                        "var plot_subtitle = " + "'current location and speed';"
                    webView.stringByEvaluatingJavaScript(from: "javascript:" + javascript_global_variables)
                    
                    let urlpath = "\(Bundle.main.resourcePath!)/Assets/Highcharts/webview_charts_3_lines_live_data_over_time.html"
                    let url = URL.init(fileURLWithPath: urlpath)
                    let req = URLRequest(url: url)
                    webView.loadRequest(req)
                    
                    

                    webView.stringByEvaluatingJavaScript(from: "javascript:"
                        + "point0 = [Date.UTC(" + year.description + "," + month.description + "," + day.description + "," + hour.description + "," + minute.description + "," + second.description + ")," + (lastAcc.values["accX"] as! Float).description + "];"
                        + "point1 = [Date.UTC(" + year.description + "," + month.description + "," + day.description + "," + hour.description + "," + minute.description + "," + second.description + ")," + (lastAcc.values["accY"] as! Float).description + "];"
                        + "point2 = [Date.UTC(" + year.description + "," + month.description + "," + day.description + "," + hour.description + "," + minute.description + "," + second.description + ")," + (lastAcc.values["accZ"] as! Float).description + "];"
                    )

            } catch {LocalizedError.self}
        } catch {LocalizedError.self}

        
            
        default:
            log.debug("notasensor")
        }
        
        
    }
    
    func updateGraph (sensorReading : SensorReading) {
        switch sensorReading.sensorConfig.sensorID {
        case 1003:
            
            let date = Date(timeIntervalSinceReferenceDate: (Double(sensorReading.timestampEpoch)/1000.0 - Date.timeIntervalBetween1970AndReferenceDate))
            let calendar = Calendar.current
            
            let year = calendar.component(.year, from: date)
            let month = calendar.component(.month, from: date)
            let day = calendar.component(.day, from: date)
            let hour = calendar.component(.hour, from: date)
            let minute = calendar.component(.minute, from: date)
            let second = calendar.component(.second, from: date)
            log.debug(date.debugDescription)
            webView.stringByEvaluatingJavaScript(from: "javascript:"
                + "point0 = [Date.UTC(" + year.description + "," + month.description + "," + day.description + "," + hour.description + "," + minute.description + "," + second.description + ")," + (sensorReading.values["lat"] as! Double).description + "];"
                + "point1 = [Date.UTC(" + year.description + "," + month.description + "," + day.description + "," + hour.description + "," + minute.description + "," + second.description + ")," + (sensorReading.values["long"] as! Double).description + "];"
                + "point2 = [Date.UTC(" + year.description + "," + month.description + "," + day.description + "," + hour.description + "," + minute.description + "," + second.description + ")," + (sensorReading.values["speed"] as! Double).description + "];")
            

        default:
            log.debug("notasensor")
        }
    }
    
    private func getTimeStampMilliseconds() -> Int64 {
        return Int64((Date.timeIntervalBetween1970AndReferenceDate + Date.timeIntervalSinceReferenceDate) * 1000)
    }

    

}

//
//  NNEvent.swift
//  nervousnet-HUB-iOS
//
//  Created by Lewin Könemann on 11.01.17.
//  Copyright © 2017 ETH Zurich - COSS. All rights reserved.
//

import Foundation

public class NNEvent {
/* since NSNotificationCenter expects a collection object if we want to provide additional info in an event
 * this class is essentially a wrapper around 'info' */
    
// NNEvent must always have an eventType upon creation
    
    public enum InfoLabel {
        case EVENT_TYPE
        case STATE
        case SENSORID
    }
    
    public static let name = NSNotification.Name("nervousnet-HUB.iOS.events.NNEvent") //essentially the event ID
    
    public private(set) var info = [InfoLabel : Any]()
    
    init(eventType : Int, state : Int, sensorID : Int64) {
        info[InfoLabel.EVENT_TYPE] = eventType
        info[InfoLabel.STATE] = state
        info[InfoLabel.SENSORID] = sensorID
    }
    
    init(eventType : Int) {
        info[InfoLabel.EVENT_TYPE] = eventType
    }
}

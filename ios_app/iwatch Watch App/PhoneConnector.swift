//
//  PhoneConnector.swift
//  phone
//
//  Created by 梁丰洲 on 2024/12/15.
//

import WatchConnectivity
import WatchKit

class PhoneConnector: NSObject, WCSessionDelegate {
    
    override init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
        print("watch activationDidCompleteWith state = \(activationState.rawValue)")
    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        // 当iPhone或Watch端连通性改变时会调用
        print("watch sessionReachabilityDidChange")
    }
    
    func sendPhoneMessage(data: [String: Any]) {
        let session = WCSession.default
        if session.isReachable {
            session.sendMessage(data, replyHandler: nil, errorHandler: { (error) in
                print("watch send message to iPhone error: \(error.localizedDescription)")
            })
        } else {
            print("watch session is not reachable")
        }
    }
}

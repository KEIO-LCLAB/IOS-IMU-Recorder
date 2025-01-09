//
//  ExtendedRuntimeManager.swift
//  phone
//
//  Created by 梁丰洲 on 2024/12/16.
//

import WatchKit

class ExtendedRuntimeManager: NSObject, WKExtendedRuntimeSessionDelegate {
    static let shared = ExtendedRuntimeManager()
    
    private var session: WKExtendedRuntimeSession?
    
    private override init() {
        super.init()
    }
    
    func startSession() {
        guard session == nil else { return }
        
        session = WKExtendedRuntimeSession()
        session?.delegate = self
        session?.start()
        
        print("Extended Runtime Session started.")
    }
    
    func endSession() {
        session?.invalidate()
        session = nil
        
        print("Extended Runtime Session ended.")
    }
    
    // MARK: - WKExtendedRuntimeSessionDelegate
    
    func extendedRuntimeSessionDidStart(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
        print("Extended Runtime Session did start.")
    }
    
    func extendedRuntimeSessionWillExpire(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
        print("Extended Runtime Session will expire.")
    }
    
    func extendedRuntimeSession(_ extendedRuntimeSession: WKExtendedRuntimeSession, didInvalidateWith reason: WKExtendedRuntimeSessionInvalidationReason, error: Error?) {
        print("Extended Runtime Session invalidated: \(reason.rawValue), error: \(String(describing: error))")
        session = nil
        if reason == .expired {
            startSession()
        }
    }
}

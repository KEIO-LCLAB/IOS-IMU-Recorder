//
//  WatchSensorManager.swift
//  phone
//
//  Created by 梁丰洲 on 2024/12/15.
//

import Foundation
import CoreMotion
import Combine
import WatchKit


struct WatchSensorData: Codable {
    let timestamp: TimeInterval
    let accX: Double
    let accY: Double
    let accZ: Double
    let gyrX: Double
    let gyrY: Double
    let gyrZ: Double
    let qatX: Double
    let qatY: Double
    let qatZ: Double
    let qatW: Double
}

class WatchSensorManager: NSObject, ObservableObject {
    static let shared = WatchSensorManager()
    let motionManager: CMMotionManager
    let phoneConnector: PhoneConnector
    let encoder: PropertyListEncoder
    
    // runtime
    var timer: Timer?
    
    @Published var accX = 0.0
    @Published var accY = 0.0
    @Published var accZ = 0.0
    @Published var gyrX = 0.0
    @Published var gyrY = 0.0
    @Published var gyrZ = 0.0
    @Published var qatX = 0.0
    @Published var qatY = 0.0
    @Published var qatZ = 0.0
    @Published var qatW = 0.0
    
    private override init() {
        self.motionManager = CMMotionManager()
        self.phoneConnector = PhoneConnector()
        self.encoder = PropertyListEncoder()
        self.encoder.outputFormat = .binary
        super.init()
    }
    
    func sendWatchSensorData() {
        let sensorData = WatchSensorData(
            timestamp: Date().timeIntervalSince1970,
            accX: self.accX,
            accY: self.accY,
            accZ: self.accZ,
            gyrX: self.gyrX,
            gyrY: self.gyrY,
            gyrZ: self.gyrZ,
            qatX: self.qatX,
            qatY: self.qatY,
            qatZ: self.qatZ,
            qatW: self.qatW
        )
        
        do {
            let encodedData = try encoder.encode(sensorData)
            phoneConnector.sendPhoneMessage(data: ["WATCH_SENSOR_DATA": encodedData])
        } catch {
            print("Failed to encode sensor data: \(error)")
        }
    }
    
    func startUpdate(_ freq: Double) {
        let interval = 1.0 / freq
        
        // MotionManager
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = interval
            motionManager.startDeviceMotionUpdates()
        }
        
        // Timer
        self.timer = Timer.scheduledTimer(timeInterval: interval,
                                          target: self,
                                          selector: #selector(self.onLogSensor),
                                          userInfo: nil,
                                          repeats: true)
        
        // ExtendedRuntime
        ExtendedRuntimeManager.shared.startSession()
        
        // HealthKit
        WorkoutManager.shared.startWorkout()
    }
    
    func stopUpdate() {
        // ExtendedRuntime
        ExtendedRuntimeManager.shared.endSession()
        
        // HealthKit
        WorkoutManager.shared.endWorkout()
        
        // Timer
        self.timer?.invalidate()
        
        // MotionManager
        if motionManager.isDeviceMotionActive {
            motionManager.stopDeviceMotionUpdates()
        }
    }
    
    @objc private func onLogSensor() {
        if let data = motionManager.deviceMotion {
            self.accX = data.userAcceleration.x
            self.accY = data.userAcceleration.y
            self.accZ = data.userAcceleration.z
            
            self.gyrX = data.rotationRate.x
            self.gyrY = data.rotationRate.y
            self.gyrZ = data.rotationRate.z
            
            self.qatX = data.attitude.quaternion.x
            self.qatY = data.attitude.quaternion.y
            self.qatZ = data.attitude.quaternion.z
            self.qatW = data.attitude.quaternion.w
            
            sendWatchSensorData()
        } else {
            self.accX = Double.nan
            self.accY = Double.nan
            self.accZ = Double.nan
            self.gyrX = Double.nan
            self.gyrY = Double.nan
            self.gyrZ = Double.nan
            self.qatX = Double.nan
            self.qatY = Double.nan
            self.qatZ = Double.nan
            self.qatW = Double.nan
        }
        
    }
    
}

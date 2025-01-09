//
//  PhoneSensorManager.swift
//  phone
//
//  Created by 梁丰洲 on 2024/12/15.
//

import Foundation
import CoreMotion
import Combine

class PhoneSensorManager: NSObject, ObservableObject {
    let motionManager: CMMotionManager
    let headphoneMotionManager: CMHeadphoneMotionManager
    
    // runtime
    var timer: Timer?
    
    @Published var phoneSensorData: SensorData?
    @Published var headSensorData: SensorData?
    
    override init() {
        self.motionManager = CMMotionManager()
        self.headphoneMotionManager = CMHeadphoneMotionManager()
        super.init()
        
    }
    
    func startUpdate(_ freq: Double) {
        let interval = 1.0 / freq
        
        if self.motionManager.isDeviceMotionAvailable {
            self.motionManager.deviceMotionUpdateInterval = interval
            self.motionManager.startDeviceMotionUpdates()
        }
        
        // head phone has a fixed frequency of 10hz?
        if self.headphoneMotionManager.isDeviceMotionAvailable {
            self.headphoneMotionManager.startDeviceMotionUpdates()
        }
        
        self.timer = Timer.scheduledTimer(timeInterval: interval,
                                          target: self,
                                          selector: #selector(self.onLogSensor),
                                          userInfo: nil,
                                          repeats: true)
    }
    
    func stopUpdate() {
        self.timer?.invalidate()
        
        if self.headphoneMotionManager.isDeviceMotionActive {
            self.headphoneMotionManager.stopDeviceMotionUpdates()
        }
        
        
        if self.motionManager.isDeviceMotionAvailable {
            self.motionManager.stopDeviceMotionUpdates()
        }
        
    }
    
    @objc private func onLogSensor() {
        let timestamp = Date().timeIntervalSince1970
        
        // iPhone
        if let motion = motionManager.deviceMotion {
            let data = SensorData(accX: motion.userAcceleration.x,
                                  accY: motion.userAcceleration.y,
                                  accZ: motion.userAcceleration.z,
                                  gyrX: motion.rotationRate.x,
                                  gyrY: motion.rotationRate.y,
                                  gyrZ: motion.rotationRate.z,
                                  qatX: motion.attitude.quaternion.x,
                                  qatY: motion.attitude.quaternion.y,
                                  qatZ: motion.attitude.quaternion.z,
                                  qatW: motion.attitude.quaternion.w)
            self.phoneSensorData = data
            SensorDataManager.shared.append(sensorType: .PHONE, data: data, timestamp: timestamp)
        } else {
            self.phoneSensorData = nil
        }
        
        // AirPods Pro
        if let data = self.headphoneMotionManager.deviceMotion {
            let data = SensorData(accX: data.userAcceleration.x,
                                  accY: data.userAcceleration.y,
                                  accZ: data.userAcceleration.z,
                                  gyrX: data.rotationRate.x,
                                  gyrY: data.rotationRate.y,
                                  gyrZ: data.rotationRate.z,
                                  qatX: data.attitude.quaternion.x,
                                  qatY: data.attitude.quaternion.y,
                                  qatZ: data.attitude.quaternion.z,
                                  qatW: data.attitude.quaternion.w)
            self.headSensorData = data
            SensorDataManager.shared.append(sensorType: .HEADSET, data: data, timestamp: timestamp)
        } else {
            self.headSensorData = nil
        }
        
    }
    
}

//
//  SensorData.swift
//  phone
//
//  Created by 梁丰洲 on 2024/12/15.
//

import SwiftUI
import Foundation

struct SensorDataRecord: Codable {
    let timestamp: TimeInterval
    let sensorType: SensorType
    let data: SensorData
}

enum SensorType: String, Codable {
    case PHONE
    case WATCH
    case HEADSET
}

struct SensorData: Codable {
    var accX: Double
    var accY: Double
    var accZ: Double
    var gyrX: Double
    var gyrY: Double
    var gyrZ: Double
    var qatX: Double
    var qatY: Double
    var qatZ: Double
    var qatW: Double
    
    func quaternionToEulerAngles() -> (roll: Double, pitch: Double, yaw: Double) {
        let w = self.qatW
        let x = self.qatX
        let y = self.qatY
        let z = self.qatZ
        let sinr_cosp = 2.0 * (w * x + y * z)
        let cosr_cosp = 1.0 - 2.0 * (x * x + y * y)
        let roll = atan2(sinr_cosp, cosr_cosp)
        
        let sinp = 2.0 * (w * y - z * x)
        let pitch: Double
        if abs(sinp) >= 1 {
            pitch = sinp > 0 ? Double.pi / 2 : -Double.pi / 2
        } else {
            pitch = asin(sinp)
        }
        
        let siny_cosp = 2.0 * (w * z + x * y)
        let cosy_cosp = 1.0 - 2.0 * (y * y + z * z)
        let yaw = atan2(siny_cosp, cosy_cosp)
        
        return (roll, pitch, yaw)
    }
    
    func toIMUString() -> String {
        return "\(self.accX),\(self.accY),\(self.accZ),\(self.qatX),\(self.qatY),\(self.qatZ),\(self.qatW)"
    }
}

//
//  SensorDataManager.swift
//  phone
//
//  Created by 梁丰洲 on 2024/12/15.
//

import Foundation

class SensorDataManager: @unchecked Sendable {
    static let shared = SensorDataManager()
    
    private var records: [SensorDataRecord] = []
    
    var latestPhone: SensorDataRecord?
    var latestWatch: SensorDataRecord?
    var latestHeadset: SensorDataRecord?
    
    private func appendInternal(record: SensorDataRecord) {
//        self.records.append(record)
        switch record.sensorType {
        case .PHONE:
            if latestPhone == nil || record.timestamp > latestPhone!.timestamp {
                latestPhone = record
            }
        case .WATCH:
            if latestWatch == nil || record.timestamp > latestWatch!.timestamp {
                latestWatch = record
            }
        case .HEADSET:
            if latestHeadset == nil || record.timestamp > latestHeadset!.timestamp {
                latestHeadset = record
            }
        }
    }
    
    func append(sensorType: SensorType, data: SensorData, timestamp: TimeInterval = Date().timeIntervalSince1970) {
        let record = SensorDataRecord(timestamp: timestamp, sensorType: sensorType, data: data)
        self.appendInternal(record: record)
    }
    
    func allRecords() -> [SensorDataRecord] {
        return records
    }
    
    func clear() {
        records = []
    }
    
    private init() {}
}

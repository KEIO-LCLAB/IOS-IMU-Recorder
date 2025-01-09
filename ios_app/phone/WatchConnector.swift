//
//  WatchConnector.swift
//  phone
//
//  Created by 梁丰洲 on 2024/12/15.
//

import WatchConnectivity

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
    
    func toSensorData() -> SensorData {
        return SensorData(
            accX: accX,
            accY: accY,
            accZ: accZ,
            gyrX: gyrX,
            gyrY: gyrY,
            gyrZ: gyrZ,
            qatX: qatX,
            qatY: qatY,
            qatZ: qatZ,
            qatW: qatW
        )
    }
}

class WatchConnector: NSObject, ObservableObject, WCSessionDelegate {
    @Published var sensorData: WatchSensorData?
    let decoder: PropertyListDecoder
    
    override init() {
        self.decoder = PropertyListDecoder()
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
        print("phone activationDidCompleteWith state = \(activationState.rawValue)")
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if let encodedData = message["WATCH_SENSOR_DATA"] as? Data {
            do {
                let decodedData = try decoder.decode(WatchSensorData.self, from: encodedData)
                if sensorData == nil || sensorData!.timestamp < decodedData.timestamp {
                    // schedule main thread
                    DispatchQueue.main.async {
                        self.sensorData = decodedData
                    }
                    SensorDataManager.shared.append(
                        sensorType: .WATCH,
                        data: decodedData.toSensorData(),
                        timestamp: decodedData.timestamp)
                }
            } catch {
                print("Failed to decode sensor data: \(error)")
            }
        }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("phone sessionDidBecomeInactive")
    }
    func sessionDidDeactivate(_ session: WCSession) {
        print("phone sessionDidDeactivate")
    }
    func sessionWatchStateDidChange(_ session: WCSession) {
        print("phone sessionWatchStateDidChange")
        
    }
}

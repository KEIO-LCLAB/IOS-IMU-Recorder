//
//  ContentView.swift
//  iwatch Watch App
//
//  Created by 梁丰洲 on 2024/12/15.
//

import SwiftUI
import WatchConnectivity

func quaternionToEulerAngles(w: Double, x: Double, y: Double, z: Double) -> (roll: Double, pitch: Double, yaw: Double) {
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

struct ContentView: View {
    @State private var logStarting = false
    @State private var showAlert = false
    @ObservedObject var sensorLogger = WatchSensorManager.shared
    
    var body: some View {
        VStack {
            Text("Watch IMU Recorder")
            Button(action: {
                if !WCSession.default.isReachable {
                    self.showAlert = true
                    return
                }
                
                self.logStarting.toggle()
                
                if self.logStarting {
                    var samplingFrequency = UserDefaults.standard.integer(forKey: "frequency_preference")
                    
                    if samplingFrequency <= 0 {
                        samplingFrequency = 30
                    }
                    
                    print("sampling frequency = \(samplingFrequency) on watch")
                    self.sensorLogger.startUpdate(Double(samplingFrequency))
                }
                else {
                    self.sensorLogger.stopUpdate()
                }
            }) {
                if self.logStarting {
                    Image(systemName: "pause.circle")
                    Text("stop pushing")
                }
                else {
                    Image(systemName: "play.circle")
                    Text("Push data")
                }
            }.alert(isPresented: $showAlert) {
                Alert(title: Text("Watch Not Active"), message: Text("Please activate your watch by raising your wrist before pushing data."), dismissButton: .default(Text("OK")))
            }
        }
        
        VStack {
            VStack {
                Text("Accelerometer").font(.headline)
                HStack {
                    Text(String(format: "%.2f", self.sensorLogger.accX))
                    Spacer()
                    Text(String(format: "%.2f", self.sensorLogger.accY))
                    Spacer()
                    Text(String(format: "%.2f", self.sensorLogger.accZ))
                }.padding(.horizontal)
            }
            
            VStack {
                Text("Gyroscope").font(.headline)
                HStack {
                    Text(String(format: "%.2f", self.sensorLogger.gyrX))
                    Spacer()
                    Text(String(format: "%.2f", self.sensorLogger.gyrX))
                    Spacer()
                    Text(String(format: "%.2f", self.sensorLogger.gyrX))
                }.padding(.horizontal)
            }
            
            VStack {
                HStack {
                    let (roll, pitch, yaw) = quaternionToEulerAngles(w: self.sensorLogger.qatW, x: self.sensorLogger.qatX, y: self.sensorLogger.qatY, z: self.sensorLogger.qatZ)
                    
                    Text(String(format: "%.2f", roll * 180.0 / Double.pi))
                    Spacer()
                    Text(String(format: "%.2f", pitch * 180.0 / Double.pi))
                    Spacer()
                    Text(String(format: "%.2f", yaw * 180.0 / Double.pi))
                }.padding(.horizontal)
            }
        }
    }
}

#Preview {
    ContentView()
}

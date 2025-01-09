//
//  ContentView.swift
//  phone
//
//  Created by 梁丰洲 on 2024/12/15.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject private var watchConnector = WatchConnector()
    @ObservedObject private var sensorLogger = PhoneSensorManager()
    @ObservedObject private var clientSocket = SocketClient()
    
    @State private var host = "100.64.1.26"
    @State private var port = "12345"
    @State private var logStarting = false
    @State private var backgroundTaskID: UIBackgroundTaskIdentifier?
    
    func logAction(_ LargeFeedback: Bool) {
        self.logStarting.toggle()
        
        let switchFeedback: UIImpactFeedbackGenerator
        if LargeFeedback {
            switchFeedback = UIImpactFeedbackGenerator(style: .heavy)
        }
        else {
            switchFeedback = UIImpactFeedbackGenerator(style: .medium)
        }
        switchFeedback.impactOccurred()
        
        if self.logStarting {
            // background task
            self.backgroundTaskID = UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
            
            // start to measure
            var samplingFrequency = UserDefaults.standard.integer(forKey: "frequency_preference")
            if samplingFrequency <= 0 {
                samplingFrequency = 30
            }
            
            print("sampling frequency = \(samplingFrequency)")
            
            self.sensorLogger.startUpdate(Double(samplingFrequency))
        }
        else {
            self.sensorLogger.stopUpdate()
            if let backgroundTaskID = self.backgroundTaskID {
                UIApplication.shared.endBackgroundTask(backgroundTaskID)
            }
        }
    }
    
    var body: some View {
        VStack {
            VStack{
                HStack{
                    Spacer()
                    Text("IP")
                    TextField("server ip", text: $host)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.vertical, 4)
                        .disabled(clientSocket.isConnected || clientSocket.isConnecting)
                    Spacer()
                    Text("Port")
                    TextField("server port", text: $port)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.vertical, 4)
                        .keyboardType(.numberPad)
                        .disabled(clientSocket.isConnected || clientSocket.isConnecting)
                    Spacer()
                }.padding([.horizontal])
            }
            HStack {
                Spacer ()
                // socket state
                if clientSocket.isConnected {
                    HStack {
                        Image(systemName: "checkmark.circle")
                        Text("online")
                    }.foregroundColor(.green)
                } else {
                    if clientSocket.isConnecting {
                        HStack {
                            Image(systemName: "arrow.2.circlepath")
                            Text("connecting")
                        }.foregroundColor(.yellow)
                    } else {
                        HStack {
                            Image(systemName: "xmark.circle")
                            Text("offline")
                        }.foregroundColor(.red)
                    }
                }
                Spacer ()
                // server button
                if clientSocket.isConnected || clientSocket.isConnecting {
                    Button(action: {
                        clientSocket.disconnect()
                    }) {
                        HStack {
                            Image(systemName: "server.rack")
                            Text("disconnect")
                        }
                    }
                } else {
                    Button(action: {
                        guard let portNum = UInt16(port) else { return }
                        clientSocket.connect(host: host, port: portNum)
                    }) {
                        HStack {
                            Image(systemName: "server.rack")
                            Text("conect")
                        }
                    }
                }
                Spacer ()
                // start or stop
                Button(action: {}) {
                    if self.logStarting {
                        // double click or long touch
                        HStack {
                            Image(systemName: "pause.circle")
                            Text("Stop")
                        }
                        .onTapGesture(count: 2, perform: {
                            self.logAction(true)
                        })
                        .onLongPressGesture {
                            self.logAction(true)
                        }
                    }
                    else {
                        HStack {
                            Image(systemName: "play.circle")
                            Text("Start")
                        }.onTapGesture {
                            self.logAction(false)
                        }
                        
                    }
                }
                Spacer ()
            }
            .padding(.vertical)
            
            // 根据设备类型(iPhone/iPad)显示对应数据
            if UIDevice.current.userInterfaceIdiom == .phone {
                deviceView(
                    deviceName: "iPhone",
                    deviceIcon: "iphone",
                    sensorData: sensorLogger.phoneSensorData
                )
            } else if UIDevice.current.userInterfaceIdiom == .pad {
                deviceView(
                    deviceName: "iPad",
                    deviceIcon: "ipad",
                    sensorData: sensorLogger.phoneSensorData
                )
            }
            
            // Watch数据（非iPad时显示）
            if UIDevice.current.userInterfaceIdiom != .pad {
                deviceView(
                    deviceName: "Watch",
                    deviceIcon: "applewatch",
                    sensorData: watchConnector.sensorData?.toSensorData()
                )
            }
            
            // AirPods数据
            deviceView(
                deviceName: "AirPods Pro",
                deviceIcon: "airpodspro",
                sensorData: sensorLogger.headSensorData
            )
            
        }
    }
    
    
    func deviceView(deviceName: String, deviceIcon: String, sensorData: SensorData?) -> some View {
        VStack {
            HStack {
                Image(systemName: deviceIcon)
                Text(deviceName).font(.headline)
            }
            
            HStack {
                Image(systemName: "speedometer")
                Spacer()
                Text(String(format: "%.3f", sensorData?.accX ?? Double.nan))
                Spacer()
                Text(String(format: "%.3f", sensorData?.accY ?? Double.nan))
                Spacer()
                Text(String(format: "%.3f", sensorData?.accZ ?? Double.nan))
            }
            .padding(.horizontal, 30)
            .padding(.vertical, 2)
            
            HStack {
                Image(systemName: "gyroscope")
                Spacer()
                Text(String(format: "%.3f", sensorData?.gyrX ?? Double.nan))
                Spacer()
                Text(String(format: "%.3f", sensorData?.gyrY ?? Double.nan))
                Spacer()
                Text(String(format: "%.3f", sensorData?.gyrZ ?? Double.nan))
            }
            .padding(.horizontal, 30)
            .padding(.vertical, 2)
            
            HStack {
                let (roll, pitch, yaw) = sensorData?.quaternionToEulerAngles() ?? (Double.nan, Double.nan, Double.nan)
                Image(systemName: "rotate.3d")
                Spacer()
                Text(String(format: "%.3f", roll * 180.0 / Double.pi))
                Spacer()
                Text(String(format: "%.3f", pitch * 180.0 / Double.pi))
                Spacer()
                Text(String(format: "%.3f", yaw * 180.0 / Double.pi))
            }
            .padding(.horizontal, 30)
            .padding(.vertical, 2)
        }
        .padding(.vertical, 10)
    }
    
}

#Preview {
    ContentView()
}

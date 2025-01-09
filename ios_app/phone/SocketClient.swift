//
//  SocketClient.swift
//  phone
//
//  Created by 梁丰洲 on 2024/12/15.
//

import SwiftUI
import Network

class SocketClient: ObservableObject {
    @Published var isConnected: Bool = false
    @Published var isConnecting: Bool = false
    
    private var connection: NWConnection?
    private var sendTask: Task<Void, Never>?
    
    func connect(host: String, port: UInt16) {
        guard let nwPort = NWEndpoint.Port(rawValue: port) else {
            print("invalid port")
            return
        }
        
        // connection is in progress
        isConnected = false
        isConnecting = true
        
        connection = NWConnection(host: NWEndpoint.Host(host), port: nwPort, using: .tcp)
        
        connection?.stateUpdateHandler = { [weak self] state in
            DispatchQueue.main.async {
                switch state {
                case .ready:
                    print("connected")
                    self?.isConnected = true
                    self?.isConnecting = false
                    self?.startSending()
                case .failed(let error):
                    print("connection fail: \(error)")
                    self?.isConnected = false
                    self?.isConnecting = false
                case .waiting(let error):
                    // 等待连接中，仍保持 isConnecting = true
                    print("connection waiting: \(error)")
                case .cancelled:
                    print("connection")
                    self?.isConnected = false
                    self?.isConnecting = false
                default:
                    break
                }
            }
        }
        
        connection?.start(queue: .main)
    }
    
    func disconnect() {
        connection?.cancel()
        connection = nil
        isConnected = false
        isConnecting = false
        stopSending()
    }
    
    func send(data: Data) {
        guard let conn = connection, isConnected else { return }
        conn.send(content: data, completion: .contentProcessed({ error in
            if let error = error {
                print("发送出错: \(error)")
            }
        }))
    }
    
    private func startSending() {
        stopSending()  // make sure only one sending task is running
        sendTask = Task {
            let interval = UInt64(1_000_000_000 / 30) // sample rate 30Hz
            while !Task.isCancelled {
                if isConnected {
                    var data = "#"
                    var toSend = false
                    if let phoneData = SensorDataManager.shared.latestPhone?.data.toIMUString() {
                        data += phoneData
                        toSend = true
                    }
                    data += "|"
                    if let watchData = SensorDataManager.shared.latestWatch?.data.toIMUString() {
                        data += watchData
                        toSend = true
                    }
                    
                    data += "|"
                    if let headsetData = SensorDataManager.shared.latestHeadset?.data.toIMUString() {
                        data += headsetData
                        toSend = true
                    }
                    data += "\n"
                    
                    if toSend {
                        send(data: data.data(using: .utf8)!)
                    }
                } else {
                    break
                }
                try? await Task.sleep(nanoseconds: interval)
            }
        }
    }
    
    private func stopSending() {
        sendTask?.cancel()
        sendTask = nil
    }
}

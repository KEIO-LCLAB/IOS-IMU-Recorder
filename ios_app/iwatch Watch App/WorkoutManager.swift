//
//  WokeoutManager.swift
//  phone
//
//  Created by 梁丰洲 on 2024/12/16.
//

import HealthKit

class WorkoutManager: NSObject, HKWorkoutSessionDelegate {
    static let shared = WorkoutManager()
    private var workoutSession: HKWorkoutSession?

    private override init() {
        super.init()
    }

    func startWorkout() {
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .other // 根据实际情况选择，如 .running、.cycling 等
        configuration.locationType = .indoor // 根据实际情况选择
        
        let healthStore = HKHealthStore()
        
        do {
            workoutSession = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
            workoutSession?.delegate = self
            workoutSession?.startActivity(with: nil)
            print("Workout Session START!")
        } catch {
            print("Cannot launch Workout Session: \(error.localizedDescription)")
        }
    }

    func endWorkout() {
        if let session = workoutSession {
            session.end()
            print("Workout Session END!")
        }
    }

    // MARK: - HKWorkoutSessionDelegate

    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        switch toState {
        case .running:
            startDataCollection()
        case .ended:
            stopDataCollection()
        default:
            break
        }
    }

    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        print("Workout Session 失败: \(error.localizedDescription)")
    }

    // MARK: - 数据采集
    func startDataCollection() {
    }

    func stopDataCollection() {
    }

}

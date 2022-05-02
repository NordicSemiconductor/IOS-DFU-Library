//
//  DfuProgress.swift
//  dfu
//
//  Created by Nordic on 28/03/2022.
//

import Foundation

struct DfuProgress {
    let part: Int
    let totalParts: Int
    let progress: Int
    let currentSpeedBytesPerSecond: Double
    let avgSpeedBytesPerSecond: Double
    
    func percantageProgress() -> Float {
        return Float(progress)/100
    }
    
    func avgSpeed() -> Double {
        return avgSpeedBytesPerSecond / 1000
    }
}

extension DfuProgress {
    init() {
        self.part = 0
        self.totalParts = 0
        self.progress = 0
        self.currentSpeedBytesPerSecond = 0
        self.avgSpeedBytesPerSecond = 0
    }
}

//
//  DfuUiState.swift
//  dfu
//
//  Created by Nordic on 28/03/2022.
//

import Foundation

enum DfuUiState {
    case connecting
    case starting
    case enablingDfuMode
    case uploading(DfuProgress)
    case validating
    case disconnecting
    case completed
    case aborted
    case error(DfuUiError)
}

struct IntId: Equatable, Comparable {
    var id: Int
    
    static func < (lhs: IntId, rhs: IntId) -> Bool {
        return lhs.id < rhs.id
    }
}

extension IntId : ExpressibleByIntegerLiteral {
    init(integerLiteral value: Int) {
        id = value
    }
}

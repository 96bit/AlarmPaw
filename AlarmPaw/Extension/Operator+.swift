//
//  Operator+.swift
//  AlarmPaw
//
//  Created by He Cho on 2024/1/15.
//

import Foundation


func == <T, Value: Equatable>( keyPath: KeyPath<T, Value>, value: Value) -> (T) -> Bool {
    { $0[keyPath: keyPath] == value }
}

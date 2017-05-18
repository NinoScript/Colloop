//
//  Colloop.swift
//  Colloop
//
//  Created by Maxim Zaks on 16.03.17.
//  Copyright © 2017 Maxim Zaks. All rights reserved.
//

import Foundation

public class Colloop<T : Collection> where T.IndexDistance == Int, T.Index == Int {
    private var index = 0
    private var sequence : T
    private var routine : (T.Iterator.Element)->()
    private let step : Int?
    private let deltaTime : TimeInterval?
    private(set) public var isCanceled : Bool = false {
        didSet {
            onCancel?()
        }
    }
    private(set) public var isDone : Bool = false {
        didSet {
            onDone?()
        }
    }
    public var dispatchQueue = DispatchQueue.main
    public var onDone : (() -> ())?
    public var onCancel : (() -> ())?
    
    fileprivate init(sequence: T, step : Int, routine : @escaping (T.Iterator.Element)->()) {
        self.sequence = sequence
        self.step = step
        self.routine = routine
        self.deltaTime = nil
    }
    
    fileprivate init(sequence: T, deltaTime : TimeInterval, routine : @escaping (T.Iterator.Element)->()) {
        self.sequence = sequence
        self.step = nil
        self.routine = routine
        self.deltaTime = deltaTime
    }
    
    public func cancel(){
        isCanceled = true
    }
    
    public func run() {
        if isCanceled || isDone {
            return
        }
        if let step = step {
            let end = min(index + step, sequence.count)
            for i in index..<end{
                routine(sequence[i])
            }
            if end == sequence.count {
                isDone = true
                return
            }
            index = end
            dispatchQueue.async{
                self.run()
            }
        } else if let deltaTime = deltaTime {
            let now = CFAbsoluteTimeGetCurrent()
            for i in index..<Int(sequence.count) {
                routine(sequence[i])
                index += 1
                if CFAbsoluteTimeGetCurrent() - now >= deltaTime {
                    dispatchQueue.async{
                        self.run()
                    }
                    return
                }
            }
            isDone = true
        }
    }
}

extension Collection where Self.IndexDistance == Int, Self.Index == Int {
    public func colloop(withStep step: Int, _ routine: @escaping (Iterator.Element) -> ()) -> Colloop<Self>{
        return Colloop(sequence: self, step: step, routine: routine)
    }
    public func colloop(withDeltaTime deltaTime: TimeInterval, _ routine: @escaping (Iterator.Element) -> ()) -> Colloop<Self>{
        return Colloop(sequence: self, deltaTime: deltaTime, routine: routine)
    }
}

//
//  CoRoutineTests.swift
//  CoRoutineTests
//
//  Created by Maxim Zaks on 16.03.17.
//  Copyright © 2017 Maxim Zaks. All rights reserved.
//

import XCTest
@testable import Colloop

class CoRoutineTests: XCTestCase {
    
    func testColloopWithOneBigStep() {
        // given
        var results = [String]()
        // when
        (["a", "b", "c"].colloop(withStep: 10){ o in
            results.append("\(o)_")
        }).run()
        // then
        XCTAssertEqual(["a_", "b_", "c_"], results)
    }
    
    func testColloopWithMultipleSteps() {
        // given
        var results = [String]()
        let done = expectation(description: "Wait for colloop")
        
        let r = ["a", "b", "c"].colloop(withStep: 1){ o in
            results.append("\(o)_")
        }
        r.onDone = {
            done.fulfill()
        }
        // when
        r.run()
        // then
        waitForExpectations(timeout: 1) { error in
            XCTAssertEqual(["a_", "b_", "c_"], results)
        }
    }
    
    func testColloopWithMultipleStepsAndCancel() {
        // given
        var results = [String]()
        let done = expectation(description: "Wait for colloop")
        let r = ["a", "b", "c"].colloop(withStep: 2){ o in
            results.append("\(o)_")
        }
        OperationQueue.main.addOperation {
            r.cancel()
        }
        r.onCancel = {
            done.fulfill()
        }
        // when
        r.run()
        // then
        waitForExpectations(timeout: 1) { error in
            XCTAssertEqual(["a_", "b_"], results)
        }
    }
    
    func testCoroutineWithMultipleCoRoutinesAndSteps() {
        // given
        var results = [String]()
        let done = expectation(description: "Wait for colloop")
        
        let r1 = ["a", "b", "c"].colloop(withStep: 2){ o in
            results.append("\(o)_")
        }
        let r2 = ["1", "2", "3"].colloop(withStep: 1){ o in
            results.append("\(o)_")
        }
        r2.onDone = {
            done.fulfill()
        }
        // when
        r1.run()
        r2.run()
        // then
        waitForExpectations(timeout: 1) { error in
            XCTAssertEqual(["a_", "b_", "1_", "c_", "2_", "3_"], results)
        }
    }
    
    func testCoroutineWithMultipleStepsOnDedicatedQueue() {
        // given
        var results = [String]()
        let done = expectation(description: "Wait for colloop")
        
        let r = ["a", "b", "c"].colloop(withStep: 1){ o in
            results.append("\(o)_")
        }
        let q = DispatchQueue(label: "test")
        
        r.dispatchQueue = q
        r.onDone = {
            done.fulfill()
        }
        // when
        r.run()
        // then
        waitForExpectations(timeout: 1) { error in
            XCTAssertEqual(["a_", "b_", "c_"], results)
        }
    }
    
    func testCoroutineWithMultipleCoRoutinesAndStepsOnDeidcatedQueue() {
        // given
        var results = [String]()
        let done = expectation(description: "Wait for colloop")
        
        let q = DispatchQueue(label: "test")
        
        let r1 = ["a", "b", "c"].colloop(withStep: 2){ o in
            results.append("\(o)_")
        }
        r1.dispatchQueue = q
        let r2 = ["1", "2", "3"].colloop(withStep: 1){ o in
            results.append("\(o)_")
        }
        r2.onDone = {
            done.fulfill()
        }
        r2.dispatchQueue = q
        // when
        q.async { // because when we start it on the main queue the result is non deterministic
            r1.run()
            r2.run()
        }
        // then
        waitForExpectations(timeout: 1) { error in
            XCTAssertEqual(["a_", "b_", "1_", "c_", "2_", "3_"], results)
        }
    }
    
    func testCoroutineWithOneBigDeltaTime() {
        // given
        var results = [String]()
        // when
        (["a", "b", "c"].colloop(withDeltaTime: 1.0){ o in
            results.append("\(o)_")
        }).run()
        // then
        XCTAssertEqual(["a_", "b_", "c_"], results)
    }
    
    func testCoroutineWithShortDeltaTime() {
        // given
        var results = [String]()
        let done = expectation(description: "Wait for colloop")
        
        let r = ["a", "b", "c"].colloop(withDeltaTime: 0.0000001){ o in
            results.append("\(o)_")
        }
        r.onDone = {
            done.fulfill()
        }
        // when
        r.run()
        // then
        waitForExpectations(timeout: 1) { error in
            XCTAssertEqual(["a_", "b_", "c_"], results)
        }
    }
    
    func testCoroutineWithShortDeltaTimeAndCancel() {
        // given
        var results = [String]()
        let done = expectation(description: "Wait for colloop")
        
        let r = ["a", "b", "c"].colloop(withDeltaTime: 0.0000001){ o in
            results.append("\(o)_")
        }
        DispatchQueue.main.async {
            r.cancel()
        }
        r.onCancel = {
            done.fulfill()
        }
        // when
        r.run()
        // then
        waitForExpectations(timeout: 1) { error in
            XCTAssertEqual(["a_"], results)
        }
    }
    
    func testMultipleCoroutinesWithShortDeltaTimeAndStep() {
        // given
        var results = [String]()
        let done = expectation(description: "Wait for colloop")
        
        let r1 = ["a", "b", "c"].colloop(withDeltaTime: 0.0000001){ o in
            results.append("\(o)_")
        }
        let r2 = ["1", "2", "3"].colloop(withStep: 2){ o in
            results.append("\(o)_")
        }
        r1.onDone = {
            done.fulfill()
        }
        // when
        r1.run()
        r2.run()
        // then
        waitForExpectations(timeout: 1) { error in
            XCTAssertEqual(["a_", "1_", "2_", "b_", "3_", "c_"], results)
        }
    }
}

//
//  PeriodSummaryCAGRTests.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

@testable import FlowWorthLib
import XCTest

import AllocData

import FlowBase

class PeriodSummaryCAGRTests: XCTestCase {
    var tz: TimeZone!
    var df: ISO8601DateFormatter!
    var timestamp1a: Date!
    var timestamp1b: Date!
    var timestamp1c: Date!
    var timestamp2a: Date!
    var timestamp2b: Date!
    var zeroPos: MValuationPosition!
    var negPos: MValuationPosition!
    var pos1: MValuationPosition!
    var pos2: MValuationPosition!

    override func setUpWithError() throws {
        tz = TimeZone(identifier: "EST")!
        df = ISO8601DateFormatter()
        timestamp1a = df.date(from: "2020-06-01T12:00:00Z")! // anchor
        timestamp2a = df.date(from: "2020-12-02T12:00:00Z")! // six months later

        zeroPos = MValuationPosition(snapshotID: "X", accountID: "1", assetID: "Bond", totalBasis: 1, marketValue: 0)
        negPos = MValuationPosition(snapshotID: "X", accountID: "1", assetID: "Bond", totalBasis: 1, marketValue: -13)

        pos1 = MValuationPosition(snapshotID: "X", accountID: "1", assetID: "Bond", totalBasis: 1, marketValue: 13)

        pos2 = MValuationPosition(snapshotID: "X", accountID: "1", assetID: "Bond", totalBasis: 1, marketValue: 16)
    }

    func testDurationIsNil() throws {
        let period = DateInterval(start: timestamp2a, end: timestamp2a)
        let ps = PeriodSummary(period: period)
        XCTAssertNil(ps.singlePeriodCAGR)
    }

    func testNoBegCagrIsNil() throws {
        let period = DateInterval(start: timestamp1a, end: timestamp2a)
        let ps = PeriodSummary(period: period, endPositions: [pos1])
        XCTAssertNil(ps.singlePeriodCAGR)
    }

    func testNoEndCagrIsNil() throws {
        let period = DateInterval(start: timestamp1a, end: timestamp2a)
        let ps = PeriodSummary(period: period, begPositions: [pos1])
        XCTAssertNil(ps.singlePeriodCAGR)
    }

    func testZeroBegMVIsNil() throws {
        let period = DateInterval(start: timestamp1a, end: timestamp2a)
        let ps = PeriodSummary(period: period, begPositions: [zeroPos], endPositions: [pos1])
        XCTAssertNil(ps.singlePeriodCAGR)
    }

    func testZeroEndMVIsNil() throws {
        let period = DateInterval(start: timestamp1a, end: timestamp2a)
        let ps = PeriodSummary(period: period, begPositions: [pos1], endPositions: [zeroPos])
        XCTAssertNil(ps.singlePeriodCAGR)
    }

    func testNegBegMVIsNil() throws {
        let period = DateInterval(start: timestamp1a, end: timestamp2a)
        let ps = PeriodSummary(period: period, begPositions: [negPos], endPositions: [pos1])
        XCTAssertNil(ps.singlePeriodCAGR)
    }

    func testNegEndMVIsNil() throws {
        let period = DateInterval(start: timestamp1a, end: timestamp2a)
        let ps = PeriodSummary(period: period, begPositions: [pos1], endPositions: [negPos])
        XCTAssertNil(ps.singlePeriodCAGR)
    }

    func testNoChange() throws {
        let period = DateInterval(start: timestamp1a, end: timestamp2a)
        let ps = PeriodSummary(period: period, begPositions: [pos1], endPositions: [pos1])
        XCTAssertEqual(0.0, ps.singlePeriodCAGR)
    }

    func testPositive() throws {
        let period = DateInterval(start: timestamp1a, end: timestamp2a)
        let ps = PeriodSummary(period: period, begPositions: [pos1], endPositions: [pos2])
        XCTAssertEqual(0.510, ps.singlePeriodCAGR!, accuracy: 0.001)
    }

    func testNegative() throws {
        let period = DateInterval(start: timestamp1a, end: timestamp2a)
        let ps = PeriodSummary(period: period, begPositions: [pos2], endPositions: [pos1])
        XCTAssertEqual(-0.338, ps.singlePeriodCAGR!, accuracy: 0.001)
    }

    // example from Investopedia entry for CAGR
    func testExample1() throws {
        let period = DateInterval(start: df.date(from: "2018-01-01T12:00:00Z")!,
                                  end: df.date(from: "2021-01-01T12:00:00Z")!)
        let ps = PeriodSummary(period: period,
                               begPositions: [MValuationPosition(snapshotID: "X", accountID: "1", assetID: "Bond", totalBasis: 1, marketValue: 10000)],
                               endPositions: [MValuationPosition(snapshotID: "X", accountID: "1", assetID: "Bond", totalBasis: 1, marketValue: 19000)])
        XCTAssertEqual(0.2385, ps.singlePeriodCAGR!, accuracy: 0.0001) // NOTE different from the 23.86%
    }

    // a second example from Investopedia entry for CAGR
    func testExample2() throws {
        let period = DateInterval(start: df.date(from: "2017-12-01T12:00:00Z")!,
                                  end: df.date(from: "2020-12-01T12:00:00Z")!)
        let ps = PeriodSummary(period: period,
                               begPositions: [MValuationPosition(snapshotID: "X", accountID: "1", assetID: "LC", totalBasis: 1, marketValue: 64900)],
                               endPositions: [MValuationPosition(snapshotID: "X", accountID: "1", assetID: "LC", totalBasis: 1, marketValue: 176_000)])
        XCTAssertEqual(0.3944, ps.singlePeriodCAGR!, accuracy: 0.0001) // NOTE different from the 39.5%
    }

    // a third example from Investopedia entry for CAGR
    func testExample3() throws {
        let period = DateInterval(start: df.date(from: "2013-06-01T12:00:00Z")!,
                                  end: df.date(from: "2018-09-08T12:00:00Z")!)
        let ps = PeriodSummary(period: period,
                               begPositions: [MValuationPosition(snapshotID: "X", accountID: "1", assetID: "LC", totalBasis: 1, marketValue: 10000.00)],
                               endPositions: [MValuationPosition(snapshotID: "X", accountID: "1", assetID: "LC", totalBasis: 1, marketValue: 16897.14)])
        XCTAssertEqual(5.271, ps.yearsInPeriod, accuracy: 0.001)
        XCTAssertEqual(0.1046, ps.singlePeriodCAGR!, accuracy: 0.0001)
    }
}

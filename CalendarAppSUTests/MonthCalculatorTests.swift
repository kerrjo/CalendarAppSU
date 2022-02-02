//
//  MonthCalculator.swift
//  CalendarAppSUTests
//
//  Created by JOSEPH KERR on 2/2/22.
//

//
//  MonthCalculatorTests.swift
//  CalendarAppUTests
//
//  Created by JOSEPH KERR on 1/27/22.
//

import XCTest
@testable import CalendarAppSU

class MonthCalculatorTests: XCTestCase {
    
    override func setUpWithError() throws { }
    
    override func tearDownWithError() throws { }
    
    func testValues() throws {
        let sut = MonthCalculation(m: 1, d: 26, y: 2022) as MonthCalculating
        let values = sut.mdyValues
        XCTAssertEqual(1, values.0)
        XCTAssertEqual(26, values.1)
        XCTAssertEqual(2022, values.2)
    }
    
    func testNumberOfDaysInMonth() throws {
        let sut = MonthCalculation(m: 9, d: 26, y: 2022)
        let value = sut.numberOfDaysInMonth
        XCTAssertEqual(30, value)
    }
    
    func testStartDayOfWeek() throws {
        let sut = MonthCalculation(m: 1, d: 26, y: 2022)
        let value = sut.startDayOfWeek
        XCTAssertEqual(7, value)
    }
    
    func testStartDayOfWeekOne() throws {
        let sut = MonthCalculation(m: 8, d: 26, y: 2021)
        let value = sut.startDayOfWeek
        XCTAssertEqual(1, value)
    }
    
    func testPreviousMonth() throws {
        let sut = MonthCalculation(m: 4, d: 26, y: 2022)
        sut.previousMonth()
        let values = sut.mdyValues
        XCTAssertEqual(3, values.0)
    }
    
    func testNextMonth() throws {
        let sut = MonthCalculation(m: 4, d: 26, y: 2022)
        sut.nextMonth()
        let values = sut.mdyValues
        XCTAssertEqual(5, values.0)
    }
    
    func testNextMonthCrossoverYear() throws {
        let sut = MonthCalculation(m: 12, d: 26, y: 2022)
        sut.nextMonth()
        let values = sut.mdyValues
        XCTAssertEqual(1, values.0)
        XCTAssertEqual(2023, values.2)
    }
    
    func testPreviousMonthCrossoverYear() throws {
        let sut = MonthCalculation(m: 1, d: 26, y: 2022)
        sut.previousMonth()
        let values = sut.mdyValues
        XCTAssertEqual(12, values.0)
        XCTAssertEqual(2021, values.2)
    }
}

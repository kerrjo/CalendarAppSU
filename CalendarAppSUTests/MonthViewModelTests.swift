//
//  MonthViewModelTests.swift
//  CalendarAppSUTests
//
//  Created by JOSEPH KERR on 2/2/22.
//

import XCTest
@testable import CalendarAppSU

class MonthViewModelTests: XCTestCase {

    override func setUpWithError() throws { }

    override func tearDownWithError() throws { }

    func testValues() throws {
        let mockCalc = MockMonthCalculator()
        let mockService = MockHolidayService {
            $0(.success([]))
        }
        let sut = MonthViewModel(with: mockCalc, service: mockService) as MonthViewing
        XCTAssertEqual(1, sut.numberOfDaysInMonth)
    }
    
    func testFetchCalled() throws {
        let mockCalc = MockMonthCalculator()

        let expectation = XCTestExpectation()
        let expectedHoliday = HolidayElement(name: "Test", nameLocal: "", language: "", holidayDescription: "", country: "", location: "", type: "", date: "", dateYear: "", dateMonth: "", dateDay: "", weekDay: "")
        let mockService = MockHolidayService {
            $0(.success([expectedHoliday]))
            expectation.fulfill()
        }
        let sut = MonthViewModel(with: mockCalc, service: mockService) as MonthViewing
        sut.next()
        wait(for: [expectation], timeout: 0.2)
    }

    func testFetchError() throws {
        let mockCalc = MockMonthCalculator()

        let expectation = XCTestExpectation()
        let mockService = MockHolidayService {
            $0(.failure(.statusCode))
            expectation.fulfill()
        }
        let sut = MonthViewModel(with: mockCalc, service: mockService) as MonthViewing
        sut.next()
        
        wait(for: [expectation], timeout: 0.2)
    }

}

/// Navigation

extension MonthViewModelTests {
    
    func testStartMonth() throws {
        let mockCalc = MockMonthCalculator()

        let expectedFetches = 2
        let expectation = XCTestExpectation()
        
        expectation.expectedFulfillmentCount = expectedFetches
        mockCalc.numberOfDaysInMonth = expectedFetches
        let expectedHoliday = HolidayElement(name: "Test", nameLocal: "", language: "", holidayDescription: "", country: "", location: "", type: "", date: "", dateYear: "", dateMonth: "", dateDay: "", weekDay: "")
        let mockService = MockHolidayService {
            $0(.success([expectedHoliday]))
            expectation.fulfill()
        }
        
        let _ = MonthViewModel(with: mockCalc, service: mockService) as MonthViewing
        wait(for: [expectation], timeout: 0.2)
    }
    
    func testNextMonth() throws {
        let expectation = XCTestExpectation()
        let mockCalc = MockMonthCalculator(nextCalled: {
            expectation.fulfill()
        })
        let mockService = MockHolidayService {
            $0(.success([]))
        }
        let sut = MonthViewModel(with: mockCalc, service: mockService) as MonthViewing
        sut.next()
        wait(for: [expectation], timeout: 0.2)
    }

    func testPreviousMonth() throws {
        let expectation = XCTestExpectation()
        let mockCalc = MockMonthCalculator(previousCalled: {
            expectation.fulfill()
        })
        let mockService = MockHolidayService {
            $0(.success([]))
        }
        let sut = MonthViewModel(with: mockCalc, service: mockService) as MonthViewing
        sut.previous()
        wait(for: [expectation], timeout: 0.2)
    }
}

// MOCKS

class MockMonthCalculator: MonthCalculating {
    var monthName: String = ""
    
    typealias Completion = () -> ()
    var previousCalled: Completion?
    var nextCalled: Completion?
    
    init(
        previousCalled: Completion? = nil,
        nextCalled: Completion? = nil,
        numDays: Int = 1,
        startDay: Int = 1,
        dayValues: (Int, Int, Int) = (1, 1, 1)
    ) {
        self.previousCalled = previousCalled
        self.nextCalled = nextCalled
        numberOfDaysInMonth =  numDays
        startDayOfWeek = startDay
        mdyValues = dayValues
    }
    
    var date: Date = Date()
    var numberOfDaysInMonth: Int
    var startDayOfWeek: Int
    var mdyValues: (Int, Int, Int)
    func previousMonth() {
        previousCalled?()
    }
    func nextMonth() {
        nextCalled?()
    }
}

// MOCKS

class MockHolidayService: HolidayWebService {
    func cancel() { }
    
    func fetchHolidays(year: Int, month: Int, day: Int, completion: @escaping (Result<Holidays, FetchError>) -> ()) {
        fetchHandler?(completion)
    }
    
    typealias FetchCompletion = (Result<Holidays, FetchError>) -> ()
    typealias FetchCompletionHandler = (FetchCompletion) -> ()

    var fetchHandler: FetchCompletionHandler?
    init(fetchCompletion: FetchCompletionHandler? = nil) {
        fetchHandler = fetchCompletion
    }
}


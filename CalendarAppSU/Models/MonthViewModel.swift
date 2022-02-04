//
//  MonthModel.swift
//  CalendarAppSU
//
//  Created by JOSEPH KERR on 2/1/22.
//

import Foundation

protocol MonthNavigating {
    func next()
    func previous()
    /// currently set month
    func startMonth()
}

protocol MonthViewing: AnyObject, MonthNavigating {
    var current: Int { get }
    var year: Int { get }
    var startDay: Int { get } // day of week start in month 1 - 7
    var numberOfDaysInMonth: Int { get }
    var yearMonthTitle: String { get }
}

/**
 Model a calendar month, that allows changing to next and previous month
 retieves holidays from service
 
 */
class MonthViewModel: ObservableObject, MonthViewing {
    
    @Published var numberOfDaysInMonth: Int = 0
    @Published var yearMonthTitle: String = ""
    @Published var startDay: Int = 0
    @Published var current: Int = 0
    @Published var year: Int = 0
    @Published var dayViewModels: [WeekViewModel] = []
    @Published var selectedHoliday: String = ""
    
    private func update() {
        numberOfDaysInMonth = monthCalculator.numberOfDaysInMonth
        current = monthCalculator.mdyValues.0
        year = monthCalculator.mdyValues.2
        startDay = monthCalculator.startDayOfWeek
        yearMonthTitle = "\(year)  " + monthName
        dayViewModels = []
        generateDayModels()
    }
    
    private lazy var dateFormatter = DateFormatter()
    private var service: HolidayWebService?
    private var monthCalculator: MonthCalculating
    private var cancelling: Bool = false
    private var useRetry: Bool = false
    private var monthName: String {
        dateFormatter.dateFormat = "LLLL"
        return dateFormatter.string(from: monthCalculator.date)
    }
    
    init(with calc: MonthCalculating? = nil, service: HolidayWebService? = nil, cancelling: Bool = false) {
        self.monthCalculator = calc ?? MonthCalculation()
        self.service = service ?? HolidayService()
        self.cancelling = cancelling
        updateNewMonth()
    }
    
    func startMonth() {
        updateNewMonth()
    }
    
    func next() {
        monthCalculator.nextMonth()
        updateNewMonth()
    }
    
    func previous() {
        monthCalculator.previousMonth()
        updateNewMonth()
    }
    
    private func updateNewMonth() {
        update()
        newMonthCleanup()
        serviceCalls()
    }
    
    private var cancellableServiceCalls: [HolidayWebService] = []
}

// service calls

private extension MonthViewModel {
    
    func serviceCall(for day: Int, using service: HolidayWebService) {
        print(#function, day)
        service.fetchHolidays(year: year, month: current, day: day) { [weak self] in
            guard let self = self else { return }
            switch $0 {
            case .success(let holidays):
                self.helloHolidays(holidays)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func serviceCalls() {
        cancelling ?
        serviceCallsCancelling() :
        serviceCallsNonCancelling()
    }
    
    func serviceCallsNonCancelling() {
        print(#function)
        guard let service = service else { return }
        (1...numberOfDaysInMonth).forEach {
            serviceCall(for: $0, using: service)
        }
    }
    
    func serviceCallsCancelling() {
        print(#function)
        (1...numberOfDaysInMonth).forEach {
            let service: HolidayWebService = useRetry ? HolidayRetryService() : HolidayService()
            serviceCall(for: $0, using: service)
            cancellableServiceCalls.append(service)
        }
    }
    
    func newMonthCleanup() {
        for service in cancellableServiceCalls {
            service.cancel()
        }
        cancellableServiceCalls = []
    }
}

private extension MonthViewModel {
    
    var allDays: [DayViewModel] { dayViewModels.map({ $0.days }).flatMap({ $0 }) }
    
    // Each holiday is mapped to its day
    func helloHolidays(_ holidays: Holidays) {
        let days = allDays
        
        holidays.forEach { holiday in
            if let day = days.first(where: { Int($0.dayNumber) == Int(holiday.dateDay) }) {
                DispatchQueue.main.async {
                    day.holidayText = holiday.name
                }
            }
        }
    }
    
    func generateDayModels() {
        var day = 1
        let maxDays = numberOfDaysInMonth
        
        // Leading week
        let week1 = startDay == 1 ?
        WeekViewModel((day...day+6).map( { DayViewModel($0) })) :
        WeekViewModel((1...startDay-1).map( { _ in  DayViewModel(0) }) + (1...8-startDay).map( { DayViewModel($0) }))
        day = day + 8-startDay
        
        // Middle weeks
        let week2 = WeekViewModel((day...day+6).map( { DayViewModel($0) }))
        day = day + 7
        let week3 = WeekViewModel((day...day+6).map( { DayViewModel($0) }))
        day = day + 7
        let week4 = WeekViewModel((day...day+6).map( { DayViewModel($0) }))
        day = day + 7
        
        // Trailing weeks use day counter until maxdays then use 0
        let week5 = WeekViewModel((day...day+7).map( { DayViewModel($0 > maxDays ? 0 : $0) }))
        day = day + 7
        let week6 = WeekViewModel((day...day+7).map( { DayViewModel($0 > maxDays ? 0 : $0) }))

        dayViewModels = [week1, week2, week3, week4, week5, week6 ]
    }
}

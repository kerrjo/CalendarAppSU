//
//  MonthModel.swift
//  CalendarAppSU
//
//  Created by JOSEPH KERR on 2/1/22.
//

import Foundation
import Combine

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
    private var cancellables = Set<AnyCancellable>()
}

// service calls

private extension MonthViewModel {
    
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
}

private extension MonthViewModel {
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
        
        for holiday in holidays {
            if let day = days.first(where: { Int($0.dayNumber) == Int(holiday.dateDay) }) {
                DispatchQueue.main.async {
                    day.holidayText = holiday.name
                }
            }
        }
    }
    
    func generateDayModels() {
        var day = 0
        let maxDays = numberOfDaysInMonth
        
        var days: [DayViewModel]
        
        // Leading week
        
        days = []
        (1...7).forEach {
            day = $0 == startDay ? (day + 1) : (day + 0) // skipping iteration until startday reached
            days.append(DayViewModel(day))
            day = (day > 0) ? (day + 1) : (day + 0) // increment only if greater than 0
        }
        let week1 = WeekViewModel(days)
        
        // Middle weeks
        
        days = []
        (1...7).forEach { _ in
            days.append(DayViewModel(day))
            day = day + 1
        }
        let week2 = WeekViewModel(days)
        
        days = []
        (1...7).forEach { _ in
            days.append(DayViewModel(day))
            day = day + 1
        }
        let week3 = WeekViewModel(days)
        
        days = []
        (1...7).forEach { _ in
            days.append(DayViewModel(day))
            day = day + 1
        }
        let week4 = WeekViewModel(days)
        
        days = []
        (1...7).forEach { _ in
            // use day counter until maxdays then use 0
            days.append(DayViewModel(day > maxDays ? 0 : day))
            day = day + 1
        }
        let week5 = WeekViewModel(days)
        
        days = []
        (1...7).forEach { _ in
            // use day counter until maxdays then use 0
            days.append(DayViewModel(day > maxDays ? 0 : day))
            day = day + 1
        }
        let week6 = WeekViewModel(days)
        
        dayViewModels.append(week1)
        dayViewModels.append(week2)
        dayViewModels.append(week3)
        dayViewModels.append(week4)
        dayViewModels.append(week5)
        dayViewModels.append(week6)
    }
}

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
        startMonth()
    }
    
    func startMonth() {
        update()
        navigation()
    }
    
    func next() {
        monthCalculator.nextMonth()
        update()
        navigation()
    }
    
    func previous() {
        monthCalculator.previousMonth()
        update()
        navigation()
    }
    
    private func navigation() {
        newMonthCleanup()
        serviceCalls()
    }
    
    private var cancellableServiceCalls: [HolidayWebService] = []
    private var holidays: [HolidayElement] = []
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

            service.fetchHolidays(year: year, month: current, day: $0) { [weak self] in
                guard let self = self else { return }
                switch $0 {
                case .success(let holidays):
                    if !holidays.isEmpty {
                        self.holidays = self.holidays + holidays
                        self.helloHolidays(holidays)
                    }
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    
    func serviceCallsCancelling() {
        print(#function)
        
        (1...numberOfDaysInMonth).forEach {
            let service: HolidayWebService = useRetry ? HolidayRetryService() : HolidayService()

            service.fetchHolidays(year: year, month: current, day: $0) { [weak self] in
                guard let self = self else { return }
                switch $0 {
                case .success(let holidays):
                    if !holidays.isEmpty {
                        self.holidays = self.holidays + holidays
                        self.helloHolidays(holidays)
                    }
                case .failure(let error):
                    print(error)
                }
            }
            cancellableServiceCalls.append(service)
        }
    }
    
    func newMonthCleanup() {
        for service in cancellableServiceCalls {
            service.cancel()
        }
        cancellableServiceCalls = []
        holidays = []
    }
    
}

private extension MonthViewModel {

    func helloHolidays(_ holidays: Holidays) {
        for holiday in holidays {
            for week in dayViewModels {
                let days = week.days.filter {
                    Int($0.dayNumber) == Int(holiday.dateDay)
                }
                for day in days {
                    DispatchQueue.main.async {
                        day.holidayText = holiday.name
                    }
                }
            }
        }
    }

    func generateDayModels() {
        var day = 0
        let maxDays = numberOfDaysInMonth
        let week1 = WeekViewModel()
        let week2 = WeekViewModel()
        let week3 = WeekViewModel()
        let week4 = WeekViewModel()
        let week5 = WeekViewModel()
        let week6 = WeekViewModel()

        // Leading week

        (1...7).forEach {
            day = $0 == startDay ? (day + 1) : (day + 0) // skipping iteration until startday reched
            week1.days.append(DayViewModel(day))
            day = (day > 0) ? (day + 1) : (day + 0) // increment only if greater than 0
        }

        // Middle weeks
        
        (1...7).forEach { _ in
            week2.days.append(DayViewModel(day))
            day = day + 1
        }

        (1...7).forEach { _ in
            week3.days.append(DayViewModel(day))
            day = day + 1
        }

        (1...7).forEach { _ in
            week4.days.append(DayViewModel(day))
            day = day + 1
        }

        // Trailing weeks

        (1...7).forEach { _ in
            let dayValue = day > maxDays ? 0 : day // use day counter until maxdays then use 0
            week5.days.append(DayViewModel(dayValue))
            day = day + 1
        }

        (1...7).forEach { _ in
            let dayValue = day > maxDays ? 0 : day // use day counter until maxdays then use 0
            week6.days.append(DayViewModel(dayValue))
            day = day + 1
        }
        
        dayViewModels.append(week1)
        dayViewModels.append(week2)
        dayViewModels.append(week3)
        dayViewModels.append(week4)
        dayViewModels.append(week5)
        dayViewModels.append(week6)
    }
}

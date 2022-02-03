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
    @Published var selectedDayInWeek: Int = -1
    @Published var selectedDay: String = "" {
        didSet {
            if selectedDay.isEmpty {
                selectedDayInWeek = -1
            }
        }
    }
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
    private var holidays: [HolidayElement] = []
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
                if !holidays.isEmpty {
                    self.holidays = self.holidays + holidays
                    self.helloHolidays(holidays)
                }
            case .failure(let error):
                print(error)
            }
        }
    }

    func newMonthCleanup() {
        for service in cancellableServiceCalls {
            service.cancel()
        }
        cancellableServiceCalls = []
        holidays = []
        selectedDay = ""
        selectedHoliday = ""
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
    
    func dayViewModel(for day: Int) -> DayViewModel {
        let viewModel = DayViewModel(day)
        
        viewModel.$daySelected.sink(receiveValue: {
            print($0, "selected")
            if let weekIndex = self.daySelected($0) {
                self.selectedDayInWeek = weekIndex
            }
        }).store(in: &cancellables)
        return viewModel
    }
    
    func daySelected(_ day: String) -> Int? {
        for (index, week) in dayViewModels.enumerated() {
            if let day = week.days.first(where: { $0.dayNumber == day }) {
                selectedDay = day.dayNumber
                selectedHoliday = day.holidayText
                return index
            }
        }
        return nil
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
            day = $0 == startDay ? (day + 1) : (day + 0) // skipping iteration until startday reached
            week1.days.append(dayViewModel(for: day))
            day = (day > 0) ? (day + 1) : (day + 0) // increment only if greater than 0
        }
        // Middle weeks
        (1...7).forEach { _ in
            week2.days.append(dayViewModel(for: day))
            day = day + 1
        }
        (1...7).forEach { _ in
            week3.days.append(dayViewModel(for: day))
            day = day + 1
        }
        (1...7).forEach { _ in
            week4.days.append(dayViewModel(for: day))
            day = day + 1
        }
        // Trailing weeks
        (1...7).forEach { _ in
            // use day counter until maxdays then use 0
            week5.days.append(dayViewModel(for: day > maxDays ? 0 : day))
            day = day + 1
        }
        (1...7).forEach { _ in
            // use day counter until maxdays then use 0
            week6.days.append(dayViewModel(for: day > maxDays ? 0 : day))
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

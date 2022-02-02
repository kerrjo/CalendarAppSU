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
    func startMonth()
}

protocol MonthViewing: AnyObject, MonthNavigating {
    var current: Int { get }
    var year: Int { get }
    var startDay: Int { get } // day of week start month 0
    var numberOfDaysInMonth: Int { get }
    var yearMonthTitle: String { get }
}

//var onHolidays: ([HolidayElement])  -> () { get set }
//var monthName: String { get }
//var onNewMonth: () -> () { get set }

class MonthViewModel: ObservableObject, MonthViewing {
    
    private lazy var dateFormatter = DateFormatter()
    private var service: HolidayWebService?
    private var monthCalculator: MonthCalculating
    private var cancelling: Bool = false
    private var useRetry: Bool = false

    init(with calc: MonthCalculating? = nil, service: HolidayWebService? = nil, cancelling: Bool = false) {
        self.monthCalculator = calc ?? MonthCalculation()
        self.service = service ?? HolidayService()
        self.cancelling = cancelling
        update()
        startMonth()
    }
    
    
    private var monthName: String {
        dateFormatter.dateFormat = "LLLL"
        return dateFormatter.string(from: monthCalculator.date)
    }

    @Published var numberOfDaysInMonth: Int = 0
    @Published var yearMonthTitle: String = ""
    @Published var startDay: Int = 0
    @Published var current: Int = 0
    @Published var year: Int = 0

//    var onNewMonth: () -> () = { }
//    var onHolidays: ([HolidayElement])  -> () = { _ in }

//    @Published var dayViewModels: [[DayViewModel]] = [[]]
    @Published var dayViewModels: [WeekViewModel] = []

    func startMonth() {
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
    
    func update() {
        numberOfDaysInMonth = monthCalculator.numberOfDaysInMonth
        current = monthCalculator.mdyValues.0
        year = monthCalculator.mdyValues.2
        startDay = monthCalculator.startDayOfWeek
        yearMonthTitle = "\(year)  " + monthName
        dayViewModels = []
        generateDayModels()
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

            //let service: HolidayWebService = useRetry ? HolidayRetryService() : HolidayService()
            let service: HolidayWebService = HolidayService()

            service.fetchHolidays(year: year, month: current, day: $0) { [weak self] in
                guard let self = self else { return }
                switch $0 {
                case .success(let holidays):
                    if !holidays.isEmpty {
                        self.holidays = self.holidays + holidays
                        self.helloHolidays(holidays)
//                        self.onHolidays(holidays)
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

//                for day in days {
//                    DispatchQueue.main.async {
//                        day.holidayText = holiday.name
//                    }
//                }
//
//            }
//
//            let days = dayViewModels.flatMap({ $0 }).filter {
//                Int($0.dayNumber) == Int(holiday.dateDay)
//            }
//            for day in days {
//                DispatchQueue.main.async {
//                    day.holidayText = holiday.name
//                }
//            }
//        }
//    }
    
    func generateDayModels() {
        var day = 0
        let maxDays = numberOfDaysInMonth
        
        let week1 = WeekViewModel()
        (1...7).forEach {
            day = $0 == startDay ? (day + 1) : (day + 0)
            /// skipping iteration until startday reched
            
            week1.days.append(DayViewModel(day))
            
            /// increment only if greater than 0
            day = (day > 0) ? (day + 1) : (day + 0)
        }
        dayViewModels.append(week1)

        let week2 = WeekViewModel()
        (1...7).forEach { _ in
            week2.days.append(DayViewModel(day))
            day = day + 1
        }
        dayViewModels.append(week2)

        let week3 = WeekViewModel()
        (1...7).forEach { _ in
            week3.days.append(DayViewModel(day))
            day = day + 1
        }
        dayViewModels.append(week3)


        let week4 = WeekViewModel()
        (1...7).forEach { _ in
            week4.days.append(DayViewModel(day))
            day = day + 1
        }
        dayViewModels.append(week4)

        let week5 = WeekViewModel()
        (1...7).forEach { _ in
            // use day counter until maxdays then use 0
            let dayValue = day > maxDays ? 0 : day
            week5.days.append(DayViewModel(dayValue))
            day = day + 1
        }
        dayViewModels.append(week5)

        let week6 = WeekViewModel()
        (1...7).forEach { _ in
            // use day counter until maxdays then use 0
            let dayValue = day > maxDays ? 0 : day
            week6.days.append(DayViewModel(dayValue))
            day = day + 1
        }
        dayViewModels.append(week6)
    }

}
//    func generateDayModels1() {
//        var day = 0
//        let maxDays = numberOfDaysInMonth
//        dayViewModels.append([])
//        (1...7).forEach {
//            day = $0 == startDay ? (day + 1) : (day + 0)
//            /// skipping iteration until startday reched
//            dayViewModels[0].append(DayViewModel(day))
//            /// increment only if greater than 0
//            day = (day > 0) ? (day + 1) : (day + 0)
//        }
//
//        dayViewModels.append([])
//        (1...7).forEach { _ in
//            dayViewModels[1].append(DayViewModel(day))
//            day = day + 1
//        }
//
//        dayViewModels.append([])
//        (1...7).forEach { _ in
//            dayViewModels[2].append(DayViewModel(day))
//            day = day + 1
//        }
//
//        dayViewModels.append([])
//        (1...7).forEach { _ in
//            dayViewModels[3].append(DayViewModel(day))
//            day = day + 1
//        }
//
//        dayViewModels.append([])
//        (1...7).forEach { _ in
//            // use day counter until maxdays then use 0
//            let dayValue = day > maxDays ? 0 : day
//            dayViewModels[4].append(DayViewModel(dayValue))
//            day = day + 1
//        }
//
//        dayViewModels.append([])
//        (1...7).forEach { _ in
//            // use day counter until maxdays then use 0
//            let dayValue = day > maxDays ? 0 : day
//            dayViewModels[5].append(DayViewModel(dayValue))
//            day = day + 1
//        }
//    }
//}

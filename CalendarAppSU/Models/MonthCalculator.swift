//
//  MonthCalculator.swift
//  CalendarAppSU
//
//  Created by JOSEPH KERR on 2/1/22.
//

import Foundation

protocol MonthCalculating {
    var numberOfDaysInMonth: Int { get }
    var startDayOfWeek: Int { get }
    var mdyValues: (Int, Int, Int) { get }
    var monthName: String { get }
    func previousMonth()
    func nextMonth()
}

class MonthCalculation: MonthCalculating {
    
    private(set) var date: Date
    private lazy var dateFormatter = DateFormatter()
    var monthName: String {
        dateFormatter.dateFormat = "LLLL"
        return dateFormatter.string(from: date)
    }
    
    func previousMonth() {
        guard let newDate = Calendar.current.date(byAdding: DateComponents(month: -1), to: date) else { return }
        date = newDate
    }
    
    func nextMonth() {
        guard let newDate = Calendar.current.date(byAdding: DateComponents(month: 1), to: date) else { return }
        date = newDate
    }
    
    var numberOfDaysInMonth: Int {
        guard let range = Calendar.current.range(of: .day, in: .month, for: date) else  { return 0 }
        return range.count
    }
    
    /// returns the start day,  sun  thru sat, of week 1...7 , -1 on error
    var startDayOfWeek: Int {
        let components = Calendar.current.dateComponents([.day, .month, .year], from: date)
        guard let month = components.month,
              let year = components.year,
              let date = Calendar.current.date(from: DateComponents(year: year, month: month, day: 1))  else { return -1 }
        return Calendar.current.component(.weekday, from: date)
    }
    
    /// month day year
    var mdyValues: (Int, Int, Int) {
        let components = Calendar.current.dateComponents([.day, .month, .year], from: date)
        return (components.month ?? 0, components.day ?? 0, components.year ?? 0)
    }
    
    convenience init(m: Int, d: Int, y: Int) {
        let components = DateComponents(year: y, month: m, day: d)
        if let date = Calendar.current.date(from: components) {
            self.init(with: date)
        } else {
            self.init()
        }
    }
    
    init(with date: Date? = nil) {
        self.date = date ?? Date()
    }
}

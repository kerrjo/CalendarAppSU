//
//  MonthCalculator.swift
//  CalendarAppSU
//
//  Created by JOSEPH KERR on 2/1/22.
//

import Foundation


protocol MonthCalculating {
    var date: Date { get }
    var numberOfDaysInMonth: Int { get }
    var startDayOfWeek: Int { get }
    var mdyValues: (Int, Int, Int) { get }
    func previousMonth()
    func nextMonth()
}

class MonthCalculation: MonthCalculating {
    private(set) var date: Date

    func previousMonth() {
        incrementMonth(by: -1)
    }
    
    func nextMonth() {
        incrementMonth(by: 1)
    }
    
    var numberOfDaysInMonth: Int {
        guard let range = Calendar.current.range(of: .day, in: .month, for: date) else  { return 0 }
        return range.count
    }
    
    // sun - sat  1 thru 7
    var startDayOfWeek: Int {
        let components = Calendar.current.dateComponents([.day, .month, .year], from: date)
        guard let month = components.month, let year = components.year else { return -1 }
        guard let date = Calendar.current.date(from: DateComponents(year: year, month: month, day: 1))  else { return -1 }
        return Calendar.current.component(.weekday, from: date)
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

    /// month day year
    var mdyValues: (Int, Int, Int) {
        let values = dateValues()
        return (values.0 ?? 0, values.1 ?? 0, values.2 ?? 0)
    }
    
    /// month day year
    private func dateValues() -> (Int?, Int?, Int?) {
        let components = Calendar.current.dateComponents([.day, .month, .year], from: date)
        return (components.month, components.day, components.year)
    }
    
    /// adjust by month - to previous + next
    private func incrementMonth(by incr: Int) {
        guard let newDate = Calendar.current.date(byAdding: DateComponents(month: incr), to: date) else { return }
        date = newDate
    }
}

//
//  DayViewModel.swift
//  CalendarAppSU
//
//  Created by JOSEPH KERR on 2/2/22.
//

import Foundation

class DayViewModel: ObservableObject, Identifiable {
    var id: UUID = UUID()
    var dayNumber: String = ""
    @Published var holidayText: String = ""
    @Published var daySelected: String = ""
    
    func didSelect() {
        daySelected = dayNumber
    }
    
    init(_ day: Int = 0, holiday: String = "") {
        dayNumber = day > 0 ? "\(day)" : ""
        holidayText = holiday
    }
}

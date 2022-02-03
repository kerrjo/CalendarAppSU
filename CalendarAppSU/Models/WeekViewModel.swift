//
//  WeekViewModel.swift
//  CalendarAppSU
//
//  Created by JOSEPH KERR on 2/2/22.
//

import Foundation

class WeekViewModel: ObservableObject {
    @Published var days: [DayViewModel] = []
    
    init(_ days: [DayViewModel] = []) {
        self.days = days
    }
}

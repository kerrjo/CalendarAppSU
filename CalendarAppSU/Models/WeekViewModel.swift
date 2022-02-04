//
//  WeekViewModel.swift
//  CalendarAppSU
//
//  Created by JOSEPH KERR on 2/2/22.
//

import Foundation
import Combine

class WeekViewModel: ObservableObject {
    @Published var days: [DayViewModel] = []
    @Published var isDetailsRevealed: Bool = false
    @Published var details: (String, String) = ("", "")
    
    init(_ days: [DayViewModel] = [], isDetailsRevealed: Bool = false, details: (String, String) = ("", "") ) {
        self.isDetailsRevealed = isDetailsRevealed
        self.details = details
        self.days = days
        days.forEach { day in
            day.$daySelected
                .sink(receiveValue: {
                    guard !$0.isEmpty else { return }
                    self.isDetailsRevealed = true
                    self.details = (day.dayNumber, day.holidayText)
                }).store(in: &cancellables)
        }
    }
    
    func didSelectDetails() {
        isDetailsRevealed = false
        details = ("", "")
    }
    
    private var cancellables = Set<AnyCancellable>()
}

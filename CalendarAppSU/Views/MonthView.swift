//
//  MonthView.swift
//  CalendarAppSU
//
//  Created by JOSEPH KERR on 2/2/22.
//

import SwiftUI

struct MonthView: View {
    @ObservedObject var viewModel: MonthViewModel
    
    var body: some View {
        VStack {
            VStack {
                WeekView(viewModel: viewModel.dayViewModels[0])
                if viewModel.selectedDayInWeek == 0 {
                    HStack {
                        Text(viewModel.selectedDay)
                        Text(viewModel.selectedHoliday)
                    }
                }
            }
            VStack {
                WeekView(viewModel: viewModel.dayViewModels[1])
                if viewModel.selectedDayInWeek == 1 {
                    HStack {
                        Text(viewModel.selectedDay)
                        Text(viewModel.selectedHoliday)
                    }
                }
            }
            VStack {
                WeekView(viewModel: viewModel.dayViewModels[2])
                if viewModel.selectedDayInWeek == 2 {
                    HStack {
                        Text(viewModel.selectedDay)
                        Text(viewModel.selectedHoliday)
                    }
                }
            }
            VStack {
                WeekView(viewModel: viewModel.dayViewModels[3])
                
                if viewModel.selectedDayInWeek == 3 {
                    HStack {
                        Text(viewModel.selectedDay)
                        Text(viewModel.selectedHoliday)
                    }
                }
            }
            VStack {
                WeekView(viewModel: viewModel.dayViewModels[4])
                if viewModel.selectedDayInWeek == 4 {
                    HStack {
                        Text(viewModel.selectedDay).padding()
                        Text(viewModel.selectedHoliday)
                    }
                }
            }
            VStack {
                WeekView(viewModel: viewModel.dayViewModels[5])
                if viewModel.selectedDayInWeek == 5 {
                    HStack {
                        Text(viewModel.selectedDay).padding()
                        Text(viewModel.selectedHoliday)
                    }
                }
            }
        }
    }
}

struct MonthView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MonthView(viewModel: MonthViewModel())
                .previewLayout(.sizeThatFits)
        }
    }
}

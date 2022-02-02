//
//  MonthView.swift
//  CalendarAppSU
//
//  Created by JOSEPH KERR on 2/2/22.
//

import SwiftUI

class WeekViewModel: ObservableObject {
    @Published var days: [DayViewModel] = []
}

struct WeekView: View {
    @ObservedObject var viewModel: WeekViewModel
    var body: some View {
        HStack {
            ForEach(viewModel.days, id: \.id) { item in
                DayView(viewModel: item)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .border(Color.red)
            }
        }
    }
}


struct MonthView: View {
    @ObservedObject var viewModel: MonthViewModel
    var body: some View {
        VStack {
            WeekView(viewModel: viewModel.dayViewModels[0])
            WeekView(viewModel: viewModel.dayViewModels[1])
            WeekView(viewModel: viewModel.dayViewModels[2])
            WeekView(viewModel: viewModel.dayViewModels[3])
            WeekView(viewModel: viewModel.dayViewModels[4])
            WeekView(viewModel: viewModel.dayViewModels[5])
        }
    }
}


struct MonthView_Previews: PreviewProvider {
    static var previews: some View {
        MonthView(viewModel: MonthViewModel())
    }
}

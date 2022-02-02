//
//  WeekView.swift
//  CalendarAppSU
//
//  Created by JOSEPH KERR on 2/2/22.
//

import SwiftUI

class WeekViewModel: ObservableObject {
    @Published var days: [DayViewModel] = []
    
    init(_ days: [DayViewModel] = []) {
        self.days = days
    }
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

struct WeekView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            WeekView(viewModel: WeekViewModel([
                DayViewModel(1),
                DayViewModel(2),
                DayViewModel(3),
                DayViewModel(4),
                DayViewModel(5),
                DayViewModel(6),
                DayViewModel(7),
            ])
            ).previewLayout(.sizeThatFits)
        }
    }
}



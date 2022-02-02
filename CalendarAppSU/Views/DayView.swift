//
//  DayView.swift
//  CalendarAppSU
//
//  Created by JOSEPH KERR on 2/2/22.
//

import SwiftUI

struct DayView: View {
    @ObservedObject var viewModel: DayViewModel
    
    var body: some View {
        VStack {
            Text(viewModel.dayNumber)
            Text(viewModel.holidayText)
        }
    }
}

struct DayView_Previews: PreviewProvider {
    static var previews: some View {
        DayView(viewModel: DayViewModel(5, holiday: "test"))
            .previewLayout(.sizeThatFits)
    }
}

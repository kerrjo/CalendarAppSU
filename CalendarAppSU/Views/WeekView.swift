//
//  WeekView.swift
//  CalendarAppSU
//
//  Created by JOSEPH KERR on 2/2/22.
//

import SwiftUI

struct WeekView: View {
    @ObservedObject var viewModel: WeekViewModel

    var tap: some Gesture {
        TapGesture(count: 1).onEnded { _ in
            viewModel.didSelectDetails()
        }
    }

    var body: some View {
        VStack {
            HStack {
                ForEach(viewModel.days, id: \.id) { item in
                    DayView(viewModel: item)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .border(Color.red)
                }
            }

            if viewModel.isDetailsRevealed {
                HStack {
                    Text(viewModel.details.0)
                    Text(viewModel.details.1)
                }
                .gesture(tap)
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



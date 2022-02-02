//
//  ContentView.swift
//  CalendarAppSU
//
//  Created by JOSEPH KERR on 2/1/22.
//

import SwiftUI

struct DayNamesHeaderView: View {
    var body: some View {
        HStack {
            Text("Su")
                .frame(maxWidth: .infinity)
            Text("Mo")
                .frame(maxWidth: .infinity)
            Text("Tu")
                .frame(maxWidth: .infinity)
            Text("We")
                .frame(maxWidth: .infinity)
            Text("Th")
                .frame(maxWidth: .infinity)
            Text("Fr")
                .frame(maxWidth: .infinity)
            Text("Sa")
                .frame(maxWidth: .infinity)
        }
    }
}


struct ContentMonthView: View {
    @ObservedObject var viewModel: MonthViewModel
    var body: some View {
        VStack {
            Text(viewModel.yearMonthTitle)
                .fontWeight(.semibold)
                .font(.headline)
            Spacer(minLength: 20)
            DayNamesHeaderView()
            MonthView(viewModel: viewModel)
                .frame(maxWidth: .infinity)
        }
    }
}


struct ContentView: View {
    @StateObject var viewModel = MonthViewModel()
    
    var body: some View {
        VStack {
            Spacer(minLength: 32)

            Button(action: viewModel.previous) {
                HStack {
                       Image(systemName: "arrowtriangle.up.fill")
                           .font(.body)
                       Text("Previous")
                        .fontWeight(.semibold)
                        .font(.body)
                   }
                   .padding()
            }.buttonStyle(.borderless)

            Spacer(minLength: 20)
            ContentMonthView(viewModel: viewModel)

            Button(action: viewModel.next) {
                HStack {
                       Image(systemName: "arrowtriangle.down.fill")
                           .font(.body)
                       Text("Next")
                           .fontWeight(.semibold)
                           .font(.body)
                   }
                   .padding()
            }.buttonStyle(.borderless)
            
            Spacer(minLength: 32)

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
                .previewLayout(.sizeThatFits)
        }
    }
}

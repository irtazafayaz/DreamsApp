//
//  CalendarWidget.swift
//  DreamsApp
//
//  Created by Irtaza Fiaz on 23/02/2024.
//

import SwiftUI
import HorizonCalendar

struct CalendarWidget: View {
    
    @State private var selectedStartDate: DayComponents?
    @State private var selectedEndDate: DayComponents?
    @State private var calendar = Calendar(identifier: .gregorian)
    @StateObject private var calendarViewProxy = CalendarViewProxy()

    private var beginningDate: Date {
        let calendar = Calendar.current
        let components = DateComponents(year: 2020)
        return calendar.date(from: components)!
    }
    
    private var endDate: Date {
        return Date()
    }
    
    private func getBackgroundColor(_ day: DayComponents) -> Color {
        if day == selectedStartDate || day == selectedEndDate {
            return .blue
        }
        return .gray.opacity(0.2)
    }
    
    private func getForegroundColor(_ day: DayComponents) -> Color {
        if day == selectedStartDate || day == selectedEndDate {
            return .white
        }
        return .black
    }
    
    var body: some View {
        VStack {
            
            CalendarViewRepresentable(
                visibleDateRange: beginningDate...endDate,
                monthsLayout: .vertical,
                dataDependency: (selectedStartDate, endDate),
                proxy: calendarViewProxy
            )

            .verticalDayMargin(10)
            .horizontalDayMargin(10)
            .interMonthSpacing(30)
            
            .dayItemProvider { day in
                ZStack(alignment: .center) {
                    Circle()
                        .foregroundColor(getBackgroundColor(day))
                    Text("\(day.day)")
                        .foregroundStyle(getForegroundColor(day))
                }
                .calendarItemModel
            }
            
            .onDaySelection { day in
                selectedStartDate = day
            }
            
            .onAppear {
              calendarViewProxy.scrollToDay(containing: .now, scrollPosition: .centered, animated: false)
            }
            
        }
        .padding(.horizontal,20)
    }
}

#Preview {
    CalendarWidget()
}

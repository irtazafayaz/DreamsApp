//
//  CalendarWidget.swift
//  DreamsApp
//
//  Created by Irtaza Fiaz on 23/02/2024.
//

import SwiftUI
import HorizonCalendar

struct CalendarWidget: View {
    
    @State private var calendar = Calendar(identifier: .gregorian)
    @StateObject private var calendarViewProxy = CalendarViewProxy()
    @Binding var refreshCalendar: Bool  // Bind to the new refresh trigger
    @Binding var moveToChatScreen: Bool
    @Binding var selectedDate: DayComponents?
    var createdAtDates: [Date]
    
    private var beginningDate: Date {
        let calendar = Calendar.current
        let components = DateComponents(year: 2024, month: 3)
        return calendar.date(from: components)!
    }
    
    private var endDate: Date {
        return Date()
    }
    
    private func compareTwoDates(day: DayComponents) -> Bool {
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.year = day.month.year
        dateComponents.month = day.month.month
        dateComponents.day = day.day
        guard let date = calendar.date(from: dateComponents) else {
            return false
        }
        for createdAtDate in createdAtDates {
            if calendar.isDate(createdAtDate, equalTo: date, toGranularity: .day) {
                return true
            }
            print("Created Date \(createdAtDate) - Calendar Date \(date)")
        }
        return false
    }
    
    private func getBackgroundColor(_ day: DayComponents) -> Color {
        if compareTwoDates(day: day) {
            return Color(hex: Colors.primary.rawValue)
        }
        return .clear
    }

    
    private func getForegroundColor(_ day: DayComponents) -> Color {
        if compareTwoDates(day: day) {
            return .white
        }
        return .black
    }
    
    var body: some View {
        VStack {
            
            CalendarViewRepresentable(
                visibleDateRange: beginningDate...endDate,
                monthsLayout: .horizontal,
                dataDependency: (selectedDate, endDate),
                proxy: calendarViewProxy
            )
            
            .verticalDayMargin(10)
            .horizontalDayMargin(10)
            //            .interMonthSpacing(30)
            
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
                selectedDate = day
                moveToChatScreen.toggle()
            }
            
            .onAppear {
                calendarViewProxy.scrollToDay(containing: .now, scrollPosition: .firstFullyVisiblePosition(padding: 0), animated: false)
            }
            
        }
        .padding(.horizontal,20)
        .onChange(of: refreshCalendar) { _ in
            // This block doesn't need to do anything. It's just here to trigger a refresh.
        }
    }
}


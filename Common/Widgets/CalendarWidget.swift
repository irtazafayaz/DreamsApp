//
//  CalendarWidget.swift
//  DreamsApp
//
//  Created by Irtaza Fiaz on 23/02/2024.
//

import SwiftUI
import HorizonCalendar

struct CalendarWidget: View {
    
    // MARK: Data Members
    
    @State private var calendar = Calendar(identifier: .gregorian)
    @StateObject private var calendarViewProxy = CalendarViewProxy()
    var createdAtDates: [Date]

    // MARK: Binding Members
    
    @Binding var moveToChatScreen: Bool
    @Binding var selectedDate: DayComponents?
    
    var openChatWithMessages: ((Date?) -> Void)?
    
    // MARK: Date Ranges
    
    private var beginningDate: Date {
        let calendar = Calendar.current
        let components = DateComponents(year: 2024, month: 3)
        return calendar.date(from: components)!
    }
    
    private var endDate: Date {
        return Date()
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
                openChatWithMessages?(Utilities.convertDayToDate(day))
            }
            
            .onAppear {
                calendarViewProxy.scrollToDay(containing: .now, scrollPosition: .firstFullyVisiblePosition(padding: 0), animated: false)
            }
        }
        .padding(.horizontal,20)
    }
    
    // MARK: Helper Functions
    
    private func checkIfDayHasChatHistory(day: DayComponents) -> Bool {
        
        guard let date = Utilities.convertDayToDate(day) else { return false }
        for createdAtDate in createdAtDates {
            if calendar.isDate(createdAtDate, equalTo: date, toGranularity: .day) {
                return true
            }
        }
        return false
    }
    
    private func getBackgroundColor(_ day: DayComponents) -> Color {
        if checkIfDayHasChatHistory(day: day) {
            return Color(hex: Colors.primary.rawValue)
        }
        return .clear
    }

    
    private func getForegroundColor(_ day: DayComponents) -> Color {
        if checkIfDayHasChatHistory(day: day) {
            return .white
        }
        return .black
    }
    
}


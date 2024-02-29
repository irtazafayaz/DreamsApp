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
    @Binding var moveToChatScreen: Bool
    @Binding var selectedDate: DayComponents?

    private var beginningDate: Date {
        let calendar = Calendar.current
        let components = DateComponents(year: 2020)
        return calendar.date(from: components)!
    }
    
    private var endDate: Date {
        return Date()
    }
    
    private func getBackgroundColor(_ day: DayComponents) -> Color {
        if day == selectedDate {
            return .blue
        }
        return .gray.opacity(0.2)
    }
    
    private func getForegroundColor(_ day: DayComponents) -> Color {
        if day == selectedDate {
            return .white
        }
        return .black
    }
    
    var body: some View {
        VStack {
            
            CalendarViewRepresentable(
                visibleDateRange: beginningDate...endDate,
                monthsLayout: .vertical,
                dataDependency: (selectedDate, endDate),
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
                selectedDate = day
                moveToChatScreen.toggle()
            }
            
            .onAppear {
              calendarViewProxy.scrollToDay(containing: .now, scrollPosition: .centered, animated: false)
            }
            
        }
        .padding(.horizontal,20)
    }
}
//
//#Preview {
//    CalendarWidget(moveToChatScreen: .constant(false), selectedDate: .constant(DayComponents(month: MonthComponents(era: <#Int#>, year: <#Int#>, month: <#Int#>, isInGregorianCalendar: <#Bool#>), day: 1)))
//}

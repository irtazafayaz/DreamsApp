//
//  HorizonCalendarWrapper.swift
//  DreamsApp
//
//  Created by Irtaza Fiaz on 23/02/2024.
//

import Foundation
import SwiftUI
import HorizonCalendar

struct HorizonCalendarWrapper: UIViewRepresentable {
    
    
    func makeUIView(context: Context) -> some UIView {
        let calendarView = CalendarView(initialContent: makeContent())
        return calendarView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {}
    
    private func makeContent() -> CalendarViewContent {
        let calendar = Calendar.current
        let startDate = calendar.date(byAdding: .year, value: -1, to: Date())!
        let endDate = calendar.date(byAdding: .year, value: 1, to: Date())!
        
        return CalendarViewContent(
            calendar: calendar,
            visibleDateRange: startDate...endDate,
            monthsLayout: .vertical(options: VerticalMonthsLayoutOptions()))
    }
    
}



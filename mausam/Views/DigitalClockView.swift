//
//  DigitalClockView.swift
//  mausam
//
//  Created by Sanjana Shah on 7/25/26.
//

import SwiftUI

struct DigitalClockView:View {
    let timeZoneIdentifier : String
    
    private var timeZone: TimeZone {
        TimeZone(identifier: timeZoneIdentifier) ?? .current
    }
    var body: some View {
        TimelineView(.everyMinute) {context in
            Text(context.date.formatted(Date.FormatStyle(date: .omitted, time: .shortened, timeZone: timeZone)))
                .font(.system(size: 64, weight: .light))
        }
    }
}

//
//  DigitalClockView.swift
//  mausam
//
//  Created by Sanjana Shah on 7/25/26.
//

import SwiftUI

struct DigitalClockView:View {
    var body: some View {
        TimelineView(.everyMinute) {context in
            Text(context.date, format: .dateTime.hour().minute())
                .font(.system(size: 64, weight: .light))
        }
    }
}

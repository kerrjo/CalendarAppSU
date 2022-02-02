//
//  Holiday.swift
//  CalendarAppSU
//
//  Created by JOSEPH KERR on 2/1/22.
//

import Foundation

struct HolidayElement: Codable {
    let name, nameLocal, language, holidayDescription: String
    let country, location, type, date: String
    let dateYear, dateMonth, dateDay, weekDay: String

    enum CodingKeys: String, CodingKey {
        case name
        case nameLocal = "name_local"
        case language
        case holidayDescription = "description"
        case country, location, type, date
        case dateYear = "date_year"
        case dateMonth = "date_month"
        case dateDay = "date_day"
        case weekDay = "week_day"
    }
}

typealias Holidays = [HolidayElement]

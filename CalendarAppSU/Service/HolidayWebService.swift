//
//  HolidayWebService.swift
//  CalendarAppSU
//
//  Created by JOSEPH KERR on 2/1/22.
//

import Foundation

enum FetchError: Error {
    case error(Error)
    case malformedURL
    case statusCode
    case parse
    case badresponseData
    case badresponse
    case notImplemented
}

protocol HolidayWebService {
    func cancel()
    func fetchHolidays(year: Int, month: Int, day: Int, completion: @escaping (Result<Holidays, FetchError>) -> ())
    func holidayServiceURL(year: Int, month: Int, day: Int) -> URL?
}

extension HolidayWebService {
    func holidayServiceURL(year: Int, month: Int, day: Int) -> URL? {
        guard var components = URLComponents(string: "https://holidays.abstractapi.com/v1/") else { return nil }
        components.queryItems = [
            URLQueryItem(name: "api_key", value: "f27cda4192bc4425b8da32db7d3f925d"),
            URLQueryItem(name: "country", value: "US"),
            URLQueryItem(name: "year", value: "\(year)"),
            URLQueryItem(name: "month", value: "\(month)"),
            URLQueryItem(name: "day", value: "\(day)"),
        ]
        return components.url
    }
}

//
//  HolidayRetryService.swift
//  CalendarAppSU
//
//  Created by JOSEPH KERR on 2/2/22.
//

import Foundation
import Combine

/**
 A  HolidayWebService Class that submits a url request and retries on some errors
 
 */
class HolidayRetryService: HolidayWebService {
    
    private(set) var fetcher: HolidayFetcher?
    
    func fetchHolidays(year: Int, month: Int, day: Int, completion: @escaping (Result<Holidays, FetchError>) -> ()) {
        guard let url = holidayServiceURL(year: year, month: month, day: day) else { return completion(.failure(.malformedURL)) }

        // Early exit for testing

        //if day < 3 || day > 27 { /* proceed */ } else { return completion(.failure(.notImplemented)) }
        if day < 1 { /* proceed */ } else { return completion(.failure(.notImplemented)) }
        //if day < 2 { /* proceed */ } else { return completion(.failure(.notImplemented)) }
        
        fetcher = HolidayFetcher()
        fetcher?.fetch(url: url, completion: completion)
    }
    
    func cancel() {
        if fetcher != nil {
            print(#function, "cancelled")
            fetcher = nil
        } else {
            print(#function, "no fetcher")
        }
    }
}

/*
 */


/**
 A fetcher that submits url and processes response, retries if needed, and returns the decoded results on success

 - Note: dataTaskPublisher brought to you by gist from donnywals, `donnywals/RetryAfter.swift`
 https://www.donnywals.com/retrying-a-network-request-with-a-delay-in-combine/
 https://gist.github.com/donnywals/83985376d4f83842d505e2868c3498c3

 */
class HolidayFetcher {
    
    enum DataTaskError: Error {
        case rateLimit(UUID)
        case serverBusy(UUID)
        case invalidResponse
    }

    private var cancellables = Set<AnyCancellable>()
    
    typealias DataTaskOutput = URLSession.DataTaskPublisher.Output
    typealias DataTaskResult = Result<DataTaskOutput, Error>
    
    func fetch(url: URL, completion: @escaping (Result<Holidays, FetchError>) -> ()) {

        /// Upon response from `dataTaskPublisher`,  and  initial `tryMap` ...
    
        // analyze the response to ensure we have a response that we want to try
        // I transform output -> Result so we can work around the tryCatch later if we encountered a non-retryable error
        
        URLSession.shared.dataTaskPublisher(for: url)
            .tryMap({ (dataTaskOutput: DataTaskOutput) -> DataTaskResult in
                guard let response = dataTaskOutput.response as? HTTPURLResponse else {
                    completion(.failure(.badresponse))
                    throw DataTaskError.invalidResponse
                }
                
                // we want to retry a rate limit error
                if response.statusCode == 429 {
                    throw DataTaskError.rateLimit(UUID())
                }
                
                // we don't want to retry anything else
                return .success(dataTaskOutput)
            })
        // catch any errors
            .catch({ (error: Error) -> AnyPublisher<DataTaskResult, Error> in
                switch error {
                case DataTaskError.rateLimit(let uuid):
                    print("caught error: \(uuid)")
                    // return a Fail publisher that fails after 3 seconds, this means the `retry` will fire after 3s
                    return Fail(error: error)
                        .delay(for: 2, scheduler: DispatchQueue.main)
                        .eraseToAnyPublisher()
                default:
                    completion(.failure(.error(error)))
                    // We encountered a non-retryable error, wrap in Result so the publisher succeeds and we'll extract the error later
                    return Just(.failure(error))
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }
            })
            .retry(4)
            .tryMap({ result in
                // Result -> Result.Success or emit Result.Failure
                return try result.get()
            })
            .map { $0.data }
            .decode(type: Holidays.self, decoder: JSONDecoder())
            .sink(receiveCompletion: { completion in
                print(completion)
            }, receiveValue: { value in
                completion(.success(value))
            })
            .store(in: &cancellables)
    }
}

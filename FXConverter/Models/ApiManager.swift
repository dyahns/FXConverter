//
//  ApiManager.swift
//  FXConverter
//
//  Created by D Yahns on 12/10/2018.
//

import Foundation

class ApiManager {
    weak var consumer: RateDataConsumer?
    let decoder: JSONDecoder
    
    init(consumer: RateDataConsumer) {
        self.consumer = consumer
        
        decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        getRateData()
    }
    
    private func scheduleFetch() {
        let queue = DispatchQueue(label: "com.dyahns.FXConverter")
        queue.asyncAfter(deadline: .now() + 1) {
            self.getRateData()
        }
    }
    
    private func getRateData() {
        ApiManager.makeRequest(requeue: scheduleFetch) { [weak self] (data) in
            guard let manager = self else {
                // manager/consumer have been released
                return
            }

            guard let rateData = try? manager.decoder.decode(RateData.self, from: data) else {
                print("Can't parse server response")
                return
            }
            
            manager.consumer?.updateRates(with: rateData)
        }
    }
    
    static let url = URL(string: "https://revolut.duckdns.org/latest?base=EUR")!
    private static func makeRequest(requeue: @escaping () -> Void, completion: @escaping (Data)->()) {
        // print("Requesting rate data...")
        let dataTask = URLSession.shared.dataTask(with: url) { (data, response, error) -> Void in
            requeue()
            
            guard error == nil else {
                print(error!)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, let data = data else {
                print("Invalid response or empty data")
                return
            }
            
            completion(data)
        }
        
        dataTask.resume()
    }
}

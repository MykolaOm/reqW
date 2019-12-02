//
//  NetworkService.swift
//  servT
//
//  Created by Nikolas Omelianov on 30.11.2019.
//  Copyright © 2019 Nikolas Omelianov. All rights reserved.
//

import Foundation

class NetworkService {
    func postRequest(completion: @escaping (JsonModel) -> ()) {
        // Prepare params for POST
        let parameters = ["date": "\(Date.timeIntervalSinceReferenceDate)"]
        let url = URL(string: "http://www.ifsac.pw/mc/in?name=mykola")!
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
        }
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        //Do POST
        let task = session.dataTask(with: request, completionHandler: { data, response, error in
            guard error == nil else { return }
            guard let data = data else { return }
            do {
                guard let base64Encoded = String(data: data, encoding: .utf8) else { return }
                guard let decodedData = Data(base64Encoded: base64Encoded) else { return }
                guard let model = try? JSONDecoder().decode(JsonModel.self, from: decodedData) else { return }
                completion(model)
            } catch let error {
                print(error.localizedDescription)
            }
        })
        task.resume()
    }
}

//
//  NetworkingClient.swift
//  Swifty Protein
//
//  Created by MacBook Pro on 9/10/19.
//  Copyright © 2019 MacBook Pro. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class NetworkingClient {
    
    private let baseUrl: String = "https://files.rcsb.org/ligands/view//"
    
    func getLigand(ligandName: String, completion: @escaping (Data?, Error?) -> Void) {
        Alamofire.request(baseUrl + ligandName + "_ideal.pdb", method: .get).validate().responseData { (response) in
            if let error = response.error {
                completion(nil, error)
            } else if let value = response.result.value {
                let data = value
                completion(data, nil)
            }
        }
    }
}

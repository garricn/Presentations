//
//  Fetcher.swift
//  Phlickr
//
//  Created by Garric Nahapetian on 10/20/16.
//  Copyright © 2016 Garric Nahapetian. All rights reserved.
//

import GGNObservable

protocol ErrorOutputing {
    var errorOutput: Observable<ErrorType> { get }
}

protocol Fetching: ErrorOutputing {
    var output: Observable<NSDictionary> { get }

    func fetch(with request: NSMutableURLRequest)
}

class Fetcher: Fetching {
    let output = Observable<NSDictionary>()
    let errorOutput = Observable<ErrorType>()

    func fetch(with request: NSMutableURLRequest) {
        NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
            do {
                guard let dictionary = try NSJSONSerialization.JSONObjectWithData(
                    data!,
                    options: .AllowFragments
                    ) as? NSDictionary else { return }
                self.output.emit(dictionary)
            } catch {
                self.errorOutput.emit(error)
            }
        }.resume()
    }
}

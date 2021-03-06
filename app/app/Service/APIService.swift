//
//  APIService.swift
//  app
//
//  Created by rfl3 on 19/10/20.
//  Copyright © 2020 renacio. All rights reserved.
//

import Foundation
import Alamofire

class APIService {

    public static var shared = APIService()
    var genres: [Int: String] = [:]

    let apiKey = "62f7df73c60e2b4119f17e8514cb0ba6"
    let url = "https://api.themoviedb.org/3"
    let movieURL = "https://image.tmdb.org/t/p/w500"

    var totalPages = -1
    var page = -1

    init() {

        let parameters: [String: Any] = ["api_key": self.apiKey]
        let headers: HTTPHeaders = ["Content-Type": "application/json"]

        AF.request("\(self.url)/genre/movie/list",
            method: .get,
            parameters: parameters,
            encoding: URLEncoding.default,
            headers: headers).responseJSON { response in

                switch response.response?.statusCode {
                    case 200:
                        guard let data = response.data,
                            let genres = try? JSONDecoder().decode(GenreAPIResponse.self, from: data)
                            else { return }

                        genres.genres.forEach {
                            self.genres[$0.id] = $0.name
                        }

                        break
                    default:
                        break
                }

        }

    }

    func requestPopular(completion: @escaping (([Movie]?) -> Void)) {

        var parameters: [String: Any] = ["api_key": self.apiKey]
        if self.page != -1 {
            parameters["page"] = self.page
        }

        let headers: HTTPHeaders = ["Content-Type": "application/json"]

        AF.request("\(self.url)/movie/popular",
                   method: .get,
                   parameters: parameters,
                   encoding: URLEncoding.default,
                   headers: headers).responseJSON { response in

                    switch response.response?.statusCode {
                        case 200:
                            let decoder = JSONDecoder()
                            let formatter = DateFormatter()
                            formatter.dateFormat = "yyyy-MM-dd"
                            decoder.dateDecodingStrategy = .formatted(formatter)

                            guard let data = response.data,
                                let movies = try? decoder.decode(APIResponse.self, from: data)
                                else { return }

                            if self.page == -1 {
                                self.page = movies.page
                                self.totalPages = movies.totalPages
                            } else {
                                self.page += 1
                            }

                            completion(movies.results)
                            break
                        default:
                            completion(nil)
                            break
                    }
        }

    }

}

//
//  Movie.swift
//  Flicks
//
//  Created by Sethi, Pinkesh on 3/31/17.
//  Copyright © 2017 Intuit. All rights reserved.
//

import Foundation
import AFNetworking

private let movieDBUrl = "https://api.themoviedb.org/3/movie/"
private let params = ["api_key": "820d6e1a28229d4564b440ace769bbd9"]
private let posterPath = "https://image.tmdb.org/t/p/w500"
private let lowResolutionPosterPath = "https://image.tmdb.org/t/p/w342"

class Movie{
    
    var movieTitle: String?
    var moviePosterUrl: String?
    var movieOverView: String?
    var movieReleaseDate: String?
    var movieVoteAverage: Float?
    var moviePosterLowResolutionUrl: String?
    
    init(jsonMovieResponse: NSDictionary){
        movieTitle = jsonMovieResponse["title"] as? String
        if let posterEndPoint = jsonMovieResponse["poster_path"] as? String {
            moviePosterUrl = posterPath+posterEndPoint
            moviePosterLowResolutionUrl = lowResolutionPosterPath+posterEndPoint
        }else{
            moviePosterUrl =  nil
        }
        movieOverView = jsonMovieResponse["overview"] as? String
        movieReleaseDate = jsonMovieResponse["release_date"] as? String
        movieVoteAverage = jsonMovieResponse["vote_average"] as? Float
    }
    
    class func fecthMovieData(endPoint: String, successCallback: @escaping ([Movie]) -> Void, error: ((Error?) -> Void)?){
        let url = movieDBUrl+endPoint
        let networkManager = AFHTTPSessionManager()
        networkManager.get(url, parameters: params, progress: nil, success: {(operation, responseData) -> Void in
        
            let responseDataDic = responseData as? NSDictionary
            if let posts = responseDataDic?["results"] as? NSArray{
                var movies: [Movie] = []
                for post in posts as! [NSDictionary]{
                    movies.append(Movie(jsonMovieResponse:post))
                }
                print("Fetched movie data successfully")
                print(movies.count)
                successCallback(movies)
                }
            }, failure:{(operation, requestError) -> Void in
                print(requestError)
                error!(requestError)
        })
    }
    
   /* class func fetchMovies(successCallBack: @escaping ([Movie]) -> (), errorCallBack: ((Error?) -> ())?) {
        let apiKey = "820d6e1a28229d4564b440ace769bbd9"
        let url = URL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        let task: URLSessionDataTask = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            if let error = error {
                errorCallBack?(error)
            } else if let data = data,
                let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                //print(dataDictionary)
                if let posts = dataDictionary["results"] as? [NSDictionary]{
                    var movies: [Movie] = []
                    for post in posts as [NSDictionary]{
                    movies.append(Movie(jsonMovieResponse:post))
                    }
                    successCallBack(movies)
                }
            }
        }
        task.resume()
    } */
}

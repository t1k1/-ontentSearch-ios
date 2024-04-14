//
//  ContentService.swift
//  СontentSearch-ios
//
//  Created by Aleksey Kolesnikov on 13.04.2024.
//

import UIKit

// MARK: NetworkError

enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
    case decodeDataError
    case getImageError
}

// MARK: ContentService

final class ContentService {
    
    // MARK: Public variables
    
    static let shared = ContentService()
    
    // MARK: Private variables
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private let imageCache = NSCache<NSString, UIImage>()
    
    //MARK: - Initialization
    
    private init() { }
    
    // MARK: Public functions
    
    func fetchContent(
        searchText: String,
        completion: @escaping (Result<ContentModelResult, Error>) -> Void
    ) {
        assert(Thread.isMainThread)
        if task != nil {
            task?.cancel()
            task = nil
        }
        
        guard let url = getFinalURL(with: searchText) else {
            completion(.failure(NetworkError.decodeDataError))
            return
        }
        
        let task = urlSession.dataTask(with: url) { data, response, error in
            if let data = data,
               let response = response,
               let statusCode = (response as? HTTPURLResponse)?.statusCode
            {
                if 200 ..< 300 ~= statusCode {
                    do {
                        let decoder = JSONDecoder()
                        decoder.keyDecodingStrategy  = .convertFromSnakeCase
                        decoder.dateDecodingStrategy = .iso8601
                        
                        let contentSearchResult = try decoder.decode(ContentModelResult.self, from: data)
                        
                        completion(.success(contentSearchResult))
                        self.task = nil
                    } catch {
                        completion(.failure(NetworkError.decodeDataError))
                    }
                } else {
                    completion(.failure(NetworkError.httpStatusCode(statusCode)))
                }
            } else if let error = error {
                completion(.failure(NetworkError.urlRequestError(error)))
            } else {
                completion(.failure(NetworkError.urlSessionError))
            }
        }
        
        self.task = task
        task.resume()
    }
    
    func fetchImage(
        urlString: String,
        completion: @escaping (Result<UIImage, Error>) -> Void
    ) {
        let imageCacheKey = NSString(string: urlString)
        
        if let image = imageCache.object(forKey: imageCacheKey) {
            completion(.success(image))
            return
        }
        
        guard let imageUrl = URL(string: urlString.replacingOccurrences(of: "100", with: "1000")) else {
            completion(.failure(NetworkError.getImageError))
            return
        }
        
        let task = URLSession.shared.dataTask(with: imageUrl) { [weak self] data, response, error in
            guard let self = self,
                  let data = data,
                  let statusCode = (response as? HTTPURLResponse)?.statusCode,
                  let image = UIImage(data: data) else {
                completion(.failure(NetworkError.getImageError))
                return
            }
            if 200 ..< 300 ~= statusCode {
                self.imageCache.setObject(image, forKey: imageCacheKey)
                completion(.success(image))
            } else {
                completion(.failure(NetworkError.httpStatusCode(statusCode)))
            }
        }
        
        task.resume()
    }
}

// MARK: Private functions

private extension ContentService {
    func getFinalURL(with param: String) -> URL? {
        let baseUrlString = "https://itunes.apple.com/search?entity=movie,podcast,song&term="
        let finalUrlString = "\(baseUrlString)\(param.replacingOccurrences(of: " ", with: "+"))"
        return URL(string: finalUrlString)
    }
}

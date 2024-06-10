import Foundation
import Combine

public class NetworkManager {
   public static let shared = NetworkManager()
   private let baseURL = "https://api.themoviedb.org/3"
   private let apiKey = "909594533c98883408adef5d56143539"
   private let language = "en-US"

   public var session: URLSession = URLSession.shared

   private init() {}

    @available(iOS 13.0, *)
    public func fetchPopularMovies(page: Int = 1) -> AnyPublisher<[Movie], Error> {
        //Testing
        var urlComponents = URLComponents(string: "\(baseURL)/movie/popular")!
        urlComponents.queryItems = [
            URLQueryItem(name: "api_key", value: apiKey),
            URLQueryItem(name: "language", value: language),
            URLQueryItem(name: "page", value: "\(page)")
        ]
        
        var request = URLRequest(url: urlComponents.url!)
        request.httpMethod = "GET"
        
        return session.dataTaskPublisher(for: request)
            .subscribe(on: DispatchQueue.global(qos: .background)) // Perform network request on background thread
            .map(\.data)
            .decode(type: MovieResponse.self, decoder: JSONDecoder())
            .map { $0.results }
            .receive(on: DispatchQueue.main) // Ensure UI updates happen on the main thread
            .eraseToAnyPublisher()
    }
    @available(iOS 13.0, *)
    public func fetchLatestMovies(page: Int = 1) -> AnyPublisher<[Movie], Error> {
       //Testing
       var urlComponents = URLComponents(string: "\(baseURL)/movie/now_playing")!
       urlComponents.queryItems = [
           URLQueryItem(name: "api_key", value: apiKey),
           URLQueryItem(name: "language", value: language),
           URLQueryItem(name: "page", value: "\(page)")
       ]

       var request = URLRequest(url: urlComponents.url!)
       request.httpMethod = "GET"

       return session.dataTaskPublisher(for: request)
           .subscribe(on: DispatchQueue.global(qos: .background)) // Perform network request on background thread
           .map(\.data)
           .decode(type: MovieResponse.self, decoder: JSONDecoder())
           .map { $0.results }
           .receive(on: DispatchQueue.main) // Ensure UI updates happen on the main thread
           .eraseToAnyPublisher()
   }
    
    public func fetchMovieDetails(movieId: Int, completion: @escaping (Result<MovieDetails, Error>) -> Void) {
        let urlString = "https://api.themoviedb.org/3/movie/\(movieId)?api_key=\(apiKey)&language=en-US"
        
        guard let url = URL(string: urlString) else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                    completion(.failure(error))
                return
            }
            
            guard let data = data else {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let movieDetails = try decoder.decode(MovieDetails.self, from: data)
                    completion(.success(movieDetails))
            } catch {
                    completion(.failure(error))
            }
        }
        
        task.resume()
    }
}

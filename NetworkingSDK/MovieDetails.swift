import Foundation

public struct MovieDetails: Codable {
    public let id: Int
    public let title: String
    public let overview: String
    public let release_date: String
    public let runtime: Int
    public let vote_average: Double
    public let vote_count: Int
    public let backdrop_path: String?
}

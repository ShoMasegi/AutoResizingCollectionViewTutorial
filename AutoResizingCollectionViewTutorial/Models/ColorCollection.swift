import Foundation

struct ColorCollection: Decodable {
    let header: String
    let columnCount: Int
    let items: [ColorItem]
}
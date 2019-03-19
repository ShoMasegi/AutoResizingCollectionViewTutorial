import Foundation

struct ColorCollection: Decodable {
    let header: String
    let items: [ColorItem]
}
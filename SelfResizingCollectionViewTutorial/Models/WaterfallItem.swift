import Foundation

struct WaterfallItem: Decodable {
    let header: String
    let items: [ImageTextItem]
}

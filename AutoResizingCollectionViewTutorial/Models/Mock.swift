import Foundation

struct Mock: Decodable {
    let coverSection: ColorItem
    let automaticTextSection: TextItem
    let horizontalSection: [ColorCollection]
    let collectionSection: ColorCollection
    let waterfallSection: WaterfallItem
}

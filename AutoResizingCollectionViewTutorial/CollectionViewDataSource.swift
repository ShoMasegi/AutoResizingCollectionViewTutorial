import UIKit

enum Section {
    case cover(_ cover: ColorItem)
    case text(_ item: TextItem)
    case horizontal(_ collection: ColorCollection)
    case collection(_ collection: ColorCollection)
    case waterfall(_ item: WaterfallItem)

    static func makeItems(from mock: Mock) -> [Section] {
        var sections = [Section]()
        sections.append(.cover(mock.coverSection))
        sections.append(.text(mock.automaticTextSection))
        mock.horizontalSection.forEach {
            sections.append(.horizontal($0))
        }
        mock.collectionSection.forEach {
            sections.append(.collection($0))
        }
        sections.append(.waterfall(mock.waterfallSection))
        return sections
    }
}

final class CollectionViewDataSource: NSObject, UICollectionViewDataSource {
    func load(mock: Mock) {
        self.sections = Section.makeItems(from: mock)
    }

    override init() {
        super.init()
    }

    private(set) var sections: [Section] = []

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch sections[section] {
        case .cover, .text, .horizontal:
            return 1
        case let .collection(section):
            return section.items.count
        case let .waterfall(section):
            return section.items.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch sections[indexPath.section] {
        case let .cover(colorItem):
            let cell: CollectionViewCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
            cell.colorItem = colorItem
            return cell
        case let .text(textItem):
            let cell: LabelCollectionViewCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
            cell.textItem = textItem
            return cell
        case let .horizontal(collection):
            let cell: HorizontalCollectionViewCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
            cell.collection = collection
            return cell
        case let .collection(collection):
            let cell: CollectionViewCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
            cell.colorItem = collection.items[indexPath.item]
            return cell
        case let .waterfall(collection):
            let cell: ImageLabelCollectionViewCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
            cell.imageTextItem = collection.items[indexPath.item]
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let headerView: CollectionViewHeaderFooterView = collectionView
                .dequeueReusableSupplementaryView(ofKind: kind, for: indexPath)
            switch sections[indexPath.section] {
            case let .collection(collection):
                headerView.label.text = collection.header
            case let .horizontal(collection):
                headerView.label.text = collection.header
            case let .waterfall(collection):
                headerView.label.text = collection.header
            default:
                break
            }
            return headerView
        }
        return UICollectionReusableView()
    }
}

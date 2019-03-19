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
        sections.append(.collection(mock.collectionSection))
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
        case .cover:
            let cell: CollectionViewCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
            return cell
        case .text:
            let cell: LabelCollectionViewCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
            return cell
        case let .horizontal(section):
            let cell: HorizontalCollectionViewCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
            return cell
        case let .collection(section):
            let cell: CollectionViewCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
            return cell
        case let .waterfall(section):
            let cell: ImageLabelCollectionViewCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let headerView: CollectionViewHeaderFooterView = collectionView
                .dequeueReusableSupplementaryView(ofKind: kind, for: indexPath)
            return headerView
        }
        return UICollectionReusableView()
    }
}

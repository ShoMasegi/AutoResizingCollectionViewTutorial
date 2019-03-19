import UIKit

protocol CollectionViewLayoutDelegate: class {
    func collectionViewLayout(for section: Int) -> CollectionViewLayout.Layout
    func collectionView(_ collectionView: UICollectionView, layout: CollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    func collectionView(_ collectionView: UICollectionView, layout: CollectionViewLayout, headerHeightFor section: Int) -> CGFloat
    func collectionView(_ collectionView: UICollectionView, layout: CollectionViewLayout, footerHeightFor section: Int) -> CGFloat

    func collectionView(_ collectionView: UICollectionView, layout: CollectionViewLayout, minimumInteritemSpacingFor section: Int) -> CGFloat?
    func collectionView(_ collectionView: UICollectionView, layout: CollectionViewLayout, minimumLineSpacingFor section: Int) -> CGFloat?
    func collectionView(_ collectionView: UICollectionView, layout: CollectionViewLayout, sectionInsetFor section: Int) -> UIEdgeInsets?
}

extension CollectionViewLayout {
    func collectionView(_ collectionView: UICollectionView, layout: CollectionViewLayout, minimumInteritemSpacingFor section: Int) -> CGFloat? { return nil }
    func collectionView(_ collectionView: UICollectionView, layout: CollectionViewLayout, minimumLineSpacingFor section: Int) -> CGFloat? { return nil }
    func collectionView(_ collectionView: UICollectionView, layout: CollectionViewLayout, sectionInsetFor section: Int) -> UIEdgeInsets? { return nil }
}

final class CollectionViewLayout: UICollectionViewLayout {
    static let automaticSize = CGSize(width: CGFloat.greatestFiniteMagnitude, height: .greatestFiniteMagnitude)
    enum Layout {
        case flow(column: Int)
        case waterfall(column: Int)

        var column: Int {
            switch self {
            case let .flow(column): return column
            case let .waterfall(column): return column
            }
        }
    }

    weak var delegate: CollectionViewLayoutDelegate?

    override init() {
        super.init()
    }
    required init?(coder aDecoder: NSCoder) { fatalError() }

    override var collectionViewContentSize: CGSize {
        return super.collectionViewContentSize
    }

    private var allItemAttributes = [UICollectionViewLayoutAttributes]()
    private var cachedItemSizes = [IndexPath: CGSize]()
    private var columnOffsetsY = [[CGFloat]]()

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return newBounds.width != (collectionView?.bounds ?? .zero).width
    }

    override func shouldInvalidateLayout(
            forPreferredLayoutAttributes preferredAttributes: UICollectionViewLayoutAttributes,
            withOriginalAttributes originalAttributes: UICollectionViewLayoutAttributes
    ) -> Bool {
        guard let delegate = delegate, let collectionView = collectionView else {
            return false
        }
        let itemSize = delegate.collectionView(collectionView,
                                               layout: self,
                                               sizeForItemAt: originalAttributes.indexPath)
        if itemSize == CollectionViewLayout.automaticSize {
            return cachedItemSizes[originalAttributes.indexPath] != preferredAttributes.size
        }
        return super.shouldInvalidateLayout(forPreferredLayoutAttributes: preferredAttributes,
                                            withOriginalAttributes: originalAttributes)
    }

    override func invalidateLayout(with context: UICollectionViewLayoutInvalidationContext) {
        allItemAttributes.removeAll()
        columnOffsetsY.removeAll()
        super.invalidateLayout(with: context)
    }

    override func invalidationContext(
            forPreferredLayoutAttributes preferredAttributes: UICollectionViewLayoutAttributes,
            withOriginalAttributes originalAttributes: UICollectionViewLayoutAttributes
    ) -> UICollectionViewLayoutInvalidationContext {
        cachedItemSizes[originalAttributes.indexPath] = preferredAttributes.size
        return super.invalidationContext(forPreferredLayoutAttributes: preferredAttributes,
                                         withOriginalAttributes: originalAttributes)
    }

    override func prepare() {
        super.prepare()
        guard let collectionView = collectionView, let delegate = delegate else {
            return
        }
        let numberOfSections = collectionView.numberOfSections
        guard numberOfSections > 0 else { return }

        (0 ..< numberOfSections).forEach { section in
            let columnCount = delegate.collectionViewLayout(for: section).column
            columnOffsetsY.append(Array(repeating: 0.0, count: columnCount))
        }

        var position: CGFloat = 0.0
        (0 ..< numberOfSections).forEach { section in
            layoutHeader(position: &position, collectionView: collectionView, delegate: delegate, section: section)
            layoutItems(position: position, collectionView: collectionView, delegate: delegate, section: section)
            layoutFooter(position: &position, collectionView: collectionView, delegate: delegate, section: section)
        }
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return allItemAttributes.filter { rect.intersects($0.frame) }
    }

    private func layoutHeader(
        position: inout CGFloat,
        collectionView: UICollectionView,
        delegate: CollectionViewLayoutDelegate,
        section: Int
    ) {
        let headerHeight = delegate.collectionView(collectionView,
                                                   layout: self,
                                                   headerHeightFor: section)
        if headerHeight > CGFloat.leastNonzeroMagnitude {
            let layoutAttributes = UICollectionViewLayoutAttributes(
                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                with: IndexPath(item: 0, section: section)
            )
            layoutAttributes.frame = CGRect(
                x: 0,
                y: position,
                width: collectionView.bounds.width,
                height: headerHeight
            )
            allItemAttributes.append(layoutAttributes)
            position = layoutAttributes.frame.maxY
        }
    }

    private func layoutItems(
        position: CGFloat,
        collectionView: UICollectionView,
        delegate: CollectionViewLayoutDelegate,
        section: Int
    ) {
        let layout = delegate.collectionViewLayout(for: section)
        let columnCount = layout.column
        let sectionInset = self.sectionInset(for: section)
        let minimumLineSpacing = self.minimumLineSpacing(for: section)
        let minimumInteritemSpacing = self.minimumInteritemSpacing(for: section)
        let width = collectionView.bounds.width - (sectionInset.left + sectionInset.right)
        let itemWidth = floor(width - CGFloat(columnCount - 1) * minimumLineSpacing) / CGFloat(columnCount)
        let itemCount = collectionView.numberOfItems(inSection: section)

        var itemsLayoutAttributes = [UICollectionViewLayoutAttributes]()

        (0 ..< itemCount).forEach { itemIndex in
            let indexPath = IndexPath(item: itemIndex, section: section)
            let columnIndex = pickColumn(indexPath: indexPath, delegate: delegate)
            let itemSize = delegate.collectionView(collectionView, layout: self, sizeForItemAt: indexPath)
            let itemHeight: CGFloat
            if itemSize == CollectionViewLayout.automaticSize {
                itemHeight = (cachedItemSizes[indexPath] ?? .zero).height
            } else {
                cachedItemSizes[indexPath] = itemSize
                itemHeight = itemSize.height > 0 && itemSize.width > 0 ?
                             floor(itemSize.height * itemWidth / itemSize.width) :
                             0.0
            }
            let offsetY: CGFloat
            switch layout {
            case let .flow(column):
                offsetY = itemIndex < columnCount ? position : columnOffsetsY[section][columnIndex]
            case let .waterfall:
                offsetY = columnOffsetsY[section][columnIndex]
            }

            let layoutAttributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            layoutAttributes.frame = CGRect(
                x: sectionInset.left + (itemWidth + minimumLineSpacing) * CGFloat(columnIndex),
                y: offsetY,
                width: itemWidth,
                height: itemHeight
            )
            columnOffsetsY[section][columnIndex] = layoutAttributes.frame.maxY + minimumInteritemSpacing
            itemsLayoutAttributes.append(layoutAttributes)
        }
        allItemAttributes.append(contentsOf: itemsLayoutAttributes)
    }

    private func layoutFooter(
        position: inout CGFloat,
        collectionView: UICollectionView,
        delegate: CollectionViewLayoutDelegate,
        section: Int
    ) {
        let maxOffsetY = columnOffsetsY[section].sorted { $0 > $1 }.first ?? 0.0
        position = maxOffsetY

        let footerHeight = delegate.collectionView(collectionView, layout: self, footerHeightFor: section)
        if footerHeight > CGFloat.leastNonzeroMagnitude {
            let layoutAttributes = UICollectionViewLayoutAttributes(
                forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                with: IndexPath(item: 0, section: section)
            )
            layoutAttributes.frame = CGRect(
                x: 0,
                y: maxOffsetY,
                width: collectionView.bounds.width,
                height: footerHeight
            )
            allItemAttributes.append(layoutAttributes)
            position = layoutAttributes.frame.maxY
        }
    }

    private func pickColumn(
        indexPath: IndexPath,
        delegate: CollectionViewLayoutDelegate
    ) -> Int {
        let layout = delegate.collectionViewLayout(for: indexPath.section)
        switch layout {
        case .flow:
            return indexPath.item % layout.column
        case .waterfall:
            var minColumn = 0
            var minHeight = CGFloat.greatestFiniteMagnitude
            columnOffsetsY[indexPath.section].enumerated().forEach { column, height in
                if height < minHeight {
                    minColumn = column
                    minHeight = height
                }
            }
            return minColumn
        }
    }

    private func minimumLineSpacing(for section: Int) -> CGFloat {
        return collectionView.flatMap { delegate?.collectionView($0, layout: self, minimumLineSpacingFor: section) } ?? .leastNonzeroMagnitude
    }

    private func minimumInteritemSpacing(for section: Int) -> CGFloat {
        return collectionView.flatMap { delegate?.collectionView($0, layout: self, minimumInteritemSpacingFor: section) } ?? .leastNonzeroMagnitude
    }

    private func sectionInset(for section: Int) -> UIEdgeInsets {
        return collectionView.flatMap { delegate?.collectionView($0, layout: self, sectionInsetFor: section) } ?? .zero
    }
}

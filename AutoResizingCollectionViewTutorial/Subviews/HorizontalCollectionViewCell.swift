import UIKit

final class HorizontalCollectionViewCell: UICollectionViewCell, NibLoadable, Reusable {

    var collection: ColorCollection? {
        didSet {
            collectionView.reloadData()
        }
    }

    private let layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        layout.minimumLineSpacing = 8
        layout.itemSize = CGSize(width: 100, height: 100)
        return layout
    }()

    @IBOutlet private weak var collectionView: UICollectionView! {
        didSet {
            collectionView.collectionViewLayout = layout
            collectionView.dataSource = self
            collectionView.register(CollectionViewCell.self)
        }
    }
}

extension HorizontalCollectionViewCell: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return collection?.items.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: CollectionViewCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
        cell.contentView.layer.cornerRadius = 8
        cell.contentView.clipsToBounds = true
        cell.colorItem = collection?.items[indexPath.item]
        return cell
    }
}

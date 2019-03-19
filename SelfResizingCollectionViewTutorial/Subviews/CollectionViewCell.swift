import UIKit

final class CollectionViewCell: UICollectionViewCell, NibLoadable, Reusable {

    var colorItem: ColorItem? {
        didSet {
            contentView.backgroundColor = UIColor(hex: colorItem?.color ?? "")
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .white
    }
}

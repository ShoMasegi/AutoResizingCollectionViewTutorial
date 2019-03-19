import UIKit

final class LabelCollectionViewCell: UICollectionViewCell, NibLoadable, Reusable {

    var textItem: TextItem? {
        didSet {
            guard let textItem = textItem else { return }
            titleLabel.text = textItem.title
            descriptionLabel.text = textItem.description
            layoutIfNeeded()
        }
    }

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
}

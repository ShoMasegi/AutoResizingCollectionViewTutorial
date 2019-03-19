import UIKit
import Kingfisher

final class ImageLabelCollectionViewCell: UICollectionViewCell, NibLoadable, Reusable {

    var imageTextItem: ImageTextItem? {
        didSet {
            guard let item = imageTextItem,
                  let url = URL(string: item.imageUrl) else { return }
            imageView.kf.setImage(with: url)
            titleLabel.text = item.title
            layoutIfNeeded()
        }
    }

    @IBOutlet private weak var imageView: StretchImageView! {
        didSet {
            imageView.layer.cornerRadius = 8
            imageView.clipsToBounds = true
            imageView.contentMode = .scaleAspectFit
        }
    }
    @IBOutlet private weak var titleLabel: UILabel!
}

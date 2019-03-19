import UIKit

final class StretchImageView: UIImageView {
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        guard let image = self.image else {
            return super.sizeThatFits(size)
        }

        let newHeight = size.width * (image.size.height / image.size.width)
        return CGSize(width: size.width, height: newHeight)
    }

    override var intrinsicContentSize: CGSize {
        return sizeThatFits(bounds.size)
    }
}

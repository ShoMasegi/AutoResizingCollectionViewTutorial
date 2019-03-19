import UIKit

final class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource.load(mock: mock)
        collectionView.reloadData()
    }

    private let dataSource = CollectionViewDataSource()
    private lazy var layout: CollectionViewLayout = {
        let layout = CollectionViewLayout()
        layout.delegate = self
        return layout
    }()

    @IBOutlet private weak var collectionView: UICollectionView! {
        didSet {
            collectionView.contentInset = UIEdgeInsets(
                top: -UIApplication.shared.statusBarFrame.height,
                left: 0,
                bottom: 0,
                right: 0
            )
            collectionView.dataSource = dataSource
            collectionView.collectionViewLayout = layout
            collectionView.register(CollectionViewCell.self)
            collectionView.register(LabelCollectionViewCell.self)
            collectionView.register(ImageLabelCollectionViewCell.self)
            collectionView.register(HorizontalCollectionViewCell.self)
            collectionView.register(CollectionViewHeaderFooterView.self,
                                   forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader)
        }
    }

    private lazy var mock: Mock = {
        guard let path = Bundle.main.path(forResource: "mock", ofType: "json") else {
            fatalError("Json file not found")
        }
        let data = try! Data(contentsOf: URL(fileURLWithPath: path))
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try! decoder.decode(Mock.self, from: data)
    }()
}

extension ViewController: CollectionViewLayoutDelegate {

    func collectionViewLayout(for section: Int) -> CollectionViewLayout.Layout {
        switch dataSource.sections[section] {
        case .cover, .horizontal, .text:
            return .flow(column: 1)
        case let .collection(collection):
            return .flow(column: collection.columnCount)
        case .waterfall:
            return .waterfall(column: 2)
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout: CollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch dataSource.sections[indexPath.section] {
        case .text, .waterfall:
            return CollectionViewLayout.automaticSize
        case .cover:
            let width = collectionView.bounds.width
            return CGSize(width: width, height: width)
        case .collection:
            return CGSize(width: 200, height: 200)
        case .horizontal:
            let width = collectionView.bounds.width
            return CGSize(width: width, height: 100)
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout: CollectionViewLayout,
                        headerHeightFor section: Int) -> CGFloat {
        switch dataSource.sections[section] {
        case .cover, .text:
            return .leastNonzeroMagnitude
        default:
            return 44
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout: CollectionViewLayout,
                        footerHeightFor section: Int) -> CGFloat {
        return .leastNonzeroMagnitude
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout: CollectionViewLayout,
                        sectionInsetFor section: Int) -> UIEdgeInsets? {
        switch dataSource.sections[section] {
        case .cover, .horizontal:
            return nil
        default:
            return UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout: CollectionViewLayout,
                        minimumLineSpacingFor section: Int) -> CGFloat? {
        return 6
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout: CollectionViewLayout,
                        minimumInteritemSpacingFor section: Int) -> CGFloat? {
        return 6
    }
}

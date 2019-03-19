import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let demo = mock
    }

    private let layout: CollectionViewLayout = {
        let layout = CollectionViewLayout()
        return layout
    }()

    @IBOutlet private weak var collectionView: UICollectionView! {
        didSet {
            collectionView.collectionViewLayout = layout
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

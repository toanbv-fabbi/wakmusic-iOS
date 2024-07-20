import BaseFeature
import DesignSystem
import Kingfisher
import RxCocoa
import RxSwift
import SnapKit
import Then
import UIKit

final class SongCreditViewController: BaseReactorViewController<SongCreditReactor> {
    private typealias SectionType = String
    private typealias ItemType = CreditModel.CreditWorker

    private let songCreditCollectionView = UICollectionView(frame: .zero, collectionViewLayout: .init()).then {
        let songCreditLayout = CreditCollectionViewLayout()
        $0.collectionViewLayout = songCreditLayout
        $0.contentInset = .init(top: 20, left: 20, bottom: 20, right: 20)
        $0.backgroundColor = .clear
    }

    private lazy var creditPositionHeaderViewRegistration = UICollectionView.SupplementaryRegistration<
        CreditCollectionViewPositionHeaderView
    >(
        elementKind: UICollectionView.elementKindSectionHeader
    ) { [reactor] supplementaryView, _, indexPath in
        let position = reactor?.currentState.credits[safe: indexPath.section]?.position ?? ""
        supplementaryView.configure(position: position)
    }

    private lazy var creditCellRegistration = UICollectionView.CellRegistration<
        CreditCollectionViewCell, ItemType
    > { cell, _, itemIdentifier in
        cell.configure(name: itemIdentifier.name)
    }

    private lazy var creditDiffableDataSource = UICollectionViewDiffableDataSource<SectionType, ItemType>(
        collectionView: songCreditCollectionView
    ) { [creditCellRegistration] collectionView, indexPath, itemIdentifier in
        let cell = collectionView.dequeueConfiguredReusableCell(
            using: creditCellRegistration,
            for: indexPath,
            item: itemIdentifier
        )
        return cell
    }.then {
        $0.supplementaryViewProvider = { [creditPositionHeaderViewRegistration] collectionView, kind, index in
            if kind == UICollectionView.elementKindSectionHeader {
                return collectionView.dequeueConfiguredReusableSupplementary(
                    using: creditPositionHeaderViewRegistration,
                    for: index
                )
            } else {
                fatalError()
            }
        }
    }

    private let backgroundImageView = UIImageView().then {
        $0.backgroundColor = .gray
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
    }
    private let dimmedBackgroundView = UIView()
    private var dimmedGridentLayer: DimmedGradientLayer?

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if dimmedGridentLayer == nil {
            let dimmedGridentLayer = DimmedGradientLayer(frame: dimmedBackgroundView.bounds)
            dimmedBackgroundView.layer.insertSublayer(dimmedGridentLayer, at: 0)
            self.dimmedGridentLayer = dimmedGridentLayer
        }
    }

    override func addView() {
        view.addSubviews(backgroundImageView, dimmedBackgroundView, songCreditCollectionView)
    }

    override func setLayout() {
        songCreditCollectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        backgroundImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        dimmedBackgroundView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    override func bindAction(reactor: SongCreditReactor) {
        self.rx.methodInvoked(#selector(viewDidLoad))
            .map { _ in Reactor.Action.viewDidLoad }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }

    override func bindState(reactor: SongCreditReactor) {
        let sharedState = reactor.state.share()

        sharedState.map(\.credits)
            .distinctUntilChanged()
            .bind { [creditDiffableDataSource] credits in
                var snapshot = NSDiffableDataSourceSnapshot<SectionType, ItemType>()
                snapshot.appendSections(credits.map(\.position))
                credits.forEach { snapshot.appendItems($0.names, toSection: $0.position) }
                creditDiffableDataSource.apply(snapshot)
            }
            .disposed(by: disposeBag)

        sharedState.map(\.backgroundImageURL)
            .bind(with: backgroundImageView) { backgroundImageView, url in
                backgroundImageView.kf.setImage(
                    with: URL(string: url),
                    options: [
                        .transition(.fade(0.5)),
                        .processor(
                            DownsamplingImageProcessor(
                                size: .init(width: 10, height: 10)
                            )
                        )
                    ]
                )
            }
            .disposed(by: disposeBag)
    }
}

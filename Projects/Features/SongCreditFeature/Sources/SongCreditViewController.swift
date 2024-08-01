import BaseFeature
import CreditSongListFeatureInterface
import DesignSystem
import Kingfisher
import Localization
import RxCocoa
import RxSwift
import SnapKit
import Then
import UIKit
import Utility

final class SongCreditViewController: BaseReactorViewController<SongCreditReactor> {
    private typealias SectionType = String
    private typealias ItemType = CreditModel.CreditWorker

    private let songCreditCollectionView = UICollectionView(frame: .zero, collectionViewLayout: .init()).then {
        let songCreditLayout = CreditCollectionViewLayout()
        $0.collectionViewLayout = songCreditLayout
        $0.contentInset = .init(top: 40, left: 20, bottom: 20, right: 20)
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

    private let dismissButton = UIButton(type: .system).then {
        $0.setImage(DesignSystemAsset.Navigation.back.image, for: .normal)
        $0.tintColor = .white
    }

    private let backgroundImageView = UIImageView().then {
        $0.backgroundColor = .gray
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
    }

    private let dimmedBackgroundView = UIView()
    private var dimmedGridentLayer: DimmedGradientLayer?
    private let wmNavigationbarView = WMNavigationBarView()

    private let creditSongListFactory: any CreditSongListFactory

    init(
        reactor: SongCreditReactor,
        creditSongListFactory: any CreditSongListFactory
    ) {
        self.creditSongListFactory = creditSongListFactory
        super.init(reactor: reactor)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if dimmedGridentLayer == nil {
            let dimmedGridentLayer = DimmedGradientLayer(frame: dimmedBackgroundView.bounds)
            dimmedBackgroundView.layer.insertSublayer(dimmedGridentLayer, at: 0)
            self.dimmedGridentLayer = dimmedGridentLayer
        }
    }

    override func addView() {
        view.addSubviews(backgroundImageView, dimmedBackgroundView, songCreditCollectionView, wmNavigationbarView)
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

        wmNavigationbarView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(STATUS_BAR_HEGHIT())
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(48)
        }
    }

    override func configureNavigation() {
        wmNavigationbarView.setLeftViews([dismissButton])
        wmNavigationbarView.setTitle(LocalizationStrings.titleCreditList, textColor: .white)
    }

    override func bindAction(reactor: SongCreditReactor) {
        self.rx.methodInvoked(#selector(viewDidLoad))
            .map { _ in Reactor.Action.viewDidLoad }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        dismissButton.rx.tap
            .map { Reactor.Action.backButtonDidTap }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        songCreditCollectionView.rx.itemSelected
            .compactMap { [reactor] indexPath in
                reactor.currentState.credits[safe: indexPath.section]?.names[safe: indexPath.row]
            }
            .map(Reactor.Action.creditSelected(worker:))
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

        sharedState
            .compactMap(\.navigateType)
            .bind(with: self) { owner, navigate in
                switch navigate {
                case .back:
                    owner.back()

                case let .creditDetail(name):
                    owner.navigateCreditDetail(name: name)
                }
            }
            .disposed(by: disposeBag)
    }
}

private extension SongCreditViewController {
    func back() {
        self.navigationController?.popViewController(animated: true)
    }

    func navigateCreditDetail(name: String) {
        let viewController = creditSongListFactory.makeViewController(workerName: name)
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}
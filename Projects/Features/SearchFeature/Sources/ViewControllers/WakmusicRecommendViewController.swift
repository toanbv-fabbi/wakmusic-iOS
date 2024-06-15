import BaseFeature
import DesignSystem
import LogManager
import PlayListDomainInterface
import PlaylistFeatureInterface
import UIKit
import Utility

#warning("실제 데이터 및 이벤트 연결")
final class WakmusicRecommendViewController: BaseReactorViewController<WakmusicRecommendReactor> {
    private let wmNavigationbarView = WMNavigationBarView().then {
        $0.setTitle("왁뮤팀이 추천하는 리스트")
    }

    private let dismissButton = UIButton().then {
        let dismissImage = DesignSystemAsset.Navigation.back.image
        $0.setImage(dismissImage, for: .normal)
    }

    private lazy var collectionView: UICollectionView = createCollectionView().then {
        $0.backgroundColor = .clear
    }

    private lazy var dataSource: UICollectionViewDiffableDataSource<RecommendSection, RecommendPlayListEntity> =
        createDataSource()

    private let playlistDetailFactory: any PlaylistDetailFactory

    init(playlistDetailFactory: any PlaylistDetailFactory, reactor: WakmusicRecommendReactor) {
        self.playlistDetailFactory = playlistDetailFactory
        super.init(reactor: reactor)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = DesignSystemAsset.BlueGrayColor.gray100.color
        reactor?.action.onNext(.viewDidLoad)
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
    }

    override func addView() {
        super.addView()
        self.view.addSubviews(wmNavigationbarView, collectionView)
    }

    override func setLayout() {
        super.setLayout()

        wmNavigationbarView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(STATUS_BAR_HEGHIT())
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(48)
        }
        wmNavigationbarView.setLeftViews([dismissButton])

        collectionView.snp.makeConstraints {
            $0.top.equalTo(wmNavigationbarView.snp.bottom)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }

    override func bind(reactor: WakmusicRecommendReactor) {
        super.bind(reactor: reactor)
        collectionView.delegate = self
    }

    override func bindState(reactor: WakmusicRecommendReactor) {
        super.bindState(reactor: reactor)
        let sharedState = reactor.state.share()

        sharedState.map(\.dataSource)
            .distinctUntilChanged()
            .withUnretained(self)
            .bind(onNext: { owner, recommendPlaylist in

                var snapShot = owner.dataSource.snapshot(for: .main)
                snapShot.append(recommendPlaylist)
                owner.dataSource.apply(snapShot, to: .main)

            })
            .disposed(by: disposeBag)

        sharedState.map(\.isLoading)
            .distinctUntilChanged()
            .withUnretained(self)
            .bind { owner, isLoading in
                if isLoading {
                    owner.indicator.startAnimating()
                } else {
                    owner.indicator.stopAnimating()
                }
            }
            .disposed(by: disposeBag)
    }
}

extension WakmusicRecommendViewController {
    private func createCollectionView() -> UICollectionView {
        return UICollectionView(frame: .zero, collectionViewLayout: RecommendCollectionViewLayout())
    }

    private func createDataSource() -> UICollectionViewDiffableDataSource<RecommendSection, RecommendPlayListEntity> {
        let recommendCellRegistration = UICollectionView.CellRegistration<
            RecommendPlayListCell,
            RecommendPlayListEntity
        >(cellNib: UINib(
            nibName: "RecommendPlayListCell",
            bundle: BaseFeatureResources.bundle
        )) { cell, indexPath, item in
            cell.update(
                model: item
            )
        }
        let dataSource = UICollectionViewDiffableDataSource<
            RecommendSection,
            RecommendPlayListEntity
        >(collectionView: collectionView) {
            (
                collectionView: UICollectionView, indexPath: IndexPath, item: RecommendPlayListEntity
            ) -> UICollectionViewCell? in

            return
                collectionView.dequeueConfiguredReusableCell(
                    using: recommendCellRegistration,
                    for: indexPath,
                    item: item
                )
        }

        return dataSource
    }

    private func initDataSource() {
        // initial data
        var snapshot = NSDiffableDataSourceSnapshot<RecommendSection, RecommendPlayListEntity>()

        snapshot.appendSections([.main])

        dataSource.apply(snapshot, animatingDifferences: false)
    }
}

extension WakmusicRecommendViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let model = dataSource.itemIdentifier(for: indexPath) else {
            return
        }

        self.navigationController?.pushViewController(
            playlistDetailFactory.makeView(id: model.key, isCustom: false),
            animated: true
        )
    }
}
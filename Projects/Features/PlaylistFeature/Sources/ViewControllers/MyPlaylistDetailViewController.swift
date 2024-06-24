import BaseFeature
import BaseFeatureInterface
import DesignSystem
import ReactorKit
import SnapKit
import SongsDomainInterface
import Then
import UIKit
import Utility

final class MyPlaylistDetailViewController: BaseReactorViewController<MyPlaylistDetailReactor>, EditSheetViewType,
    SongCartViewType {
    var songCartView: BaseFeature.SongCartView!

    var editSheetView: EditSheetView!

    var bottomSheetView: BottomSheetView!

    //   private let multiPurposePopUpFactory: any MultiPurposePopUpFactory

    private var wmNavigationbarView: WMNavigationBarView = WMNavigationBarView()

    private var lockButton: UIButton = UIButton()
    private let lockImage = DesignSystemAsset.Playlist.lock.image
    private let unLockImage = DesignSystemAsset.Playlist.unLock.image

    fileprivate let dismissButton = UIButton().then {
        let dismissImage = DesignSystemAsset.Navigation.back.image
            .withTintColor(DesignSystemAsset.BlueGrayColor.blueGray900.color, renderingMode: .alwaysOriginal)
        $0.setImage(dismissImage, for: .normal)
    }

    private var moreButton: UIButton = UIButton().then {
        $0.setImage(DesignSystemAsset.MyInfo.more.image, for: .normal)
    }

    private var headerView: MyPlaylistHeaderView = MyPlaylistHeaderView(frame: .init(
        x: .zero,
        y: .zero,
        width: APP_WIDTH(),
        height: 140
    ))

    private lazy var tableView: UITableView = UITableView().then {
        $0.backgroundColor = .clear
        $0.register(PlaylistTableViewCell.self, forCellReuseIdentifier: PlaylistTableViewCell.identifier)
        $0.tableHeaderView = headerView
        $0.separatorStyle = .none
    }

    private lazy var completeButton: RectangleButton = RectangleButton().then {
        $0.setBackgroundColor(.clear, for: .normal)
        $0.setColor(isHighlight: true)
        $0.setTitle("완료", for: .normal)
        $0.titleLabel?.font = .init(font: DesignSystemFontFamily.Pretendard.bold, size: 12)
        $0.layer.borderWidth = 1
        $0.layer.cornerRadius = 4
    }

    lazy var dataSource: MyplaylistDetailDataSource = createDataSource()

    #warning("추후 의존성 추가")
//    init(reactor: MyPlaylistDetailReactor, multiPurposePopUpFactory: any MultiPurposePopUpFactory) {
//        self.multiPurposePopUpFactory = multiPurposePopUpFactory
//        super.init(reactor: reactor)
//    }
//

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
        self.view.addSubviews(wmNavigationbarView, tableView)
        wmNavigationbarView.setLeftViews([dismissButton])
        wmNavigationbarView.setRightViews([lockButton, moreButton, completeButton])
    }

    override func setLayout() {
        super.setLayout()

        wmNavigationbarView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(STATUS_BAR_HEGHIT())
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(48)
        }

        tableView.snp.makeConstraints {
            $0.top.equalTo(wmNavigationbarView.snp.bottom).offset(8)
            $0.leading.trailing.bottom.equalToSuperview()
        }

        completeButton.snp.makeConstraints {
            $0.width.equalTo(45)
            $0.height.equalTo(24)
            $0.bottom.equalToSuperview().offset(-5)
        }
    }

    override func configureUI() {
        super.configureUI()
    }

    override func bind(reactor: MyPlaylistDetailReactor) {
        super.bind(reactor: reactor)
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
    }

    override func bindAction(reactor: MyPlaylistDetailReactor) {
        super.bindAction(reactor: reactor)

        let sharedState = reactor.state.share()

        lockButton.rx
            .tap
            .asDriver()
            .throttle(.seconds(1))
            .drive(onNext: { [weak self] _ in

                reactor.action.onNext(.privateButtonDidTap)

            })
            .disposed(by: disposeBag)

        dismissButton.rx
            .tap
            .withLatestFrom(sharedState.map(\.isEditing))
            .bind(with: self) { owner, isEditing in

                if isEditing {
                    #warning("경고 팝업 후 되돌릭")

                    reactor.action.onNext(.restore)

                } else {
                    owner.navigationController?.popViewController(animated: true)
                }
            }
            .disposed(by: disposeBag)

        moreButton.rx
            .tap
            .bind(with: self) { owner, _ in
                #warning("추후 바텀시트로 팝업으로 교체")
                reactor.action.onNext(.editButtonDidTap)
            }
            .disposed(by: disposeBag)

        completeButton.rx
            .tap
            .bind(with: self) { owner, _ in
                reactor.action.onNext(.completeButtonDidTap)
            }
            .disposed(by: disposeBag)

        headerView.rx.editNickNameButtonDidTap
            .bind(with: self) { ownerm, _ in
                DEBUG_LOG("탭 이름 변경 버튼")
            }
            .disposed(by: disposeBag)

        headerView.rx.cameraButtonDidTap
            .bind(with: self) { owner, _ in
                DEBUG_LOG("카메라 버튼 탭")
            }
            .disposed(by: disposeBag)
    }

    override func bindState(reactor: MyPlaylistDetailReactor) {
        super.bindState(reactor: reactor)

        let sharedState = reactor.state.share()

        sharedState.map(\.isEditing)
            .distinctUntilChanged()
            .bind(with: self) { owner, isEditing in
                owner.lockButton.isHidden = isEditing
                owner.moreButton.isHidden = isEditing
                owner.completeButton.isHidden = !isEditing
                owner.tableView.isEditing = isEditing
                owner.headerView.updateEditState(isEditing)
                owner.navigationController?.interactivePopGestureRecognizer?.delegate = isEditing ? owner : nil
                owner.tableView.reloadData()
            }
            .disposed(by: disposeBag)

        sharedState.map(\.dataSource)
            .distinctUntilChanged()
            .bind(with: self) { owner, model in
                var snapShot = NSDiffableDataSourceSnapshot<Int, SongEntity>()

                owner.headerView.updateData(model.title, model.songs.count, model.image)
                owner.lockButton.setImage(model.private ? owner.lockImage : owner.unLockImage, for: .normal)
                let warningView = WMWarningView(
                    text: "리스트에 곡이 없습니다."
                )

                if model.songs.isEmpty {
                    owner.tableView.setBackgroundView(warningView, APP_HEIGHT() / 2.5)
                } else {
                    owner.tableView.restore()
                }

                #warning("셀 선택 업데이트 관련 질문")
                snapShot.appendSections([0])
                snapShot.appendItems(model.songs)

                owner.dataSource.apply(snapShot, animatingDifferences: false)
            }
            .disposed(by: disposeBag)

        sharedState.map(\.isLoading)
            .distinctUntilChanged()
            .bind(with: self) { owner, isLoading in

                if isLoading {
                    owner.indicator.startAnimating()
                } else {
                    owner.indicator.stopAnimating()
                }
            }
            .disposed(by: disposeBag)

        sharedState.map(\.selectedCount)
            .distinctUntilChanged()
            .withLatestFrom(sharedState.map(\.dataSource.songs.count)) { ($0, $1) }
            .bind(with: self) { owner, info in

                let (count, limit) = (info.0, info.1)

                if count == .zero {
                    owner.hideSongCart()
                } else {
                    owner.showSongCart(
                        in: owner.view,
                        type: .myList,
                        selectedSongCount: count,
                        totalSongCount: limit,
                        useBottomSpace: false
                    )
                }
            }
            .disposed(by: disposeBag)
    }
}

extension MyPlaylistDetailViewController {
    func createDataSource() -> MyplaylistDetailDataSource {
        #warning("옵셔널 해결하기")
        let dataSource =
            MyplaylistDetailDataSource(
                reactor: reactor!,
                tableView: tableView
            ) { [weak self] tableView, indexPath, itemIdentifier in

                guard let self, let cell = tableView.dequeueReusableCell(
                    withIdentifier: PlaylistTableViewCell.identifier,
                    for: indexPath
                ) as? PlaylistTableViewCell else {
                    return UITableViewCell()
                }

                cell.delegate = self
                cell.setContent(song: itemIdentifier, index: indexPath.row, isEditing: tableView.isEditing)
                cell.selectionStyle = .none

                return cell
            }

        tableView.dataSource = dataSource

        return dataSource
    }
}

extension MyPlaylistDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(60.0)
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let playbuttonGroupView = PlayButtonGroupView()
        playbuttonGroupView.delegate = self

        guard let reactor = reactor else {
            return nil
        }

        if reactor.currentState.dataSource.songs.isEmpty {
            return nil
        } else {
            return playbuttonGroupView
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let reactor = reactor else {
            return .zero
        }

        if reactor.currentState.dataSource.songs.isEmpty {
            return .zero
        } else {
            return CGFloat(52.0 + 32.0)
        }
    }

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell
        .EditingStyle {
        return .none
    }

    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false // 편집모드 시 셀의 들여쓰기를 없애려면 false를 리턴합니다.
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DEBUG_LOG("HELLo")
    }

    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        DEBUG_LOG("\(sourceIndexPath) \(destinationIndexPath)")
    }
}

extension MyPlaylistDetailViewController: PlayButtonGroupViewDelegate {
    func play(_ event: PlayEvent) {
        DEBUG_LOG("playGroup Touched")
        #warning("재생 이벤트 넣기")
        switch event {
        case .allPlay:
            break
        case .shufflePlay:
            break
        }
    }
}

extension MyPlaylistDetailViewController: PlaylistTableViewCellDelegate {
    func superButtonTapped(index: Int) {
        tableView.deselectRow(at: IndexPath(row: index, section: 0), animated: false)
        reactor?.action.onNext(.itemDidTap(index))
    }
}

extension MyPlaylistDetailViewController: UIGestureRecognizerDelegate {
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}

extension MyPlaylistDetailViewController: SongCartViewDelegate {
    func buttonTapped(type: BaseFeature.SongCartSelectType) {
        #warning("송카트 구횬")
    }
}

extension MyPlaylistDetailViewController: EditSheetViewDelegate {
    public func buttonTapped(type: EditSheetSelectType) {
        #warning("EditSheet 구현")
    }
}

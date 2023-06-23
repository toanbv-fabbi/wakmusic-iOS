import UIKit
import CommonFeature
import Utility
import DesignSystem
import PanModal
import BaseFeature
import RxSwift
import RxCocoa
import DataMappingModule
import DomainModule
import NVActivityIndicatorView
import Then
import SnapKit

public final class HomeViewController: BaseViewController, ViewControllerFromStoryBoard {

    @IBOutlet weak var topSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var activityIndicator: NVActivityIndicatorView!
    
    //왁뮤차트 TOP100
    @IBOutlet weak var topCircleImageView: UIImageView!
    @IBOutlet weak var chartContentView: UIView!
    @IBOutlet weak var chartBorderView: UIView!
    @IBOutlet weak var chartTitleLabel: UILabel!
    @IBOutlet weak var chartArrowImageView: UIImageView!
    @IBOutlet weak var chartAllListenButton: UIButton!
    @IBOutlet weak var chartMoreButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    //최신음악
    @IBOutlet weak var latestSongLabel: UILabel!
    @IBOutlet weak var latestSongAllButton: UIButton!
    @IBOutlet weak var latestSongWwgButton: UIButton!
    @IBOutlet weak var latestSongIseButton: UIButton!
    @IBOutlet weak var latestSongGomButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    private let glassmorphismView = GlassmorphismView().then {
        $0.setCornerRadius(12)
        $0.setTheme(theme: .light)
        $0.setDistance(100)
        $0.layer.cornerRadius = 12
        $0.clipsToBounds = true
    }
    private let colorView = UIView().then {
        $0.layer.cornerRadius = 12
        $0.clipsToBounds = true
        $0.backgroundColor = .white.withAlphaComponent(0.4)
    }
    private var refreshControl = UIRefreshControl()
    var playListDetailComponent: PlayListDetailComponent!
    var recommendViewHeightConstraint: NSLayoutConstraint?

    var viewModel: HomeViewModel!
    private lazy var input = HomeViewModel.Input()
    private lazy var output = viewModel.transform(from: input)
    var disposeBag = DisposeBag()

    public override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureBlurUI()
        inputBind()
        outputBind()
    }
    
    public static func viewController(viewModel: HomeViewModel, playListDetailComponent :PlayListDetailComponent) -> HomeViewController {
        let viewController = HomeViewController.viewController(storyBoardName: "Home", bundle: Bundle.module)
        viewController.viewModel = viewModel
        viewController.playListDetailComponent = playListDetailComponent
        return viewController
    }
}

extension HomeViewController {
    private func inputBind() {
        chartMoreButton.rx.tap
            .bind(to: input.chartMoreTapped)
            .disposed(by: disposeBag)

        chartAllListenButton.rx.tap
            .bind(to: input.allListenTapped)
            .disposed(by: disposeBag)

        Observable.merge(
            latestSongAllButton.rx.tap.map { _ -> NewSongGroupType in .all },
            latestSongWwgButton.rx.tap.map { _ -> NewSongGroupType in .woowakgood },
            latestSongIseButton.rx.tap.map { _ -> NewSongGroupType in .isedol },
            latestSongGomButton.rx.tap.map { _ -> NewSongGroupType in .gomem }
        )
        .withLatestFrom(input.newSongTypeTapped) { ($0, $1) }
        .filter{ (currentSelectedType, previousType) in
            guard currentSelectedType != previousType else { return false }
            return true
        }
        .throttle(RxTimeInterval.seconds(1), latest: false, scheduler: MainScheduler.instance)
        .do(onNext: { [weak self] (currentSelectedType, previousType) in
            guard let `self` = self else { return }
            
            switch previousType {
            case .all:
                self.latestSongAllButton.isSelected = false
            case .woowakgood:
                self.latestSongWwgButton.isSelected = false
            case .isedol:
                self.latestSongIseButton.isSelected = false
            case .gomem:
                self.latestSongGomButton.isSelected = false
            }

            switch currentSelectedType {
            case .all:
                self.latestSongAllButton.isSelected = true
                self.latestSongWwgButton.isEnabled = false
                self.latestSongIseButton.isEnabled = false
                self.latestSongGomButton.isEnabled = false
            case .woowakgood:
                self.latestSongAllButton.isEnabled = false
                self.latestSongWwgButton.isSelected = true
                self.latestSongIseButton.isEnabled = false
                self.latestSongGomButton.isEnabled = false
            case .isedol:
                self.latestSongAllButton.isEnabled = false
                self.latestSongWwgButton.isEnabled = false
                self.latestSongIseButton.isSelected = true
                self.latestSongGomButton.isEnabled = false

            case .gomem:
                self.latestSongAllButton.isEnabled = false
                self.latestSongWwgButton.isEnabled = false
                self.latestSongIseButton.isEnabled = false
                self.latestSongGomButton.isSelected = true
            }
            self.activityIndicator.startAnimating()
        })
        .map { (currentSelectedType, _) -> NewSongGroupType in
            return currentSelectedType
        }
        .bind(to: input.newSongTypeTapped)
        .disposed(by: disposeBag)
        
        refreshControl.rx
            .controlEvent(.valueChanged)
            .bind(to: input.refreshPulled)
            .disposed(by: disposeBag)

        tableView.rx.itemSelected
            .withLatestFrom(output.chartDataSource) { ($0, $1) }
            .map { SongEntity(
                    id: $0.1[$0.0.row].id,
                    title: $0.1[$0.0.row].title,
                    artist: $0.1[$0.0.row].artist,
                    remix: $0.1[$0.0.row].remix,
                    reaction: $0.1[$0.0.row].reaction,
                    views: $0.1[$0.0.row].views,
                    last: $0.1[$0.0.row].last,
                    date: $0.1[$0.0.row].date
                )
            }
            .subscribe(onNext: { (song) in
                PlayState.shared.loadAndAppendSongsToPlaylist([song])
            })
            .disposed(by: disposeBag)
        
        collectionView.rx.itemSelected
            .withLatestFrom(output.newSongDataSource) { ($0, $1) }
            .map { SongEntity(
                    id: $0.1[$0.0.row].id,
                    title: $0.1[$0.0.row].title,
                    artist: $0.1[$0.0.row].artist,
                    remix: $0.1[$0.0.row].remix,
                    reaction: $0.1[$0.0.row].reaction,
                    views: $0.1[$0.0.row].views,
                    last: $0.1[$0.0.row].last,
                    date: "\($0.1[$0.0.row].date)"
                )
            }
            .subscribe(onNext: { (song) in
                PlayState.shared.loadAndAppendSongsToPlaylist([song])
            })
            .disposed(by: disposeBag)
    }
    
    private func outputBind() {
        tableView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
        
        collectionView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)

        output.chartDataSource
            .skip(1)
            .filter { $0.count >= 5 }
            .map{ Array($0[0..<5]) }
            .do(onNext: { [weak self] _ in
                self?.activityIndicator.stopAnimating()
            })
            .bind(to: tableView.rx.items) { (tableView, index, model) -> UITableViewCell in
                let indexPath: IndexPath = IndexPath(row: index, section: 0)
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "HomeChartCell", for: indexPath) as? HomeChartCell else{
                    return UITableViewCell()
                }
                cell.update(model: model, index: indexPath.row)
                return cell
            }.disposed(by: disposeBag)
        
        output.newSongDataSource
            .skip(1)
            .do(onNext: { [weak self] _ in
                self?.collectionView.contentOffset = .zero
                self?.refreshControl.endRefreshing()
                self?.activityIndicator.stopAnimating()
                self?.latestSongAllButton.isEnabled = true
                self?.latestSongWwgButton.isEnabled = true
                self?.latestSongIseButton.isEnabled = true
                self?.latestSongGomButton.isEnabled = true
            })
            .bind(to: collectionView.rx.items) { (collectionView, index, model) -> UICollectionViewCell in
                let indexPath = IndexPath(item: index, section: 0)
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeNewSongCell", for: indexPath) as? HomeNewSongCell else {
                    return UICollectionViewCell()
                }
                cell.update(model: model)
                return cell
            }.disposed(by: disposeBag)
        
        output.playListDataSource
            .skip(1)
            .filter { !$0.isEmpty }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] (model) in
                guard let `self` = self else { return }
                let subviews: [UIView] = self.stackView.arrangedSubviews.filter { $0 is RecommendPlayListView }.compactMap { $0 }
                let height: CGFloat = RecommendPlayListView.getViewHeight(model: model)

                if subviews.isEmpty {
                    let recommendView = RecommendPlayListView(
                        frame: CGRect(
                            x: 0,
                            y: 0,
                            width: APP_WIDTH(),
                            height: height
                        )
                    )
                    recommendView.dataSource = model
                    recommendView.delegate = self
                    let constraint = recommendView.heightAnchor.constraint(equalToConstant: height)
                    constraint.isActive = true
                    self.stackView.addArrangedSubview(recommendView)
                    self.recommendViewHeightConstraint = constraint

                    let bottomSpace = UIView(frame: CGRect(x: 0, y: 0, width: APP_WIDTH(), height: 56))
                    bottomSpace.heightAnchor.constraint(equalToConstant: bottomSpace.frame.height).isActive = true
                    self.stackView.addArrangedSubview(bottomSpace)

                }else{
                    guard let recommendView = subviews.first as? RecommendPlayListView else { return }
                    self.recommendViewHeightConstraint?.constant = height
                    recommendView.dataSource = model
                }
            }).disposed(by: disposeBag)
        
        output.songEntityOfAllChart
            .subscribe(onNext: { (songs) in
                let songEntities: [SongEntity] = songs.map {
                    return SongEntity(
                        id: $0.id,
                        title: $0.title,
                        artist: $0.artist,
                        remix: $0.remix,
                        reaction: $0.reaction,
                        views: $0.views,
                        last: $0.last,
                        date: $0.date
                    )
                }
                PlayState.shared.loadAndAppendSongsToPlaylist(songEntities)
            })
            .disposed(by: disposeBag)
    }
    
    private func configureBlurUI() {
        [glassmorphismView, colorView].forEach {
            chartContentView.insertSubview($0, at: 0)
            $0.snp.makeConstraints {
                $0.left.equalToSuperview().offset(20)
                $0.right.equalToSuperview().offset(-20)
                $0.top.bottom.equalToSuperview()
            }
        }
    }
    
    private func configureUI() {
        activityIndicator.type = .circleStrokeSpin
        activityIndicator.color = DesignSystemAsset.PrimaryColor.point.color
        activityIndicator.startAnimating()
        view.backgroundColor = DesignSystemAsset.GrayColor.gray100.color
        topCircleImageView.image = DesignSystemAsset.Home.gradationBg.image

        chartBorderView.layer.cornerRadius = 12
        chartBorderView.layer.borderWidth = 1
        chartBorderView.layer.borderColor = DesignSystemAsset.GrayColor.gray25.color.cgColor
        
        let mainTitleLabelAttributedString = NSMutableAttributedString(
            string: "왁뮤차트 TOP100",
            attributes: [.font: DesignSystemFontFamily.Pretendard.bold.font(size: 16),
                         .foregroundColor: DesignSystemAsset.GrayColor.gray900.color,
                         .kern: -0.5]
        )
        chartTitleLabel.attributedText = mainTitleLabelAttributedString

        let mainTitleAllButtonAttributedString = NSMutableAttributedString(
            string: "전체듣기",
            attributes: [.font: DesignSystemFontFamily.Pretendard.medium.font(size: 14),
                         .foregroundColor: DesignSystemAsset.GrayColor.gray25.color,
                         .kern: -0.5]
        )
        chartAllListenButton.setAttributedTitle(mainTitleAllButtonAttributedString, for: .normal)
        chartArrowImageView.image = DesignSystemAsset.Home.homeArrowRight.image
        
        let latestSongAttributedString = NSMutableAttributedString(
            string: "최신 음악",
            attributes: [.font: DesignSystemFontFamily.Pretendard.bold.font(size: 16),
                         .foregroundColor: DesignSystemAsset.GrayColor.gray900.color,
                         .kern: -0.5]
        )
        latestSongLabel.attributedText = latestSongAttributedString
        
        let buttons: [UIButton] = [latestSongAllButton, latestSongWwgButton, latestSongIseButton, latestSongGomButton]
        
        for (model, button) in zip(NewSongGroupType.allCases, buttons) {
            let attributedString = NSMutableAttributedString(
                string: model.display,
                attributes: [.font: DesignSystemFontFamily.Pretendard.light.font(size: 14),
                             .foregroundColor: DesignSystemAsset.GrayColor.gray900.color,
                             .kern: -0.5]
            )
            button.setAttributedTitle(attributedString, for: .normal)
            
            let selectedAttributedString = NSMutableAttributedString(
                string: model.display,
                attributes: [.font: DesignSystemFontFamily.Pretendard.bold.font(size: 14),
                             .foregroundColor: DesignSystemAsset.GrayColor.gray900.color,
                             .kern: -0.5]
            )
            button.setAttributedTitle(selectedAttributedString, for: .selected)
        }
        
        latestSongAllButton.isSelected = true
        scrollView.refreshControl = refreshControl
    }
}

extension HomeViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 58
    }
}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    public func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(width: 144.0, height: 131.0)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 20.0, bottom: 0, right: 20.0)
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8.0
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8.0
    }
}

extension HomeViewController: RecommendPlayListViewDelegate {
    public func itemSelected(model: RecommendPlayListEntity) {
        let playListDetailVc = playListDetailComponent.makeView(id: model.key, type: .wmRecommend)
        self.navigationController?.pushViewController(playListDetailVc, animated: true)
    }
}

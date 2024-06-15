import BaseFeature
import BaseFeatureInterface
import DesignSystem
import Foundation
import LogManager
import MyInfoFeatureInterface
import RxSwift
import SignInFeatureInterface
import SnapKit
import Then
import UIKit
import Utility

final class MyInfoViewController: BaseReactorViewController<MyInfoReactor> {
    let myInfoView = MyInfoView()
    private var textPopUpFactory: TextPopUpFactory!
    private var signInFactory: SignInFactory!
    private var faqComponent: FaqComponent! // 자주 묻는 질문
    private var noticeComponent: NoticeComponent! // 공지사항
    private var questionComponent: QuestionComponent! // 문의하기
    private var teamInfoComponent: TeamInfoComponent! // 팀 소개
    private var settingComponent: SettingComponent!

    override func configureNavigation() {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }

    override func loadView() {
        view = myInfoView
    }

    public static func viewController(
        reactor: MyInfoReactor,
        textPopUpFactory: TextPopUpFactory,
        signInFactory: SignInFactory,
        faqComponent: FaqComponent,
        noticeComponent: NoticeComponent,
        questionComponent: QuestionComponent,
        teamInfoComponent: TeamInfoComponent,
        settingComponent: SettingComponent
    ) -> MyInfoViewController {
        let viewController = MyInfoViewController(reactor: reactor)
        viewController.textPopUpFactory = textPopUpFactory
        viewController.signInFactory = signInFactory
        viewController.faqComponent = faqComponent
        viewController.noticeComponent = noticeComponent
        viewController.questionComponent = questionComponent
        viewController.teamInfoComponent = teamInfoComponent
        viewController.settingComponent = settingComponent
        return viewController
    }

    override func bindState(reactor: MyInfoReactor) {
        reactor.state.map(\.isLoggedIn)
            .distinctUntilChanged()
            .bind(with: self) { owner, isLoggedIn in
                owner.myInfoView.updateIsHiddenLoginWarningView(isLoggedIn: isLoggedIn)
            }
            .disposed(by: disposeBag)

        reactor.state.map(\.nickname)
            .distinctUntilChanged()
            .bind(with: self) { owner, nickname in
                owner.myInfoView.profileView.updateNickName(nickname: nickname)
            }
            .disposed(by: disposeBag)

        reactor.state.map(\.platform)
            .distinctUntilChanged()
            .bind(with: self) { owner, platform in
                owner.myInfoView.profileView.updatePlatform(platform: platform)
            }
            .disposed(by: disposeBag)

        reactor.pulse(\.$loginButtonDidTap)
            .compactMap { $0 }
            .bind(with: self) { owner, _ in
                let vc = owner.signInFactory.makeView()
                owner.present(vc, animated: true)
            }
            .disposed(by: disposeBag)

        reactor.pulse(\.$moreButtonDidTap)
            .compactMap { $0 }
            .bind { _ in
                #warning("[프로필 변경, 닉네임 수정] 팝업 띄워야 함")
            }
            .disposed(by: disposeBag)

        reactor.pulse(\.$navigateType)
            .compactMap { $0 }
            .bind(with: self) { owner, navigate in
                switch navigate {
                case .draw:
                    #warning("뽑기 화면 이동 기능 필요")
                case .like:
                    if reactor.currentState.isLoggedIn {
                        NotificationCenter.default.post(name: .movedTab, object: 4)
                        NotificationCenter.default.post(name: .movedStorageFavoriteTab, object: nil)
                    } else {
                        guard let vc = owner.textPopUpFactory.makeView(
                            text: "로그인이 필요한 서비스입니다.\n로그인 하시겠습니까?",
                            cancelButtonIsHidden: false,
                            allowsDragAndTapToDismiss: nil,
                            confirmButtonText: nil,
                            cancelButtonText: nil,
                            completion: {
                                let loginVC = owner.signInFactory.makeView()
                                owner.present(loginVC, animated: true)
                            },
                            cancelCompletion: {}
                        ) as? TextPopupViewController else {
                            return
                        }

                        vc.modalPresentationStyle = .popover
                        owner.present(vc, animated: true)
                        #warning("팬모달 이슈 해결되면 변경 예정")
                        // owner.showPanModal(content: vc)
                    }
                case .faq:
                    let vc = owner.faqComponent.makeView()
                    owner.navigationController?.pushViewController(vc, animated: true)
                case .noti:
                    let vc = owner.noticeComponent.makeView()
                    owner.navigationController?.pushViewController(vc, animated: true)
                case .mail:
                    let vc = owner.questionComponent.makeView()
                    vc.modalPresentationStyle = .overFullScreen
                    owner.present(vc, animated: true)
                case .team:
                    let vc = owner.teamInfoComponent.makeView()
                    owner.navigationController?.pushViewController(vc, animated: true)
                case .setting:
                    let vc = owner.settingComponent.makeView()
                    owner.navigationController?.pushViewController(vc, animated: true)
                }
            }
            .disposed(by: disposeBag)
    }

    override func bindAction(reactor: MyInfoReactor) {
        myInfoView.rx.loginButtonDidTap
            .throttle(.milliseconds(500), latest: false, scheduler: MainScheduler.asyncInstance)
            .map { MyInfoReactor.Action.loginButtonDidTap }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        myInfoView.rx.moreButtonDidTap
            .map { MyInfoReactor.Action.moreButtonDidTap }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        myInfoView.rx.drawButtonDidTap
            .map { MyInfoReactor.Action.drawButtonDidTap }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        myInfoView.rx.likeNavigationButtonDidTap
            .map { MyInfoReactor.Action.likeNavigationDidTap }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        myInfoView.rx.qnaNavigationButtonDidTap
            .map { MyInfoReactor.Action.faqNavigationDidTap }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        myInfoView.rx.notiNavigationButtonDidTap
            .map { MyInfoReactor.Action.notiNavigationDidTap }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        myInfoView.rx.mailNavigationButtonDidTap
            .map { MyInfoReactor.Action.mailNavigationDidTap }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        myInfoView.rx.teamNavigationButtonDidTap
            .map { MyInfoReactor.Action.teamNavigationDidTap }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        myInfoView.rx.settingNavigationButtonDidTap
            .map { MyInfoReactor.Action.settingNavigationDidTap }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
}
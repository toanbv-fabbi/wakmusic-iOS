//
//  RequestViewController.swift
//  StorageFeature
//
//  Created by yongbeomkwak on 2023/01/28.
//  Copyright © 2023 yongbeomkwak. All rights reserved.
//

import UIKit
import Utility
import DesignSystem
import CommonFeature
import RxSwift

public final class RequestViewController: UIViewController, ViewControllerFromStoryBoard {

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var reportBugButton: UIButton!
    @IBOutlet weak var songRequestButton: UIButton!
    @IBOutlet weak var qnaButton: UIButton!
    @IBOutlet weak var dotLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var fakeViewHeight: NSLayoutConstraint!
    @IBOutlet weak var serviceButton: UIButton!
    @IBOutlet weak var privacyButton: UIButton!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var withdrawButton: UIButton!
    
    @IBAction func pressBackAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func moveQnaAction(_ sender: UIButton) {
        let viewController = qnaComponent.makeView()
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func presswithDrawAction(_ sender: UIButton) {
        
        let secondConfirmVc = TextPopupViewController.viewController(text: "정말 탈퇴하시겠습니까?", cancelButtonIsHidden: false,completion: {
            // 회원탈퇴 작업
            self.input.pressWithdraw.onNext(())
        })
        
        let firstConfirmVc = TextPopupViewController.viewController(text: "회원탈퇴 신청을 하시겠습니까?", cancelButtonIsHidden: false,completion: {
            self.showPanModal(content: secondConfirmVc)
        })
        
        self.showPanModal(content: firstConfirmVc)
    }
    
    @IBAction func pressServiceAction(_ sender: UIButton) {
        let vc = ContractViewController.viewController(type: .service)
        vc.modalPresentationStyle = .fullScreen //꽉찬 모달
        self.present(vc, animated: true)
    }
    
    @IBAction func pressPrivacyAction(_ sender: UIButton) {
        let vc = ContractViewController.viewController(type: .privacy)
        vc.modalPresentationStyle = .fullScreen //꽉찬 모달
        self.present(vc, animated: true)
    }
    
    var viewModel:RequestViewModel!
    lazy var input = RequestViewModel.Input()
    lazy var output = viewModel.transform(from: input)
    
    var qnaComponent:QnaComponent!
    
    var disposeBag = DisposeBag()
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        configureUI()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.interactivePopGestureRecognizer?.delegate = nil //스와이프로 뒤로가기
    }
    

    public static func viewController(viewModel:RequestViewModel,qnaComponent:QnaComponent) -> RequestViewController {
        let viewController = RequestViewController.viewController(storyBoardName: "Storage", bundle: Bundle.module)
        
        viewController.viewModel = viewModel
        viewController.qnaComponent = qnaComponent
        
        return viewController
    }

}

extension RequestViewController{
    
    private func configureUI(){
        
        
        self.backButton.setImage(DesignSystemAsset.Navigation.back.image, for: .normal)
        
        self.titleLabel.font = DesignSystemFontFamily.Pretendard.medium.font(size: 16)
        
        let buttons:[UIButton] = [self.reportBugButton,self.songRequestButton,self.qnaButton]
        
        for i in 0...2 {
            
            var title = ""
            switch i {
            case 0:
                title = "버그 제보"
            case 1:
                title = "노래 추가, 수정 요청"
            case 2:
                title = "자주 묻는 질문"
            default:
                return
            }
            
            var attr:NSAttributedString = NSAttributedString(string: title, attributes: [
                NSAttributedString.Key.font: DesignSystemFontFamily.Pretendard.medium.font(size: 16),
                .foregroundColor: DesignSystemAsset.GrayColor.gray900.color])
            
            buttons[i].setAttributedTitle(attr, for: .normal)
            
            buttons[i].layer.borderWidth = 1
            buttons[i].layer.cornerRadius = 12
            buttons[i].layer.borderColor = DesignSystemAsset.GrayColor.gray200.color.withAlphaComponent(0.4).cgColor
            

        }
        
        dotLabel.layer.cornerRadius = 2
        dotLabel.clipsToBounds = true
        descriptionLabel.font = DesignSystemFontFamily.Pretendard.light.font(size: 12)
        
        
        let serviceAttributedString = NSMutableAttributedString.init(string: "서비스 이용약관")
        
        serviceAttributedString.addAttributes([.font: DesignSystemFontFamily.Pretendard.medium.font(size: 14),
                                               .foregroundColor: DesignSystemAsset.GrayColor.gray600.color], range: NSRange(location: 0, length: serviceAttributedString.string.count))
        
        
        let privacyAttributedString = NSMutableAttributedString.init(string: "개인정보처리방침")
        
        privacyAttributedString.addAttributes([.font: DesignSystemFontFamily.Pretendard.medium.font(size: 14),
                                               .foregroundColor: DesignSystemAsset.GrayColor.gray600.color], range: NSRange(location: 0, length: privacyAttributedString.string.count))
        
        privacyButton.layer.cornerRadius = 8
        privacyButton.layer.borderColor = DesignSystemAsset.GrayColor.gray400.color.withAlphaComponent(0.4).cgColor
        privacyButton.layer.borderWidth = 1
        privacyButton.setAttributedTitle(privacyAttributedString, for: .normal)
        
        
        serviceButton.layer.cornerRadius = 8
        serviceButton.layer.borderColor = DesignSystemAsset.GrayColor.gray400.color.withAlphaComponent(0.4).cgColor
        serviceButton.layer.borderWidth = 1
        serviceButton.setAttributedTitle(serviceAttributedString, for: .normal)
        
        
        
        versionLabel.font = DesignSystemFontFamily.Pretendard.light.font(size: 12)
        versionLabel.text = "버전정보 \(APP_VERSION())"
        
        
        let withDrawAttributedString = NSMutableAttributedString.init(string: "회원탈퇴")
        
        withDrawAttributedString.addAttributes([.font: DesignSystemFontFamily.Pretendard.bold.font(size: 12),
                                               .foregroundColor: DesignSystemAsset.GrayColor.gray400.color], range: NSRange(location: 0, length: withDrawAttributedString.string.count))
        
        withdrawButton.layer.borderWidth = 1
        withdrawButton.layer.cornerRadius = 4
        withdrawButton.layer.borderColor = DesignSystemAsset.GrayColor.gray300.color.cgColor
        withdrawButton.setAttributedTitle(withDrawAttributedString, for: .normal)
        
        
       
        fakeViewHeight.constant = calculateFakeViewHeight()
        self.view.layoutIfNeeded()
        bindRx()
        
        
    }
    
    private func bindRx(){
        
        output.statusCode.subscribe(onNext: { [weak self] in
            guard let self = self else{
                return
            }
            
            DEBUG_LOG($0.isEmpty)
            let completed: Bool = $0.isEmpty
            
            let withdrawVc = TextPopupViewController.viewController(
                text: $0.isEmpty ? "회원탈퇴가 완료되었습니다.\n이용해주셔서 감사합니다." : $0,
                cancelButtonIsHidden: true,
                completion: {
                    if completed {
                        self.navigationController?.popViewController(animated: true)
                    }
                })
            self.showPanModal(content: withdrawVc)
        })
        .disposed(by: disposeBag)
    }
    
    private func calculateFakeViewHeight() -> CGFloat{
        let window: UIWindow? = UIApplication.shared.windows.first
        let statusBarHeight:CGFloat = window?.safeAreaInsets.top ?? 0
        let safeAreaBottomHeight = window?.safeAreaInsets.bottom ?? 0
        let navigationBarHeight:CGFloat =  48
        let gapBtwNaviAndStack:CGFloat = 20
        let threeButtonHeight:CGFloat = 60 * 3
        let gapButtons:CGFloat = 8 * 2
        let gapBtwLabelAndLastButton:CGFloat = 20
        let textHeight = "왁타버스 뮤직 팀에 속한 모든 팀원들은 부아내비 (부려먹는 게 아니라 내가 비빈거다)라는 모토를 가슴에 새기고 일하고 있습니다.".heightConstraintAt(width: APP_WIDTH() - 56, font:DesignSystemFontFamily.Pretendard.light.font(size: 12))
        let bottomButtonHeight:CGFloat = 44
        let gapBtwBattomButtonsAndVersionLabel:CGFloat = 20
        let versionLabelHeight:CGFloat = 18
        let mainTabBarHeight:CGFloat = 56

        let res = (APP_HEIGHT() - (safeAreaBottomHeight + statusBarHeight + navigationBarHeight + gapBtwNaviAndStack + threeButtonHeight + gapButtons + gapBtwLabelAndLastButton + textHeight + bottomButtonHeight + gapBtwBattomButtonsAndVersionLabel + versionLabelHeight + mainTabBarHeight  +  20))
        
        return res
    }
}

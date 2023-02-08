//
//  CreatePlayListPopupViewController.swift
//  DesignSystem
//
//  Created by yongbeomkwak on 2023/01/21.
//  Copyright © 2023 yongbeomkwak. All rights reserved.
//

import UIKit
import Utility
import PanModal
import RxCocoa
import RxSwift
import RxKeyboard


public enum PurposeType{
    case creation
    case edit
    case load
    case share
    case nickname
}

extension PurposeType{
    
    var title:String{
        switch self{
            
        case .creation:
            return "플레이리스트 만들기"
        case .edit:
            return "플레이리스트 수정하기"
        case .load:
            return "플레이리스트 가져오기"
        case .share:
            return "플레이리스트 공유하기"
        
        case .nickname:
            return "닉네임 수정"
            
        }
        
        
    }
    
    var subTitle:String{
        
        switch self{
            
        case .creation:
            return "플레이리스트 제목"
        case .edit:
            return "플레이리스트 제목"
        case .load:
            return "플레이리스트 코드"
        case .share:
            return "플레이리스트 코드"
        case .nickname:
            return "닉네임"
            
        }
    
    }
    
    var btnText:String{
        switch self{
        case .creation:
            return "플레이리스트 생성"
        case .edit:
            return "플레이리스트 수정"
        case .load:
           return "가져오기"
        case .share:
            return "확인"
        case .nickname:
            return "완료"
        }
        
    }
}




public final class  MultiPurposePopupViewController: UIViewController, ViewControllerFromStoryBoard {

    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var dividerView: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var limitLabel: UILabel!
    @IBOutlet weak var confirmLabel: UILabel!
    
    let limitCount:Int = 12
    var completion: (() -> Void)?
    var shareCode:String?
    

    @IBOutlet weak var fakeViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var confireLabelGap: NSLayoutConstraint!
    
    @IBOutlet weak var cancelButtonHeight: NSLayoutConstraint!
    
    @IBOutlet weak var cancelButtonWidth: NSLayoutConstraint!
    
    @IBAction func cancelAction(_ sender: UIButton) {
        
        
        if type == .share
        {
            UIPasteboard.general.string = viewModel.input.textString.value
            completion?() //토스트 팝업을 위한 컴플리션
            
        }
        else
        {
            textField.rx.text.onNext("")
            viewModel.input.textString.accept("")
        }
        
        
    }
    
    
    @IBAction func saveAction(_ sender: UIButton) {
        
    
        //네트워크 작업
        completion?()
        dismiss(animated: true)
        self.view.endEditing(true)
    }
    
    var type:PurposeType = .creation
    lazy var viewModel = CreatePlayListPopupViewModel()
    
    public var disposeBag = DisposeBag()
    
   
   
    
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
        //bindRx()
        // Do any additional setup after loading the view.
    }
    
    public static func viewController(type:PurposeType,shareCode:String? = nil,completion: (() -> Void)? = nil) -> MultiPurposePopupViewController {
        let viewController = MultiPurposePopupViewController.viewController(storyBoardName: "CommonUI", bundle: Bundle.module)
        
        viewController.type = type
        viewController.shareCode = shareCode
        viewController.completion = completion
        
        return viewController
    }
    



}


extension MultiPurposePopupViewController{
    private func configureUI() {

        titleLabel.text = type.title
        titleLabel.font = DesignSystemFontFamily.Pretendard.medium.font(size: 18)
        titleLabel.textColor = DesignSystemAsset.GrayColor.gray900.color
        
        
        subTitleLabel.text = type.subTitle
        subTitleLabel.font = DesignSystemFontFamily.Pretendard.light.font(size: 16)
        subTitleLabel.textColor = DesignSystemAsset.GrayColor.gray400.color
        
        let headerFontSize:CGFloat = 20
        
        let focusedplaceHolderAttributes = [
            NSAttributedString.Key.foregroundColor: DesignSystemAsset.GrayColor.gray400.color,
            NSAttributedString.Key.font : DesignSystemFontFamily.Pretendard.medium.font(size: headerFontSize)
        ] // 포커싱 플레이스홀더 폰트 및 color 설정
        
        self.textField.attributedPlaceholder = NSAttributedString(string: type == .creation || type == .edit ?  "플레이리스트 제목을 입력하세요." : type == .nickname ? "닉네임을 입력하세요." : "코드를 입력해주세요."  ,attributes:focusedplaceHolderAttributes) //플레이스 홀더 설정
        self.textField.font = DesignSystemFontFamily.Pretendard.medium.font(size: headerFontSize)
        
        if type == .share { //공유는 오직 읽기 전용
            self.textField.isEnabled = false
            self.viewModel.input.textString.accept(shareCode!)
            self.textField.text = shareCode!
        }
        
       
        
        self.dividerView.backgroundColor = DesignSystemAsset.GrayColor.gray200.color
        
        if type == .share
        {
            self.cancelButtonWidth.constant = 32
            self.cancelButtonHeight.constant = 32
            self.cancelButton.setImage(DesignSystemAsset.Storage.copy.image, for: .normal)
        }
        else
        {
            self.cancelButton.layer.cornerRadius = 12
            self.cancelButton.titleLabel?.text = "취소"
            self.cancelButton.titleLabel?.font = DesignSystemFontFamily.Pretendard.bold.font(size: 12)
            self.cancelButton.layer.cornerRadius = 4
            self.cancelButton.layer.borderColor =  DesignSystemAsset.GrayColor.gray200.color.cgColor
            self.cancelButton.layer.borderWidth = 1
            self.cancelButton.backgroundColor = .white
            self.cancelButton.isHidden = true
        }
        
        if (type == .creation || type == .edit)
        {
            self.confirmLabel.font = DesignSystemFontFamily.Pretendard.light.font(size: 12)
            self.confirmLabel.isHidden = true
            
            self.limitLabel.font = DesignSystemFontFamily.Pretendard.light.font(size: 12)
            self.limitLabel.textColor = DesignSystemAsset.GrayColor.gray500.color
            
            self.countLabel.font = DesignSystemFontFamily.Pretendard.light.font(size: 12)
            self.countLabel.textColor = DesignSystemAsset.PrimaryColor.point.color
        }
        
        else
        {
         
            self.confirmLabel.font = DesignSystemFontFamily.Pretendard.light.font(size: 12)
            self.confirmLabel.textColor = DesignSystemAsset.GrayColor.gray500.color
            self.confirmLabel.isHidden = false
            self.confirmLabel.text =  type == .load ?  "· 플레이리스트 코드로 플레이리스트를 가져올 수 있습니다." : "· 플레이리스트 코드로 플레이리스트를 공유할 수 있습니다."
            self.confireLabelGap.constant = 12
            
            
            self.limitLabel.isHidden = true
            self.countLabel.isHidden = true
    
        }
        
        if type == .creation || type == .edit || type == .nickname{
            bindRxCreationOrEditOrNickName()
        }
        else{
            bindRxLoadOrShare()
        }
        
        
        
       
        
        
        saveButton.layer.cornerRadius = 12
        saveButton.clipsToBounds = true
        saveButton.setAttributedTitle(NSMutableAttributedString(string:type.btnText,
                                                                attributes: [.font: DesignSystemFontFamily.Pretendard.medium.font(size: 18),
                                                                             .foregroundColor: DesignSystemAsset.GrayColor.gray25.color ]), for: .normal)
        

        saveButton.setBackgroundColor(DesignSystemAsset.PrimaryColor.point.color, for: .normal)
        saveButton.setBackgroundColor(DesignSystemAsset.GrayColor.gray300.color, for: .disabled)
        
    }
    
    
    private func bindRxCreationOrEditOrNickName()
    {
        textField.rx.text.orEmpty
            .skip(1)  //바인드 할 때 발생하는 첫 이벤트를 무시
            .bind(to: self.viewModel.input.textString)
            .disposed(by: self.disposeBag)
        
        
        
        self.viewModel.input.textString.subscribe { [weak self] (str:String) in
            
            guard let self = self else{
                return
            }
            
            let errorColor = DesignSystemAsset.PrimaryColor.increase.color
            let passColor = DesignSystemAsset.PrimaryColor.decrease.color
            
            self.countLabel.text = "\(str.count)자"
            if str.count == 0
            {
                self.cancelButton.isHidden = true
                self.confirmLabel.isHidden = true
                self.saveButton.isEnabled = false
                self.dividerView.backgroundColor = DesignSystemAsset.GrayColor.gray200.color
                self.countLabel.textColor = DesignSystemAsset.PrimaryColor.point.color
                return
            }
            
            else
            {
                self.cancelButton.isHidden = false
                self.confirmLabel.isHidden = false
            }
            
            if  str.isWhiteSpace
            {
                self.dividerView.backgroundColor = errorColor
                self.confirmLabel.text = "제목이 비어있습니다."
                self.confirmLabel.textColor = errorColor
                self.countLabel.textColor = errorColor
                self.saveButton.isEnabled = false
            }
            else if str.count > self.limitCount {
                self.dividerView.backgroundColor = errorColor
                self.confirmLabel.text = "글자 수를 초과하였습니다."
                self.confirmLabel.textColor = errorColor
                self.countLabel.textColor = errorColor
                self.saveButton.isEnabled = false
            }
            
            else
            {
                self.dividerView.backgroundColor = passColor
                self.confirmLabel.text =  self.type == .nickname ? "사용할 수 있는 닉네임입니다." : "사용할 수 있는 제목입니다."
                self.confirmLabel.textColor = passColor
                self.countLabel.textColor = DesignSystemAsset.PrimaryColor.point.color
                self.saveButton.isEnabled = true
            }
            
            
          
            
        }.disposed(by: disposeBag)
        
        
        keyboardBinding()
        
    }
    
    private func bindRxLoadOrShare() {
        
        textField.rx.text.orEmpty
            .skip(1)  //바인드 할 때 발생하는 첫 이벤트를 무시
            .bind(to: self.viewModel.input.textString)
            .disposed(by: self.disposeBag)
        
        
        self.viewModel.input.textString.subscribe { [weak self] (str:String) in
            
            guard let self = self else{
                return
            }
            
            
            
            if str.count == 0
            {
                self.cancelButton.isHidden = true
                self.saveButton.isEnabled = false

            }
            else
            {
                self.cancelButton.isHidden =  false
                if str.isWhiteSpace
                {
                    self.saveButton.isEnabled = false
                }
                
                else
                {
                    self.saveButton.isEnabled = true
                }
            }
            

            
            
            
          
            
        }.disposed(by: disposeBag)
        
        
        keyboardBinding()
    }
    
    private func keyboardBinding()
    {
        //키보드 바인딩 작업
        RxKeyboard.instance.visibleHeight //드라이브: 무조건 메인쓰레드에서 돌아감
            .skip(1)
            .drive(onNext: { [weak self] keyboardVisibleHeight in
                
                guard let self = self else {
                    return
                }
                
                
                //키보드는 바텀 SafeArea부터 계산되므로 빼야함
                let window: UIWindow? = UIApplication.shared.windows.first
                let safeAreaInsetsBottom: CGFloat = window?.safeAreaInsets.bottom ?? 0
                
               
                self.fakeViewHeight.constant = keyboardVisibleHeight - safeAreaInsetsBottom
                self.panModalSetNeedsLayoutUpdate()
                self.panModalTransition(to: .longForm)
                print("키보드 높이: \(self.fakeViewHeight.constant)")
                self.view.layoutIfNeeded()
                
                
                
                
            }).disposed(by: disposeBag)
            
        
    }
}


extension MultiPurposePopupViewController: PanModalPresentable {

    public override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    public var panModalBackgroundColor: UIColor {
        return colorFromRGB(0x000000, alpha: 0.4)
    }

    public var panScrollable: UIScrollView? {
      return nil
    }

    public var longFormHeight: PanModalHeight {
    
   
        return PanModalHeight.contentHeight(296 + self.fakeViewHeight.constant)
     }

    public var cornerRadius: CGFloat {
        return 24.0
    }

    public var allowsExtendedPanScrolling: Bool {
        return true
    }

    public var showDragIndicator: Bool {
        return false
    }
}
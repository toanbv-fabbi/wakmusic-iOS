//
//  ContainSongsViewController.swift
//  CommonFeature
//
//  Created by yongbeomkwak on 2023/03/11.
//  Copyright © 2023 yongbeomkwak. All rights reserved.
//

import UIKit
import BaseFeature
import Utility
import DesignSystem
import RxSwift

public final class ContainSongsViewController: BaseViewController,ViewControllerFromStoryBoard{
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var songCountLabel: UILabel!
    
    var disposeBag = DisposeBag()
    var viewModel:ContainSongsViewModel!
    lazy var input = ContainSongsViewModel.Input()
    lazy var output = viewModel.transform(from: input)
    
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()

        // Do any additional setup after loading the view.
    }
    
    public static func viewController(viewModel:ContainSongsViewModel) -> ContainSongsViewController {
        let viewController = ContainSongsViewController.viewController(storyBoardName: "CommonUI", bundle: Bundle.module)
        
    
        viewController.viewModel = viewModel
    
       
        return viewController
    }
    

}

extension ContainSongsViewController {
    
    private func configureUI() {
        closeButton.setImage(DesignSystemAsset.Navigation.close.image, for: .normal)
        
        titleLabel.font = DesignSystemFontFamily.Pretendard.medium.font(size: 16)
        titleLabel.textColor = DesignSystemAsset.GrayColor.gray900.color
        
        subTitleLabel.font =  DesignSystemFontFamily.Pretendard.medium.font(size: 14)
        subTitleLabel.textColor = DesignSystemAsset.GrayColor.gray900.color
        
        songCountLabel.font = DesignSystemFontFamily.Pretendard.medium.font(size: 14)
        songCountLabel.textColor = DesignSystemAsset.PrimaryColor.point.color
        
        
        tableView.delegate = self
        
      //  bindRx()
        
        
    }
    
    private func bindRx() {
        
        tableView.rx.setDelegate(self).disposed(by: disposeBag)
        
        
        output.dataSource
        .skip(1)
        .do(onNext: { [weak self] model in
            
            guard let self = self else {
                return
            }
            
            let warningView = WarningView(frame: CGRect(x: 0, y: 0, width: APP_WIDTH(), height: APP_HEIGHT()/3))
            warningView.text = "내 리스트가 없습니다."
            
            
            self.tableView.tableFooterView = model.isEmpty ?  warningView : nil
            
            
            
        })
            .bind(to: tableView.rx.items){[weak self] (tableView,index,model) -> UITableViewCell in
                guard let self = self else{return UITableViewCell()}
                
                let bgView = UIView()
                bgView.backgroundColor = DesignSystemAsset.GrayColor.gray200.color.withAlphaComponent(0.6)
                
                
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "CurrentPlayListTableViewCell",for: IndexPath(row: index, section: 0)) as? CurrentPlayListTableViewCell
                else {return UITableViewCell()}
                 
                cell.selectedBackgroundView = bgView
                cell.update(model: model)
              
                        
             return cell
            }.disposed(by: disposeBag)
        
        
    }
    
}

extension ContainSongsViewController : UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {


        let header = ContainPlayListHeaderView(frame: CGRect(x: 0, y: 0, width: APP_WIDTH(), height: 140))


        header.delegate = self
        return header
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        
        return 64
        
        
    }
}

extension ContainSongsViewController : ContainPlayListHeaderViewDelegate {
    public func action() {
        DEBUG_LOG("추가추가")
    }
    
    
}

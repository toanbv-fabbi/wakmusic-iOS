//
//  MyPlayListViewController.swift
//  StorageFeature
//
//  Created by yongbeomkwak on 2023/01/27.
//  Copyright © 2023 yongbeomkwak. All rights reserved.
//

import UIKit
import Utility
import RxSwift
import RxRelay
import RxCocoa
import DesignSystem
import PanModal
import BaseFeature

class MyPlayListViewController: BaseViewController, ViewControllerFromStoryBoard {

    @IBOutlet weak var tableView: UITableView!

    
    var dataSource: BehaviorRelay<[PlayListDTO]> = BehaviorRelay(value: [PlayListDTO(playListName: "임시 플레이리스트", numberOfSong: 100),PlayListDTO(playListName: "임시 플레이리스트2", numberOfSong: 100),PlayListDTO(playListName: "임시 플레이리스트3", numberOfSong: 100),PlayListDTO(playListName: "임시 플레이리스트4", numberOfSong: 100)])
    
    //var dataSource: BehaviorRelay<[PlayListDTO]> = BehaviorRelay(value: [])

    lazy var viewModel = MyPlayListViewModel()
    
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(sender:)))
        tableView.addGestureRecognizer(longPress)
        
        configureUI()

        // Do any additional setup after loading the view.
    }
    

    public static func viewController() -> MyPlayListViewController {
        let viewController = MyPlayListViewController.viewController(storyBoardName: "Storage", bundle: Bundle.module)
        
      
        
        return viewController
    }

}

extension MyPlayListViewController{
    
    private func configureUI()
    {
        self.tableView.dragDelegate = self
        self.tableView.dropDelegate = self
        bindRx()
    }
    
    @objc private func handleLongPress(sender: UILongPressGestureRecognizer) {
        
        
        if  !viewModel.output.isEditinglist.value && sender.state == .began {
            viewModel.output.isEditinglist.accept(true)
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }
    }
    
    private func bindRx()
    {
        tableView.rx.setDelegate(self).disposed(by: disposeBag)
        
        dataSource
        .do(onNext: { [weak self] model in
            
            guard let self = self else {
                return
            }
            
            let warningView = WarningView(frame: CGRect(x: 0, y: 0, width: APP_WIDTH(), height: APP_HEIGHT()/3))
            warningView.text = "내 리스트가 없습니다."
            
            
            self.tableView.tableHeaderView = model.isEmpty ?  warningView : nil
            
            
            
        })
            .bind(to: tableView.rx.items){[weak self] (tableView,index,model) -> UITableViewCell in
                guard let self = self else{return UITableViewCell()}
                
                let bgView = UIView()
                bgView.backgroundColor = DesignSystemAsset.GrayColor.gray200.color.withAlphaComponent(0.6)
                
                
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "MyPlayListTableViewCell",for: IndexPath(row: index, section: 0)) as? MyPlayListTableViewCell
                else {return UITableViewCell()}
                 
                cell.selectedBackgroundView = bgView
                cell.update(model: model, isEditing: self.viewModel.output.isEditinglist.value)
              
                        
             return cell
            }.disposed(by: disposeBag)
        
        
        self.viewModel.output.isEditinglist
            .do(onNext: { [weak self] (isEdit:Bool) in
                
                guard let self = self else{
                    return
                }
                
                self.tableView.dragInteractionEnabled = isEdit // true/false로 전환해 드래그 드롭을 활성화하고 비활성화 할 것입니다.
                
                guard let parent = self.parent?.parent as? AfterLoginViewController else{
                    return
                }
                // 탭맨 쪽 편집 변경
                parent.viewModel.output.isEditing.accept(isEdit)
                
            
                
                
        
                
                
            })
            .withLatestFrom(dataSource)
            .bind(to: dataSource)
            .disposed(by: disposeBag)
    
        
      
        
    }
    
}



extension MyPlayListViewController:UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        
        let header = MyPlayListHeaderView()
      

        header.delegate = self
        return dataSource.value.isEmpty ? nil :  self.viewModel.output.isEditinglist.value ? nil : header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        
        return dataSource.value.isEmpty ? 0 : self.viewModel.output.isEditinglist.value ? 0 : 140
        
        
    }
    
}

extension MyPlayListViewController:MyPlayListHeaderViewDelegate{
    func action(_ type: PurposeType) {
     
        let vc =  MultiPurposePopupViewController.viewController(type: type) {
            
//            if type == .share {
//                self.showToast(text: "복사가 완료되었습니다.", font: DesignSystemFontFamily.Pretendard.medium.font(size: 14))
//            }
            
            if type == .load {
                self.showToast(text: "잘못된 코드입니다.", font: DesignSystemFontFamily.Pretendard.medium.font(size: 14))
            }

        }
        self.showPanModal(content: vc)
    }    
}

extension  MyPlayListViewController: UITableViewDragDelegate {
    public func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        
        
        self.viewModel.input.sourceIndexPath.accept(indexPath)
        let itemProvider = NSItemProvider(object: "1" as NSString)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        return [dragItem]
        
        
        // 애플의 공식 문서에서는 사용자가 특정 행을 드래그하는 것을 원하지 않으면 빈 배열을 리턴하라고 했는데,
        //빈 배열을 리턴했을 때도 드래그가 가능했습니다. 이 부분은 더 자세히 알아봐야 할 것 같습니다.
    }
    
    
    
    
}

extension  MyPlayListViewController: UITableViewDropDelegate {
    
    
    // 손가락을 화면에서 뗐을 때. 드롭한 데이터를 불러와서 data source를 업데이트 하고, 필요하면 새로운 행을 추가한다.
    public func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
        
        let destinationIndexPath: IndexPath

                if let indexPath = coordinator.destinationIndexPath {
                    destinationIndexPath = indexPath
                } else {
                    // Get last index path of table view.
                    let section = tableView.numberOfSections - 1
                    let row = tableView.numberOfRows(inSection: section)
                    destinationIndexPath = IndexPath(row: row, section: section)
                }
        self.viewModel.input.destIndexPath.accept(destinationIndexPath)
        
        
        
        var curr = dataSource.value
        var tmp = curr[self.viewModel.input.sourceIndexPath.value.row]
        curr.remove(at: self.viewModel.input.sourceIndexPath.value.row)
        curr.insert(tmp, at: self.viewModel.input.destIndexPath.value.row)
        
        dataSource.accept(curr)
        
        
        DEBUG_LOG(destinationIndexPath)
    }
    
    // 드래그할 떄 (손가락을 화면에 대고 있을 때)
    public func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
        var dropProposal = UITableViewDropProposal(operation: .cancel)
    
       
        // Accept only one drag item.
        guard session.items.count == 1 else { return dropProposal }
        
        // The .move drag operation is available only for dragging within this app and while in edit mode.
        if tableView.hasActiveDrag {
            //            if tableView.isEditing {
            dropProposal = UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
            //            }
        } else {
            // Drag is coming from outside the app.
            dropProposal = UITableViewDropProposal(operation: .copy, intent: .insertAtDestinationIndexPath)
        }
        
        
        return dropProposal
    }
    
}
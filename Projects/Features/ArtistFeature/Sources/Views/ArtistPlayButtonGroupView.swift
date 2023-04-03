//
//  ArtistPlayButtonGroupView.swift
//  ArtistFeature
//
//  Created by KTH on 2023/04/03.
//  Copyright © 2023 yongbeomkwak. All rights reserved.
//

import Foundation
import UIKit
import DesignSystem
import Utility
import CommonFeature

public class ArtistPlayButtonGroupView: UIView {
    
    @IBOutlet weak var allPlayButton: UIButton!
    @IBOutlet weak var shufflePlayButton: UIButton!
    
    public weak var delegate: PlayButtonGroupViewDelegate?

    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupView()
    }
    
    @IBAction func allPlayButtonAction(_ sender: Any) {
        delegate?.pressPlay(.allPlay)
    }
    
    @IBAction func shufflePlayButtonAction(_ sender: Any) {
        delegate?.pressPlay(.shufflePlay)
    }
}

extension ArtistPlayButtonGroupView {
    private func setupView(){
        guard let view = Bundle.module.loadNibNamed("ArtistPlayButtonGroupView", owner: self, options: nil)?.first as? UIView else { return }
        view.frame = self.bounds
        view.layoutIfNeeded()
        self.addSubview(view)
        configureUI()
        layoutIfNeeded()
    }
}

extension ArtistPlayButtonGroupView {
    private func configureUI() {
        //전체재생
        allPlayButton.layer.cornerRadius = 8
        allPlayButton.layer.borderColor = DesignSystemAsset.GrayColor.gray200.color.cgColor
        allPlayButton.layer.borderWidth = 1
        allPlayButton.backgroundColor = UIColor.white
        allPlayButton.setImage(DesignSystemAsset.Chart.allPlay.image.withRenderingMode(.alwaysOriginal), for: .normal)
        
        let allButtonAttributedString = NSMutableAttributedString.init(string: "전체재생")
        allButtonAttributedString.addAttributes([.font: DesignSystemFontFamily.Pretendard.medium.font(size: 14),
                                                 .foregroundColor: DesignSystemAsset.GrayColor.gray900.color,
                                                 .kern: -0.5],
                                                range: NSRange(location: 0, length: allButtonAttributedString.string.count))
        allPlayButton.setAttributedTitle(allButtonAttributedString, for: .normal)

        //랜덤재생
        shufflePlayButton.layer.cornerRadius = 8
        shufflePlayButton.layer.borderColor = DesignSystemAsset.GrayColor.gray200.color.cgColor
        shufflePlayButton.layer.borderWidth = 1
        shufflePlayButton.backgroundColor = UIColor.white
        shufflePlayButton.setImage(DesignSystemAsset.Chart.shufflePlay.image.withRenderingMode(.alwaysOriginal), for: .normal)

        let shuffleButtonAttributedString = NSMutableAttributedString.init(string: "랜덤재생")
        shuffleButtonAttributedString.addAttributes([.font: DesignSystemFontFamily.Pretendard.medium.font(size: 14),
                                                     .foregroundColor: DesignSystemAsset.GrayColor.gray900.color,
                                                     .kern: -0.5],
                                                    range: NSRange(location: 0, length: shuffleButtonAttributedString.string.count))
        shufflePlayButton.setAttributedTitle(shuffleButtonAttributedString, for: .normal)
    }
}
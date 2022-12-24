//
//  StorageHeaderCVC.swift
//  Presentation
//
//  Created by 정은희 on 2022/12/08.
//  Copyright © 2022 RecorDream. All rights reserved.
//

import UIKit

import RD_Core
import RD_DSKit

import SnapKit
import HeeKit

final class StorageHeaderCVC: DreamReusableView, Reusable {
    // MARK: - UI Components
    private lazy var countLabel: UILabel = {
        let lb = UILabel()
        lb.font = RDDSKitFontFamily.Pretendard.semiBold.font(size: 12)
        lb.textAlignment = .left
        lb.textColor = RDDSKitAsset.Colors.white01.color
        return lb
    }()
    private lazy var segmentControl = RDStorageSegmentControl(items: ["", ""])
    
    // MARK: - Functions
    override func setupView() {
        self.addSubviews(countLabel, segmentControl)
        self.backgroundColor = .clear
    }
    override func setupConstraint() {
        self.countLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.centerX.equalToSuperview().inset(18)
        }
        self.segmentControl.snp.makeConstraints { make in
            make.width.equalTo(55.adjustedWidth)
            make.height.equalTo(24.adjustedHeight)
            make.top.equalToSuperview().offset(20)
            make.centerX.equalTo(countLabel.snp.trailing).inset(233)
        }
    }
}

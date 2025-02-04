//
//  DreamSearchVC.swift
//  Presentation
//
//  Created by 정은희 on 2022/10/10.
//  Copyright © 2022 RecorDream. All rights reserved.
//

import UIKit

import Domain
import RD_DSKit

import RxSwift
import RxCocoa

public class DreamSearchVC: UIViewController {
    // MARK: - UI Components
    private lazy var navigationBar = RDNaviBar().title("검색하기")
    private lazy var searchLabel: UILabel = {
        let lb = UILabel()
        lb.font = RDDSKitFontFamily.Pretendard.semiBold.font(size: 14.adjusted)
        lb.text = "검색어 입력"
        lb.textColor = .white
        return lb
    }()
    private lazy var searchTextField = DramSearchTextField()
    private lazy var dreamSearchCollectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: self.createLayout())
        cv.showsVerticalScrollIndicator = false
        cv.backgroundColor = RDDSKitAsset.Colors.dark.color
        cv.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        cv.allowsMultipleSelection = true
        return cv
    }()
    
    // MARK: - Reactive Properties
    private let searchKeyword = PublishRelay<String>()
    private let fetchedCount = BehaviorRelay<Int>(value: 0)
    private var disposeBag = DisposeBag()
    public var factory: ViewControllerFactory!
    public var viewModel: DreamSearchViewModel!
    lazy var dataSource: UICollectionViewDiffableDataSource<DreamSearchResultType, AnyHashable>! = nil
    
    // MARK: - View Life Cycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setDelegate()
        self.bindCollectionView()
        self.bindDismissButton()
        self.bindTextField()
        self.bindViewModels()
        self.setupView()
        self.setupConstraint()
        self.setDataSource()
        self.registerXib()
    }
}

// MARK: - UI
extension DreamSearchVC {
    public func setupView() {
        self.view.backgroundColor = .black
        self.view.addSubviews(navigationBar, searchLabel, searchTextField, dreamSearchCollectionView)
    }
    
    private func setDelegate() {
        self.dreamSearchCollectionView.rx
            .setDelegate(self)
            .disposed(by: self.disposeBag)
    }
    
    public func setupConstraint() {
        navigationBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(44.adjustedHeight)
        }
        searchLabel.snp.makeConstraints { make in
            make.top.equalTo(navigationBar.snp.bottom).offset(34)
            make.leading.equalToSuperview().offset(16)
        }
        searchTextField.snp.makeConstraints { make in
            make.height.equalTo(46.adjustedHeight)
            make.width.equalTo(343.adjustedWidth)
            make.centerX.equalToSuperview()
            make.top.equalTo(searchLabel.snp.bottom).offset(16)
        }
        dreamSearchCollectionView.snp.makeConstraints { make in
            make.top.equalTo(searchTextField.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    private func registerXib() {
        dreamSearchCollectionView.register(DreamSearchBottomCVC.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: DreamSearchBottomCVC.reuseIdentifier)
        dreamSearchCollectionView.register(DreamSearchHeaderCVC.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: DreamSearchHeaderCVC.reuseIdentifier)
        dreamSearchCollectionView.register(DreamSearchExistCVC.self, forCellWithReuseIdentifier: DreamSearchExistCVC.reuseIdentifier)
    }
}
// MARK: - DataSource
extension DreamSearchVC: UICollectionViewDelegate {
    private func setDataSource() {
        self.dataSource = UICollectionViewDiffableDataSource<DreamSearchResultType, AnyHashable>(collectionView: dreamSearchCollectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            if let model = itemIdentifier as? DreamSearchEntity.Record {
                guard let resultCell = collectionView.dequeueReusableCell(withReuseIdentifier: DreamSearchExistCVC.reuseIdentifier, for: indexPath) as? DreamSearchExistCVC else { return UICollectionViewCell() }
                resultCell.setData(emotion: model.emotion ?? 0, date: model.date ?? "", title: model.title ?? "", genre: model.genre ?? [])
                return resultCell
            }
            else {
                collectionView.setEmptyView()
            }
            return UICollectionViewCell()
        })
        
        self.dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            switch kind {
            case UICollectionView.elementKindSectionHeader:
                guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: DreamSearchHeaderCVC.reuseIdentifier, for: indexPath) as? DreamSearchHeaderCVC else { return UICollectionReusableView() }
                header.configureCell(counts: self.fetchedCount.value)
                return header
            case UICollectionView.elementKindSectionFooter:
                guard let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: DreamSearchBottomCVC.reuseIdentifier, for: indexPath) as? DreamSearchBottomCVC else { return UICollectionReusableView() }
                return footer
            default:
                return UICollectionReusableView()
            }
        }
    }
    private func applySnapShot(model: DreamSearchEntity) {
        var snapshot = NSDiffableDataSourceSnapshot<DreamSearchResultType, AnyHashable>()
        self.fetchedCount.accept(model.recordsCount)
        if model.recordsCount == 0 {
            self.dreamSearchCollectionView.setEmptyView()
        } else {
            self.dreamSearchCollectionView.restore()
            snapshot.appendSections([.exist])
            print(model.records)
            snapshot.appendItems(model.records, toSection: .exist)
        }
        self.dataSource.apply(snapshot)
        self.view.setNeedsLayout()
    }
}
// MARK: - Bind
extension DreamSearchVC {
    private func bindViewModels() {
        let input = DreamSearchViewModel.Input(currentSearchQuery: self.searchTextField.shouldLoadResult, returnButtonTapped: self.searchTextField.returnKeyTapped.asObservable())
        
        let output = self.viewModel.transform(from: input, disposeBag: self.disposeBag)
        
        output.searchResultModelFetched
            .compactMap { $0 }
            .withUnretained(self)
            .subscribe(onNext: { owner, entity in
                owner.applySnapShot(model: entity)
            }).disposed(by: self.disposeBag)
        
        output.loadingStatus
            .bind(to: self.rx.isLoading)
            .disposed(by: disposeBag)
        
    }
    private func bindCollectionView() {
        self.dreamSearchCollectionView.rx.itemSelected
            .withUnretained(self)
            .subscribe(onNext: { (owner, item) in
                let detailVC = owner.factory.instantiateDetailVC(dreamId: "")
                owner.present(detailVC, animated: true)
            }).disposed(by: disposeBag)
    }
    private func bindDismissButton() {
        self.navigationBar.leftButtonTapped
            .withUnretained(self)
            .subscribe(onNext: { owner in
                self.dismiss(animated: true)
            }).disposed(by: disposeBag)
    }
    
    private func bindTextField() {
        self.searchTextField.shouldLoadResult
            .bind(to: self.searchKeyword)
            .disposed(by: self.disposeBag)
    }
}

//
//  MyPageViewModel.swift
//  PresentationTests
//
//  Created by Junho Lee on 2022/10/09.
//  Copyright © 2022 RecorDream. All rights reserved.
//

import Domain
import RD_Core
import RD_DSKit

import RxSwift
import RxCocoa

public class MyPageViewModel: ViewModelType {
    
    private let useCase: MyPageUseCase
    private let disposeBag = DisposeBag()
    
    // MARK: - Inputs
    
    public struct Input {
        let viewDidLoad: Observable<Void>
        let editButtonTapped: Observable<Void>
        let myPageReturnOutput: Observable<MyPageEditableView.EndEditOutput>
        let usernameAlertDismissed: Observable<Void>
        let pushSwitchChagned: Observable<Bool>
        let pushTimePicked: Observable<String>
        let logoutButtonTapped: Observable<Void>
        let withdrawlButtonTapped: Observable<Void>
    }
    
    // MARK: - CoordinatorInput
    
    var logoutCompleted = PublishRelay<Void>()
    var withdrawlCompleted = PublishRelay<Void>()
    
    // MARK: - Outputs
    
    public struct Output {
        var myPageDataFetched = PublishRelay<MyPageEntity>()
        var startUsernameEdit = PublishRelay<Bool>()
        var showAlert = PublishRelay<Void>()
        var usernameEditCompleted = PublishRelay<Bool>()
        var loadingStatus = BehaviorRelay<Bool>(value: true)
    }
    
    // MARK: - Coordination
    
    public init(useCase: MyPageUseCase) {
        self.useCase = useCase
    }
}

extension MyPageViewModel {
    public func transform(from input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output()
        
        self.bindOutput(output: output, disposeBag: disposeBag)
        return output
    }
  
    private func bindOutput(output: Output, disposeBag: DisposeBag) {
    
    }
}

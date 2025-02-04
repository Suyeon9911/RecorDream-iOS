//
//  SplashVC.swift
//  Presentation
//
//  Created by 정은희 on 2022/12/01.
//  Copyright © 2022 RecorDream. All rights reserved.
//

import UIKit

import Domain
import RD_Core
import RD_Network

import RxSwift

public final class SplashVC: UIViewController {
    
    private let authView = AuthView()
    private let disposeBag = DisposeBag()
    public var factory: ViewControllerFactory!
    
    // MARK: - View Life Cycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupView()
        self.setupConstraint()
    }
}

// MARK: - Extensions
extension SplashVC: AuthControllable {
    func setupView() {
        self.view.addSubview(authView)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            UIView.animate(withDuration: 1.0, delay: 0) {
                self.modalTransitionStyle = .partialCurl
                self.setupViewState()
            }
        }
    }
    
    func setupConstraint() {
        self.authView.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalToSuperview()
            make.centerX.centerY.equalToSuperview()
        }
    }
}

extension SplashVC {
    private func setupViewState() {
        self.checkLoginEnable { loginEnabled in
            switch loginEnabled {
            case true:
                self.presentMainTabBar()
            case false:
                self.presentLoginVC()
            }
        }
    }
    
    private func presentMainTabBar() {
        let mainTabBar = self.factory.instantiateMainTabBarController()
        let navigation = UINavigationController(rootViewController: mainTabBar)
        UIApplication.setRootViewController(window: UIWindow.keyWindowGetter!, viewController: navigation, withAnimation: true)
    }
    
    private func presentLoginVC() {
        let loginVC = self.factory.instantiateLoginVC()
        loginVC.modalPresentationStyle = .overFullScreen
        loginVC.modalTransitionStyle = .crossDissolve
        self.present(loginVC, animated: true)
    }
    
    private func checkLoginEnable(completion: @escaping ((Bool) -> Void)) {
        if UserDefaults.standard.string(forKey: UserDefaultKey.userToken.rawValue) != nil &&
            UserDefaults.standard.string(forKey: UserDefaultKey.accessToken.rawValue) != nil {
            DefaultAuthService.shared.reissuance()
                .subscribe(onNext: { response in
                    guard let response = response else {
                        completion(false)
                        return
                    }
                    
                    let isStillValidToken = (response.status == 403)
                    if isStillValidToken {
                        completion(true)
                        return
                    }
                    
                    guard let token = response.data else {
                        completion(false)
                        return
                    }
                    
                    DefaultUserDefaultManager.set(value: token.accessToken, keyPath: .accessToken)
                    DefaultUserDefaultManager.set(value: token.refreshToken, keyPath: .refreshToken)
                    completion(true)
                })
                .disposed(by: self.disposeBag)
        }
        else {
            completion(false)
        }
    }
}

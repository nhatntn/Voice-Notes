//
//  AppCoordinator.swift
//  VoiceNotes
//
//  Created by nhatnt on 27/05/2022.
//

import Foundation
import UIKit

protocol Coordinator {
    func start()
}

final class AppCoordinator: Coordinator {
    lazy var appConfiguration = AppConfiguration()
    
    private let window: UIWindow?
    private let navigationController = UINavigationController()
    
    init(window: UIWindow) {
        self.window = window
    }
    
    func start() {
        window?.rootViewController = navigationController
        
        let homeCoordinator = HomeCoordinator(navigator: navigationController)
        homeCoordinator.start()
        
        window?.makeKeyAndVisible()
    }
}

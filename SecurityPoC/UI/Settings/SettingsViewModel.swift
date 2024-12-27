//
//  SettingsViewModel.swift
//  SecurityPoC
//
//  Created by Vladislav Simovic on 25.12.24..
//

import SwiftUI
import Combine

final class SettingsViewModel: ObservableObject {
    var items: [SettingsItemViewModel]
    
    init() {
        self.items = [
            SettingsItemViewModel(strategy: SMSFilteringStrategy()),
            SettingsItemViewModel(strategy: SafariContentBlockerStrategy()),
            SettingsItemViewModel(strategy: NEContentBlockerStrategy()),
            SettingsItemViewModel(strategy: NELocalVPNStrategy())
        ]
    }
}

final class SettingsItemViewModel: ObservableObject {
    @Published var isOn: Bool = false
    let name: String
    private let strategy: ProtectionStrategy
    private var subscriptions = Set<AnyCancellable>()
    
    init(strategy: ProtectionStrategy) {
        self.name = strategy.name
        self.strategy = strategy
        
        $isOn
            .dropFirst()
            .sink { value in
                if value {
                    strategy.start()
                } else {
                    strategy.stop()
                }
            }
            .store(in: &subscriptions)
    }
}


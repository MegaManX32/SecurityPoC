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
                Task {
                    do {
                        if value {
                            try await strategy.start()
                        } else {
                            try await strategy.stop()
                        }
                    } catch {
                        await MainActor.run { [weak self] in
                            self?.isOn = !value
                            Logger.shared.log(message: error.localizedDescription, level: .error)
                        }
                    }
                }
            }
            .store(in: &subscriptions)
    }
}


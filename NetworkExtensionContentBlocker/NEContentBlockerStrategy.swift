//
//  NEContentBlockerStrategy.swift
//  SecurityPoC
//
//  Created by Vladislav Simovic on 25.12.24..
//

import NetworkExtension

final class NEContentBlockerStrategy: ProtectionStrategy {
    private let user: String
    private let description: String
    
    init(user: String = "Administrator", description: String = "Content Blocker") {
        self.user = user
        self.description = description
    }
    
    var name: String {
        "Network Extension Content Blocker"
    }
    
    func start() async throws {
        let filterManager = NEFilterManager.shared()
        try await filterManager.loadFromPreferences()
        
        if filterManager.providerConfiguration == nil {
            filterManager.localizedDescription = description
            let providerConfig = NEFilterProviderConfiguration()
            providerConfig.filterSockets = true
            providerConfig.filterBrowsers = true
            providerConfig.username = user
            filterManager.providerConfiguration = providerConfig
        }
        
        filterManager.isEnabled = true
        try await filterManager.saveToPreferences()
        
        Logger.shared.log(message: "Network Content Blocker Enabled")
    }
    
    func stop() async throws {
        let filterManager = NEFilterManager.shared()
        try await filterManager.loadFromPreferences()
        
        filterManager.isEnabled = false
        try await filterManager.saveToPreferences()
        
        Logger.shared.log(message: "Network Content Blocker Disabled")
    }
}

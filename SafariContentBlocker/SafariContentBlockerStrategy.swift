//
//  SafariContentBlockerStrategy.swift
//  SecurityPoC
//
//  Created by Vladislav Simovic on 25.12.24..
//

import Foundation
import SafariServices

final class SafariContentBlockerStrategy: ProtectionStrategy {
    
    private enum SafariContentBlockerError: String, Error {
        case sharedContainerNotFound
    }
    
    private let encoder = JSONEncoder()
    
    var name: String {
        "Safari Content Blocker"
    }
    
    func start() {
        Task {
            do {
                let rules = PhishingCacheFactory.shared.phishingCache().blockedDomains.map { SafariCBRule(domain: $0) }
                try await updateSFContentBlockerManager(with: rules)
                Logger.shared.log(message: "Safari Content Blocker Enabled")
            } catch {
                Logger.shared.log(message: error.localizedDescription, level: .error)
            }
        }
    }
    
    func stop() {
        Task {
            do {
                let rules = SafariCBRule.emptySet
                try await updateSFContentBlockerManager(with: rules)
                Logger.shared.log(message: "Safari Content Blocker Disabled")
            } catch {
                Logger.shared.log(message: error.localizedDescription, level: .error)
            }
        }
    }
    
    private func updateSFContentBlockerManager(with rules: [SafariCBRule]) async throws {
        let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: PhishingKeys.suiteName)
        guard let container else { throw SafariContentBlockerError.sharedContainerNotFound }
        
        let data = try encoder.encode(rules)
        let blockerPath = container.appendingPathComponent(PhishingKeys.contentBlockerPath)
        try data.write(to: blockerPath, options: .atomic)
        try await SFContentBlockerManager.reloadContentBlocker(withIdentifier: PhishingKeys.pseudoBrowserBundle)
    }
}
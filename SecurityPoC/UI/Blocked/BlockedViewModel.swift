//
//  WelcomeViewModel.swift
//  SMSFiltering
//
//  Created by Vladislav Simovic on 12.12.24..
//

import Foundation
import NetworkExtension

final class BlockedViewModel: ObservableObject {
    
    @Published private(set) var domains: [String]
    @Published var newDomain: String = ""
    private let cache: PhishingCache
    
    init() {
        cache = PhishingCacheFactory.shared.phishingCache()
        domains = cache.blockedDomains
    }
    
    func addDomain() {
        cache.add(domain: newDomain)
        PhishingCacheFactory.shared.saveCache(cache)
        domains = cache.blockedDomains
        newDomain = ""
    }
    
    func removeDomain(_ domain: String) {
        cache.remove(domain: domain)
        PhishingCacheFactory.shared.saveCache(cache)
        domains = cache.blockedDomains
    }
}

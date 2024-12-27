//
//  PhishingCache.swift
//  SMSFiltering
//
//  Created by Vladislav Simovic on 11.12.24..
//

import Foundation

final class PhishingCache: Codable {
    private(set) var blockedDomains = [String]()
    
    init() {
        blockedDomains.append("www.phishing.com")
        blockedDomains.append("www.phishing.net")
    }
    
    func add(domain: String) {
        blockedDomains.append(domain)
    }
    
    func remove(domain: String) {
        blockedDomains = blockedDomains.filter { $0 != domain }
    }
    
    func isPhishing(with body: String) -> Bool {
        for key in blockedDomains {
            if body.contains(key) {
                return true
            }
        }
        return false
    }
}

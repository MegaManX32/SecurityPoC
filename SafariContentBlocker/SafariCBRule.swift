//
//  ContentBlockerRule.swift
//  PhishingProtector
//
//  Created by Vladislav Simovic on 13.12.24..
//

struct SafariCBRule: Codable {
    
    static let emptySet = [SafariCBRule(domain: "www.none.com")]
    
    struct Action: Codable {
        let type = "block"
        
        private enum CodingKeys: String, CodingKey {
            case type
        }
    }
    
    struct Trigger: Codable {
        let filter: String
        
        private enum CodingKeys: String, CodingKey {
            case filter = "url-filter"
        }
    }
    
    let action: Action
    let trigger: Trigger
    
    private enum CodingKeys: String, CodingKey {
        case action, trigger
    }
    
    init(action: Action, trigger: Trigger) {
        self.action = action
        self.trigger = trigger
    }
    
    init(domain: String) {
        self.init(action: Action(), trigger: Trigger(filter: domain))
    }
}

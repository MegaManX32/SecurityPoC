//
//  PhishingFactory.swift
//  PhishingProtector
//
//  Created by Vladislav Simovic on 13.12.24..
//

import Foundation
import SafariServices

final class PhishingCacheFactory {
    
    private enum PhishingCacheError: String, Error {
        case cacheDataCouldNotBeRetrieved
    }
    
    static let shared = PhishingCacheFactory()
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    func phishingCache() -> PhishingCache {
        do {
            let data = try dataFromSuite()
            let cache = try decoder.decode(PhishingCache.self, from: data)
            Logger.shared.log(message: "Cache found")
            return cache
        } catch {
            Logger.shared.log(message: error.localizedDescription, level: .error)
        }
        
        let cache = PhishingCache()
        do {
            let data = try encoder.encode(cache)
            storeDataToSuite(data)
            Logger.shared.log(message: "Cache created")
        } catch {
            Logger.shared.log(message: error.localizedDescription, level: .error)
        }
        
        return cache
    }
    
    func saveCache(_ cache: PhishingCache) {
        do {
            let data = try encoder.encode(cache)
            storeDataToSuite(data)
            Logger.shared.log(message: "Cache saved")
        } catch {
            Logger.shared.log(message: error.localizedDescription, level: .error)
        }
    }
    
    private func dataFromSuite() throws -> Data {
        guard let data = UserDefaults(suiteName: PhishingKeys.suiteName)?.data(forKey: PhishingKeys.cacheKey) else {
            throw PhishingCacheError.cacheDataCouldNotBeRetrieved
        }
        return data
    }
    
    private func storeDataToSuite(_ data: Data) {
        UserDefaults(suiteName: PhishingKeys.suiteName)?.set(data, forKey: PhishingKeys.cacheKey)
    }
}

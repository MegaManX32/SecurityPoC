//
//  FilterDataProvider.swift
//  NetworkExtensionContentBlocker
//
//  Created by Vladislav Simovic on 24.12.24..
//

import Foundation
import NetworkExtension

class FilterDataProvider: NEFilterDataProvider {
    
    override func handleNewFlow(_ flow: NEFilterFlow) -> NEFilterNewFlowVerdict {
        if let browserFlow = flow as? NEFilterBrowserFlow, let url = browserFlow.request?.url {
            if isBlockedURL(url) {
                Logger.shared.log(message: "Blocking outbound traffic to \(url.absoluteString)")
                return .drop()
            } else {
                Logger.shared.log(message: "Allowing outbound traffic to \(url.absoluteString)")
                return .allow()
            }
        } else if let socketFlow = flow as? NEFilterSocketFlow, let remoteHost = socketFlow.remoteHostname {
            if isBlockedHost(remoteHost) {
                Logger.shared.log(message: "Blocking outbound traffic to \(remoteHost)")
                return .drop()
            } else {
                Logger.shared.log(message: "Allowing outbound traffic to \(remoteHost)")
                return .allow()
            }
        } else {
            return .allow()
        }
    }
    
    private func isBlockedURL(_ url: URL) -> Bool {
        guard let host = url.host() else { return false }
        return isBlockedHost(host)
    }
    
    private func isBlockedHost(_ host: String) -> Bool {
        let blockedDomains = PhishingCacheFactory.shared.phishingCache().blockedDomains
        return blockedDomains.contains(where: { host.contains($0) })
    }
}

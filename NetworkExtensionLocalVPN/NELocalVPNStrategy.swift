//
//  NELocalVPNStrategy.swift
//  SecurityPoC
//
//  Created by Vladislav Simovic on 26.12.24..
//

import NetworkExtension

final class NELocalVPNStrategy: ProtectionStrategy {
    
    private enum NELocalVPNStrategyError: String, Error {
        case noExistingVPNConfiguration
    }
    
    private var vpnManager: NETunnelProviderManager!
    private let bundleId = "com.grouplogic.securityPoC.NetworkExtensionLocalVPN"
    
    var name: String {
        "Network Extension Local VPN (Beta)"
    }
    
    private func vpnManager() async throws -> NETunnelProviderManager {
        if vpnManager != nil {
            return vpnManager
        } else {
            vpnManager = try await manager(for: bundleId)
            return vpnManager
        }
    }
    
    private func manager(for bundleId: String) async throws -> NETunnelProviderManager {
        let managers = try await NETunnelProviderManager.loadAllFromPreferences()
        if let vpnManager = managers.first {
            Logger.shared.log(message: "Found VPN manager")
            return vpnManager
        }

        Logger.shared.log(message: "No preferences, create new VPN manager")
        let vpnManager = NETunnelProviderManager()
        
        let tunnelProtocol = NETunnelProviderProtocol()
        tunnelProtocol.serverAddress = "127.0.0.1"
        tunnelProtocol.providerBundleIdentifier = bundleId
        tunnelProtocol.disconnectOnSleep = false
        
        vpnManager.protocolConfiguration = tunnelProtocol
        vpnManager.isEnabled = true
        
        Logger.shared.log(message: "Attempt save to preferances")
        try await vpnManager.saveToPreferences()
        Logger.shared.log(message: "Saved to preferances")
        throw NELocalVPNStrategyError.noExistingVPNConfiguration
    }
    
    func start() async throws {
        try await vpnManager().connection.startVPNTunnel()
        Logger.shared.log(message: "VPN tunnel started successfully")
    }
    
    func stop() async throws {
        try await vpnManager().connection.stopVPNTunnel()
        Logger.shared.log(message: "VPN tunnel stopped successfully")
    }
}

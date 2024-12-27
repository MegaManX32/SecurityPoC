//
//  NELocalVPNStrategy.swift
//  SecurityPoC
//
//  Created by Vladislav Simovic on 26.12.24..
//

import NetworkExtension

final class NELocalVPNStrategy: ProtectionStrategy {
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
        
        try await vpnManager.saveToPreferences()
        return vpnManager
    }
    
    func start() {
        Task {
            do {
                try await vpnManager().connection.startVPNTunnel()
                Logger.shared.log(message: "VPN tunnel started successfully")
            } catch {
                Logger.shared.log(message: error.localizedDescription, level: .error)
            }
        }
    }
    
    func stop() {
        Task {
            do {
                try await vpnManager().connection.stopVPNTunnel()
                Logger.shared.log(message: "VPN tunnel stopped successfully")
            } catch {
                Logger.shared.log(message: error.localizedDescription, level: .error)
            }
        }
    }
}

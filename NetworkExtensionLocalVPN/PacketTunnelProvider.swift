//
//  PacketTunnelProvider.swift
//  SecurityPoC
//
//  Created by Vladislav Simovic on 26.12.24..
//

import NetworkExtension

final class PacketTunnelProvider: NEPacketTunnelProvider {
    
    private var isReadingPackets = false
    private var packetCounter = 0
    
    override func startTunnel(options: [String : NSObject]? = nil) async throws {
        Logger.shared.log(message: "Start Tunnel")
        let tunnelSettings = NEPacketTunnelNetworkSettings(tunnelRemoteAddress: "127.0.0.1")
        
        // Assign a virtual network interface IP address
        tunnelSettings.ipv4Settings = NEIPv4Settings(addresses: ["192.168.1.1"], subnetMasks: ["255.255.255.0"])
        tunnelSettings.ipv4Settings?.includedRoutes = [NEIPv4Route.default()]
        
        // Set DNS servers
        tunnelSettings.dnsSettings = NEDNSSettings(servers: ["8.8.8.8", "1.1.1.1"])
        
        try await setTunnelNetworkSettings(tunnelSettings)
        
        startInspecting()
    }
    
    private func startInspecting() {
        Task.detached(priority: .background) { [unowned self] in
            isReadingPackets = true
            let packetFlow = self.packetFlow
            
            while isReadingPackets {
                let (packets, protocols) = await packetFlow.readPackets()
                packetFlow.writePackets(packets, withProtocols: protocols)
            }
        }
    }
    
    override func stopTunnel(with reason: NEProviderStopReason) async {
        isReadingPackets = false
    }
}


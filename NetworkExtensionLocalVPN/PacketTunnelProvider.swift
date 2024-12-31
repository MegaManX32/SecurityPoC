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
        tunnelSettings.ipv4Settings?.excludedRoutes = [
            NEIPv4Route(destinationAddress: "8.8.8.8", subnetMask: "255.255.255.255"),
            NEIPv4Route(destinationAddress: "1.1.1.1", subnetMask: "255.255.255.255"),
        ]
        
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
                for (packet, protocolNumber) in zip(packets, protocols) {
                    if let destinationAddress = extractDestinationIPAddress(from: packet, protocolNumber: protocolNumber.int32Value) {
                        Logger.shared.log(message: "Destination Address: \(destinationAddress)")
                    }
                }
                
                packetFlow.writePackets(packets, withProtocols: protocols)
            }
        }
    }
    
    override func stopTunnel(with reason: NEProviderStopReason) async {
        isReadingPackets = false
    }
}

// MARK: - IP Extraction

extension PacketTunnelProvider {
    private func extractDestinationIPAddress(from packet: Data, protocolNumber: Int32) -> String? {
        if protocolNumber == AF_INET { // IPv4
            guard packet.count >= 20 else { return nil }
            let destinationIP = packet.subdata(in: 16..<20)
            let address = destinationIP.map { String($0) }.joined(separator: ".")
            if let port = extractDestinationPort(from: packet, protocolNumber: protocolNumber) {
                return "\(address):\(port)"
            }
            return address
        } else if protocolNumber == AF_INET6 { // IPv6
            if let address = extractIPv6DestinationAddress(from: packet) {
                if let port = extractDestinationPort(from: packet, protocolNumber: protocolNumber) {
                    return "[\(address)]:\(port)"
                }
                return address
            }
        }
        return nil
    }
    
    private func extractIPv6DestinationAddress(from packet: Data) -> String? {
        guard packet.count >= 40 else { return nil } // Minimum size of an IPv6 header

        let destinationIP = packet.subdata(in: 24..<40) // Bytes 24–39
        let segments = stride(from: 0, to: destinationIP.count, by: 2).map {
            String(format: "%02x%02x", destinationIP[$0], destinationIP[$0 + 1])
        }
        return segments.joined(separator: ":")
    }
    
    private func extractDestinationPort(from packet: Data, protocolNumber: Int32) -> Int? {
        let ipHeaderLength: Int
        if protocolNumber == AF_INET {
            ipHeaderLength = 20 // IPv4 header length
        } else if protocolNumber == AF_INET6 {
            ipHeaderLength = 40 // IPv6 header length
        } else {
            return nil
        }
        
        guard packet.count >= ipHeaderLength + 4 else { return nil }
        let portBytes = packet.subdata(in: ipHeaderLength + 2..<ipHeaderLength + 4)
        return Int(portBytes.withUnsafeBytes { $0.load(as: UInt16.self).bigEndian })
    }
}

// MARK: - SNI extraction (In Development)

extension PacketTunnelProvider {
    func extractSNI(from packet: Data) -> String? {
        guard packet.count > 43 else { return nil }
        
        if packet[0] == 0x16 {
            let handshakeType = packet[5]
            if handshakeType == 0x01 {
                if let range = packet.range(of: Data([0x00, 0x00])) {
                    let lengthIndex = range.upperBound
                    if lengthIndex + 2 < packet.count {
                        let nameLength = Int(packet[lengthIndex]) << 8 | Int(packet[lengthIndex + 1])
                        let nameStart = lengthIndex + 2
                        if nameStart + nameLength <= packet.count {
                            return String(data: packet.subdata(in: nameStart..<nameStart + nameLength), encoding: .utf8)
                        }
                    }
                }
            }
        }
        return nil
    }
}


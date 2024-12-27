//
//  ProtectionStrategy.swift
//  SecurityPoC
//
//  Created by Vladislav Simovic on 25.12.24..
//

protocol ProtectionStrategy {
    var name: String { get }
    func start()
    func stop()
}

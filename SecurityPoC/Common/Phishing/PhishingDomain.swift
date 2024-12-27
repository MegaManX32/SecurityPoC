//
//  PhishingDomain.swift
//  PhishingProtector
//
//  Created by Vladislav Simovic on 13.12.24..
//

import Foundation

struct PhishingDomain: Codable, Identifiable, Equatable {
    let name: String
    var id: String { name }
}

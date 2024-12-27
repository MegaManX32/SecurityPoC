//
//  MainView.swift
//  SecurityPoC
//
//  Created by Vladislav Simovic on 25.12.24..
//

import SwiftUI

struct MainView: View {
    var body: some View {
        TabView {
            Tab {
                NavigationStack {
                    BlockedView()
                        .navigationTitle("Blocked Domains")
                }
            } label: {
                Image(systemName: "nosign")
            }
            
            Tab {
                NavigationStack {
                    SettingsView()
                        .navigationTitle("Settings")
                }
            } label: {
                Image(systemName: "gear")
            }
        }
    }
}

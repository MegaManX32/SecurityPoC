//
//  SettingsView.swift
//  SecurityPoC
//
//  Created by Vladislav Simovic on 25.12.24..
//

import SwiftUI

struct SettingsView: View {
    
    @StateObject private var viewModel = SettingsViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(viewModel.items.indices, id: \.self) { index in
                SettingsItemView(viewModel: viewModel.items[index])
                    .padding([.top, .bottom], 8)
            }
            
            Spacer()
        }
        .padding([.leading, .trailing], 16)
    }
}

private struct SettingsItemView: View {
    @ObservedObject private var viewModel: SettingsItemViewModel
    
    init(viewModel: SettingsItemViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        Toggle(viewModel.name, isOn: $viewModel.isOn)
            .toggleStyle(.switch)
    }
}

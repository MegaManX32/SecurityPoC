//
//  BlockedView.swift
//  SMSFiltering
//
//  Created by Vladislav Simovic on 12.12.24..
//

import SwiftUI

struct BlockedView: View {
    
    @StateObject private var viewModel = BlockedViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(viewModel.domains.indices, id: \.self) { index in
                    BlockedRow(text: viewModel.domains[index]) {
                        viewModel.removeDomain(viewModel.domains[index])
                    }
                }
                BlockedAddRow(newDomainName: $viewModel.newDomain) {
                    viewModel.addDomain()
                }
                Spacer()
            }
        }
    }
}

private struct BlockedRow: View {
    let text: String
    let tapClosure: (() -> Void)?
    
    var body: some View {
        HStack {
            Text(text)
                .multilineTextAlignment(.leading)
                .font(.system(size: 18))
                .padding([.leading, .trailing], 16)
                .padding([.top, .bottom], 8)
            
            Spacer()
            
            Button(action: {
                tapClosure?()
            }) {
                Label("", systemImage: "trash")
                    .foregroundStyle(.red)
            }
            .padding(.trailing, 16)
        }
    }
}

private struct BlockedAddRow: View {
    @Binding var newDomainName: String
    let tapClosure: (() -> Void)?
    
    var body: some View {
        HStack(spacing: 0) {
            TextField("Enter new domain", text: $newDomainName)
                .autocapitalization(.none)
                .autocorrectionDisabled()
                .multilineTextAlignment(.leading)
                .font(.system(size: 18))
                .padding([.leading, .trailing], 16)
                .padding([.top, .bottom], 8)
                .overlay(content: {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.blue, lineWidth: 2)
                })
                .padding([.leading, .trailing], 16)
            
            Button(action: {
                tapClosure?()
            }) {
                Label("", systemImage: "plus")
                    .foregroundStyle(.blue)
            }
            .padding([.leading, .trailing], 16)
        }
    }
}

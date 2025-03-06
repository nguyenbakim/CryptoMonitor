//
//  ContentView.swift
//  CryptoMonitor
//
//  Created by Kim Nguyen on 22.02.24.
//

import SwiftUI

struct CryptoListView: View {
    @StateObject private var repo = BinanceRepoFactory.makeRepo()

    @State private var info: [String: String] = [:]
    
    var body: some View {
        NavigationStack {
            HStack {
                Image("CryptoMonitor")
                    .resizable().scaledToFit()
                    .frame(width: 32, height: 32)
                Text("CRYPTO MONITOR")
                    .font(.headline)
            }
            Divider()

            List {
                ForEach(Array(info.keys), id: \.self) { key in
                    if let crypto = BinanceRepoFactory.getCrypto(for: key),
                       let price = info[key]?.asDecimalStringRounded() {
                        NavigationLink(destination: CryptoTradeView(repo: repo, cryptoStream: .init(stream: key, crypto: crypto))) {
                            CryptoItemView(crypto: crypto, price: price)
                                .frame(height: 45)
                        }
                    }
                }
            }
            .listStyle(.plain)
        }
        .onChange(of: repo.response) { _, newValue in
            if let newValue {
                info[newValue.stream] = newValue.data.p
            }
        }
        .task {
            repo.connect()
        }
    }
}

#Preview {
    CryptoListView()
}

//
//  CryptoItemView.swift
//  CryptoMonitor
//
//  Created by Kim Nguyen on 02.03.24.
//

import SwiftUI

struct CryptoItemView: View {
    let crypto: Crypto
    let price: String
    
    var body: some View {
        HStack {
            Image(crypto.icon)
                .resizable()
                .scaledToFit()
                .frame(width: 32, height: 32)
            
            VStack(alignment: .leading) {
                Text(crypto.symbol.uppercased())
                    .font(.headline)
                Text(crypto.name)
                    .foregroundStyle(.secondary)
                
            }

            Spacer()
            
            Text(price)
                .font(.headline)
        }
    }
}

#Preview {
    CryptoItemView(
        crypto: .init(name: "Bitcoin", symbol: "BTC", icon: "bitcoin"),
        price: "99.99"
    ).padding()
}

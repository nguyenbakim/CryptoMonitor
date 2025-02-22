//
//  BinanceRepoFactory.swift
//  CryptoMonitor
//
//  Created by Kim Nguyen on 02.03.24.
//

import Foundation

final class BinanceRepoFactory {
    // Default most 10 traded cryptos
    static let cryptoStreams: [CryptoStream] = [
        .init(
            stream: "btcusdt@trade",
            crypto: .init(name: "Bitcoin", symbol: "BTC", icon: "bitcoin")
        ),
        .init(
            stream: "bnbusdt@trade",
            crypto: .init(name: "Binance Coin", symbol: "BNB", icon: "bnb")
        ),
        .init(
            stream: "ethusdt@trade",
            crypto: .init(name: "Ethereum", symbol: "ETH", icon: "ethereum")
        ),
        .init(
            stream: "usdcusdt@trade",
            crypto: .init(name: "USD Coin", symbol: "USDC", icon: "usd-coin")
        ),
        .init(
            stream: "xrpusdt@trade",
            crypto: .init(name: "XRP", symbol: "XRP", icon: "xrp")
        ),
        .init(
            stream: "solusdt@trade",
            crypto: .init(name: "Solana", symbol: "SOL", icon: "solana")
        ),
        .init(
            stream: "suiusdt@trade",
            crypto: .init(name: "SUI", symbol: "SUI", icon: "sui")
        ),
        .init(
            stream: "dogeusdt@trade",
            crypto: .init(name: "DODGE Coin", symbol: "DOGE", icon: "dogecoin")
        ),
        .init(
            stream: "ltcusdt@trade",
            crypto: .init(name: "Lite Coin", symbol: "LTC", icon: "litecoin")
        ),
        .init(
            stream: "shibusdt@trade",
            crypto: .init(name: "Shiba Inu", symbol: "SHIB", icon: "shiba")
        )
    ]

    static func makeRepo() -> WebSocketRepo<String, BTrade> {
        let baseURLString = "wss://stream.binance.com:9443"
        let streams = cryptoStreams.map(\.stream).joined(separator: "/")
        let urlString = "\(baseURLString)/stream?streams=\(streams)"
        // Example Websocket URL string:
        // wss://stream.binance.com:9443/stream?streams=btcusdt@trade/ethusdt@trade/dogeusdt@trade
        return WebSocketRepo<String, BTrade>(url: URL(string: urlString)!)
    }
    
    static func getCrypto(for stream: String) -> Crypto? {
        cryptoStreams.first(where: { $0.stream == stream })?.crypto
    }
}

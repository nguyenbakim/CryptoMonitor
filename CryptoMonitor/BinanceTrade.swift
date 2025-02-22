//
//  BinanceTrade.swift
//  CryptoMonitor
//
//  Created by Kim Nguyen on 02.03.24.
//

struct BTrade: Decodable {
    let stream: String
    let data: LiveData
    
    struct LiveData: Decodable {
        let s: String
        let p: String
    }
}

extension BTrade: Equatable {
    static func == (lhs: BTrade, rhs: BTrade) -> Bool {
        lhs.stream == rhs.stream
        && lhs.data.s == rhs.data.s
        && lhs.data.p == rhs.data.p
    }
}

// Binance Websocket for one crypto
// wss://stream.binance.com:9443/ws/ethusdt@trade
// Binance Websocket for multiple cryptos
// wss://stream.binance.com:9443/stream?streams=btcusdt@trade/ethusdt@trade/usdcusdt@trade
// To manually subscribe to streams, send message with the following structure

/*
{
    "method": "SUBSCRIBE",
    "params": [
        "btcusdt@trade",
        "ethusdt@trade"
    ],
    "id": 1
}
*/
 

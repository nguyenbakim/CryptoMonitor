//
//  FinnHubTrade.swift
//  CryptoMonitor
//
//  Created by Kim Nguyen on 02.03.24.
//

struct FHTrade: Decodable {
    let data: [LiveData]?
    
    struct LiveData: Decodable {
        let s: String
        let p: Double
    }
}

// FinnHub Websocket repo
// wss://ws.finnhub.io?token=<YourToken>"
// To subscribe, send message with the following format
/*
{
    "type": "subscribe",
    "symbol": "BINANCE:BTCUSDT"
}
*/

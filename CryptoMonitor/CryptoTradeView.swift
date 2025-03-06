//
//  CryptoTradeView.swift
//  CryptoMonitor
//
//  Created by Kim Nguyen on 04.03.25.
//

import SwiftUI
import Charts

struct CryptoTradeView: View {
    struct DataPoint: Equatable {
        let time: Date
        let price: Double
    }
    @ObservedObject private var repo: WebSocketRepo<String, BTrade>
    @State private var dataPoints: [DataPoint] = []
    @State private var startTime = Date()
    @State private var lastPrice: String?

    private let cryptoStream: CryptoStream
    private let maxDataPoints = 100
    
    private var priceRange: ClosedRange<Double> {
        guard let minPrice = dataPoints.min(by: { $0.price < $1.price })?.price,
              let maxPrice = dataPoints.max(by: { $0.price < $1.price })?.price else {
            return 0...1
        }
        return (minPrice * 0.9995)...(maxPrice * 1.0005)
    }
    
    init(repo: WebSocketRepo<String, BTrade>, cryptoStream: CryptoStream) {
        self.repo = repo
        self.cryptoStream = cryptoStream
    }
    
    var body: some View {
        VStack {
            Image(cryptoStream.crypto.icon)
                .resizable()
                .scaledToFit()
                .frame(width: 100)
            
            Chart {
                ForEach(dataPoints, id: \.time) { data in
                    LineMark(
                        x: .value("Time", data.time),
                        y: .value("Price", data.price)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(.blue)
                }
            }
            .chartXScale(domain: startTime...Date())
            .chartYScale(domain: priceRange)
            .frame(height: 300)
            .padding()
            
            if let lastPrice {
                Text("Last Price: \(lastPrice.asDecimalStringRounded())")
                    .font(.title2)
                    .padding()
            }

            Spacer()
        }
        .navigationTitle("Live Chart: \(cryptoStream.crypto.name)")
        .onChange(of: repo.response) { _, newValue in
            guard let newValue, newValue.stream == cryptoStream.stream,
                  let price = Double(newValue.data.p) else { return }
            
            let currentTime = Date()
            dataPoints.append(DataPoint(time: currentTime, price: price))
            lastPrice = newValue.data.p
            
            if dataPoints.count > maxDataPoints {
                dataPoints.removeFirst()
                startTime = dataPoints.first?.time ?? currentTime
            }
        }
    }
}

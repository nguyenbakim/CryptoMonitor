//
//  String+Decimal.swift
//  CryptoMonitor
//
//  Created by Kim Nguyen on 02.03.24.
//
import Foundation

extension String {
    func asDecimalStringRounded() -> String {
        guard let decimalValue = Decimal(string: self) else { return self }

        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "en_US") // Price in USD
        formatter.maximumFractionDigits = 8
        formatter.minimumFractionDigits = 2
        
        return formatter.string(from: decimalValue as NSDecimalNumber) ?? self
    }
}

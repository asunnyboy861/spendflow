import Foundation

extension Double {
    var currencyFormatted: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = Locale.current.currency?.identifier ?? "USD"
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: self)) ?? "$0.00"
    }

    var compactCurrencyFormatted: String {
        if self >= 1000 {
            let formatted = String(format: "%.1fk", self / 1000)
            return "$\(formatted)"
        }
        return currencyFormatted
    }
}

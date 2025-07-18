import Foundation

extension Date {
    func formatToTime() -> String {
        let formatter: DateFormatter = .init()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: self)
    }
    
    func formatRelatively(dateStyle: DateFormatter.Style = .medium) -> String {
        let relativeDateFormatter: DateFormatter = .init()
        relativeDateFormatter.locale = Locale(identifier: IQLanguageTexts.model.code ?? "ru")
        relativeDateFormatter.timeStyle = .none
        relativeDateFormatter.dateStyle = dateStyle
        relativeDateFormatter.doesRelativeDateFormatting = true
        return relativeDateFormatter.string(from: self)
    }
}

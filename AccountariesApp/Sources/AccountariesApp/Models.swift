import SwiftUI

struct Movement: Identifiable {
    enum MovementType: String {
        case income = "Entrée"
        case expense = "Dépense"
        case transfer = "Transfert"
    }

    let id = UUID()
    var type: MovementType
    var title: String
    var amount: Double
    var category: String
    var date: Date
    var periodicity: String?
    var destination: Destination?

    enum Destination {
        case goal(Goal)
        case savings(SavingsAccount)
    }
}

struct Goal: Identifiable, Hashable {
    let id = UUID()
    var name: String
    var target: Double
    var deadline: Date?
    var saved: Double

    var progress: Double {
        target == 0 ? 0 : min(saved / target, 1)
    }
}

struct SavingsAccount: Identifiable, Hashable {
    let id = UUID()
    var name: String
    var balance: Double
    var annualYield: Double

    var estimatedInterestsPerYear: Double {
        balance * annualYield
    }
}

struct BudgetEnvelope: Identifiable {
    let id = UUID()
    var category: String
    var cap: Double
    var spent: Double

    var status: Status {
        let ratio = cap == 0 ? 0 : spent / cap
        switch ratio {
        case ..<0.8: return .ok
        case ..<1.0: return .warning
        default: return .over
        }
    }

    enum Status: String {
        case ok = "OK"
        case warning = "Attention"
        case over = "Dépassement"
    }
}

struct AutomationRule: Identifiable {
    let id = UUID()
    var keyword: String
    var category: String
}

struct RecurringTemplate: Identifiable {
    let id = UUID()
    var title: String
    var amount: Double
    var category: String
    var dayOfMonth: Int
}

struct BudgetSnapshot {
    var revenues: Double
    var fixedCharges: Double
    var variableExpenses: Double
    var goalSavings: Double
    var accountSavings: Double

    var totalSavings: Double { goalSavings + accountSavings }
    var maxSpendingAfterSavings: Double { revenues - fixedCharges - totalSavings }
    var maxToSavingsAccount: Double { revenues - fixedCharges - variableExpenses - goalSavings }
    var estimatedResteAVivre: Double { revenues - fixedCharges - variableExpenses - totalSavings }
}

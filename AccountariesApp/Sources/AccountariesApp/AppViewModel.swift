import SwiftUI

final class AppViewModel: ObservableObject {
    @Published var selectedSection: Section = .dashboard
    @Published var movements: [Movement]
    @Published var goals: [Goal]
    @Published var savingsAccounts: [SavingsAccount]
    @Published var envelopes: [BudgetEnvelope]
    @Published var rules: [AutomationRule]
    @Published var recurringTemplates: [RecurringTemplate]

    @Published var budgetSnapshot: BudgetSnapshot

    private let baseFixedCharges: Double = 1400

    init() {
        let goals = [
            Goal(name: "Vacances", target: 1500, deadline: Calendar.current.date(byAdding: .month, value: 6, to: .now), saved: 400),
            Goal(name: "Coussin de sécurité", target: 3000, deadline: nil, saved: 1200)
        ]

        let savingsAccounts = [
            SavingsAccount(name: "Livret A", balance: 2500, annualYield: 0.03),
            SavingsAccount(name: "PEP", balance: 6800, annualYield: 0.025)
        ]

        self.movements = [
            Movement(type: .income, title: "Salaire", amount: 2800, category: "Revenus", date: .now, periodicity: "Mensuel", destination: nil),
            Movement(type: .expense, title: "Loyer", amount: 900, category: "Charges fixes", date: .now, periodicity: "Mensuel", destination: nil),
            Movement(type: .expense, title: "Carrefour", amount: 80, category: "Courses", date: .now, periodicity: nil, destination: nil),
            Movement(type: .transfer, title: "Épargne vacances", amount: 200, category: "Épargne", date: .now, periodicity: "Mensuel", destination: .goal(goals[0])),
            Movement(type: .transfer, title: "Transfert livret", amount: 150, category: "Épargne", date: .now, periodicity: "Mensuel", destination: .savings(savingsAccounts[0]))
        ]

        self.envelopes = [
            BudgetEnvelope(category: "Courses", cap: 250, spent: 180),
            BudgetEnvelope(category: "Sorties", cap: 120, spent: 110),
            BudgetEnvelope(category: "Transports", cap: 80, spent: 40)
        ]

        self.rules = [
            AutomationRule(keyword: "Amazon", category: "Achats"),
            AutomationRule(keyword: "Carrefour", category: "Courses"),
            AutomationRule(keyword: "SNCF", category: "Transports")
        ]

        self.recurringTemplates = [
            RecurringTemplate(title: "Salaire", amount: 2800, category: "Revenus", dayOfMonth: 1),
            RecurringTemplate(title: "Loyer", amount: 900, category: "Charges fixes", dayOfMonth: 5),
            RecurringTemplate(title: "Assurance habitation", amount: 180, category: "Assurance", dayOfMonth: 15)
        ]

        self.goals = goals
        self.savingsAccounts = savingsAccounts

        self.budgetSnapshot = .init(
            revenues: 0,
            fixedCharges: baseFixedCharges,
            variableExpenses: 0,
            goalSavings: 0,
            accountSavings: 0
        )

        recalculateBudgetSnapshot()
    }

    func addMovement(_ movement: Movement) {
        movements.append(movement)
        applyDestinationBalance(for: movement, adding: true)
        recalculateBudgetSnapshot()
    }

    func removeMovements(at offsets: IndexSet) {
        let removed = offsets.map { movements[$0] }
        movements.remove(atOffsets: offsets)
        removed.forEach { applyDestinationBalance(for: $0, adding: false) }
        recalculateBudgetSnapshot()
    }

    private func recalculateBudgetSnapshot() {
        var revenues = 0.0
        var variableExpenses = 0.0
        var goalSavings = 0.0
        var accountSavings = 0.0

        for movement in movements {
            switch movement.type {
            case .income:
                revenues += movement.amount
            case .expense:
                variableExpenses += movement.amount
            case .transfer:
                if let destination = movement.destination {
                    switch destination {
                    case .goal:
                        goalSavings += movement.amount
                    case .savings:
                        accountSavings += movement.amount
                    }
                }
            }
        }

        budgetSnapshot = BudgetSnapshot(
            revenues: revenues,
            fixedCharges: baseFixedCharges,
            variableExpenses: variableExpenses,
            goalSavings: goalSavings,
            accountSavings: accountSavings
        )
    }

    private func applyDestinationBalance(for movement: Movement, adding: Bool) {
        guard let destination = movement.destination else { return }
        let factor = adding ? 1.0 : -1.0

        switch destination {
        case .goal(let goal):
            guard let index = goals.firstIndex(where: { $0.id == goal.id }) else { return }
            goals[index].saved = max(0, goals[index].saved + movement.amount * factor)
        case .savings(let account):
            guard let index = savingsAccounts.firstIndex(where: { $0.id == account.id }) else { return }
            savingsAccounts[index].balance = max(0, savingsAccounts[index].balance + movement.amount * factor)
        }
    }

    enum Section: CaseIterable, Hashable {
        case dashboard, movements, charts, goals, savings, budgetTable, envelopes, rules, automations, settings

        var title: String {
            switch self {
            case .dashboard: return "Accueil"
            case .movements: return "Mouvements"
            case .charts: return "Graphiques"
            case .goals: return "Objectifs"
            case .savings: return "Livrets"
            case .budgetTable: return "Tableau budget"
            case .envelopes: return "Budgets"
            case .rules: return "Règles"
            case .automations: return "Automatisations"
            case .settings: return "Réglages"
            }
        }
    }
}

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = AppViewModel()

    var body: some View {
        NavigationSplitView {
            List(AppViewModel.Section.allCases, selection: $viewModel.selectedSection) { section in
                NavigationLink(section.title, value: section)
            }
            .navigationTitle("Accountaries")
        } detail: {
            switch viewModel.selectedSection {
            case .dashboard:
                DashboardView(viewModel: viewModel)
            case .movements:
                MovementsView(viewModel: viewModel)
            case .charts:
                ChartsView(viewModel: viewModel)
            case .goals:
                GoalsView(viewModel: viewModel)
            case .savings:
                SavingsView(viewModel: viewModel)
            case .budgetTable:
                BudgetTableView(snapshot: viewModel.budgetSnapshot)
            case .envelopes:
                EnvelopesView(envelopes: viewModel.envelopes)
            case .rules:
                RulesView(rules: viewModel.rules)
            case .automations:
                AutomationsView(recurring: viewModel.recurringTemplates)
            case .settings:
                SettingsView()
            }
        }
        .frame(minWidth: 1080, minHeight: 720)
    }
}

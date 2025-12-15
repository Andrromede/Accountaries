import SwiftUI

struct DashboardView: View {
    @ObservedObject var viewModel: AppViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Résumé du mois")
                    .font(.largeTitle.bold())
                summaryCards
                envelopeAlerts
                forecast
            }
            .padding()
        }
    }

    private var summaryCards: some View {
        HStack(spacing: 12) {
            SummaryCard(title: "Revenus", value: viewModel.budgetSnapshot.revenues, subtitle: "Ce mois")
            SummaryCard(title: "Dépenses", value: viewModel.budgetSnapshot.variableExpenses + viewModel.budgetSnapshot.fixedCharges, subtitle: "Charges + variables")
            SummaryCard(title: "Épargne", value: viewModel.budgetSnapshot.totalSavings, subtitle: "Objectifs + livrets")
        }
    }

    private var envelopeAlerts: some View {
        VStack(alignment: .leading) {
            Text("Budgets à surveiller")
                .font(.headline)
            ForEach(viewModel.envelopes.prefix(3)) { envelope in
                ProgressView(value: envelope.spent, total: envelope.cap) {
                    HStack {
                        Text(envelope.category)
                        Spacer()
                        Text("\(Int(envelope.spent))/\(Int(envelope.cap)) €")
                            .foregroundStyle(.secondary)
                    }
                }
                .tint(envelope.status == .over ? .red : envelope.status == .warning ? .orange : .green)
            }
        }
    }

    private var forecast: some View {
        VStack(alignment: .leading) {
            Text("Prévision fin de mois")
                .font(.headline)
            Text("Reste à vivre estimé : \(Int(viewModel.budgetSnapshot.estimatedResteAVivre)) €")
            Text("Dépenses max restantes : \(Int(viewModel.budgetSnapshot.maxSpendingAfterSavings)) €")
        }
    }
}

struct SummaryCard: View {
    var title: String
    var value: Double
    var subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            Text(String(format: "%.0f €", value))
                .font(.title3.bold())
            Text(subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

struct MovementsView: View {
    @ObservedObject var viewModel: AppViewModel
    @State private var presentingAddSheet = false

    var body: some View {
        List {
            ForEach(viewModel.movements) { movement in
                VStack(alignment: .leading) {
                    HStack {
                        Text(movement.title)
                            .font(.headline)
                        Spacer()
                        Text(String(format: "%.0f €", movement.amount))
                            .foregroundStyle(movement.type == .income ? .green : .primary)
                    }
                    HStack(spacing: 12) {
                        Label(movement.type.rawValue, systemImage: "arrow.triangle.2.circlepath")
                        Label(movement.category, systemImage: "tag")
                        if let periodicity = movement.periodicity { Label(periodicity, systemImage: "calendar") }
                        if let destination = movement.destination { destinationLabel(destination) }
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
            }
            .onDelete(perform: viewModel.removeMovements)
        }
        .navigationTitle("Mouvements")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    presentingAddSheet = true
                } label: {
                    Label("Ajouter", systemImage: "plus")
                }
                .help("Ajouter un mouvement")
            }
        }
        .sheet(isPresented: $presentingAddSheet) {
            AddMovementView(viewModel: viewModel, isPresented: $presentingAddSheet)
                .frame(minWidth: 420, minHeight: 520)
        }
    }

    private func destinationLabel(_ destination: Movement.Destination) -> some View {
        switch destination {
        case .goal(let goal):
            return Label("Objectif: \(goal.name)", systemImage: "target")
        case .savings(let savings):
            return Label("Livret: \(savings.name)", systemImage: "banknote")
        }
    }
}

struct ChartsView: View {
    @ObservedObject var viewModel: AppViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Graphiques")
                .font(.largeTitle.bold())
            Text("Camemberts dépenses et revenus (données maquettes)")
                .foregroundStyle(.secondary)
            ChartPlaceholder(title: "Dépenses par catégorie", segments: viewModel.envelopes.map { ($0.category, $0.spent) })
            ChartPlaceholder(title: "Revenus par catégorie", segments: [("Salaire", 2800), ("Autres", 400)])
            ChartPlaceholder(title: "Net mensuel (optionnel)", segments: [("Net", viewModel.budgetSnapshot.estimatedResteAVivre)])
            Spacer()
        }
        .padding()
    }
}

struct ChartPlaceholder: View {
    var title: String
    var segments: [(String, Double)]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            HStack(spacing: 8) {
                ForEach(segments.indices, id: \.self) { index in
                    let segment = segments[index]
                    VStack {
                        Circle()
                            .fill(Color.accentColor.opacity(0.6 + Double(index % 3) * 0.1))
                            .frame(width: 12, height: 12)
                        Text(segment.0)
                        Text(String(format: "%.0f €", segment.1))
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).stroke(.secondary.opacity(0.2)))
        }
    }
}

struct AddMovementView: View {
    @ObservedObject var viewModel: AppViewModel
    @Binding var isPresented: Bool

    @State private var type: Movement.MovementType = .expense
    @State private var title: String = ""
    @State private var amount: Double = 50
    @State private var category: String = "Courses"
    @State private var date: Date = .now
    @State private var periodicity: String = ""
    @State private var destinationChoice: DestinationChoice = .none
    @State private var selectedGoal: Goal?
    @State private var selectedSavings: SavingsAccount?

    enum DestinationChoice: String, CaseIterable, Identifiable {
        case none = "Aucune"
        case goal = "Objectif"
        case savings = "Livret"

        var id: Self { self }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Mouvement") {
                    Picker("Type", selection: $type) {
                        Text(Movement.MovementType.income.rawValue).tag(Movement.MovementType.income)
                        Text(Movement.MovementType.expense.rawValue).tag(Movement.MovementType.expense)
                        Text(Movement.MovementType.transfer.rawValue).tag(Movement.MovementType.transfer)
                    }
                    .pickerStyle(.segmented)

                    TextField("Titre", text: $title)
                    TextField("Montant", value: $amount, format: .number)
                        .keyboardType(.decimalPad)
                    TextField("Catégorie", text: $category)
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    TextField("Périodicité", text: $periodicity)
                        .textInputAutocapitalization(.words)
                        .autocorrectionDisabled()
                }

                Section("Épargne vers") {
                    Picker("Destination", selection: $destinationChoice) {
                        ForEach(DestinationChoice.allCases) { choice in
                            Text(choice.rawValue).tag(choice)
                        }
                    }
                    .onChange(of: destinationChoice) { newValue in
                        if newValue != .none { type = .transfer }
                    }

                    if destinationChoice == .goal {
                        Picker("Objectif", selection: $selectedGoal) {
                            ForEach(viewModel.goals) { goal in
                                Text(goal.name).tag(Optional(goal))
                            }
                        }
                    }

                    if destinationChoice == .savings {
                        Picker("Livret", selection: $selectedSavings) {
                            ForEach(viewModel.savingsAccounts) { account in
                                Text(account.name).tag(Optional(account))
                            }
                        }
                    }
                }
            }
            .navigationTitle("Ajouter un mouvement")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") { isPresented = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Enregistrer") { saveMovement() }
                        .disabled(title.isEmpty || amount <= 0)
                }
            }
        }
    }

    private func saveMovement() {
        let destination: Movement.Destination?
        switch destinationChoice {
        case .none:
            destination = nil
        case .goal:
            destination = selectedGoal.map { .goal($0) }
        case .savings:
            destination = selectedSavings.map { .savings($0) }
        }

        var resolvedType = type
        if destination != nil {
            resolvedType = .transfer
        }

        let newMovement = Movement(
            type: resolvedType,
            title: title,
            amount: amount,
            category: category,
            date: date,
            periodicity: periodicity.isEmpty ? nil : periodicity,
            destination: destination
        )

        viewModel.addMovement(newMovement)
        isPresented = false
    }
}

struct GoalsView: View {
    @ObservedObject var viewModel: AppViewModel

    var body: some View {
        List {
            ForEach(viewModel.goals) { goal in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(goal.name)
                            .font(.headline)
                        Spacer()
                        Text("Objectif: \(Int(goal.target)) €")
                    }
                    ProgressView(value: goal.progress) {
                        Text("Épargné: \(Int(goal.saved)) €")
                    }
                    if let deadline = goal.deadline {
                        Text("Date limite: \(deadline.formatted(date: .abbreviated, time: .omitted))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationTitle("Objectifs")
    }
}

struct SavingsView: View {
    @ObservedObject var viewModel: AppViewModel

    var body: some View {
        List {
            Section("Livrets") {
                ForEach(viewModel.savingsAccounts) { account in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(account.name)
                                .font(.headline)
                            Spacer()
                            Text(String(format: "%.0f €", account.balance))
                        }
                        Text(String(format: "Rendement annuel: %.2f%%", account.annualYield * 100))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(String(format: "Intérêts estimés/an: %.0f €", account.estimatedInterestsPerYear))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Section("Simulation livret") {
                SavingsSimulationView()
            }
        }
        .navigationTitle("Livrets")
    }
}

struct SavingsSimulationView: View {
    @State private var monthlyDeposit: Double = 200
    @State private var months: Double = 24
    @State private var annualYield: Double = 0.03

    private var totalDeposits: Double { monthlyDeposit * months }
    private var estimatedBalance: Double {
        let monthlyYield = annualYield / 12
        return (1...Int(months)).reduce(0) { partial, month in
            let accrued = (partial + monthlyDeposit) * (1 + monthlyYield)
            return accrued
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Versement mensuel")
                Slider(value: $monthlyDeposit, in: 50...1000, step: 50)
                Text("\(Int(monthlyDeposit)) €")
            }
            HStack {
                Text("Durée (mois)")
                Slider(value: $months, in: 12...60, step: 6)
                Text("\(Int(months))")
            }
            HStack {
                Text("Rendement annuel")
                Slider(value: $annualYield, in: 0.01...0.07, step: 0.005)
                Text(String(format: "%.1f%%", annualYield * 100))
            }
            Divider()
            Text(String(format: "Total versements: %.0f €", totalDeposits))
            Text(String(format: "Solde estimé: %.0f €", estimatedBalance))
            Text(String(format: "Intérêts cumulés: %.0f €", estimatedBalance - totalDeposits))
        }
        .padding(.vertical, 4)
    }
}

struct BudgetTableView: View {
    var snapshot: BudgetSnapshot

    var body: some View {
        Form {
            Section("Épargne") {
                labeledRow("Épargne totale (ET)", value: snapshot.totalSavings)
                labeledRow("Épargne objectifs (EV)", value: snapshot.goalSavings)
                labeledRow("Épargne livrets (EL)", value: snapshot.accountSavings)
            }

            Section("Formules") {
                labeledRow("DMAX = R - CF - ET", value: snapshot.maxSpendingAfterSavings)
                labeledRow("LMAX = R - CF - DV - EV", value: snapshot.maxToSavingsAccount)
                labeledRow("RV = R - CF - DV - ET", value: snapshot.estimatedResteAVivre)
            }
        }
        .navigationTitle("Tableau budget")
    }

    private func labeledRow(_ title: String, value: Double) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(String(format: "%.0f €", value))
                .foregroundStyle(.secondary)
        }
    }
}

struct EnvelopesView: View {
    var envelopes: [BudgetEnvelope]

    var body: some View {
        List {
            ForEach(envelopes) { envelope in
                HStack {
                    VStack(alignment: .leading) {
                        Text(envelope.category)
                            .font(.headline)
                        ProgressView(value: envelope.spent, total: envelope.cap)
                        Text("\(Int(envelope.spent)) / \(Int(envelope.cap)) €")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Text(envelope.status.rawValue)
                        .padding(8)
                        .background(statusColor(for: envelope.status).opacity(0.15))
                        .foregroundStyle(statusColor(for: envelope.status))
                        .clipShape(Capsule())
                }
            }
        }
        .navigationTitle("Budgets")
    }

    private func statusColor(for status: BudgetEnvelope.Status) -> Color {
        switch status {
        case .ok: return .green
        case .warning: return .orange
        case .over: return .red
        }
    }
}

struct RulesView: View {
    var rules: [AutomationRule]

    var body: some View {
        List {
            Section("Règles auto-catégorisation") {
                ForEach(rules) { rule in
                    HStack {
                        Text("Si le titre contient \"\(rule.keyword)\"")
                        Spacer()
                        Text("→ \(rule.category)")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            Section("Actions") {
                Label("Tester une règle", systemImage: "checkmark.seal")
                Label("Appliquer à l'historique", systemImage: "clock.arrow.circlepath")
            }
        }
        .navigationTitle("Règles")
    }
}

struct AutomationsView: View {
    var recurring: [RecurringTemplate]

    var body: some View {
        List {
            ForEach(recurring) { template in
                VStack(alignment: .leading) {
                    HStack {
                        Text(template.title)
                            .font(.headline)
                        Spacer()
                        Text(String(format: "%.0f €", template.amount))
                    }
                    Text("Jour du mois: \(template.dayOfMonth)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("Catégorie: \(template.category)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Section("Automatisation") {
                Label("Déclencher les occurrences dues", systemImage: "bolt")
                Label("Générer les mouvements", systemImage: "calendar.badge.clock")
            }
        }
        .navigationTitle("Automatisations")
    }
}

struct SettingsView: View {
    var body: some View {
        Form {
            Section("Assistance") {
                Label("FAQ & Aide", systemImage: "questionmark.circle")
            }
            Section("Configuration") {
                Label("Réglages généraux", systemImage: "gear")
                Label("Relancer l'onboarding", systemImage: "arrow.triangle.2.circlepath")
            }
        }
        .navigationTitle("Réglages")
    }
}

//
//  ProspectsListView.swift
//  HotProspects
//
//  Created by Ayrton Parkinson on 2024/08/03.
//

import CodeScanner
import SwiftUI
import SwiftData
import UserNotifications

struct ProspectsListView: View {
    @Environment(\.modelContext) var modelContext
    @Query var prospects: [Prospect]
    
    @State private var isShowingScanner = false
    @State private var selectedProspects = Set<Prospect>()
    
    enum FilterType {
        case none, contacted, uncontacted
    }
    
    let filter: FilterType
    
    var title: String {
        switch filter {
        case .none:
            "Everyone"
        case .contacted:
            "Contacted people"
        case .uncontacted:
            "Uncontacted people"
        }
    }
    
    var body: some View {
        List(prospects, selection: $selectedProspects) { prospect in
            NavigationLink {
                EditProspectView(prospect: prospect)
            } label : {
                HStack {
                    VStack(alignment: .leading) {
                        Text(prospect.name)
                            .font(.headline)
                        Text(prospect.emailAddress)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    if filter == .none && prospect.isContacted {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                    }
                }
            }
            .swipeActions {
                Button("Delete", systemImage: "trash", role: .destructive) {
                    modelContext.delete(prospect)
                }
                
                if prospect.isContacted {
                    Button("Mark Uncontacted", systemImage: "person.crop.circle.badge.xmark") {
                        prospect.isContacted.toggle()
                    }
                    .tint(.blue)
                } else {
                    Button("Mark Contacted", systemImage: "person.crop.circle.fill.badge.checkmark") {
                        prospect.isContacted.toggle()
                    }
                    .tint(.green)
                    
                    Button("Remind Me", systemImage: "bell") {
                        addNotification(for: prospect)
                    }
                    .tint(.orange)
                }
            }
            .tag(prospect)
        }
        .navigationTitle(title)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Scan", systemImage: "qrcode.viewfinder") {
                    isShowingScanner = true
                }
            }
            
            ToolbarItem(placement: .topBarLeading) {
                EditButton()
            }
            
            if !selectedProspects.isEmpty {
                ToolbarItem(placement: .bottomBar) {
                    Button("Delete Selected", action: delete)
                }
            }
        }
        .sheet(isPresented: $isShowingScanner) {
            CodeScannerView(codeTypes: [.qr], simulatedData: "Paul Hudson\npaul@hackingwithswift.com", completion: handleScan)
        }
        .onAppear {
            selectedProspects = []
        }
    }
    
    init(filter: FilterType) {
        self.filter = filter
        
        if filter != .none {
            let showContactedOnly = filter == .contacted
            
            _prospects = Query(filter: #Predicate {
                $0.isContacted == showContactedOnly
            }, sort: [SortDescriptor(\Prospect.name)])
        }
    }
    
    func handleScan(result: Result<ScanResult, ScanError>) {
        isShowingScanner = false
        
        switch result {
        case .success(let result):
            let details = result.string.components(separatedBy: "\n")
            guard details.count == 2 else { return }
            
            let person = Prospect(name: details[0], emailAddress: details[1], isContacted: false)
            modelContext.insert(person)
        case .failure(let error):
            print("Scanning failed: \(error.localizedDescription)")
        }
    }
    
    func delete() {
        for prospect in selectedProspects {
            modelContext.delete(prospect)
        }
    }
    
    func addNotification(for prospect: Prospect) {
        let center = UNUserNotificationCenter.current()
        
        let addRequest = {
            let content = UNMutableNotificationContent()
            content.title = "Contact \(prospect.name)"
            content.subtitle = prospect.emailAddress
            content.sound = UNNotificationSound.default
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
            
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            center.add(request)
        }
        
        center.getNotificationSettings { settings in
            if settings.authorizationStatus == .authorized {
                addRequest()
            } else {
                center.requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                    if success {
                        addRequest()
                    } else if let error {
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
}

#Preview {
    ProspectsListView(filter: .none)
        .modelContainer(for: Prospect.self)
}
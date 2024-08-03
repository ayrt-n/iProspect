//
//  EditProspectView.swift
//  HotProspects
//
//  Created by Ayrton Parkinson on 2024/08/03.
//

import SwiftUI
import SwiftData

struct EditProspectView: View {
    var prospect: Prospect
    @Environment(\.dismiss) var dismiss
    
    @State private var name: String
    @State private var emailAddress: String
    
    var body: some View {
        Form {
            TextField("Name", text: $name)
                .font(.title)
            
            TextField("Email address", text: $emailAddress)
                .font(.title)
        }
        .navigationTitle("Edit prospect")
        .toolbar {
            Button("Save", action: save)
                .disabled(!hasChanges())
        }
    }
    
    init(prospect: Prospect) {
        self.prospect = prospect
        _name = State(initialValue: prospect.name)
        _emailAddress = State(initialValue: prospect.emailAddress)
    }
    
    func save() {
        prospect.name = name
        prospect.emailAddress = emailAddress
        
        dismiss()
    }
    
    func hasChanges() -> Bool {
        prospect.name != name || prospect.emailAddress != emailAddress
    }
}

#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Prospect.self, configurations: config)
        let prospect = Prospect(name: "Ayrton Parkinson", emailAddress: "me@ayrtonparkinson.dev", isContacted: false)
        return EditProspectView(prospect: prospect)
            .modelContainer(container)
   } catch {
       return Text("Failed to create container: \(error.localizedDescription)")
   }
}

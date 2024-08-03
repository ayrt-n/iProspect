//
//  SortableProspectsView.swift
//  HotProspects
//
//  Created by Ayrton Parkinson on 2024/08/03.
//

import SwiftUI
import SwiftData

struct SortableProspectsView: View {
    let filter: ProspectsView.FilterType
    @State private var sortOrder = SortDescriptor(\Prospect.name)
    
    var body: some View {
        NavigationStack {
            ProspectsView(filter: filter, sortOrder: sortOrder)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Menu("Sort", systemImage: "arrow.up.arrow.down") {
                            Picker("Sort", selection: $sortOrder) {
                                Text("Sort by name")
                                    .tag(SortDescriptor(\Prospect.name))
                                Text("Sort by date")
                                    .tag(SortDescriptor(\Prospect.dateAdded))
                            }
                        }
                    }
                }
        }
    }
}

#Preview {
    SortableProspectsView(filter: .none)
        .modelContainer(for: Prospect.self)
}

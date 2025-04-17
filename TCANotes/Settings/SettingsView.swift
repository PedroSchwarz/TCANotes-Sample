//
//  SettingsView.swift
//  TCANotes
//
//  Created by Pedro Schwarz Rodrigues on 16/4/2025.
//

import SwiftUI
import ComposableArchitecture

struct SettingsView: View {
    @Bindable var store: StoreOf<SettingsFeature>
    
    var body: some View {
        Form {
            Section(header: Text("Appearance")) {
                Toggle("Dark Mode", isOn: $store.isDarkModeEnabled)
            }
            
            Section(header: Text("Notifications")) {
                Toggle("Enable Notifications", isOn: $store.notificationEnabled)
            }
            
            Section(header: Text("Statistics")) {
                HStack {
                    Text("Notes")
                    Spacer()
                    Text("\(store.noteCount)")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Categories")
                    Spacer()
                    Text("\(store.categoryCount)")
                        .foregroundColor(.secondary)
                }
            }
            
            Section(header: Text("About")) {
                HStack {
                    Text("Version")
                    Spacer()
                    Text("1.0.0")
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("Settings")
        .onAppear {
            store.send(.onAppear)
        }
    }
}

#Preview {
    SettingsView(store: .init(initialState: .init(), reducer: {
        SettingsFeature()
    }))
}

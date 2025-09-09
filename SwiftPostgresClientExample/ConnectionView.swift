//
//  ConnectionView.swift
//  SwiftPostgresClientExample
//
//  Copyright 2025 Will Temperley
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import SwiftUI
import SwiftPostgresClient

struct ConnectionView: View {
    @State private var host = "localhost"
    @State private var port = 5432
    @State private var database = "postgres"
    @State private var user = "postgres"
    @State private var password = ""
    @State private var useTLS = false
    
    @State private var useTrust = false
    
    @State private var connectionStatus: String? = nil
    
    @Binding var viewModel: WeatherViewModel?
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Form {
            Section(header: Text("Connection")) {
                TextField("Host", text: $host)
                TextField("Port", value: $port, formatter: NumberFormatter())
                TextField("Database", text: $database)
                TextField("User", text: $user)
                
                Toggle("Use Trust", isOn: $useTrust)
                if !useTrust {
                    SecureField("Password", text: $password)
                }
                Toggle("Use SSL", isOn: $useTLS)
            }
            
            Section {
                Button("Connect") {
                    Task {
                        do {
                            try await connect()
                        } catch {
                            connectionStatus = "Error: \(error)"
                        }
                    }
                }
            }
            
            if let connectionStatus {
                Text(connectionStatus)
                    .foregroundColor(connectionStatus.contains("Success") ? .green : .red)
            }
        }
        .padding()
    }
    
    private func credential()  -> Credential? {
        if useTrust {
            return .trust
        } else if !password.isEmpty {
            if useTLS {
                return .scramSHA256(password: password, channelBindingPolicy: .preferred)
            } else {
                return .cleartextPassword(password: password)
            }
        } else {
            connectionStatus = "Please enter a password or enable 'Use Trust'"
            return nil
        }
    }
    
    private func connect() async throws {
        let connection = try await Connection.connect(
            host: host,
            port: port,
            useTLS: useTLS
        )
        guard let credential = self.credential() else {
            return
        }
        try await connection.authenticate(user: user, database: database, credential: credential)
        viewModel = try await WeatherViewModel(connection: connection)
        dismiss()
    }
}

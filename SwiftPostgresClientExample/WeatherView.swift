//
//  WeatherView.swift
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

struct WeatherView: View {
    
    var viewModel: WeatherViewModel
    @State var errorDescription: String?
    
    var body: some View {
        if let errorDescription {
            Text(errorDescription)
        }
        VStack {
            HStack {
                Button("Generate table") {
                    Task {
                        let result = await viewModel.createTable()
                        if case .failure(let error) = result {
                            errorDescription = error.localizedDescription
                        }
                    }
                }
                .disabled(viewModel.tableExists)
                Button("Run query") {
                    Task {
                        do {
                            let result = try await viewModel.runQuery()
                            if case .failure(let error) = result {
                                errorDescription = error.localizedDescription
                            }
                        } catch {
                            print(error)
                        }
                    }
                }
            }
            WeatherTable(weather: viewModel.weather)
        }
        .padding()
    }
    
}

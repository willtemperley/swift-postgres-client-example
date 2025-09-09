//
//  WeatherTable.swift
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

struct WeatherTable: View {
    
    var weather: [WeatherRow]
    
    var body: some View {
        Table(weather) {
            TableColumn("City", value: \.city)
            TableColumn("Temp Lo") { val in
                Text("\(val.temp_lo.description)")
            }
            TableColumn("Temp Hi") { val in
                Text("\(val.temp_hi.description)")
            }
            TableColumn("Precipitation") { val in
                Text("\(val.prcp?.description ?? "Nil")")
            }
            TableColumn("Date") { val in
                Text("\(val.date.description)")
            }
        }
    }
}

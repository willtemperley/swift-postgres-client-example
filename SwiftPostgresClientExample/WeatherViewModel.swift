//
//  WeatherViewModel.swift
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

import SwiftPostgresClient
import Observation
import Foundation

enum QueryResult {
    case success
    case failure(Error)
}

@Observable
class WeatherViewModel {
    
    private var connection: Connection
    var tableExists: Bool = false
    var weather: [WeatherRow] = []
    
    init(connection: Connection) async throws {
        
        self.connection = connection
        
//        let cursor = try await connection.query("SELECT EXISTS ( SELECT 1 FROM pg_catalog.pg_tables WHERE schemaname = 'public' AND tablename = 'weather' );")
//        for try await row in cursor {
//            tableExists = try row.columns[0].bool()
//        }
    }
    
    func createTable() async -> QueryResult {
        do {
            
            try await connection.execute("""
            CREATE TABLE weather (
                id serial primary key,
                city varchar(80),
                temp_lo int,
                temp_hi int,
                prcp real,
                date date
            )
        """)
            let statement = try await connection.prepareStatement(
                text: "INSERT INTO weather (city, temp_lo, temp_hi, prcp, date) VALUES ($1, $2, $3, $4, $5)"
            )
            try await statement.bind(parameterValues: ["San Francisco", 46, 50, 0.25, "1994-11-27"]).execute()
            try await statement.bind(parameterValues: ["San Francisco", 43, 57, 0.0, "1994-11-29"]).execute()
            try await statement.bind(parameterValues: ["Hayward", 37, 54, nil, "1994-11-29"]).execute()
            try await statement.close()
        } catch {
            return .failure(error)
        }
        return .success
    }
    
    func runQuery() async throws -> QueryResult {
        
        let connection = try await Connection.connect(
            host: "localhost",
            port: 5432,
            useTLS: false
        )
        try await connection.authenticate(user: "will", database: "postgres", credential: .trust)
        do {
            weather = try await decodeByColumnName(
                sql: "SELECT id, city, temp_lo, temp_hi, prcp, date FROM weather ORDER BY date, city;",
                type: WeatherRow.self,
                using: connection
            )
            return .success
        } catch {
            return .failure(error)
        }
    }
    
    func decodeByColumnName<T>(
        sql: String,
        type: T.Type,
        using connection: Connection,
        retrieveColumnMetadata: Bool = true,
        defaultTimeZone: TimeZone? = nil
    ) async throws -> [T] where T: Decodable, T:Sendable {
        
        let statement = try await connection.prepareStatement(text: sql)
        let cursor = try await statement.bind(columnMetadata: retrieveColumnMetadata).query()
        
        var data: [T] = []
        for try await row in cursor {
            let weather = try row.decodeByColumnName(T.self)
            data.append(weather)
        }
        
        return data
        // No idea why this is complaining about T not being sendable
        //        return try await cursor.map { row in
        //            try row.decodeByColumnName(T.self, defaultTimeZone: defaultTimeZone)
        //        }.reduce(into: [T]()) {
        //            $0.append($1)
        //        }
    }
}

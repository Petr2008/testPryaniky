//
//  Structure.swift
//  testPryaniky
//
//  Created by Petr Gusakov on 14.10.2020.
//

//      НЕ НУ ЧО САМОМУ ЧТОЛИ МОЗГ ЛОМАТЬ?   :( пришлось поломать

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let pryaniky = try? newJSONDecoder().decode(Pryaniky.self, from: jsonData)

import Foundation

// MARK: - Pryaniky
struct Pryaniky: Codable {
    let data: [Datum]?
    let view: [String]
}

// MARK: - Datum
struct Datum: Codable {
    let name: String
    let data: DataClass
}

// MARK: - DataClass
struct DataClass: Codable {
    let text: String?
    let url: String?
    let selectedId: Int?
    let variants: [Variant]?

    enum CodingKeys: String, CodingKey {
        case text, url
        case selectedId
        case variants
    }
}

// MARK: - Variant
struct Variant: Codable {
    let id: Int
    let text: String
}

// MARK: - Other
struct Picture: Codable {
    let url: String
    let text: String
}

struct Selector: Codable {
    let selected: Int?
    let variants: [Variant]?
}

//struct Text: Codable {
//    let text: String
//}


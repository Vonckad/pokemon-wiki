//
//  MainModel.swift
//  pokemon-wiki
//
//  Created by Vlad Ralovich on 14.08.2022.
//

import Foundation

struct MainModel: Decodable {
    var count: Int
    var next, previous: String?
    var results: [ResultsModel]
}

struct ResultsModel: Decodable {
    var name, url: String
}

struct ImageModel: Decodable {
    var sprites: Sprites
}
struct Sprites: Decodable {
    var back_default, front_default: String
}

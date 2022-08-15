//
//  Network.swift
//  pokemon-wiki
//
//  Created by Vlad Ralovich on 14.08.2022.
//

import Foundation
import UIKit

final class Network {
    static func loadPokemons(_ urlString: String, complition: @escaping (_ model: MainModel) -> () ) {
        guard let url = URL(string: urlString) else { return }
        let request = URLRequest(url: url)
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else { return }
            guard let model = try? JSONDecoder().decode(MainModel.self, from: data) else { return }
            DispatchQueue.main.async {
                complition(model)
            }
        }.resume()
    }
    
    static func loadImage(_ urlString: String, complition: @escaping (_ image: UIImage) -> () ) {
        guard let url = URL(string: urlString) else {
            print("Erorr url = \(urlString)")
            return }
        let request = URLRequest(url: url)
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print("Erorr load")
                return }
            guard let model = try? JSONDecoder().decode(ImageModel.self, from: data) else {
                print("error get image")
                DispatchQueue.main.async {
                    guard let imageBall = UIImage(named: "ball") else { return }
                    complition(imageBall)
                }
                return }
            guard let imgUrl = URL(string: model.sprites.front_default) else {
                print("Erorr url = \(model.sprites.front_default)")
                return }
            let imgRequest = URLRequest(url: imgUrl)
            URLSession.shared.dataTask(with: imgRequest) { imgData, imgResponse, imgError in
                guard let imgData = imgData else {
                    print("Erorr imgData")
                    return }
                guard let image = UIImage(data: imgData) else { return }
                DispatchQueue.main.async {
                    complition(image)
                }
            }.resume()
        }.resume()
    }
}

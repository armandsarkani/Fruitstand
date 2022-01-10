//
//  ProductOperations.swift
//  Fruitstand
//
//  Created by Armand Sarkani on 1/9/22.
//

import Foundation
import Combine

func resetDefaults() {
    let defaults = UserDefaults.standard
    let dictionary = defaults.dictionaryRepresentation()
    dictionary.keys.forEach { key in
        defaults.removeObject(forKey: key)}
    print("Reset to default settings.")
}

func eraseProduct(uuid: String) {
    let defaults = UserDefaults.standard
    defaults.removeObject(forKey: uuid)
}





//
//  Gasto.swift
//  ControleDeGastos
//
//  Created by Andre Machado Parente on 6/2/16.
//  Copyright © 2016 Andre Machado Parente. All rights reserved.
//

import Foundation

public var gastosGlobal: [Gasto] = []

public class Gasto: NSObject {
    var name : String?
    var value = Double()
    var date = NSDate() // formato "dd/MM/yyyy"
    var category = String()
    
    // init para gasto em dinheiro
    init(nome: String, categoria: String, valor: Double, data: NSDate) {
        self.name = nome
        self.category = categoria
        self.value = valor
        self.date = data
    }
}

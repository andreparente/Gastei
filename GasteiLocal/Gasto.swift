//
//  Gasto.swift
//  ControleDeGastos
//
//  Created by Andre Machado Parente on 6/2/16.
//  Copyright © 2016 Andre Machado Parente. All rights reserved.
//

import Foundation

public var gastosGlobal: [Gasto] = []

open class Gasto: NSObject {
    var name : String?
    var value = Double()
    var date = Date() // formato "dd/MM/yyyy"
    var category = String()
    
    // init para gasto em dinheiro
    init(nome: String, categoria: String, valor: Double, data: Date) {
        self.name = nome
        self.category = categoria
        self.value = valor
        self.date = data
    }
}

//
//  User.swift
//  ControleDeGastos
//
//  Created by Andre Machado Parente on 6/1/16.
//  Copyright © 2016 Andre Machado Parente. All rights reserved.
//

import Foundation
import CloudKit


public var userLogged: User!
public var arrayUserRecords: Array<CKRecord> = []


public class User {
    

    var cloudId: String!
    var categories: [String] = ["Outros","Alimentação","Transporte"]
    var limiteMes: Double = 0
    var arrayGastos: [CKReference] = []
    public var gastos: [Gasto] = []
    
    
    init(cloudId: String) {
        self.cloudId = cloudId
    }
    func addCategoriaGasto(categ: String) {
        self.categories.append(categ)
    }
    
    func getCategorias() -> [String] {
        return self.categories
    }
    
    func addGasto(gasto: Gasto) {
        self.gastos.append(gasto)
    }
    
    func getGastos() -> [Gasto] {
        return gastos
    }
    
    func setLimiteMes(limite: Double) {
        self.limiteMes = limite
    }
    
    func getLimiteMes() -> Double {
        return self.limiteMes
    }
    
    
    // -------------------------------------------- MUDAR ESSAS FUNCOES PARA CLOUDKIT-------------------------------
    
    
    
    func getGastosMes(mes: Int, ano: Int) -> [Gasto] {
        // gera o novo vetor
        var gastosMes: [Gasto] = []
        for gasto in self.gastos
        {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy"
            let data = dateFormatter.stringFromDate(gasto.date).componentsSeparatedByString("/")
            // data == [ano, mes, dia]
            let mesGasto = Int(data[1])
            let anoGasto = Int(data[2])
            if (mesGasto == mes && ano == anoGasto) {
                gastosMes.append(gasto)
            }
        }
        return gastosMes
    }
    
    // passando zero retorna os gastos de hoje
    func getGastosUltimosDias(dias: Int) -> [Gasto] {
        // descobre ano, mes e dia atuais
        let hoje = NSDate()
        let components = NSCalendar.currentCalendar().components([.Day, .Month, .Year], fromDate: hoje)
        let mesAtual = components.month
        let anoAtual = components.year
        let diaAtual = components.day
        
        // gera o novo vetor
        var gastosUltimosDias: [Gasto] = []
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        
        for gasto in self.gastos {
            let data = dateFormatter.stringFromDate(gasto.date).componentsSeparatedByString("/")
            // data == [ano, mes, dia]
            let dia = Int(data[0])
            let mes = Int(data[1])
            let ano = Int(data[2])
            if (mes == mesAtual && ano == anoAtual && dia >= (diaAtual - dias)) {
                gastosUltimosDias.append(gasto)
            }
        }
        return gastosUltimosDias
    }
    
    func getGastosHoje() -> [Gasto] {
        return getGastosUltimosDias(0)
    }
    
    // funcao retorna os gastos do ultimo mes
    // exemplo, se for chamada no dia 2016-03-14,
    // vai retornar os gastos de 03-01 a 03-14
    
    func getGastosUltimoMês() -> [Gasto] {
        // descobre ano e mes atuais
        let hoje = NSDate()
        let components = NSCalendar.currentCalendar().components([.Day, .Month, .Year], fromDate: hoje)
        let diaAtual = components.day
        
        // subtrai 1 pq os dias do mes nao comecam no zero
        
        return getGastosUltimosDias(diaAtual-1)
    }
    
    func calculaMediaPorDia(user: User) -> Double {
        
        var mediaPorDia: Double!
        
        let hoje = NSDate()
        let components = NSCalendar.currentCalendar().components([.Day, .Month, .Year], fromDate: hoje)
        
        let dateComponents = NSDateComponents()
        dateComponents.year = components.year
        dateComponents.month = components.month
        let diaAtual = components.day
        
        let calendar = NSCalendar.currentCalendar()
        let date = calendar.dateFromComponents(dateComponents)!
        let range = calendar.rangeOfUnit(.Day, inUnit: .Month, forDate: date)
        let numDays = range.length
        
        let numDaysLeft = Double(numDays - diaAtual)
        
        mediaPorDia = user.limiteMes/numDaysLeft
        
        return mediaPorDia
    }
    
    func calculaGastosNoDia(user: User) -> Double {
        
        var totNoDia: Double = 0
        
        let gastosDoDia: [Gasto] = getGastosHoje()
        
        for gasto in gastosDoDia {
            totNoDia += gasto.value
        }
        
        
        return totNoDia
    }
    
    
    func abaixoDaMedia(user: User) -> Bool {
        
        if(calculaMediaPorDia(user) > calculaGastosNoDia(user)) {
            return false
        }
        else {
            return true
        }
    }
    
    func previsaoGastosMes(user: User) -> Double {
        
        var result: Double!
        var gastos: [Gasto]?
        var total: Double = 0
        let hoje = NSDate()
        let components = NSCalendar.currentCalendar().components([.Day, .Month, .Year], fromDate: hoje)
        
        let dateComponents = NSDateComponents()
        dateComponents.year = components.year
        dateComponents.month = components.month
        let diaAtual = components.day
        let mesAtual = components.month
        
        gastos = self.getGastosUltimoMês()
        
        if(gastos != nil) {
            
            
            for gasto in gastos! {
                total += gasto.value
            }
            
            if(total == 0) {
                return 0
            }
                
            else {
                if mesAtual == 1 || mesAtual == 3 || mesAtual == 5 || mesAtual == 7 || mesAtual == 8 || mesAtual == 10 || mesAtual == 12
                {
                result = total + ((total/Double((diaAtual))) * Double(31 - diaAtual))
                }
                else{
                    if mesAtual == 2
                    {
                     result = total + ((total/Double((diaAtual))) * Double(28 - diaAtual))
                    }
                    else{
                        result = total + ((total/Double((diaAtual))) * Double(30 - diaAtual))
                    }
                }
                
                return result
            }
        }
        else {
            return 0
        }
    }
}

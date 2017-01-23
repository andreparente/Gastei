//
//  Filtros.swift
//  ControleDeGastos
//
//  Created by Caio Valente on 04/04/16.
//  Copyright © 2016 Andre Machado Parente. All rights reserved.
//

import Foundation
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}


// filtra o vetor de gastos pelo intervalo de valores
public func filtraValor(_ min: Double, max: Double, gastos: [Gasto]) -> [Gasto] {
    // gera o novo vetor
    var gastosFiltrados: [Gasto] = []
    for gasto in gastos {
        let valor = gasto.value
        if (valor >= min && valor <= max) {
            gastosFiltrados.append(gasto)
        }
    }
    return gastosFiltrados
}

// filtra o vetor de gastos pelo valor minimo
public func filtraValorMin(_ min: Double, gastos: [Gasto]) -> [Gasto] {
    // gera o novo vetor
    var gastosFiltrados: [Gasto] = []
    for gasto in gastos {
        let valor = gasto.value
        if (valor >= min) {
            gastosFiltrados.append(gasto)
        }
    }
    return gastosFiltrados
}

// filtra o vetor de gastos pelo valor maximo
public func filtraValorMax(_ max: Double, gastos: [Gasto]) -> [Gasto] {
    // gera o novo vetor
    var gastosFiltrados: [Gasto] = []
    for gasto in gastos {
        let valor = gasto.value
        if (valor <= max) {
            gastosFiltrados.append(gasto)
        }
    }
    return gastosFiltrados
}

// filtra o vetor de gastos pela categoria
public func filtraCategoria(_ categoriaFiltro: String, gastos: [Gasto]) -> [Gasto] {
    // gera o novo vetor
    var gastosFiltrados: [Gasto] = []
    for gasto in gastos {
        let categ = gasto.category
        if (categ == categoriaFiltro) {
            gastosFiltrados.append(gasto)
        }
    }
    return gastosFiltrados
}

public func comparadata(_ data1: Date, date2: Date) ->(Int)
{
    //data1.changeDaysBy(-1)
    if data1.compare(date2) == ComparisonResult.orderedDescending
    {
        //NSLog("date1 after date2");
        return 1
    } else if data1.compare(date2) == ComparisonResult.orderedAscending
    {
        //NSLog("date1 before date2");
        return -1
    } else
    {
        //NSLog("dates are equal");
        return 0
    }
}

public func filtroData(_ inicio:Date, fim:Date, gastos:[Gasto]) ->([Gasto])
{
    var gastosFiltrados: [Gasto] = []
    let dateFormatter = DateFormatter()
    
    // eh necessario zerar a hora, os minutos e os segundos antes de comecar
    let cal: Calendar = Calendar(identifier: Calendar.Identifier.gregorian)
    let inicio_ = (cal as NSCalendar).date(bySettingHour: 0, minute: 0, second: 0, of: inicio, options: NSCalendar.Options())!
    let fim_ = (cal as NSCalendar).date(bySettingHour: 0, minute: 0, second: 0, of: fim, options: NSCalendar.Options())!
    
    dateFormatter.dateFormat = "dd/MM/yyyy"
    for i in 0..<gastos.count {
      //  let dataGasto = dateFormatter.dateFromString(gastos[i].date)!
        //print (dataGasto, " --- ", fim, " --- ", inicio)
       /* if ( (comparadata(inicio_, date2: gastos[i].date) == -1 || comparadata(inicio_, date2: gastos[i].date) == 0) && (comparadata(fim_, date2: gastos[i].date) == 0 || comparadata(fim_,date2: gastos[i].date) == 1) ) {
            gastosFiltrados.append(gastos[i])
        }*/
        
        print(gastos[i].date)
        if gastos[i].date.isLessThanDate(fim) && gastos[i].date.isGreaterThanDate(inicio) {
            gastosFiltrados.append(gastos[i])
        }
    }
    return gastosFiltrados
}

// passando zero retorna os gastos de hoje
func filtraUltimosDias(_ dias: Int,gastos:[Gasto]) ->([Gasto]) {
    // descobre ano, mes e dia atuais
    let hoje = Date()
    let components = (Calendar.current as NSCalendar).components([.day, .month, .year], from: hoje)
    let mesAtual = components.month
    let anoAtual = components.year
    let diaAtual = components.day
    
    // gera o novo vetor
    var gastosUltimosDias: [Gasto] = []
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "dd/MM/yyyy"
    
    for gasto in gastos {
        
        let data = dateFormatter.string(from: gasto.date as Date).components(separatedBy: "/")
        // data == [ano, mes, dia]
        let dia = Int(data[0])
        let mes = Int(data[1])
        let ano = Int(data[2])
        if (mes! == mesAtual! && ano! == anoAtual! && dia! >= (diaAtual! - dias)) {
            gastosUltimosDias.append(gasto)
        }
    }
    return gastosUltimosDias
}

extension Date {
    func isGreaterThanDate(_ dateToCompare: Date) -> Bool {
        //Declare Variables
        var isGreater = false
        
        //Compare Values
        if self.compare(dateToCompare) == ComparisonResult.orderedDescending {
            isGreater = true
        }
        
        //Return Result
        return isGreater
    }
    
    func isLessThanDate(_ dateToCompare: Date) -> Bool {
        //Declare Variables
        var isLess = false
        
        //Compare Values
        if self.compare(dateToCompare) == ComparisonResult.orderedAscending {
            isLess = true
        }
        
        //Return Result
        return isLess
    }
    
    func equalToDate(_ dateToCompare: Date) -> Bool {
        //Declare Variables
        var isEqualTo = false
        
        //Compare Values
        if self.compare(dateToCompare) == ComparisonResult.orderedSame {
            isEqualTo = true
        }
        
        //Return Result
        return isEqualTo
    }
    
    func addDays(_ daysToAdd: Int) -> Date {
        let secondsInDays: TimeInterval = Double(daysToAdd) * 60 * 60 * 24
        let dateWithDaysAdded: Date = self.addingTimeInterval(secondsInDays)
        
        //Return Result
        return dateWithDaysAdded
    }
    
    func addHours(_ hoursToAdd: Int) -> Date {
        let secondsInHours: TimeInterval = Double(hoursToAdd) * 60 * 60
        let dateWithHoursAdded: Date = self.addingTimeInterval(secondsInHours)
        
        //Return Result
        return dateWithHoursAdded
    }
}


//
//  Filtros.swift
//  ControleDeGastos
//
//  Created by Caio Valente on 04/04/16.
//  Copyright © 2016 Andre Machado Parente. All rights reserved.
//

import Foundation

// filtra o vetor de gastos pelo intervalo de valores
public func filtraValor(min: Double, max: Double, gastos: [Gasto]) -> [Gasto] {
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
public func filtraValorMin(min: Double, gastos: [Gasto]) -> [Gasto] {
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
public func filtraValorMax(max: Double, gastos: [Gasto]) -> [Gasto] {
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
public func filtraCategoria(categoriaFiltro: String, gastos: [Gasto]) -> [Gasto] {
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

public func comparadata(data1: NSDate, date2: NSDate) ->(Int)
{
    //data1.changeDaysBy(-1)
    if data1.compare(date2) == NSComparisonResult.OrderedDescending
    {
        //NSLog("date1 after date2");
        return 1
    } else if data1.compare(date2) == NSComparisonResult.OrderedAscending
    {
        //NSLog("date1 before date2");
        return -1
    } else
    {
        //NSLog("dates are equal");
        return 0
    }
}

public func filtroData(inicio:NSDate, fim:NSDate, gastos:[Gasto]) ->([Gasto])
{
    var gastosFiltrados: [Gasto] = []
    let dateFormatter = NSDateFormatter()
    
    // eh necessario zerar a hora, os minutos e os segundos antes de comecar
    let cal: NSCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
    let inicio_ = cal.dateBySettingHour(0, minute: 0, second: 0, ofDate: inicio, options: NSCalendarOptions())!
    let fim_ = cal.dateBySettingHour(0, minute: 0, second: 0, ofDate: fim, options: NSCalendarOptions())!
    
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
func filtraUltimosDias(dias: Int,gastos:[Gasto]) ->([Gasto]) {
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
    
    for gasto in gastos {
        
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

extension NSDate {
    func isGreaterThanDate(dateToCompare: NSDate) -> Bool {
        //Declare Variables
        var isGreater = false
        
        //Compare Values
        if self.compare(dateToCompare) == NSComparisonResult.OrderedDescending {
            isGreater = true
        }
        
        //Return Result
        return isGreater
    }
    
    func isLessThanDate(dateToCompare: NSDate) -> Bool {
        //Declare Variables
        var isLess = false
        
        //Compare Values
        if self.compare(dateToCompare) == NSComparisonResult.OrderedAscending {
            isLess = true
        }
        
        //Return Result
        return isLess
    }
    
    func equalToDate(dateToCompare: NSDate) -> Bool {
        //Declare Variables
        var isEqualTo = false
        
        //Compare Values
        if self.compare(dateToCompare) == NSComparisonResult.OrderedSame {
            isEqualTo = true
        }
        
        //Return Result
        return isEqualTo
    }
    
    func addDays(daysToAdd: Int) -> NSDate {
        let secondsInDays: NSTimeInterval = Double(daysToAdd) * 60 * 60 * 24
        let dateWithDaysAdded: NSDate = self.dateByAddingTimeInterval(secondsInDays)
        
        //Return Result
        return dateWithDaysAdded
    }
    
    func addHours(hoursToAdd: Int) -> NSDate {
        let secondsInHours: NSTimeInterval = Double(hoursToAdd) * 60 * 60
        let dateWithHoursAdded: NSDate = self.dateByAddingTimeInterval(secondsInHours)
        
        //Return Result
        return dateWithHoursAdded
    }
}


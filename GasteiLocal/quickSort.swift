//
//  quickSort.swift
//  ControleDeGastos
//
//  Created by Caio Valente on 04/04/16.
//  Copyright © 2016 Andre Machado Parente. All rights reserved.
//

import Foundation
import CloudKit
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


class QuickSortClass {
    var v = [Int]()
    
    internal func partition(_ left: Int, right: Int) -> Int {
        var i = left
        for j in (left + 1)..<(right + 1) {
            if v[j] < v[left] {
                i += 1
                (v[i], v[j]) = (v[j], v[i])
            }
        }
        (v[i], v[left]) = (v[left], v[i])
        return i
    }
    
    internal func quicksort(_ left: Int, right: Int) {
        if right > left {
            let pivotIndex = partition(left, right: right)
            quicksort(left, right: pivotIndex - 1)
            quicksort(pivotIndex + 1, right: right)
        }
    }
    
    func callQuickSort () {
        quicksort(0, right: v.count-1)
    }
}


class QuickSorterGasto {
    var v = [Gasto]()
    var a = [CKReference]()
    var decrescente = false
    
    func callQuickSort (_ ordenacao: String, decrescente: Bool) {
        self.decrescente = decrescente
        if (ordenacao == "Data") {
            quicksortData(0, right: v.count-1)


        } else if (ordenacao == "Nome") {
            quicksortNome(0, right: v.count-1)

        } else if (ordenacao == "Valor") {
            quicksortValor(0, right: v.count-1)

        }
    }
    
    internal func partitionData(_ left: Int, right: Int) -> Int {
        var i = left
        for j in (left + 1)..<(right + 1) {
            var precisaTrocar = v[j].date.isLessThanDate(v[left].date)

            // inverte a verificacao para ordenar ao contrario
            if (self.decrescente) {
                precisaTrocar = !precisaTrocar
            }
            
            if precisaTrocar {
                i += 1
                (v[i], v[j]) = (v[j], v[i])
                if defaults.bool(forKey: "Cloud") {
                    (a[i], a[j]) = (a[j], a[i])
                }
                
            }
        }
        (v[i], v[left]) = (v[left], v[i])
        if defaults.bool(forKey: "Cloud") {

        (a[i], a[left]) = (a[left], a[i])
        }
        return i
    }
    
    internal func quicksortData(_ left: Int, right: Int) {
        if right > left {
            let pivotIndex = partitionData(left, right: right)
            quicksortData(left, right: pivotIndex - 1)
            quicksortData(pivotIndex + 1, right: right)
        }
    }
    
    internal func partitionNome(_ left: Int, right: Int) -> Int {
        var i = left
        for j in (left + 1)..<(right + 1) {
            var precisaTrocar = v[j].name < v[left].name
            
            // inverte a verificacao para ordenar ao contrario
            if (self.decrescente) {
                precisaTrocar = !precisaTrocar
            }
            
            if precisaTrocar {
                i += 1
                (v[i], v[j]) = (v[j], v[i])
                if defaults.bool(forKey: "Cloud") {

                (a[i], a[j]) = (a[j], a[i])
                }
            }
        }
        (v[i], v[left]) = (v[left], v[i])
        if defaults.bool(forKey: "Cloud") {

        (a[i], a[left]) = (a[left], a[i])
        }
        return i
    }
    
    internal func quicksortNome(_ left: Int, right: Int) {
        if right > left {
            let pivotIndex = partitionNome(left, right: right)
            quicksortNome(left, right: pivotIndex - 1)
            quicksortNome(pivotIndex + 1, right: right)
        }
    }
    
    internal func partitionValor(_ left: Int, right: Int) -> Int {
        var i = left
        for j in (left + 1)..<(right + 1) {
            var precisaTrocar = v[j].value < v[left].value
            
            // inverte a verificacao para ordenar ao contrario
            if (self.decrescente) {
                precisaTrocar = !precisaTrocar
            }
            
            if precisaTrocar {
                i += 1
                (v[i], v[j]) = (v[j], v[i])
                if defaults.bool(forKey: "Cloud") {

                (a[i], a[j]) = (a[j], a[i])
                }
            }
        }
        (v[i], v[left]) = (v[left], v[i])
        if defaults.bool(forKey: "Cloud") {

        (a[i], a[left]) = (a[left], a[i])
        }
        return i
    }
    
    internal func quicksortValor(_ left: Int, right: Int) {
        if right > left {
            let pivotIndex = partitionValor(left, right: right)
            quicksortValor(left, right: pivotIndex - 1)
            quicksortValor(pivotIndex + 1, right: right)
        }
    }
}

/*extension NSDate {
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
}*/

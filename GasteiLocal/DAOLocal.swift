//
//  DAOLocal.swift
//  ControleDeGastos
//
//  Created by Andre Machado Parente on 7/23/16.
//  Copyright © 2016 Andre Machado Parente. All rights reserved.
//

import Foundation
import CoreData
import UIKit

public var gastosCoreData: [NSManagedObject]!

open class DAOLocal {
    
    func salvarGasto(_ gasto: Gasto) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        
        let entity = NSEntityDescription.entity(forEntityName: "Gasto", in: managedContext)
        let gastoManage = NSManagedObject(entity: entity!, insertInto: managedContext)
        
        gastoManage.setValue(gasto.name, forKey: "name")
        gastoManage.setValue(gasto.category, forKey: "category")
        gastoManage.setValue(gasto.date, forKey: "date")
        gastoManage.setValue(gasto.value, forKey: "value")
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Erro ao salvar Gasto no CoreData: \(error), \(error.userInfo)")
        }
    }
    
    func loadGastos() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Gasto")
        
        gastosGlobal.removeAll()
        //isso já deixa numa ordem crescente ou decrescente, pelo que to entendendo da parada...
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        do {
            let results = try managedContext.fetch(fetchRequest)
            gastosCoreData = results as! [NSManagedObject]
            
            //pra garantir que o gastosGlobal e o gastosCoreData estao na mesma ordem, que nem o cloudKit!
            for gasto in gastosCoreData {
                gastosGlobal.append(
                    Gasto(nome: gasto.value(forKey: "name") as! String,
                    categoria: gasto.value(forKey: "category") as! String,
                    valor: gasto.value(forKey: "value") as! Double,
                    data: gasto.value(forKey: "date") as! Date))
            }
            
        } catch let error as NSError {
            print("Erro ao fetch Exercicios: \(error.localizedDescription), \(error.userInfo)")
        }
    }
    
    func loadGastosEspecifico(_ fromDate: Date, toDate: Date) {
        
        //a data ta em qual formato mesmo??
    
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        var request = NSFetchRequest<NSFetchRequestResult>(entityName: "Gasto")
        request.returnsObjectsAsFaults = false
//        let dateFormatter = NSDateFormatter()
//        dateFormatter.dateFormat = "dd/MM/yyyy"
//    //    dateFormatter.timeZone = NSTimeZone(name: "GMT") // this line resolved me the issue of getting one day less than the selected date
//        let startDate:NSDate = dateFormatter.dateFromString(fromDate)!
//        let endDate:NSDate = dateFormatter.dateFromString(toDate)!
        request.predicate = NSPredicate(format: "(date >= %@) AND (date <= %@)", fromDate as CVarArg, toDate as CVarArg)
        
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        do {
            let results = try managedContext.fetch(request)
            gastosCoreData = results as? [NSManagedObject]
            
            //aqui teremos que botar na ordem o gastosGlobal ou o userLogged.gastos?? acho que na versao "offline"nao iremos ter User neh
            for gasto in gastosCoreData {
                gastosGlobal.append(
                    Gasto(nome: gasto.value(forKey: "name") as! String,
                        categoria: gasto.value(forKey: "category") as! String,
                        valor: gasto.value(forKey: "value") as! Double,
                        data: gasto.value(forKey: "date") as! Date))
            }
        } catch let error as NSError {
            print("Erro ao fetch Exercicios: \(error.localizedDescription), \(error.userInfo)")
        }
        print(gastosCoreData.count)
    }
    
    func loadGastosMesEspecifico(_ month: String) {
        
        //a data ta em qual formato mesmo??
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        var request = NSFetchRequest<NSFetchRequestResult>(entityName: "Gasto")
        request.returnsObjectsAsFaults = false
        
        let fromDate = "2016-"+month+"-01"
        let toDate = "2016-"+month+"-31"
        request.predicate = NSPredicate(format: "(date >= %@) AND (date<= %@)", fromDate,toDate)
        
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        do {
            let results = try managedContext.fetch(request)
            gastosCoreData = results as! [NSManagedObject]
            
            //aqui teremos que botar na ordem o gastosGlobal ou o userLogged.gastos?? acho que na versao "offline"nao iremos ter User neh
            for gasto in gastosCoreData {
                gastosGlobal.append(
                    Gasto(nome: gasto.value(forKey: "name") as! String,
                        categoria: gasto.value(forKey: "category") as! String,
                        valor: gasto.value(forKey: "value") as! Double,
                        data: gasto.value(forKey: "date") as! Date))
            }
        } catch let error as NSError {
            print("Erro ao fetch Exercicios: \(error.localizedDescription), \(error.userInfo)")
        }
        print(gastosCoreData.count)
    }
    
    func deleteGastoEspecifico(_ gasto: Gasto, index: Int) {
        
      
        // remove the deleted item from the model
        let appDel:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context:NSManagedObjectContext = appDel.managedObjectContext
        context.delete(gastosCoreData[index])
        
       // appDel.saveContext() testar!!
        gastosCoreData.remove(at: index)
        do {
            try context.save()
        } catch let error as NSError {
            print("Erro ao deletar gasto: \(error.localizedDescription), \(error.userInfo)")
        }
        print(gastosCoreData.count)
    }
    
    func filtrarPorData(_ fromDate: Date, toDate: Date) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        var request = NSFetchRequest<NSFetchRequestResult>(entityName: "Gasto")
        request.returnsObjectsAsFaults = false
        request.predicate = NSPredicate(format: "(date >= %@) AND (date <= %@)", fromDate as CVarArg, toDate as CVarArg)
        
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        do {
            let results = try managedContext.fetch(request)
            gastosCoreData = results as? [NSManagedObject]
            
            //aqui teremos que botar na ordem o gastosGlobal ou o userLogged.gastos?? acho que na versao "offline"nao iremos ter User neh
            for gasto in gastosCoreData {
                gastosGlobal.append(
                    Gasto(nome: gasto.value(forKey: "name") as! String,
                        categoria: gasto.value(forKey: "category") as! String,
                        valor: gasto.value(forKey: "value") as! Double,
                        data: gasto.value(forKey: "date") as! Date))
            }
        } catch let error as NSError {
            print("Erro ao fetch Exercicios: \(error.localizedDescription), \(error.userInfo)")
        }
        print(gastosCoreData.count)
    }
    
    func filtrarPorDataCategoriaPreço(_ fromDate: Date, toDate: Date, fromPrice: Double, toPrice: Double, category: String) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        var request = NSFetchRequest<NSFetchRequestResult>(entityName: "Gasto")
        request.returnsObjectsAsFaults = false
        
        if category == "Todas" {
        request.predicate = NSPredicate(format: "(date >= %@) AND (date <= %@) AND (value >= %@) AND (value <= %@)", fromDate as CVarArg, toDate as CVarArg,fromPrice, toPrice)
        } else {
            request.predicate = NSPredicate(format: "(date >= %@) AND (date <= %@) AND (value >= %@) AND (value <= %@) AND (category == %@)", fromDate as CVarArg, toDate as CVarArg,fromPrice, toPrice,category)
        }
        
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        do {
            let results = try managedContext.fetch(request)
            gastosCoreData = results as? [NSManagedObject]
            
            //aqui teremos que botar na ordem o gastosGlobal ou o userLogged.gastos?? acho que na versao "offline"nao iremos ter User neh
            gastosGlobal.removeAll()
            for gasto in gastosCoreData {
                gastosGlobal.append(
                    Gasto(nome: gasto.value(forKey: "name") as! String,
                        categoria: gasto.value(forKey: "category") as! String,
                        valor: gasto.value(forKey: "value") as! Double,
                        data: gasto.value(forKey: "date") as! Date))
            }
        } catch let error as NSError {
            print("Erro ao fetch Exercicios: \(error.localizedDescription), \(error.userInfo)")
        }
        print(gastosCoreData.count)
    }
}

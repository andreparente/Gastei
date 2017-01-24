//
//  DAOCloudKit.swift
//  ControleDeGastos
//
//  Created by Andre Machado Parente on 6/1/16.
//  Copyright © 2016 Andre Machado Parente. All rights reserved.
//

import Foundation
import CloudKit
import NotificationCenter
public var arrayGastoRecords: Array<CKRecord> = []
class DAOCloudKit {
    
    func cloudAvailable()->(Bool)
    {
        if FileManager.default.ubiquityIdentityToken != nil{
            return true
        }
        else{
            return false
        }
    }
    
    
    // ------------------------------ FUNCAO PARA PEGAR ID DO USER ---------------------------
    
    func getId(_ complete: @escaping (_ instance: CKRecordID?, _ error: NSError?) -> ()) {
        let container = CKContainer.default()
        container.fetchUserRecordID() {
            recordID, error in
            if error != nil {
                print(error!.localizedDescription)
                complete(nil, error as NSError?)
                NotificationCenter.default.post(name: Notification.Name(rawValue: "notificationErrorGetId"), object: nil)
            } else {
                print("fetched ID \(recordID?.recordName)")
                complete(recordID, nil)
                
                
               // NSNotificationCenter.defaultCenter().postNotificationName("notificationSucessGetId", object: nil)
            }
        }
    }
    
    // ------------------------------ END OF FUNCTION -------------------------------------
    
    
    
    //------------------------------------ SAVE FUNCTIONS ------------------------------
    
    
    func saveUser(_ user: User) {
        
        let recordId = CKRecordID(recordName: user.cloudId)
        let record = CKRecord(recordType: "User", recordID: recordId)
        let container = CKContainer.default()
        let privateDatabase = container.privateCloudDatabase
        
        privateDatabase.fetch(withRecordID: recordId) { (fetchedRecord,error) in
            
            if error == nil {
                
                print("Already exists user!!")
                NotificationCenter.default.post(name: Notification.Name(rawValue: "notificationErrorRegister"), object: nil)
                
            }
                
            else {
                
                if(fetchedRecord == nil) {
                    
                    print("primeira vez que ta criando")
                    
                    record.setObject(user.cloudId as CKRecordValue?, forKey: "cloudId")
                    
                    record.setObject(user.categories as CKRecordValue?, forKey: "categories")
                    
                    
                    privateDatabase.save(record, completionHandler: { (record, error) -> Void in
                        if (error != nil) {
                            print(error!)
                        }
                    })
                }
            }
        }
    }
    
    func addCategory(_ user: User) {
        
        let recordId = CKRecordID(recordName: user.cloudId)
        let container = CKContainer.default()
        let privateDatabase = container.privateCloudDatabase
        
        privateDatabase.fetch(withRecordID: recordId) { (fetchedRecord,error) in
            
            print(fetchedRecord!)
            
            if error == nil {
                
                print("Already exists user!!")
                fetchedRecord!.setObject(user.categories as CKRecordValue?, forKey: "categories")
                
                privateDatabase.save(fetchedRecord!, completionHandler: { (record, error) -> Void in
                    if (error != nil) {
                        print(error!)
                    }
                })
                
                NotificationCenter.default.post(name: Notification.Name(rawValue: "notificationCategoryAdded"), object: nil)
                
            }
                
            else {
                
                NotificationCenter.default.post(name: Notification.Name(rawValue: "notificationErrorAddCategory"), object: nil)
                
                
            }
        }
    }
    
    
    func addGasto(_ gasto: Gasto, user: User) {
        
        let container = CKContainer.default()
        let privateDatabase = container.privateCloudDatabase
        
        let myRecord = CKRecord(recordType: "Gasto")
        let recordId = CKRecordID(recordName: user.cloudId)
        
        myRecord.setObject(gasto.name as CKRecordValue?, forKey: "name")
        myRecord.setObject(gasto.date as CKRecordValue?, forKey: "dataNova")
        myRecord.setObject(gasto.category as CKRecordValue?, forKey: "category")
        myRecord.setObject(gasto.value as CKRecordValue?, forKey: "value")
        let gastoReference = CKReference(recordID: myRecord.recordID, action: .none)
        
        print("---------------------- Referencia do gasto: ", gastoReference)
        user.arrayGastos.append(gastoReference)
        
        
        privateDatabase.save(myRecord, completionHandler:
            ({returnRecord, error in
                if error != nil {
                    print(error!)
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "notificationSaveError"), object: nil)
                    }
                    
                } else {
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "notificationSaveSuccess"), object: nil)
                    }
                    
                }
            }))
        
        
        container.privateCloudDatabase.fetch(withRecordID: recordId) { (fetchedRecord,error) in
            
            print(fetchedRecord!)
            
            if error == nil {
                
                print("Already exists user!!")
                
                print("---------------------- Referencia dos gastos: ", user.arrayGastos)
                fetchedRecord!.setObject(user.arrayGastos as CKRecordValue?, forKey: "gastos")
                
                container.privateCloudDatabase.save(fetchedRecord!, completionHandler: { (record, error) -> Void in
                    if (error != nil) {
                        print(error!)
                    }
                })
                
                //  NSNotificationCenter.defaultCenter().postNotificationName("notificationCategoryAdded", object: nil)
                
            }
                
            else {
                
                //    NSNotificationCenter.defaultCenter().postNotificationName("notificationErrorAddCategory", object: nil)
                
                
            }
        }
    }
    
    
    
    //------------------------------------ END OF SAVE FUNCTIONS ------------------------------
    
    
    
    //------------------------------------ DELETE FUNCTIONS ------------------------------
    
    
    func deleteGasto(_ gastoToDelete: CKReference, user: User, index: Int) {
        
        let userRecordId = CKRecordID(recordName: user.cloudId)
        
        let container = CKContainer.default()
        let privateDatabase = container.privateCloudDatabase
        
        privateDatabase.delete(withRecordID: gastoToDelete.recordID,completionHandler:
            ({returnRecord, error in
                if error != nil {
                    print(error!)
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "notificationDeleteError"), object: nil)
                    
                }
            }))
        
        
        user.arrayGastos.remove(at: index)
        
        
        container.privateCloudDatabase.fetch(withRecordID: userRecordId) { (fetchedRecord,error) in
            
            print(fetchedRecord!)
            
            if error == nil {
                
                print("Already exists user!!")
                print("---------------------- Referencia dos gastos: ", user.arrayGastos)
                fetchedRecord!.setObject(user.arrayGastos as CKRecordValue?, forKey: "gastos")
                
                container.privateCloudDatabase.save(fetchedRecord!, completionHandler: { (record, error) -> Void in
                    if (error != nil) {
                        print(error!)
                        
                        
                    }
                })
            }
        }
    }
    
    
    //------------------------------------ END OF DELETE FUNCTIONS ------------------------------
    
    
    //------------------------------------ FETCH FUNCTIONS ------------------------------
    
    
    func fetchCategoriesForUser(_ user: User) {
        
        let container = CKContainer.default()
        let privateDatabase = container.privateCloudDatabase
        let predicate = NSPredicate(value: true)
        
        let query = CKQuery(recordType: "User", predicate: predicate)
        
        privateDatabase.perform(query, inZoneWith: nil) { (results, error) -> Void in
            if error != nil {
                print(error!)
                NotificationCenter.default.post(name: Notification.Name(rawValue: "notificationErrorInternet"), object: nil)
            }
            else {
                
                for result in results! {
                    if(result.value(forKey: "cloudId") as? String == user.cloudId) {
                        
                        
                        //Inicializa o user Logado
                        userLogged.categories.removeAll()
                        for categ in result.value(forKey: "categories") as! [String]
                        {
                            userLogged.categories.append(categ)
                        }
                        return
                    }
                    else {
                    }
                }
            }
        }
    }
/*
    func fetchUserByEmail(email: String!,password: String!) {
        
        let container = CKContainer.defaultContainer()
        let privateDatabase = container.privateCloudDatabase
        let predicate = NSPredicate(value: true)
        
        let query = CKQuery(recordType: "User", predicate: predicate)
        
        privateDatabase.performQuery(query, inZoneWithID: nil) { (results, error) -> Void in
            if error != nil {
                print(error)
                NSNotificationCenter.defaultCenter().postNotificationName("notificationErrorInternet", object: nil)
            }
            else {
                
                for result in results! {
                    if(result.valueForKey("email") as? String == email) {
                        
                        print("user existe!")
                        if (result.valueForKey("password") as? String == password)
                        {
                            
                            //Inicializa o user Logado
                            userLogged = User(name: result.valueForKey("name") as! String, email: email!, password: password!)
                            NSNotificationCenter.defaultCenter().postNotificationName("notificationSuccessLogin", object: nil)
                            return
                        }
                        else {
                            NSNotificationCenter.defaultCenter().postNotificationName("notificationErrorPassword", object: nil)
                            return
                        }
                    }
                }
                NSNotificationCenter.defaultCenter().postNotificationName("notificationErrorEmail", object: nil)
            }
        }
    }
    
    func fetchUserOnlyMail(email: String!) {
        
        let container = CKContainer.defaultContainer()
        let privateDatabase = container.privateCloudDatabase
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "User", predicate: predicate)
        
        privateDatabase.performQuery(query, inZoneWithID: nil) { (results, error) -> Void in
            if error != nil {
                print(error)
            }
            else {
                
                for result in results! {
                    if(result.valueForKey("email") as? String == email) {
                        NSNotificationCenter.defaultCenter().postNotificationName("notificationFailCadastro", object: nil)
                        return
                    }
                    
                }
                NSNotificationCenter.defaultCenter().postNotificationName("notificationSuccessCadastro", object: nil)
                return
            }
        }
        
    }
    */
    //BUSCA OS GASTOS DE ACORDO COM A PK DO EMAIL DO USER LOGADO
    func fetchGastosFromUser(_ user: User) {
        
        let recordId = CKRecordID(recordName: user.cloudId)
        let container = CKContainer.default()
        let privateDatabase = container.privateCloudDatabase
        
        
        var gastosRecordIds = [CKRecordID]()
        
        privateDatabase.fetch(withRecordID: recordId) { (fetchedRecord,error) in
            
            // print(fetchedRecord)
            
            if error == nil {
                
                if let teste = fetchedRecord!.object(forKey: "gastos") {
                    print("quantidade de gastos registrados: ", (teste as! [CKRecordValue]).count)
                    
                    
                    if let limit = fetchedRecord?.object(forKey: "monthLimit") {
                        
                        userLogged.limiteMes = limit as! Double
                    }
                    else {
                        
                        userLogged.limiteMes = 0
                    }
                    
                    for gastoReference in fetchedRecord!.object(forKey: "gastos") as! [CKReference] {
                        gastosRecordIds.append(gastoReference.recordID)
                    }
                    
                    let fetchOperation = CKFetchRecordsOperation(recordIDs: gastosRecordIds)
                    fetchOperation.fetchRecordsCompletionBlock = {
                        records, error in
                        if error != nil {
                            print(error!)
                            NotificationCenter.default.post(name: Notification.Name(rawValue: "notificationErrorInternet"), object: nil)
                            
                        } else {
                            
                            userLogged.gastos.removeAll()
                            userLogged.arrayGastos.removeAll()
                            
                            for (_, result) in records! {
                                
                                userLogged.arrayGastos.append(CKReference(recordID: result.recordID, action: .none))
                                userLogged.gastos.append(Gasto(nome: result.value(forKey: "name") as! String, categoria: result.value(forKey: "category") as! String, valor: result.value(forKey: "value") as! Double, data: result.value(forKey: "dataNova") as! Date))
                            }
                            
                            NotificationCenter.default.post(name: Notification.Name(rawValue: "notificationSuccessLoadUser"), object: nil)
                            
                            
                        }
                    }
                    
                    CKContainer.default().privateCloudDatabase.add(fetchOperation)
                }
                    
                else {
                    
                    if userLogged.gastos.count == 0
                    {
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "notificationSuccessLoadUser"), object: nil)
                    }
                    else{
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "notificationErrorLoadUser"), object: nil)
                        
                    }
                    
                }
            }
            else {
                if userLogged.gastos.count == 0
                {
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "notificationSuccessLoadUser"), object: nil)
                }
                
                print(error!)
            }
        }
    }
    
    //------------------------------------ END OF FETCH FUNCTIONS ------------------------------
    
    
    //------------------------------------ UPDATE/CHANGE FUNCTIONS ------------------------------
    
    
    
    func changeLimit(_ user: User) {
        
        let recordId = CKRecordID(recordName: user.cloudId)
        let container = CKContainer.default()
        let privateDatabase = container.privateCloudDatabase
        
        privateDatabase.fetch(withRecordID: recordId) { (fetchedRecord,error) in
            
            if error == nil {
                
                print("MUDANDO O LIMITE POR MES DE UM USUARIO EXISTENTE")
                fetchedRecord!.setObject(userLogged.limiteMes as CKRecordValue?, forKey: "monthLimit")
                
                privateDatabase.save(fetchedRecord!, completionHandler: { (record, error) -> Void in
                    if (error != nil) {
                        print(error!)
                        let alert=UIAlertController(title:"Erro", message: "Nāo foi possivel alterar seu  limite", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title:"Ok",style: UIAlertActionStyle.default,handler: nil))
                        SettingsViewController().present(alert,animated: true, completion: nil)
                    }
                })
            }
                
            else {
                print(error!)
            }
        }
    }
    
    //------------------------------------ END OF UPDATE/CHANGE FUNCTIONS ------------------------------
    
}



//
//  MainViewController.swift
//  ControleDeGastos
//
//  Created by Andre Machado Parente on 3/23/16.
//  Copyright © 2016 Andre Machado Parente. All rights reserved.
//

import UIKit
var executar = false
import WatchConnectivity

class MainViewController: UIViewController,WCSessionDelegate {
    
    @IBOutlet weak var settingsbutton: UIButton!
    @IBOutlet weak var gastei: UIButton!
    @IBOutlet weak var act: UIActivityIndicatorView!
    @IBOutlet weak var limite: UILabel!
    @IBOutlet weak var totaldisponivel: UILabel!
    @IBOutlet weak var totalgastos: UILabel!
    @IBOutlet weak var totalDisponivelMes: UILabel!
    let app = UIApplication.sharedApplication()
    //@IBOutlet weak var RS: UILabel!
    @IBOutlet weak var gastos: UILabel!
    @IBOutlet weak var background_image: UIImageView!
    
    
    var items: [NSDictionary] = []
    var available: Double!
    var valortotal: Double = 0.0
    var valorTotalMes: Double = 0.0
    var flagLogout: Bool = false;
    
    
    override func viewDidLoad() {
        print("Executou Load")
        super.viewDidLoad()
        act.startAnimating()
        valortotal = 0
        valorTotalMes = 0
        view.backgroundColor = UIColor.whiteColor()
        gastei.hidden = true
        limite.hidden = true
        totaldisponivel.hidden = true
        totalgastos.hidden = true
        settingsbutton.hidden = true
        //RS.hidden = true
        gastos.hidden = true
        //background_image.hidden = true
        self.tabBarController?.tabBar.hidden = true
        userLogged = User(cloudId: "noCloud")
        
        
        if defaults.objectForKey("categories") == nil {
            
            //SETANDO PELA PRIMEIRA VEZ AS CATEGORIAS
            defaults.setObject(userLogged.categories, forKey: "categories")

        } else {
            userLogged.categories = defaults.objectForKey("categories") as! [String]!
        }
        
        if defaults.boolForKey("Cloud") {
            
     //       DAOCloudKit().fetchCategoriesForUser(userLogged)
   //         DAOCloudKit().fetchGastosFromUser(userLogged)
            
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MainViewController.actOnNotificationSuccessLoad), name: "notificationSuccessLoadUser", object: nil)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MainViewController.actOnNotificationErrorLoad), name: "notificationErrorLoadUser", object: nil)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MainViewController.actOnNotificationErrorInternet), name: "notificationErrorInternet", object: nil)
            
        }

        
    }
    
    func printaLimite(usuario: User) {
        
        if(userLogged.limiteMes == 0) {
            limite.text = "O limite mensal ainda não foi cadastrado.\nRealize-o nas configurações."
        }
        else {
            limite.text = "Seu limite mensal é de \n R$ \(usuario.limiteMes)"
        }
    }
    
    @IBAction func botaogastar(sender: UIButton) {
        
        if userLogged.previsaoGastosMes(userLogged) > userLogged.limiteMes
        {
            let alertTime = NSDate().dateByAddingTimeInterval(60)
            let notifyAlarm = UILocalNotification()
            
            notifyAlarm.fireDate = alertTime
            notifyAlarm.timeZone = NSTimeZone.defaultTimeZone()
            notifyAlarm.soundName = UILocalNotificationDefaultSoundName
            notifyAlarm.category = "Aviso_Category"
            notifyAlarm.alertTitle = "Cuidado"
            notifyAlarm.alertBody = "Seu limite mensal é R$\(userLogged.limiteMes) e a sua previsão de gastos para o mês é : R$\(userLogged.previsaoGastosMes(userLogged).roundToPlaces(2))"
            app.scheduleLocalNotification(notifyAlarm)
        }
        /* else{
         if userLogged.abaixoDaMedia(userLogged)
         {
         let alertTime = NSDate().dateByAddingTimeInterval(60)
         
         let notifyAlarm = UILocalNotification()
         
         notifyAlarm.fireDate = alertTime
         notifyAlarm.timeZone = NSTimeZone.defaultTimeZone()
         notifyAlarm.soundName = UILocalNotificationDefaultSoundName
         notifyAlarm.category = "Aviso_Category"
         notifyAlarm.alertTitle = "Atenção"
         notifyAlarm.alertBody = "Você está gastando muito hoje.Previsão para o mês: R$\(userLogged.previsaogastosmes(userLogged).roundToPlaces(2)))"
         app.scheduleLocalNotification(notifyAlarm)
         }
         }
         */
        
    }
    
    @IBAction func botaosettings(sender: UIButton) {
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "MainToSettings" {
            
            let vc = segue.destinationViewController as! SettingsViewController
            vc.mainVC = segue.sourceViewController as? MainViewController
            
            
        }
    }
    
    func actOnNotificationSuccessLoad()
    {
        setView()
    }
    
    func actOnNotificationErrorInternet() {
        
        let alert=UIAlertController(title:"Erro", message: "Verifique a sua conexão com a internet, erro ao acessar a Cloud.", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title:"Ok",style: UIAlertActionStyle.Default,handler: nil))
        self.presentViewController(alert,animated: true, completion: nil)
        exit(0)
    }
    
    func actOnNotificationErrorLoad()
    {
        let alert=UIAlertController(title:"Erro", message: "Favor verificar se está conectado no iCloud.", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title:"Ok",style: UIAlertActionStyle.Default,handler: nil))
        self.presentViewController(alert,animated: true, completion: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        
        gastosGlobal.removeAll()
        var gastosmes:[Gasto]!
        print("entrou na viewWillAppear")
        //  setNotification()
        
        print(executar)
  
        let calendar = NSCalendar.currentCalendar()
        
        let twoMonthsAgo = calendar.dateByAddingUnit(.Month, value: -2, toDate: NSDate(), options: [])
        
        //PARA PEGAR O PRIMEIRO E ULTIMO DIA DO MES
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let components = calendar.components([.Year, .Month], fromDate: NSDate())
        let startOfMonth = calendar.dateFromComponents(components)!
        print(dateFormatter.stringFromDate(startOfMonth))
        let comps2 = NSDateComponents()
        comps2.month = 1
        comps2.day = -1
        let endOfMonth = calendar.dateByAddingComponents(comps2, toDate: startOfMonth, options: [])!
        print(dateFormatter.stringFromDate(endOfMonth))
        
        DAOLocal().loadGastosEspecifico(twoMonthsAgo!, toDate: endOfMonth)
        userLogged.gastos.removeAll()
        userLogged.gastos = gastosGlobal
        let quickSorter = QuickSorterGasto()
        quickSorter.v = gastosGlobal
        quickSorter.a = userLogged.arrayGastos
        quickSorter.callQuickSort("Data", decrescente: true)
        gastosGlobal = quickSorter.v
        userLogged.arrayGastos = quickSorter.a
        userLogged.gastos = gastosGlobal
        var i = 0
        
        for gasto in gastosGlobal {
            print(gasto.name)
           // print(userLogged.gastos[i].name)
            i += 1
        }
        
        
        self.valorTotalMes = 0
        self.valortotal = 0
        
        dispatch_async(dispatch_get_main_queue()) {
            
            gastosmes = userLogged.getGastosUltimoMês()
            self.gastei.hidden = false
            self.limite.hidden = false
            self.totaldisponivel.hidden = false
            self.totalgastos.hidden = false
            self.settingsbutton.hidden = false
            self.tabBarController?.tabBar.hidden = false
            //self.RS.hidden = false
            self.gastos.hidden = false
            //self.background_image.hidden = false
            self.act.stopAnimating()
            self.printaLimite(userLogged)
            let hoje = NSDate()
            let components = NSCalendar.currentCalendar().components([.Day, .Month, .Year], fromDate: hoje)
            let mesAtual = components.month
            let anoAtual = components.year
            
            print("GASTOS MES:::::::::::::::", gastosmes)
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy"
            
            for valor in (gastosmes) {
                
                let data = dateFormatter.stringFromDate(valor.date).componentsSeparatedByString("/")
                self.valortotal += valor.value
                if(Int(data[1]) == mesAtual && Int(data[2]) == anoAtual) {
                    self.valorTotalMes += valor.value
                }
            }
            
            self.totalgastos.text = "R$ \(self.valorTotalMes)"
            self.totaldisponivel.numberOfLines = 3
            
            if(userLogged.limiteMes != 0)
            {
                self.available = userLogged.limiteMes - self.valorTotalMes
                if(self.available >  0 && self.available >= (0.2 * userLogged.limiteMes) )
                {
                    
                    self.totaldisponivel.text = "Você ainda tem R$ \(self.available) \n para gastar nesse mês"
                    // eamarela = false
                    evermelha = false
                    eazul = true
                }
                else
                {
                    if (self.available > 0 && self.available <= (0.2 * userLogged.limiteMes) )
                    {
                        self.totaldisponivel.text = "Atenção! Você só tem mais \n R$ \(self.available) para gastar \n nesse mês"
                        //  eamarela = true
                        evermelha = false
                        eazul = true
                    }
                    else
                    {
                        if self.available == 0
                        {
                            self.totaldisponivel.text = "Você atingiu seu limite mensal!"
                            // eamarela = false
                            evermelha = true
                            eazul = false
                        }
                            
                        else
                        {
                            self.totaldisponivel.text = "Você estourou seu limite \n mensal por R$\(self.valorTotalMes - userLogged.limiteMes)"
                            // eamarela = false
                            evermelha = true
                            eazul = false
                            executar = true
                        }
                    }
                }
                
                if (evermelha)
                {
                    //self.background_image.image = UIImage(named: "background_red.png")
                    self.gastei.setImage(UIImage(named: "add_red.png"), forState: .Normal)
                    self.view.backgroundColor = UIColor(patternImage: UIImage(named: "background_red.png")!)
                }
                if (eazul)
                {
                    //self.background_image.image = UIImage(named: "background_blue.png")
                    self.gastei.setImage(UIImage(named: "add_blue.png"), forState: .Normal)
                    self.view.backgroundColor = UIColor(patternImage: UIImage(named: "background_blue.png")!)
                }
                self.totaldisponivel.hidden=false
            }
            else
            {
                self.totaldisponivel.hidden=true
                //self.background_image.image = UIImage(named: "background_blue.png")
                self.gastei.setImage(UIImage(named: "add_blue.png"), forState: .Normal)
                self.view.backgroundColor = UIColor(patternImage: UIImage(named: "background_blue.png")!)
            }
            
            var arrayCategories = [String]()
            var arrayValor = [String]()
            var total = [String]()
            
            total.append(String(self.valorTotalMes))
            var i = 0
            for _ in userLogged.getGastosHoje()
            {
                arrayCategories.append(userLogged.getGastosHoje()[i].category)
                arrayValor.append(String(userLogged.getGastosHoje()[i].value))
                i+=1
            }
            
            /*   let item = ["categories": arrayCategories, "valor": arrayValor,"total":total]
             self.items.append(item)
             if let newItems = NSUserDefaults.standardUserDefaults().objectForKey("items") as? [NSDictionary] {
             self.items = newItems
             }
             print(self.items)
             WCSession.defaultSession().transferUserInfo(item)
             */
            
            
            if (WCSession.isSupported()) {
                let session = WCSession.defaultSession()
                session.delegate = self
                session.activateSession()
                session.sendMessage(["categorias":[arrayCategories,arrayValor,total]], replyHandler: {(handler) -> Void in print(handler)}, errorHandler: {(error) -> Void in print(#file,error)})
            }
            else
            {
                print("Nao está conectado ao watch")
            }
        }

        
    }

    
    func setView() {
        executar = false
        var gastosmes:[Gasto]!
        gastosGlobal = userLogged.gastos
        
        let quickSorter = QuickSorterGasto()
        quickSorter.v = gastosGlobal
        quickSorter.a = userLogged.arrayGastos
        quickSorter.callQuickSort("Data", decrescente: true)
        gastosGlobal = quickSorter.v
        userLogged.arrayGastos = quickSorter.a
        userLogged.gastos = gastosGlobal
        var i = 0
        
        for gasto in gastosGlobal {
            print(gasto.name)
            print(userLogged.gastos[i].name)
            i += 1
        }
        
        
        self.valorTotalMes = 0
        self.valortotal = 0
        
        dispatch_async(dispatch_get_main_queue()) {
            
            gastosmes = userLogged.getGastosUltimoMês()
            self.gastei.hidden = false
            self.limite.hidden = false
            self.totaldisponivel.hidden = false
            self.totalgastos.hidden = false
            self.settingsbutton.hidden = false
            self.tabBarController?.tabBar.hidden = false
            //self.RS.hidden = false
            self.gastos.hidden = false
            //self.background_image.hidden = false
            self.act.stopAnimating()
            self.printaLimite(userLogged)
            let hoje = NSDate()
            let components = NSCalendar.currentCalendar().components([.Day, .Month, .Year], fromDate: hoje)
            let mesAtual = components.month
            let anoAtual = components.year
            
            print("GASTOS MES:::::::::::::::", gastosmes)
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy"
            
            for valor in (gastosmes) {
                
                let data = dateFormatter.stringFromDate(valor.date).componentsSeparatedByString("/")
                self.valortotal += valor.value
                if(Int(data[1]) == mesAtual && Int(data[2]) == anoAtual) {
                    self.valorTotalMes += valor.value
                }
            }
            
            self.totalgastos.text = "R$ \(self.valorTotalMes)"
            self.totaldisponivel.numberOfLines = 3
            
            if(userLogged.limiteMes != 0)
            {
                self.available = userLogged.limiteMes - self.valorTotalMes
                if(self.available >  0 && self.available >= (0.2 * userLogged.limiteMes) )
                {
                    
                    self.totaldisponivel.text = "Você ainda tem R$ \(self.available) \n para gastar nesse mês"
                    // eamarela = false
                    evermelha = false
                    eazul = true
                }
                else
                {
                    if (self.available > 0 && self.available <= (0.2 * userLogged.limiteMes) )
                    {
                        self.totaldisponivel.text = "Atenção! Você só tem mais \n R$ \(self.available) para gastar \n nesse mês"
                        //  eamarela = true
                        evermelha = false
                        eazul = true
                    }
                    else
                    {
                        if self.available == 0
                        {
                            self.totaldisponivel.text = "Você atingiu seu limite mensal!"
                            // eamarela = false
                            evermelha = true
                            eazul = false
                        }
                            
                        else
                        {
                            self.totaldisponivel.text = "Você estourou seu limite \n mensal por R$\(self.valorTotalMes - userLogged.limiteMes)"
                            // eamarela = false
                            evermelha = true
                            eazul = false
                            executar = true
                        }
                    }
                }
                
                if (evermelha)
                {
                    //self.background_image.image = UIImage(named: "background_red.png")
                    self.gastei.setImage(UIImage(named: "add_red.png"), forState: .Normal)
                    self.view.backgroundColor = UIColor(patternImage: UIImage(named: "background_red.png")!)
                }
                if (eazul)
                {
                    //self.background_image.image = UIImage(named: "background_blue.png")
                    self.gastei.setImage(UIImage(named: "add_blue.png"), forState: .Normal)
                    self.view.backgroundColor = UIColor(patternImage: UIImage(named: "background_blue.png")!)
                }
                self.totaldisponivel.hidden=false
            }
            else
            {
                self.totaldisponivel.hidden=true
                //self.background_image.image = UIImage(named: "background_blue.png")
                self.gastei.setImage(UIImage(named: "add_blue.png"), forState: .Normal)
                self.view.backgroundColor = UIColor(patternImage: UIImage(named: "background_blue.png")!)
            }
            
            var arrayCategories = [String]()
            var arrayValor = [String]()
            var total = [String]()
            
            total.append(String(self.valorTotalMes))
            var i = 0
            for _ in userLogged.getGastosHoje()
            {
                arrayCategories.append(userLogged.getGastosHoje()[i].category)
                arrayValor.append(String(userLogged.getGastosHoje()[i].value))
                i+=1
            }
            
            /*   let item = ["categories": arrayCategories, "valor": arrayValor,"total":total]
             self.items.append(item)
             if let newItems = NSUserDefaults.standardUserDefaults().objectForKey("items") as? [NSDictionary] {
             self.items = newItems
             }
             print(self.items)
             WCSession.defaultSession().transferUserInfo(item)
             */
            
            
            if (WCSession.isSupported()) {
                let session = WCSession.defaultSession()
                session.delegate = self
                session.activateSession()
                session.sendMessage(["categorias":[arrayCategories,arrayValor,total]], replyHandler: {(handler) -> Void in print(handler)}, errorHandler: {(error) -> Void in print(#file,error)})
            }
            else
            {
                print("Nao está conectado ao watch")
            }
        }
    }
}
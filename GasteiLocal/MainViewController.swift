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

class MainViewController: UIViewController {
   
    
    @IBOutlet weak var settingsbutton: UIButton!
    @IBOutlet weak var gastei: UIButton!
    @IBOutlet weak var act: UIActivityIndicatorView!
    @IBOutlet weak var limite: UILabel!
    @IBOutlet weak var totaldisponivel: UILabel!
    @IBOutlet weak var totalgastos: UILabel!
    @IBOutlet weak var totalDisponivelMes: UILabel!
    let app = UIApplication.shared
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
        view.backgroundColor = UIColor.white
        gastei.isHidden = true
        limite.isHidden = true
        totaldisponivel.isHidden = true
        totalgastos.isHidden = true
        settingsbutton.isHidden = true
        //RS.hidden = true
        gastos.isHidden = true
        //background_image.hidden = true
        self.tabBarController?.tabBar.isHidden = true
        userLogged = User(cloudId: "noCloud")
        
        
        if defaults.object(forKey: "categories") == nil {
            
            //SETANDO PELA PRIMEIRA VEZ AS CATEGORIAS
            defaults.set(userLogged.categories, forKey: "categories")

        } else {
            userLogged.categories = defaults.object(forKey: "categories") as! [String]!
        }
        
        if defaults.bool(forKey: "Cloud") {
            
        DAOCloudKit().fetchCategoriesForUser(userLogged)
        DAOCloudKit().fetchGastosFromUser(userLogged)
            
            NotificationCenter.default.addObserver(self, selector: #selector(MainViewController.actOnNotificationSuccessLoad), name: NSNotification.Name(rawValue: "notificationSuccessLoadUser"), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(MainViewController.actOnNotificationErrorLoad), name: NSNotification.Name(rawValue: "notificationErrorLoadUser"), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(MainViewController.actOnNotificationErrorInternet), name: NSNotification.Name(rawValue: "notificationErrorInternet"), object: nil)
            
        }

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        gastosGlobal.removeAll()
        var gastosmes:[Gasto]!
        print("entrou na viewWillAppear")
        //  setNotification()
        
        print(executar)
        
        let calendar = Calendar.current
        
        let twoMonthsAgo = (calendar as NSCalendar).date(byAdding: .month, value: -2, to: Date(), options: [])
        
        //PARA PEGAR O PRIMEIRO E ULTIMO DIA DO MES
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let components = (calendar as NSCalendar).components([.year, .month], from: Date())
        let startOfMonth = calendar.date(from: components)!
        print(dateFormatter.string(from: startOfMonth))
        var comps2 = DateComponents()
        comps2.month = 1
        comps2.day = -1
        let endOfMonth = (calendar as NSCalendar).date(byAdding: comps2, to: startOfMonth, options: [])!
        print(dateFormatter.string(from: endOfMonth))
        
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
            print(gasto.name!)
            // print(userLogged.gastos[i].name)
            i += 1
        }
        
        
        self.valorTotalMes = 0
        self.valortotal = 0
        
        DispatchQueue.main.async {
            
            gastosmes = userLogged.getGastosUltimoMês()
            self.gastei.isHidden = false
            self.limite.isHidden = false
            self.totaldisponivel.isHidden = false
            self.totalgastos.isHidden = false
            self.settingsbutton.isHidden = false
            self.tabBarController?.tabBar.isHidden = false
            //self.RS.hidden = false
            self.gastos.isHidden = false
            //self.background_image.hidden = false
            self.act.stopAnimating()
            self.printaLimite(userLogged)
            let hoje = Date()
            let components = (Calendar.current as NSCalendar).components([.day, .month, .year], from: hoje)
            let mesAtual = components.month
            let anoAtual = components.year
            
            print("GASTOS MES:::::::::::::::", gastosmes)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy"
            
            for valor in (gastosmes) {
                
                let data = dateFormatter.string(from: valor.date as Date).components(separatedBy: "/")
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
                    self.gastei.setImage(UIImage(named: "add_red.png"), for: UIControlState())
                    self.view.backgroundColor = UIColor(patternImage: UIImage(named: "background_red.png")!)
                }
                if (eazul)
                {
                    //self.background_image.image = UIImage(named: "background_blue.png")
                    self.gastei.setImage(UIImage(named: "add_blue.png"), for: UIControlState())
                    self.view.backgroundColor = UIColor(patternImage: UIImage(named: "background_blue.png")!)
                }
                self.totaldisponivel.isHidden=false
            }
            else
            {
                self.totaldisponivel.isHidden=true
                //self.background_image.image = UIImage(named: "background_blue.png")
                self.gastei.setImage(UIImage(named: "add_blue.png"), for: UIControlState())
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
            
            /*
             if (WCSession.isSupported()) {
             let session = WCSession.default()
             session.delegate = self
             session.activate()
             session.sendMessage(["categorias":[arrayCategories,arrayValor,total]], replyHandler: {(handler) -> Void in print(handler)}, errorHandler: {(error) -> Void in print(#file,error)})
             }
             else
             {
             print("Nao está conectado ao watch")
             }
             }
             */
            
        }
    }

 
    
    @IBAction func botaogastar(_ sender: UIButton) {
        
        if userLogged.previsaoGastosMes(userLogged) > userLogged.limiteMes
        {
            sendNotificationPredictionGreaterThanLimit()
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
    
    @IBAction func botaosettings(_ sender: UIButton) {
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "MainToSettings" {
            
            let vc = segue.destination as! SettingsViewController
            vc.mainVC = segue.source as? MainViewController
            
            
        }
    }
    
    
    
    //MARK:Class Functions
    
    func printaLimite(_ usuario: User) {
        
        if(userLogged.limiteMes == 0) {
            limite.text = "O limite mensal ainda não foi cadastrado.\nRealize-o nas configurações."
        }
        else {
            limite.text = "Seu limite mensal é de \n R$ \(usuario.limiteMes)"
        }
    }
    func actOnNotificationSuccessLoad()
    {
        setView()
    }
    
    func actOnNotificationErrorInternet() {
        
        let alert=UIAlertController(title:"Erro", message: "Verifique a sua conexão com a internet, erro ao acessar a Cloud.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title:"Ok",style: UIAlertActionStyle.default,handler: nil))
        self.present(alert,animated: true, completion: nil)
        exit(0)
    }
    
    func actOnNotificationErrorLoad()
    {
        let alert=UIAlertController(title:"Erro", message: "Favor verificar se está conectado no iCloud.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title:"Ok",style: UIAlertActionStyle.default,handler: nil))
        self.present(alert,animated: true, completion: nil)
    }
    
    func sendNotificationPredictionGreaterThanLimit() {
        
        let alertTime = Date().addingTimeInterval(60)
        let notifyAlarm = UILocalNotification()
        
        notifyAlarm.fireDate = alertTime
        notifyAlarm.timeZone = TimeZone.current
        notifyAlarm.soundName = UILocalNotificationDefaultSoundName
        notifyAlarm.category = "Aviso_Category"
        notifyAlarm.alertTitle = "Cuidado"
        notifyAlarm.alertBody = "Seu limite mensal é R$\(userLogged.limiteMes) e a sua previsão de gastos para o mês é : R$\(userLogged.previsaoGastosMes(userLogged).roundToPlaces(2))"
        app.scheduleLocalNotification(notifyAlarm)

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
            print(gasto.name!)
            print(userLogged.gastos[i].name!)
            i += 1
        }
        
        
        self.valorTotalMes = 0
        self.valortotal = 0
        
        DispatchQueue.main.async {
            
            gastosmes = userLogged.getGastosUltimoMês()
            self.gastei.isHidden = false
            self.limite.isHidden = false
            self.totaldisponivel.isHidden = false
            self.totalgastos.isHidden = false
            self.settingsbutton.isHidden = false
            self.tabBarController?.tabBar.isHidden = false
            //self.RS.hidden = false
            self.gastos.isHidden = false
            //self.background_image.hidden = false
            self.act.stopAnimating()
            self.printaLimite(userLogged)
            let hoje = Date()
            let components = (Calendar.current as NSCalendar).components([.day, .month, .year], from: hoje)
            let mesAtual = components.month
            let anoAtual = components.year
            
            print("GASTOS MES:::::::::::::::", gastosmes)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy"
            
            for valor in (gastosmes) {
                
                let data = dateFormatter.string(from: valor.date as Date).components(separatedBy: "/")
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
                    self.gastei.setImage(UIImage(named: "add_red.png"), for: UIControlState())
                    self.view.backgroundColor = UIColor(patternImage: UIImage(named: "background_red.png")!)
                }
                if (eazul)
                {
                    //self.background_image.image = UIImage(named: "background_blue.png")
                    self.gastei.setImage(UIImage(named: "add_blue.png"), for: UIControlState())
                    self.view.backgroundColor = UIColor(patternImage: UIImage(named: "background_blue.png")!)
                }
                self.totaldisponivel.isHidden=false
            }
            else
            {
                self.totaldisponivel.isHidden=true
                //self.background_image.image = UIImage(named: "background_blue.png")
                self.gastei.setImage(UIImage(named: "add_blue.png"), for: UIControlState())
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
            
            
       /*     if (WCSession.isSupported()) {
                let session = WCSession.default()
                session.delegate = self
                session.activate()
                session.sendMessage(["categorias":[arrayCategories,arrayValor,total]], replyHandler: {(handler) -> Void in print(handler)}, errorHandler: {(error) -> Void in print(#file,error)})
            }
            else
            {
                print("Nao está conectado ao watch")
            }
 */
        }

    }
}

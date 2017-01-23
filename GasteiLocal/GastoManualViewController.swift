//
//  GastoManualViewController.swift
//  ControleDeGastos
//
//  Created by Andre Machado Parente on 3/23/16.
//  Copyright © 2016 Andre Machado Parente. All rights reserved.
//

import UIKit
import WatchConnectivity
import WatchKit
class GastoManualViewController: UIViewController, UIPickerViewDelegate,UIPickerViewDataSource,UITextFieldDelegate,UINavigationBarDelegate {
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var valor: UITextField!
    @IBOutlet weak var nomeGasto: UITextField!
    @IBOutlet weak var categoriaPickerView: UIPickerView!
    @IBOutlet weak var botaoQRCode: UIButton!
    
    
    // variaveis do QRCode
    var valortotal:Double!
    var dataQR: String!
    
    // variaveis internas para controle de tempo
    var dataNs = Date()
    let dateFormatter = DateFormatter()
    let calendar = Calendar.current
    
    // variaveis internas para controle de dados
    var dataStr = String()
    var categoria = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        categoria = "Outros"
        executar = false
        view.backgroundColor = UIColor(patternImage: UIImage(named: "background_blue.png")!)
        
        if (evermelha)
        {
            view.backgroundColor = UIColor(patternImage: UIImage(named: "background_red.png")!)
            
        }
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(GastoManualViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        let navigationBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 53)) // Offset by 20 pixels vertically to take the status bar into account
        
        //navigationBar.backgroundColor = UIColor(red: 105/255, green: 181/255, blue: 120/255, alpha: 0.9)
        navigationBar.barTintColor = UIColor(red: 30/255, green: 30/255, blue: 30/255, alpha: 1)
        navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont(name: "Tsukushi A Round Gothic", size: 18)!]
        navigationBar.delegate = self;
        
        // Create a navigation item with a title
        let navigationItem = UINavigationItem()
        navigationItem.title = "Gasto Manual"
        
        // Create left and right button for navigation item
        let leftButton =  UIBarButtonItem(title: "Voltar", style:   UIBarButtonItemStyle.plain, target: self, action:(#selector(GastoManualViewController.btn_clicked(_:))))
        leftButton.tintColor = UIColor.white
        leftButton.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Tsukushi A Round Gothic", size: 15)!], for: UIControlState())
        
        // Create two buttons for the navigation item
        navigationItem.leftBarButtonItem = leftButton
        // Assign the navigation item to the navigation bar
        navigationBar.items = [navigationItem]
        
        // Make the navigation bar a subview of the current view controller
        self.view.addSubview(navigationBar)
        
        (calendar as NSCalendar).components([.day , .month , .year], from: dataNs)
        
        
        categoriaPickerView.delegate = self
        categoriaPickerView.dataSource = self
        
        valor.delegate = self
        
        dateFormatter.dateFormat = "dd/MM/yyyy"
        dateFormatter.dateStyle = DateFormatter.Style.short
        if valortotal != nil
        {
            valor.text=String(valortotal)
        }
        print(valor.text!)
        valor.keyboardType = .decimalPad
        if dataQR != nil
        {
            dataStr = dataQR
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy"
            let datefromstring = dateFormatter.date(from: dataQR)
            datePicker.date = datefromstring!
            
        }
        else
        {
            let components = (self.calendar as NSCalendar).components([.day , .month , .year], from: self.dataNs)
            self.dataStr = "\(components.day)/\(components.month)/\(components.year)"
        }
        NotificationCenter.default.addObserver(self, selector: #selector(GastoManualViewController.actOnNotificationSaveError), name: NSNotification.Name(rawValue: "notificationSaveError"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(GastoManualViewController.actOnNotificationSaveSuccess), name: NSNotification.Name(rawValue: "notificationSaveSuccess"), object: nil)
        
    }
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    func actOnNotificationSaveError()
    {
        let alert=UIAlertController(title:"Erro", message: "Você não está conectado à internet", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title:"Ok",style: UIAlertActionStyle.default,handler: nil))
        self.present(alert,animated: true, completion: nil)
    }
    func  actOnNotificationSaveSuccess() {
       
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let data = dateFormatter.date(from: self.dataStr)
        userLogged.addGasto(Gasto(nome: nomeGasto.text!, categoria: self.categoria, valor: (Double(valor.text!)?.roundToPlaces(2))!, data: data!))
        executar = true
        self.dismiss(animated: true, completion: nil)
    }
    func btn_clicked(_ sender: UIBarButtonItem) {
        executar = false
        dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "GastoToMain" {
            let vc = segue.destination as! UITabBarController
            vc.selectedIndex = 1
        } else if segue.identifier == "GastoManualToQRCode" {
            let vc = segue.destination as! QRCodeViewController
            vc.delegate = self
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.categoria = userLogged.categories[row]
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return (userLogged.categories.count)
        
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? { //KARINA KARINA KARIAN KARINA
        let titleData = userLogged.categories[row]
        let myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "Tsukushi A Round Gothic", size: 15.0)!,NSForegroundColorAttributeName:UIColor.white])
        return myTitle
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return (userLogged.categories[row])
        
    }
    
    func txtFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return !(textField.placeholder == "Categoria")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
    
    @IBAction func datePickerChanged(_ sender: AnyObject) {
        dataNs = datePicker.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        dataQR = dateFormatter.string(from: dataNs)
       // let dataaux = dataQR.stringByReplacingOccurrencesOfString("/", withString: "/")
//        let fullNameArr = dataQR.componentsSeparatedByString("/")
//        var preferredLanguage = NSLocale.preferredLanguages()[0] as String
        print(datePicker.date)
        print(dataQR)
        dataStr = dataQR
       /* var stringfinal = String()
        if preferredLanguage == "pt-BR"
        {
            stringfinal =  fullNameArr[0] + "/" + fullNameArr [1] + "/" + fullNameArr[2]
        }
        else{
            stringfinal = fullNameArr[1] + "/" + fullNameArr [0] + "/" + "20" + fullNameArr[2]
        }
        dataStr = stringfinal*/
    }
    
    @IBAction func novacategoria(_ sender: UIButton) {
        
        let alert=UIAlertController(title:"Nova categoria", message: "", preferredStyle: UIAlertControllerStyle.alert)
        alert.addTextField(configurationHandler: { (field) -> Void in
            field.placeholder = "Nome"})
        alert.addAction(UIAlertAction(title:"Cancelar",style: UIAlertActionStyle.cancel,handler: nil))
        alert.addAction(UIAlertAction(title:"Ok",style: UIAlertActionStyle.default,handler:{ (action) -> Void in
            let textField = alert.textFields![0] as UITextField
            var naoExiste = true
            for categ in userLogged.categories             {
                if textField.text == categ {
                    let alert2=UIAlertController(title:"Erro", message: "Categoria já existe", preferredStyle: UIAlertControllerStyle.alert)
                    alert2.addAction(UIAlertAction(title:"Ok",style: UIAlertActionStyle.cancel,handler: nil))
                    self.present(alert2,animated: true, completion: nil)
                    naoExiste = false
                }
            }
            if (naoExiste)
            {
                // adiciona na RAM
                userLogged.addCategoriaGasto(textField.text!)
                
                //adiciona no NSUserDefaults
                defaults.set(userLogged.categories, forKey: "categories")
                
                // adiciona no cloud
                DispatchQueue.main.async(execute: {
                    
                    //            DAOCloudKit().addCategory(userLogged)
                })
                
                // atualiza label de categoria
                self.categoria = textField.text!
                // atualiza pickerView
                self.categoriaPickerView.reloadAllComponents()
                self.categoriaPickerView.selectRow((userLogged.categories.count)-1, inComponent: 0, animated: true)
            }
        }))
        executar = false
        
        self.present(alert,animated: true, completion: nil)
    }
    
    @IBAction func apertouBotaoQRCode(_ sender: AnyObject) {
        performSegue(withIdentifier: "GastoManualToQRCode", sender: self)
    }
    
    
    @IBAction func gasteiAction(_ sender: AnyObject) {
        var nome = nomeGasto.text
        let valor2 = valor.text!
        var characters2 = Array(valor2.characters)
        let j = characters2.count
        valor.text = String(characters2)
        let valorgasto = Double(valor.text!)?.roundToPlaces(2)
        
        // nao pode usar variavel sem verificar se eh nil antes
        if(valorgasto == nil) {
            let alert = UIAlertController(title: "Aviso", message: "Você não preencheu o valor do gasto", preferredStyle: UIAlertControllerStyle.alert)
            let alertAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil)
            alert.addAction(alertAction)
            self.present(alert, animated: true, completion: nil)
        } else if(self.dataStr == "" || self.dataStr.isEmpty) {
            let alert = UIAlertController(title: "Aviso", message: "Você não preencheu a data", preferredStyle: UIAlertControllerStyle.alert)
            let alertAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil)
            alert.addAction(alertAction)
            self.present(alert, animated: true, completion: nil)
        } else if(categoria == "") {
            let alert = UIAlertController(title: "Aviso", message: "Você não preencheu a categoria", preferredStyle: UIAlertControllerStyle.alert)
            let alertAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil)
            alert.addAction(alertAction)
            self.present(alert, animated: true, completion: nil)
        } else {
            
            if(nome == nil || nome!.isEmpty) {
                nome = ""
                nomeGasto.text = ""
            }
            for val in 0...j - 1
            {
                if (characters2[val] == ",")
                {
                    characters2[val] = "."
                }
            }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy"
            print(self.dataStr)
            let data = dateFormatter.date(from: self.dataStr)
           // print( "data a ser adicionada!! :::::::::  ",data! )
            var gasto : Gasto? = nil
            if let datafinal = data
            {
            gasto = Gasto(nome: nome!, categoria: self.categoria, valor: valorgasto!, data: datafinal)
            print(gasto?.date)
            }
            else
            {
                gasto = Gasto(nome: nome!, categoria: self.categoria, valor: valorgasto!, data: NSDate() as Date)
                print(gasto?.date)
            }
            //     DAOCloudKit().addGasto(gasto,user: userLogged)
            
            DAOLocal().salvarGasto(gasto!)
            dismiss(animated: true, completion: nil)
            // faz o segue
            var arrayCategories = [String]()
            var arrayValor = [String]()
            var i = 0
            for _ in userLogged.getGastosHoje()
            {
                arrayCategories.append(userLogged.getGastosHoje()[i].category)
                arrayValor.append(String(userLogged.getGastosHoje()[i].value))
                i+=1
            }
           /* if (WCSession.isSupported()) {
                let session = WCSession.default()
                session.delegate = self
                session.activate()
                session.sendMessage(["categorias":[arrayCategories,arrayValor]], replyHandler: {(handler) -> Void in print(handler)}, errorHandler: {(error) -> Void in print(#file,error)})
            }
            else
            {
                print("Nao está conectado ao watch")
            }
 */
            /*  let complicationServer = CLKComplicationServer.sharedInstance()
             for complication in complicationServer.activeComplications {
             complicationServer.reloadTimelineForComplication(complication)
             }
             */
            
        }
    }
}

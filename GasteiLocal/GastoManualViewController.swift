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
class GastoManualViewController: UIViewController, UIPickerViewDelegate,UIPickerViewDataSource,UITextFieldDelegate,UINavigationBarDelegate,WCSessionDelegate {
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var valor: UITextField!
    @IBOutlet weak var nomeGasto: UITextField!
    @IBOutlet weak var categoriaPickerView: UIPickerView!
    @IBOutlet weak var botaoQRCode: UIButton!
    
    
    // variaveis do QRCode
    var valortotal:Double!
    var dataQR: String!
    
    // variaveis internas para controle de tempo
    var dataNs = NSDate()
    let dateFormatter = NSDateFormatter()
    let calendar = NSCalendar.currentCalendar()
    
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
        
        let navigationBar = UINavigationBar(frame: CGRectMake(0, 0, self.view.frame.size.width, 53)) // Offset by 20 pixels vertically to take the status bar into account
        
        //navigationBar.backgroundColor = UIColor(red: 105/255, green: 181/255, blue: 120/255, alpha: 0.9)
        navigationBar.barTintColor = UIColor(red: 30/255, green: 30/255, blue: 30/255, alpha: 1)
        navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont(name: "Tsukushi A Round Gothic", size: 18)!]
        navigationBar.delegate = self;
        
        // Create a navigation item with a title
        let navigationItem = UINavigationItem()
        navigationItem.title = "Gasto Manual"
        
        // Create left and right button for navigation item
        let leftButton =  UIBarButtonItem(title: "Voltar", style:   UIBarButtonItemStyle.Plain, target: self, action:(#selector(GastoManualViewController.btn_clicked(_:))))
        leftButton.tintColor = UIColor.whiteColor()
        leftButton.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Tsukushi A Round Gothic", size: 15)!], forState: UIControlState.Normal)
        
        // Create two buttons for the navigation item
        navigationItem.leftBarButtonItem = leftButton
        // Assign the navigation item to the navigation bar
        navigationBar.items = [navigationItem]
        
        // Make the navigation bar a subview of the current view controller
        self.view.addSubview(navigationBar)
        
        calendar.components([.Day , .Month , .Year], fromDate: dataNs)
        
        
        categoriaPickerView.delegate = self
        categoriaPickerView.dataSource = self
        
        valor.delegate = self
        
        dateFormatter.dateFormat = "dd/MM/yyyy"
        dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        if valortotal != nil
        {
            valor.text=String(valortotal)
        }
        print(valor.text!)
        valor.keyboardType = .DecimalPad
        if dataQR != nil
        {
            dataStr = dataQR
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy"
            let datefromstring = dateFormatter.dateFromString(dataQR)
            datePicker.date = datefromstring!
            
        }
        else
        {
            let components = self.calendar.components([.Day , .Month , .Year], fromDate: self.dataNs)
            self.dataStr = "\(components.day)/\(components.month)/\(components.year)"
        }
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(GastoManualViewController.actOnNotificationSaveError), name: "notificationSaveError", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(GastoManualViewController.actOnNotificationSaveSuccess), name: "notificationSaveSuccess", object: nil)
        
    }
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    func actOnNotificationSaveError()
    {
        let alert=UIAlertController(title:"Erro", message: "Você não está conectado à internet", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title:"Ok",style: UIAlertActionStyle.Default,handler: nil))
        self.presentViewController(alert,animated: true, completion: nil)
    }
    func  actOnNotificationSaveSuccess() {
       
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let data = dateFormatter.dateFromString(self.dataStr)
        userLogged.addGasto(Gasto(nome: nomeGasto.text!, categoria: self.categoria, valor: (Double(valor.text!)?.roundToPlaces(2))!, data: data!))
        executar = true
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    func btn_clicked(sender: UIBarButtonItem) {
        executar = false
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "GastoToMain" {
            let vc = segue.destinationViewController as! UITabBarController
            vc.selectedIndex = 1
        } else if segue.identifier == "GastoManualToQRCode" {
            let vc = segue.destinationViewController as! QRCodeViewController
            vc.delegate = self
        }
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.categoria = userLogged.categories[row]
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return (userLogged.categories.count)
        
    }
    
    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? { //KARINA KARINA KARIAN KARINA
        let titleData = userLogged.categories[row]
        let myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "Tsukushi A Round Gothic", size: 15.0)!,NSForegroundColorAttributeName:UIColor.whiteColor()])
        return myTitle
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return (userLogged.categories[row])
        
    }
    
    func txtFieldShouldBeginEditing(textField: UITextField) -> Bool {
        return !(textField.placeholder == "Categoria")
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
    
    @IBAction func datePickerChanged(sender: AnyObject) {
        dataNs = datePicker.date
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        dataQR = dateFormatter.stringFromDate(dataNs)
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
    
    @IBAction func novacategoria(sender: UIButton) {
        
        let alert=UIAlertController(title:"Nova categoria", message: "", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addTextFieldWithConfigurationHandler({ (field) -> Void in
            field.placeholder = "Nome"})
        alert.addAction(UIAlertAction(title:"Cancelar",style: UIAlertActionStyle.Cancel,handler: nil))
        alert.addAction(UIAlertAction(title:"Ok",style: UIAlertActionStyle.Default,handler:{ (action) -> Void in
            let textField = alert.textFields![0] as UITextField
            var naoExiste = true
            for categ in userLogged.categories             {
                if textField.text == categ {
                    let alert2=UIAlertController(title:"Erro", message: "Categoria já existe", preferredStyle: UIAlertControllerStyle.Alert)
                    alert2.addAction(UIAlertAction(title:"Ok",style: UIAlertActionStyle.Cancel,handler: nil))
                    self.presentViewController(alert2,animated: true, completion: nil)
                    naoExiste = false
                }
            }
            if (naoExiste)
            {
                // adiciona na RAM
                userLogged.addCategoriaGasto(textField.text!)
                
                //adiciona no NSUserDefaults
                defaults.setObject(userLogged.categories, forKey: "categories")
                
                // adiciona no cloud
                dispatch_async(dispatch_get_main_queue(),{
                    
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
        
        self.presentViewController(alert,animated: true, completion: nil)
    }
    
    @IBAction func apertouBotaoQRCode(sender: AnyObject) {
        performSegueWithIdentifier("GastoManualToQRCode", sender: self)
    }
    
    
    @IBAction func gasteiAction(sender: AnyObject) {
        var nome = nomeGasto.text
        let valor2 = valor.text!
        var characters2 = Array(valor2.characters)
        let j = characters2.count
        valor.text = String(characters2)
        let valorgasto = Double(valor.text!)?.roundToPlaces(2)
        
        // nao pode usar variavel sem verificar se eh nil antes
        if(valorgasto == nil) {
            let alert = UIAlertController(title: "Aviso", message: "Você não preencheu o valor do gasto", preferredStyle: UIAlertControllerStyle.Alert)
            let alertAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
            alert.addAction(alertAction)
            self.presentViewController(alert, animated: true, completion: nil)
        } else if(self.dataStr == "" || self.dataStr.isEmpty) {
            let alert = UIAlertController(title: "Aviso", message: "Você não preencheu a data", preferredStyle: UIAlertControllerStyle.Alert)
            let alertAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
            alert.addAction(alertAction)
            self.presentViewController(alert, animated: true, completion: nil)
        } else if(categoria == "") {
            let alert = UIAlertController(title: "Aviso", message: "Você não preencheu a categoria", preferredStyle: UIAlertControllerStyle.Alert)
            let alertAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
            alert.addAction(alertAction)
            self.presentViewController(alert, animated: true, completion: nil)
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
            
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy"
            print(self.dataStr)
            let data = dateFormatter.dateFromString(self.dataStr)
            print( "data a ser adicionada!! :::::::::  ",data )
            let gasto = Gasto(nome: nome!, categoria: self.categoria, valor: valorgasto!, data: data!)
            print(gasto.date)
            //     DAOCloudKit().addGasto(gasto,user: userLogged)
            
            DAOLocal().salvarGasto(gasto)
            dismissViewControllerAnimated(true, completion: nil)
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
            if (WCSession.isSupported()) {
                let session = WCSession.defaultSession()
                session.delegate = self
                session.activateSession()
                session.sendMessage(["categorias":[arrayCategories,arrayValor]], replyHandler: {(handler) -> Void in print(handler)}, errorHandler: {(error) -> Void in print(#file,error)})
            }
            else
            {
                print("Nao está conectado ao watch")
            }
            /*  let complicationServer = CLKComplicationServer.sharedInstance()
             for complication in complicationServer.activeComplications {
             complicationServer.reloadTimelineForComplication(complication)
             }
             */
            
        }
    }
}

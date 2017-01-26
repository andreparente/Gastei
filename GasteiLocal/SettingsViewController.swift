//
//  SettingsViewController.swift
//  ControleDeGastos
//
//  Created by Andre Machado Parente on 3/23/16.
//  Copyright © 2016 Andre Machado Parente. All rights reserved.
//

import UIKit
var alteroulim = false
class SettingsViewController: UIViewController, UINavigationBarDelegate{
    
    @IBOutlet weak var background_image: UIImageView!
    
    var field:UITextField!
    var flagLogout: Bool!
    var mainVC = UIViewController() as? MainViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* view.backgroundColor = UIColor(patternImage: UIImage(named: "background_blue.png")!)
        if (eamarela)
        {
            view.backgroundColor = corAmarela
        }
 */
        if (evermelha)
        {
            //view.backgroundColor = UIColor(patternImage: UIImage(named: "background_red.png")!)
            self.background_image.image = UIImage(named: "background_red.png")
        }
        
        let navigationBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 53)) // Offset by 20 pixels vertically to take the status bar into account
        
        //navigationBar.backgroundColor = UIColor.blackColor()
        navigationBar.barTintColor = UIColor(red: 30/255, green: 30/255, blue: 30/255, alpha: 1)
        navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont(name: "Tsukushi A Round Gothic", size: 18)!]
        navigationBar.delegate = self
        
        // Create a navigation item with a title
        let navigationItem = UINavigationItem()
        navigationItem.title = "Configurações"
        
        // Create left and right button for navigation item
        let leftButton =  UIBarButtonItem(title: "Voltar", style:   UIBarButtonItemStyle.plain, target: self, action: #selector(SettingsViewController.btn_clicked(_:)))
        leftButton.tintColor = UIColor.white
        leftButton.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Tsukushi A Round Gothic", size: 15)!], for: UIControlState())
        
        
        
        // Create two buttons for the navigation item
        navigationItem.leftBarButtonItem = leftButton
        
        // Assign the navigation item to the navigation bar
        navigationBar.items = [navigationItem]
        
        // Make the navigation bar a subview of the current view controller
        self.view.addSubview(navigationBar)
        // Do any additional setup after loading the view.
    }
    
    @IBAction func limite(_ sender: UIButton) {
        
        let alert=UIAlertController(title:" Seu limite é de R$\(userLogged.getLimiteMes())", message: "", preferredStyle: UIAlertControllerStyle.alert)
        alert.addTextField(configurationHandler: { (field) -> Void in
            field.placeholder = "Novo limite mensal"})
        alert.addAction(UIAlertAction(title:"Cancelar",style: UIAlertActionStyle.cancel,handler: nil))
        alert.addAction(UIAlertAction(title:"Ok",style: UIAlertActionStyle.default,handler:{ (action) -> Void in
            let textField = alert.textFields![0] as UITextField
            print("Text field: \(textField.text)")
            userLogged.setLimiteMes(Double(textField.text!)!)
            print("LIMITE DO USUARIO USERLOGGED LOCAL::::", userLogged.limiteMes)
           DAOCloudKit().changeLimit(userLogged)
            alteroulim = true
        }))
        
        
        self.present(alert,animated: true, completion: nil)
    }
    
    func btn_clicked(_ sender: UIBarButtonItem) {
        if alteroulim == true
        {
            executar = true
        }
        else
        {
            executar = false
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func categoria(_ sender: UIButton) {
        let alert=UIAlertController(title:"Nova categoria", message: "", preferredStyle: UIAlertControllerStyle.alert)
        alert.addTextField(configurationHandler: { (field) -> Void in
            field.placeholder = "Nome"})
        alert.addAction(UIAlertAction(title:"Cancelar",style: UIAlertActionStyle.cancel,handler: nil))
        alert.addAction(UIAlertAction(title:"Ok",style: UIAlertActionStyle.default,handler:{ (action) -> Void in
            let textField = alert.textFields![0] as UITextField
            var naoExiste = true
            
            for categ in (userLogged.categories)
            {
                if textField.text == categ {
                    let alert2=UIAlertController(title:"Erro", message: "Categoria já existe.", preferredStyle: UIAlertControllerStyle.alert)
                    alert2.addAction(UIAlertAction(title:"Ok",style: UIAlertActionStyle.cancel,handler: nil))
                    self.present(alert2,animated: true, completion: nil)
                    naoExiste = false
                }
            }
            
            if (naoExiste)
            {
                // adiciona na RAM
                userLogged.addCategoriaGasto(textField.text!)
                
                //adiciona no userDefaults
                defaults.set(userLogged.categories, forKey: "categories")
                
                // adiciona no cloud
                DispatchQueue.main.async(execute: {
                    
                DAOCloudKit().addCategory(userLogged)
                })
            }
        }))
        
        self.present(alert,animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "SettingsToMain" {
            
            let vc = segue.destination as! UITabBarController
            vc.selectedIndex = 1
            
        }
    }
}

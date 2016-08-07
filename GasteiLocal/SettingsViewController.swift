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
        
        let navigationBar = UINavigationBar(frame: CGRectMake(0, 0, self.view.frame.size.width, 53)) // Offset by 20 pixels vertically to take the status bar into account
        
        //navigationBar.backgroundColor = UIColor.blackColor()
        navigationBar.barTintColor = UIColor(red: 30/255, green: 30/255, blue: 30/255, alpha: 1)
        navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont(name: "Tsukushi A Round Gothic", size: 18)!]
        navigationBar.delegate = self
        
        // Create a navigation item with a title
        let navigationItem = UINavigationItem()
        navigationItem.title = "Configurações"
        
        // Create left and right button for navigation item
        let leftButton =  UIBarButtonItem(title: "Voltar", style:   UIBarButtonItemStyle.Plain, target: self, action: #selector(SettingsViewController.btn_clicked(_:)))
        leftButton.tintColor = UIColor.whiteColor()
        leftButton.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Tsukushi A Round Gothic", size: 15)!], forState: UIControlState.Normal)
        
        
        
        // Create two buttons for the navigation item
        navigationItem.leftBarButtonItem = leftButton
        
        // Assign the navigation item to the navigation bar
        navigationBar.items = [navigationItem]
        
        // Make the navigation bar a subview of the current view controller
        self.view.addSubview(navigationBar)
        // Do any additional setup after loading the view.
    }
    
    @IBAction func limite(sender: UIButton) {
        
        let alert=UIAlertController(title:" Seu limite é de R$\(userLogged.getLimiteMes())", message: "", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addTextFieldWithConfigurationHandler({ (field) -> Void in
            field.placeholder = "Novo limite mensal"})
        alert.addAction(UIAlertAction(title:"Cancelar",style: UIAlertActionStyle.Cancel,handler: nil))
        alert.addAction(UIAlertAction(title:"Ok",style: UIAlertActionStyle.Default,handler:{ (action) -> Void in
            let textField = alert.textFields![0] as UITextField
            print("Text field: \(textField.text)")
            userLogged.setLimiteMes(Double(textField.text!)!)
            print("LIMITE DO USUARIO USERLOGGED LOCAL::::", userLogged.limiteMes)
      //      DAOCloudKit().changeLimit(userLogged)
            alteroulim = true
        }))
        
        
        self.presentViewController(alert,animated: true, completion: nil)
    }
    
    func btn_clicked(sender: UIBarButtonItem) {
        if alteroulim == true
        {
            executar = true
        }
        else
        {
            executar = false
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func categoria(sender: UIButton) {
        let alert=UIAlertController(title:"Nova categoria", message: "", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addTextFieldWithConfigurationHandler({ (field) -> Void in
            field.placeholder = "Nome"})
        alert.addAction(UIAlertAction(title:"Cancelar",style: UIAlertActionStyle.Cancel,handler: nil))
        alert.addAction(UIAlertAction(title:"Ok",style: UIAlertActionStyle.Default,handler:{ (action) -> Void in
            let textField = alert.textFields![0] as UITextField
            var naoExiste = true
            
            for categ in (userLogged.categories)
            {
                if textField.text == categ {
                    let alert2=UIAlertController(title:"Erro", message: "Categoria já existe.", preferredStyle: UIAlertControllerStyle.Alert)
                    alert2.addAction(UIAlertAction(title:"Ok",style: UIAlertActionStyle.Cancel,handler: nil))
                    self.presentViewController(alert2,animated: true, completion: nil)
                    naoExiste = false
                }
            }
            
            if (naoExiste)
            {
                // adiciona na RAM
                userLogged.addCategoriaGasto(textField.text!)
                
                //adiciona no userDefaults
                defaults.setObject(userLogged.categories, forKey: "categories")
                
                // adiciona no cloud
                dispatch_async(dispatch_get_main_queue(),{
                    
    //                DAOCloudKit().addCategory(userLogged)
                })
            }
        }))
        
        self.presentViewController(alert,animated: true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "SettingsToMain" {
            
            let vc = segue.destinationViewController as! UITabBarController
            vc.selectedIndex = 1
            
        }
    }
}

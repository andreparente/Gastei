//
//  LoginCLoudViewController.swift
//  ControleDeGastos
//
//  Created by Andre Machado Parente on 7/7/16.
//  Copyright © 2016 Andre Machado Parente. All rights reserved.
//

import UIKit

var auxID: String!
var aux8 = 0
class LoginCLoudViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        aux8 = 0
        NotificationCenter.default.addObserver(self, selector: #selector(LoginCLoudViewController().actonNotificationSucessGetID), name: NSNotification.Name(rawValue: "notificationSucessGetId"), object: nil)
    }
    
    
    @IBAction func loginActino(_ sender: AnyObject) {
        defaults.set(true, forKey: "Logged")
    }
    
    func actonNotificationSucessGetID()
    {
        
        
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    @IBAction func pularLoginAction(_ sender: UIButton) {
        defaults.set(false, forKey: "Cloud")
        defaults.set(true, forKey: "Logged")
        self.performSegue(withIdentifier: "LoginCloudToMain", sender: self)
    }
    
}

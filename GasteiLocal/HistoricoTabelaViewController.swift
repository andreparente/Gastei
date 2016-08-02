//
//  HistoricoTabelaViewController.swift
//  ControleDeGastos
//
//  Created by Andre Machado Parente on 3/23/16.
//  Copyright © 2016 Andre Machado Parente. All rights reserved.
//

import UIKit
import Foundation

class HistoricoTabelaViewController: UIViewController, UIGestureRecognizerDelegate,UITableViewDelegate,UITableViewDataSource {
    
    
    @IBOutlet weak var botaoOrdenar: UIButton!
    @IBOutlet weak var botaoFiltrar: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    var gastos = [Gasto]()
    var ordenou = false
    var filtrou = false
    override func viewDidLoad() {
        
        
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.clearColor()
        //executar = false
        //view.backgroundColor = UIColor(patternImage: UIImage(named: "background_blue.png")!)
        //viewSuperior.backgroundColor = UIColor(patternImage: UIImage(named: "background_blue.png")!)
        tableView.frame = (CGRectMake(0,44,view.frame.width,view.frame.height))
        tableView.estimatedRowHeight = 50
        // apenas para poder enxergar os botoes
        self.botaoFiltrar.backgroundColor = UIColor(red: 52/255, green: 52/255, blue: 52/255, alpha: 1)
        self.botaoOrdenar.backgroundColor = UIColor(red: 52/255, green: 52/255, blue: 52/255, alpha: 1)
        self.botaoFiltrar.titleLabel?.textColor = UIColor.whiteColor()
        self.botaoOrdenar.titleLabel?.textColor = UIColor.whiteColor()
        /*   if (eamarela)
         {
         view.backgroundColor = corAmarela
         viewSuperior.backgroundColor = corAmarela
         }
         */
        if (evermelha)
        {
            view.backgroundColor = UIColor(patternImage: UIImage(named: "background_red.png")!)
        }
        if eazul{
            view.backgroundColor = UIColor(patternImage: UIImage(named: "background_blue.png")!)
        }
        
        
        
       // tableView.registerClass(TableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    override func viewWillAppear(animated: Bool) {
        // executar = false
        
        if(ordenou || filtrou) {
            
        }
        else {
            gastosGlobal = userLogged.gastos
            let quickSorter = QuickSorterGasto()
            quickSorter.v = gastosGlobal
            quickSorter.a = userLogged.arrayGastos
            quickSorter.callQuickSort("Data", decrescente: true)
            gastosGlobal = quickSorter.v
            userLogged.arrayGastos = quickSorter.a
            userLogged.gastos = gastosGlobal
        }
        
        self.tableView.reloadData()
        tableView.backgroundColor = UIColor.clearColor()
        
        if (evermelha)
        {
            //self.background_image.image = UIImage(named: "background_red.png")
            
            view.backgroundColor = UIColor(patternImage: UIImage(named: "background_red.png")!)
        }
        if (eazul)
        {
            //self.background_image.image = UIImage(named: "background_blue.png")
            view.backgroundColor = UIColor(patternImage: UIImage(named: "background_blue.png")!)
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    //funçao que diz a quantidade de células
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let cellsNumber = gastosGlobal.count
        return (cellsNumber > 0) ? cellsNumber : 1
    }
    
    //funçao que seta as células
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell =
            self.tableView.dequeueReusableCellWithIdentifier(
                "cell", forIndexPath: indexPath)
                as! TableViewCell
        let cellsNumber = gastosGlobal.count
        
        
        cell.backgroundColor = UIColor.clearColor()
        /*let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        cell.selectedBackgroundView = backgroundView*/
        
        if (cellsNumber > 0) {
            
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy"
            
            cell.hideInfo(false)
            cell.labelNomeGasto.text = "\(gastosGlobal[indexPath.row].name!)"
            cell.labelCat.text = "\(gastosGlobal[indexPath.row].category)"
            cell.labelValor.text = "R$ " + String(gastosGlobal[indexPath.row].value)
            
            //let arrayData = dateFormatter.stringFromDate(gastosGlobal[indexPath.row].date).componentsSeparatedByString("/")
            cell.labelData.text = dateFormatter.stringFromDate(gastosGlobal[indexPath.row].date)
            
            print(indexPath.row)
            print(cell.labelCat.text)
            print(cell.labelValor.text)
        }
        else {
            print("entrou no sem gastos!")
            cell.hideInfo(true)
            cell.labelSemGastos.text = "Nenhum gasto para exibir!"
            cell.labelSemGastos.font = UIFont(name: "Tsukushi A Round Gothic", size: 16)
        }
        return cell
    }
    
    //funçao que é chamada ao clicar em determinada célula
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("You selected cell #\(indexPath.row)!")
    }
    
    @IBAction func apertouBotaoOrdenar(sender: AnyObject) {
        performSegueWithIdentifier("HistoricoTabelaToOrdenar", sender: nil)
    }
    
    @IBAction func apertouBotaoFiltrar(sender: AnyObject) {
        performSegueWithIdentifier("HistoricoTabelaToFiltrar", sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "HistoricoTabelaToFiltrar" {
            let destino = segue.destinationViewController as! FiltrarViewController
            destino.delegate = self
            
        } else if segue.identifier == "HistoricoTabelaToOrdenar" {
            let destino = segue.destinationViewController as! OrdenarViewController
            destino.delegate = self
            
        }
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if userLogged.gastos.count > 0
        {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            // handle delete (by removing the data from your array and updating the tableview)
            if(filtrou) {
               let gasto = gastosGlobal[indexPath.row]
                if let index = userLogged.gastos.indexOf(gasto) {
                    
              //      DAOCloudKit().deleteGasto(userLogged.arrayGastos[index], user: userLogged,index: index)
                    gastosGlobal.removeAtIndex(index)
                    userLogged.gastos.removeAtIndex(index)
                    tableView.reloadData()
                    executar = true
                }
            }
            else {
           //     DAOCloudKit().deleteGasto(userLogged.arrayGastos[indexPath.row], user: userLogged,index: indexPath.row)
                gastosGlobal.removeAtIndex(indexPath.row)
                userLogged.gastos = gastosGlobal
                tableView.reloadData()
                executar = true
            }
            
        }
        }
    }
}

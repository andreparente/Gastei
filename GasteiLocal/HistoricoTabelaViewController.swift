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
        tableView.backgroundColor = UIColor.clear
        tableView.frame = (CGRect(x: 0,y: 44,width: view.frame.width,height: view.frame.height))
        tableView.estimatedRowHeight = 50
        // apenas para poder enxergar os botoes
        self.botaoFiltrar.backgroundColor = UIColor(red: 52/255, green: 52/255, blue: 52/255, alpha: 1)
        self.botaoOrdenar.backgroundColor = UIColor(red: 52/255, green: 52/255, blue: 52/255, alpha: 1)
        self.botaoFiltrar.titleLabel?.textColor = UIColor.white
        self.botaoOrdenar.titleLabel?.textColor = UIColor.white
       
        if (evermelha) {
            view.backgroundColor = UIColor(patternImage: UIImage(named: "background_red.png")!)
        }
        if eazul{
            view.backgroundColor = UIColor(patternImage: UIImage(named: "background_blue.png")!)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
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
        tableView.backgroundColor = UIColor.clear
        
        if (evermelha) {
            
            view.backgroundColor = UIColor(patternImage: UIImage(named: "background_red.png")!)
        }
        if (eazul) {
            view.backgroundColor = UIColor(patternImage: UIImage(named: "background_blue.png")!)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    //funçao que diz a quantidade de células
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let cellsNumber = gastosGlobal.count
        return (cellsNumber > 0) ? cellsNumber : 1
    }
    
    //funçao que seta as células
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell =
            self.tableView.dequeueReusableCell(
                withIdentifier: "cell", for: indexPath)
                as! TableViewCell
        let cellsNumber = gastosGlobal.count
        
        
        cell.backgroundColor = UIColor.clear
        
        if (cellsNumber > 0) {
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy"
            
            cell.hideInfo(false)
            cell.labelNomeGasto.text = "\(gastosGlobal[indexPath.row].name!)"
            cell.labelCat.text = "\(gastosGlobal[indexPath.row].category)"
            cell.labelValor.text = "R$ " + String(gastosGlobal[indexPath.row].value)
            
            cell.labelData.text = dateFormatter.string(from: gastosGlobal[indexPath.row].date as Date)
            
            print(indexPath.row)
            print(cell.labelCat.text!)
            print(cell.labelValor.text!)
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
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You selected cell #\(indexPath.row)!")
    }
    
    @IBAction func apertouBotaoOrdenar(_ sender: AnyObject) {
        performSegue(withIdentifier: "HistoricoTabelaToOrdenar", sender: nil)
    }
    
    @IBAction func apertouBotaoFiltrar(_ sender: AnyObject) {
        performSegue(withIdentifier: "HistoricoTabelaToFiltrar", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "HistoricoTabelaToFiltrar" {
            let destino = segue.destination as! FiltrarViewController
            destino.delegate = self
            
        } else if segue.identifier == "HistoricoTabelaToOrdenar" {
            let destino = segue.destination as! OrdenarViewController
            destino.delegate = self
            
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if userLogged.gastos.count > 0 {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            // handle delete (by removing the data from your array and updating the tableview)
            if(filtrou) {
               let gasto = gastosGlobal[indexPath.row]
                if let index = userLogged.gastos.index(of: gasto) {
                    
                    DAOCloudKit().deleteGasto(userLogged.arrayGastos[index], user: userLogged,index: index)
                    gastosGlobal.remove(at: index)
                    userLogged.gastos.remove(at: index)
                    tableView.reloadData()
                    executar = true
                }
            }
            else {
              DAOCloudKit().deleteGasto(userLogged.arrayGastos[indexPath.row], user: userLogged,index: indexPath.row)
                gastosGlobal.remove(at: indexPath.row)
                userLogged.gastos = gastosGlobal
                tableView.reloadData()
                executar = true
                }
            
           }
        }
    }
}

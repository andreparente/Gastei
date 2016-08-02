//
//  OrdenarViewController.swift
//  ControleDeGastos
//
//  Created by Caio Valente on 03/04/16.
//  Copyright © 2016 Andre Machado Parente. All rights reserved.
//

import UIKit

class OrdenarViewController: UIViewController, UIPickerViewDelegate,UIPickerViewDataSource {
    
    var delegate = HistoricoTabelaViewController()
    var decrescente = false
    
    @IBOutlet weak var pickerTipoOrdenacao: UIPickerView!
    @IBOutlet weak var switchDecrescente: UISwitch!
    
    @IBOutlet weak var botaoCancelar: UIButton!
    @IBOutlet weak var botaoSalvar: UIButton!
    @IBOutlet weak var background_image: UIImageView!
    
    var ordenacoes = [String]()
    var ordenacaoEscolhida = String()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // linkando funcao ao switch
        switchDecrescente.addTarget(self, action: #selector(OrdenarViewController.switchClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        // altera switch para o valor atual
        switchDecrescente.setOn(self.decrescente, animated: true)
        
        pickerTipoOrdenacao.delegate = self
        pickerTipoOrdenacao.dataSource = self
        
        // adiciona opcoes de ordenacao
        self.ordenacoes.append("Data")
        self.ordenacoes.append("Valor")
        self.ordenacoes.append("Nome")
        
        // inicializa ordenacao escolhida
        self.ordenacaoEscolhida = self.ordenacoes[0]
        
        // pinta texto dos botoes
        botaoCancelar.titleLabel!.textColor = UIColor.whiteColor()
        botaoSalvar.titleLabel!.textColor = UIColor.whiteColor()
        
        view.backgroundColor = UIColor(patternImage: UIImage(named: "background_blue.png")!)
      /*  if (eamarela)
        {
            view.backgroundColor = corAmarela
        }
 */
        if (evermelha)
        {
            //self.background_image.image = UIImage(named: "background_red.png")
            view.backgroundColor = UIColor(patternImage: UIImage(named: "background_red.png")!)
        }
    }
    
    func switchClicked(sender:UIButton)
    {
        dispatch_async(dispatch_get_main_queue(), {
            self.decrescente = !self.decrescente
            print (self.decrescente)
        });
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.ordenacoes.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.ordenacoes[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.ordenacaoEscolhida = self.ordenacoes[row]
    }
    
    //karina - funcao para deixar a fonte do picker branca
    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let titleData = ordenacoes[row]
        let myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "Tsukushi A Round Gothic", size: 15.0)!,NSForegroundColorAttributeName:UIColor.whiteColor()])
        return myTitle
    }
    
    @IBAction func apertouBotaoCancelar(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func apertouBotaoSalvar(sender: AnyObject) {
        gastosGlobal = userLogged.gastos
        let quickSorter = QuickSorterGasto()
        quickSorter.v = gastosGlobal
        quickSorter.a = userLogged.arrayGastos
        quickSorter.callQuickSort(self.ordenacaoEscolhida, decrescente: self.decrescente)
        gastosGlobal = quickSorter.v
        userLogged.arrayGastos = quickSorter.a
        userLogged.gastos = gastosGlobal
        delegate.ordenou = true
        // altera os dados da historicoTabela
        
        // desfaz o segue
        dismissViewControllerAnimated(true, completion: nil)
    }
}

//
//  FiltrarViewController.swift
//  ControleDeGastos
//
//  Created by Caio Valente on 03/04/16.
//  Copyright © 2016 Andre Machado Parente. All rights reserved.
//

import UIKit

class FiltrarViewController: UIViewController,UIPickerViewDelegate,UIPickerViewDataSource,UITextFieldDelegate {
    
    @IBOutlet weak var textValorMin: UITextField!
    @IBOutlet weak var textValorMax: UITextField!
    
    @IBOutlet weak var pickerDataMin: UIDatePicker!
    @IBOutlet weak var pickerDataMax: UIDatePicker!
    
    @IBOutlet weak var pickerCategorias: UIPickerView!
    
    @IBOutlet weak var botaoCancelar: UIButton!
    @IBOutlet weak var botaoSalvar: UIButton!
    
    @IBOutlet weak var background_image: UIImageView!
    
    var categoriaSelecionada : String! // armazena o valor do pickerView categorias
    var categorias = [String]()
    var delegate = HistoricoTabelaViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(FiltrarViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        view.backgroundColor = UIColor(patternImage: UIImage(named: "background_blue.png")!)
  
        if (evermelha)
        {
            //self.background_image.image = UIImage(named: "background_red.png")
            view.backgroundColor = UIColor(patternImage: UIImage(named: "background_red.png")!)
        }
        
        // inicialmente, o vetor eh o do usuario
        gastosGlobal = userLogged.getGastos()
        
        // preenche vetor de categorias e adiciona "Todas"
        self.categorias.append("Todas")
        self.categorias.append(contentsOf: userLogged.getCategorias())
        
        // inicialmente, o valor da categoria selecionada eh Todas
        self.categoriaSelecionada = "Todas"
        
        pickerCategorias.delegate = self
        pickerCategorias.dataSource = self
        
        // configurando os valores iniciais dos pickerView de data
        // pega a data de hoje e seus components
        let dataHoje = Date()
        var components = (Calendar.current as NSCalendar).components([.day, .month, .year], from: dataHoje)
        // altera o dia pra 1
        components.day = 1
        // pega a data gerada com dia 1
        let primeiroDiaMes = Date().createFromDate(components.day!, mes: components.month!, ano: components.year!)
        // altera o pickerDate minimo
        self.pickerDataMin.setDate(primeiroDiaMes, animated: false)
        
        botaoCancelar.titleLabel!.textColor = UIColor.white
        botaoSalvar.titleLabel!.textColor = UIColor.white
        textValorMax.delegate = self
        textValorMin.delegate = self
        textValorMin.keyboardType = .decimalPad
        textValorMax.keyboardType = .decimalPad
    }
    
    @IBAction func apertouBotaoCancelar(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func apertouBotaoSalvar(_ sender: AnyObject) {
        // filtros de valor minimo e maximo
        DAOLocal().loadGastos()
        print(gastosGlobal)
        let minVal = (textValorMin.text!).toDouble()!
        let maxVal = (textValorMax.text!).toDouble()!
        if (!minVal.isZero && !maxVal.isZero) {
            gastosGlobal = filtraValor( minVal, max: maxVal, gastos: gastosGlobal )
            
        } else if (!minVal.isZero) {
            gastosGlobal = filtraValorMin( minVal, gastos: gastosGlobal )
        } else if (!maxVal.isZero) {
            gastosGlobal = filtraValorMax( maxVal, gastos: gastosGlobal)
        }
        
        // filtro de categorias
        if (categoriaSelecionada != "Todas") {
            gastosGlobal = filtraCategoria(self.categoriaSelecionada, gastos: gastosGlobal)
            
        }
        
        // filtro de data
        gastosGlobal =  filtroData(pickerDataMin.date, fim: pickerDataMax.date, gastos: gastosGlobal)
        
        // altera os dados da historicoTabela
        delegate.filtrou = true
        // desfaz o segue
        print(gastosGlobal)
        dismiss(animated: true, completion: nil)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.categorias.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.categorias[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        categoriaSelecionada = self.categorias[row]
    }
    
    //karina - funcao para deixar a fonte do picker branca
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let titleData = categorias[row]
        let myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "Tsukushi A Round Gothic", size: 15.0)!,NSForegroundColorAttributeName:UIColor.white])
        return myTitle
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
    
}

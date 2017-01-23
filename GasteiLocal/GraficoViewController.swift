
//
//  GraficoViewController.swift
//  ControleDeGastos
//
//  Created by Andre Machado Parente on 3/23/16.
//  Copyright © 2016 Andre Machado Parente. All rights reserved.
//
import UIKit
import Charts

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class GraficoViewController: UIViewController,ChartViewDelegate,UITextFieldDelegate {
    
    // AQUI ELE CRIA A VIEW PRO GRAFICO
    @IBOutlet weak var chartView: PieChartView!
    
    
    @IBOutlet weak var dataMesTextField: UITextField!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var limiteLabel: UILabel!
    @IBOutlet weak var pickermesano: MonthYearPickerView!
    @IBOutlet weak var background_image: UIImageView!
    
    var gastos: [Gasto]!
    var total = 0.0
    var dataNs = Date()
    var dateFormatter = DateFormatter()
    let calendar = Calendar.current
    var dataString: String!
    var vetorFinal: [Double] = []
    var vetorFinalCat: [String] = []
    var vetorGastosMes: [Gasto] = []
    var vetorFinalCatMes: [String] = []
    var vetorFinalGastosMes: [Double] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pickermesano.grafico = self
        if (eazul) {
            //view.backgroundColor = UIColor(patternImage: UIImage(named: "background_blue.png")!)
            self.background_image.image = UIImage(named: "background_blue.png")
        }
        /*   if (eamarela)
         {
         view.backgroundColor = corAmarela
         }
         */
        if (evermelha)
        {
            //view.backgroundColor = UIColor(patternImage: UIImage(named: "background_red.png")!)
            self.background_image.image = UIImage(named: "background_red.png")
        }
        
        dataMesTextField.delegate = self
        dataMesTextField.font = UIFont(name: "Tsukushi A Round Gothic", size: 16)
        pickermesano.isHidden = true
        dataMesTextField.inputView = pickermesano
        dateFormatter.dateStyle = DateFormatter.Style.short
        
        
        (calendar as NSCalendar).components([.year , .month], from: dataNs)
        chartView.delegate = self
        chartView.backgroundColor = UIColor(white: 1, alpha: 0)
        chartView.holeColor = UIColor(white: 1, alpha: 0)
    }
    
    //Funcao para organizar o grafico
    func organizaVetores(_ usuario: User) -> ([Double],[String]) {
        
        var vetValAux = [Double?](repeating: nil,count: userLogged.categories.count)
        var vetValAux2: [Double] = []
        var vetCatAux: [String] = []
        for i in 0..<userLogged.categories.count  {
            vetValAux[i] = 0
        }
        
        print( " VETOR QUANTIDADE DE CATEGORIAS E VALORES ZERADOS: ", vetValAux)
        
        for i in 0..<userLogged.categories.count {
            
            for gasto in usuario.gastos {
                if(gasto.category == usuario.categories[i]) {
                    if(existeCategoria(vetCatAux, categoria: gasto.category) == false) {
                        vetCatAux.append(gasto.category)
                    }
                    
                    vetValAux[i] = vetValAux[i]! + gasto.value
                    
                }
            }
        }
        
        for i in 0..<vetValAux.count {
            
            if(vetValAux[i] > 0) {
                vetValAux2.append(vetValAux[i]!)
            }
        }
        
        return (vetValAux2,vetCatAux)
    }
    
    func existeCategoria(_ vetor: [String],categoria: String) -> Bool {
        
        for auxVet in vetor {
            if(auxVet == categoria) {
                return true
            }
        }
        return false
    }
    
    func organizaVetoresMes(_ usuario: User, gastosMes: [Gasto]) -> ([Double],[String]) {
        
        
        
        var vetCatAux: [String] = []
        var vetValAux: [Double] = []
        for i in 0..<gastosMes.count {
            
            for categorias in userLogged.getCategorias()  {
                if(gastosMes[i].category == categorias) {
                    if(!existeCategoria(vetCatAux, categoria: categorias)) {
                        vetCatAux.append(categorias)
                        vetValAux.append(0)
                    }
                }
            }
        }
        
        for i in 0..<vetCatAux.count {
            for valGasto in gastosMes {
                if(valGasto.category == vetCatAux[i]) {
                    vetValAux[i] = vetValAux[i] + valGasto.value
                }
            }
        }
        
        return (vetValAux,vetCatAux)
        
        
    }
    
    
    
    //FUNCAO QUE PRINTA LIMITE
    func printaLimite(_ usuario: User) {
        
        if(usuario.limiteMes == 0) {
            
            limiteLabel.isHidden = true
        }
        else {
            //NO DATA TEXT OCORRE QUANDO NAO TEM DADOS NO GRAFICO
            chartView.noDataText = "Você não possui nenhum gasto!"
            chartView.infoTextColor = UIColor.white
            chartView.infoFont = UIFont(name: "Tsukushi A Round Gothic", size: 16)
            chartView.delegate = self
            chartView.animate(xAxisDuration: 1)
            totalLabel.isHidden = true
        }
    }
    
    
    //FUNCAO QUE SETTA TODO O GRAFICO
    func setPieChart(_ dataPoints: [String], values: [Double]) {
        
        
        if(values.count == 0) {
            chartView.clear()
        }
        else {
            
            
            var dataEntries: [ChartDataEntry] = []
            chartView.descriptionText = ""
            //ESSE FOR PREENCHE O VETOR DE ENTRADA DE DADOS, PRA CADA INDEX,
            for i in 0..<values.count {
                let dataEntry = ChartDataEntry(value: values[i].roundToPlaces(2), xIndex: i)
                dataEntries.append(dataEntry)
            }
            
            //ISSO EU NAO ENTENDI MUITO BEM MAS FUNCIONA
            let chartDataSet = PieChartDataSet(yVals: dataEntries, label: "")
            
            var r, g, b: CGFloat!
            
            chartDataSet.colors.removeAll()
            
            for i in 0...userLogged.categories.count {
                
                if (eazul) {
                    r = CGFloat(Double(i)*10 + 64)
                    g = CGFloat(Double(i)*20 + 138)
                    b = CGFloat(Double(i)*30 + 202)
                }
                    
                else if (evermelha) {
                    r = CGFloat(Double(i)*10 + 146)
                    g = CGFloat(Double(i)*20 + 16)
                    b = CGFloat(Double(i)*30 + 16)
                }
                
                chartDataSet.colors.append(NSUIColor(red: r/255, green: g/255, blue: b/255, alpha: 1))
            }
            
            let chartData = PieChartData(xVals: dataPoints, dataSet: chartDataSet)
            chartView.data = chartData
            totalLabel.text = "Total desse mês: R$ "+String(total)
            totalLabel.isHidden = false
        }
        
        
    }
    
    // FUNCAO CHAMADA QUANDO CLICAMOS EM CIMA DE UM PEDACO DA PIZZA
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, dataSetIndex: Int, highlight: ChartHighlight) {
        print("\(entry.value) in \(userLogged.categories[entry.xIndex])")
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if(textField.placeholder == "Escolha o mês e ano") {
            //dataMesDatePicker.hidden = false
            pickermesano.isHidden = false
            return false
        }
        else {
            pickermesano.isHidden = true
        }
        return true
    }
    override func viewWillAppear(_ animated: Bool) {
        //executar = false
        total = 0.0
        
        printaLimite(userLogged)
        
        if(userLogged.gastos.count == 0) {
            
            //NO DATA TEXT OCORRE QUANDO NAO TEM DADOS NO GRAFICO
            chartView.clear()
            
            chartView.noDataText = "Você não possui nenhum gasto!"
            chartView.infoTextColor = UIColor.white
            chartView.infoFont = UIFont(name: "Tsukushi A Round Gothic", size: 16)
            chartView.delegate = self
            chartView.animate(xAxisDuration: 1)
            totalLabel.isHidden = true
            
        }
        else {
            
            let year = (Calendar(identifier: Calendar.Identifier.gregorian) as NSCalendar).component(.year, from: Date())
            let month = (Calendar(identifier: Calendar.Identifier.gregorian) as NSCalendar).component(.month, from: Date())
            
            for gasto in userLogged.getGastosMes(month, ano: year){
                total = total + gasto.value
            }
            print("--------- TOTAL DE TODOS OS GASTOS DO USUARIO DO Mes:  ", total)
            (vetorFinal,vetorFinalCat) = organizaVetoresMes(userLogged,gastosMes:
                userLogged.getGastosUltimoMês())
            setPieChart(vetorFinalCat, values: vetorFinal)
            
        }
        if (evermelha)
        {
            //view.backgroundColor = UIColor(patternImage: UIImage(named: "background_red.png")!)
            self.background_image.image = UIImage(named: "background_red.png")
            
        }
        if eazul{
            //view.backgroundColor = UIColor(patternImage: UIImage(named: "background_blue.png")!)
            self.background_image.image = UIImage(named: "background_blue.png")
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        pickermesano.isHidden = true
        dataMesTextField.text = ""
    }
}


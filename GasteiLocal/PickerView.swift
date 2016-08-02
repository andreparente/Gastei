//
//  PickerView.swift
//  ControleDeGastos
//
//  Created by Felipe Viberti on 5/31/16.
//  Copyright © 2016 Andre Machado Parente. All rights reserved.
//

import Foundation

import UIKit

class MonthYearPickerView: UIPickerView, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var grafico = GraficoViewController()
    
    let months = ["Janeiro", "Fevereiro", "Março", "Abril", "Maio", "Junho", "Julho", "Agosto", "Setembro", "Outubro", "Novembro", "Dezembro"]
    var years: [Int]!
    var vetorFinalCatMes: [String] = []
    var vetorFinalGastosMes: [Double] = []
    var vetorGastosMes: [Gasto] = []
    var month: Int = 0 {
        didSet {
            selectRow(month-1, inComponent: 0, animated: false)
        }
    }
    
    var year: Int = 0 {
        didSet {
            selectRow(years.indexOf(year)!, inComponent: 1, animated: true)
        }
    }
    
    var onDateSelected: ((month: Int, year: Int) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonSetup()
    }
    
    func commonSetup() {
        var years: [Int] = []
        if years.count == 0 {
            var year = NSCalendar(identifier: NSCalendarIdentifierGregorian)!.component(.Year, fromDate: NSDate())
            for _ in 1...2 {
                years.append(year)
                year += 1
            }
        }
        self.years = years
        
        self.delegate = self
        self.dataSource = self
        
        let month = NSCalendar(identifier: NSCalendarIdentifierGregorian)!.component(.Month, fromDate: NSDate())
        self.selectRow(month-1, inComponent: 0, animated: false)
    }
    
    // Mark: UIPicker Delegate / Data Source
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0:
            return months[row]
        case 1:
            return "\(years[row])"
        default:
            return nil
        }
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return months.count
        case 1:
            return years.count
        default:
            return 0
        }
    }
    
    //karina - funcao para deixar a fonte do picker branca
    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        if component == 0 {
        let titleData = months[row]
        let myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "Tsukushi A Round Gothic", size: 15.0)!,NSForegroundColorAttributeName:UIColor.whiteColor()])
        return myTitle
        }
        
        
        else {
        let titleData2 = String(years[row])
        let myTitle = NSAttributedString(string: titleData2, attributes: [NSFontAttributeName:UIFont(name: "Tsukushi A Round Gothic", size: 15.0)!,NSForegroundColorAttributeName:UIColor.whiteColor()])
        return myTitle
        }
    }
    

    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let month = self.selectedRowInComponent(0)+1
        var total = 0.0
        let year = years[self.selectedRowInComponent(1)]
        if let block = onDateSelected {
            block(month: month, year: year)
        }
        self.month = month
        self.year = year
        let mes :Int =  month
        let ano :Int = year
        vetorGastosMes = userLogged.getGastosMes(mes, ano: ano)
        (vetorFinalGastosMes,vetorFinalCatMes) = GraficoViewController().organizaVetoresMes(userLogged, gastosMes: vetorGastosMes)
        
        if(vetorFinalGastosMes.count == 0) {
            grafico.chartView.clear()
            grafico.chartView.noDataText = "Você não possui nenhum gasto em \(months[self.month-1])"
        }
        
        else {
            grafico.setPieChart(vetorFinalCatMes, values: vetorFinalGastosMes)
            grafico.dataMesTextField.text = "\(mes)" + " " + "\(ano)"
            
            for gasto in userLogged.getGastosMes(month, ano: year){
                total = total + gasto.value
            }
        }
        
        grafico.totalLabel.text = "Total desse mês: R$" + String(total)
    }
    
}
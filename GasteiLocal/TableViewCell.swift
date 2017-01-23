//
//  File.swift
//  ControleDeGastos
//
//  Created by Andre Machado Parente on 4/2/16.
//  Copyright © 2016 Andre Machado Parente. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var labelNomeGasto: UILabel!
    @IBOutlet weak var labelData: UILabel!
    @IBOutlet weak var labelValor: UILabel!
    @IBOutlet weak var labelSemGastos: UILabel!
    @IBOutlet weak var labelCat: UILabel!
    
    func hideInfo (_ status: Bool) {
        self.labelCat.isHidden = status
        self.labelData.isHidden = status
        self.labelValor.isHidden = status
        self.labelNomeGasto.isHidden = status
        self.labelSemGastos.isHidden = !status
    }
    
}

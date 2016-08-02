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
    
    func hideInfo (status: Bool) {
        self.labelCat.hidden = status
        self.labelData.hidden = status
        self.labelValor.hidden = status
        self.labelNomeGasto.hidden = status
        self.labelSemGastos.hidden = !status
    }
    
}

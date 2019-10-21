//
//  Ligand.swift
//  Swifty Protein
//
//  Created by Serhii KAREV on 9/16/19.
//  Copyright © 2019 MacBook Pro. All rights reserved.
//

import Foundation

class Ligand {
    
    var name: String
    var atoms: [Atom]
    
    init(name: String, atoms: [Atom]) {
        self.name = name
        self.atoms = atoms
    }
}

//
//  Atom.swift
//  Swifty Protein
//
//  Created by Serhii KAREV on 9/16/19.
//  Copyright © 2019 MacBook Pro. All rights reserved.
//

import Foundation

class Atom {
    
    var id: String
    var name: String
    
    var x: Float
    var y: Float
    var z: Float
    
    var connections: [Atom] = []
    
    init(id: String, name: String, x: Float, y: Float, z: Float) {
        self.id = id
        self.name = name
        self.x = x
        self.y = y
        self.z = z
    }
}

//
//  SceneViewController.swift
//  Swifty Protein
//
//  Created by Serhii KAREV on 9/16/19.
//  Copyright © 2019 MacBook Pro. All rights reserved.
//

import UIKit
import SceneKit

class SceneViewController: UIViewController {
    
    var scnScene: SCNScene!
    var cameraNode: SCNNode!
    var ligand: Ligand?
    
    @IBOutlet weak var scnView: SCNView!
    
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var xLabel: UILabel!
    @IBOutlet weak var yLabel: UILabel!
    @IBOutlet weak var zLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = ligand?.name
        let rightBarButton1 = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareButtonPressed(sender:)))
        let rightBarButton2 = UIBarButtonItem(barButtonSystemItem: .bookmarks, target: self, action: #selector(webButtonPressed(sender:)))
        navigationItem.rightBarButtonItems = [rightBarButton1, rightBarButton2]
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector (handleTap(recognizer:)))
        scnView.addGestureRecognizer(tapRecognizer)
        
        setupInfoView()
        setupScene()
        setupCamera()
        createAtoms()
        
    }
    
    @objc func shareButtonPressed(sender:  UIView) {
        UIGraphicsBeginImageContextWithOptions(self.view.frame.size, true, 0.0)
        self.view.drawHierarchy(in: self.view.frame, afterScreenUpdates: false)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        if let image = img {
            let activityController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
            self.present(activityController, animated: true, completion: nil)
        }
        
    }
    
    @objc func webButtonPressed(sender: UIView) {
        performSegue(withIdentifier: "goToWeb", sender: nil)
    }
    
    @objc func handleTap(recognizer: UITapGestureRecognizer){
        guard recognizer.view != nil else { return }
        
        if recognizer.state == .ended {
            let location: CGPoint = recognizer.location(in: scnView)
            let hits = self.scnView.hitTest(location, options: nil)
            if hits.isEmpty == false {
                if let name = hits.first!.node.name {
                    nameLabel.text = name
                    xLabel.text = "x = " + String(hits.first!.node.position.x)
                    yLabel.text = "y = " + String(hits.first!.node.position.y)
                    zLabel.text = "z = " + String(hits.first!.node.position.z)
                    infoView.isHidden = false
                    
                    hilightAtom(node: hits.first!.node)
                    
                } else {
                    infoView.isHidden = true
                }
            } else {
                infoView.isHidden = true
            }
        }
    }
    
    func hilightAtom(node: SCNNode){
        
        let material = node.geometry!.materials.first!
        
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.5
        
        SCNTransaction.completionBlock = {
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.5
            
            material.emission.contents = UIColor.black
            
            SCNTransaction.commit()
        }
        
        material.emission.contents = UIColor.red
        
        SCNTransaction.commit()
    }
    
    func setupInfoView() {
        infoView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6)
        infoView.layer.cornerRadius = 25
        infoView.isHidden = true
        nameLabel.textColor = .white
        xLabel.textColor = .white
        yLabel.textColor = .white
        zLabel.textColor = .white
    }
    
    func setupScene() {
        scnScene = SCNScene()
        scnView.scene = scnScene
        scnScene.background.contents = UIImage(named: "backgroundLigand")
        scnView.showsStatistics = true
        scnView.allowsCameraControl = true
        scnView.autoenablesDefaultLighting = true
    }
    
    func setupCamera() {
        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 30)
        scnScene.rootNode.addChildNode(cameraNode)
    }
    
    func createAtoms() {
        for atom in ligand!.atoms {
            let box = SCNNode()
            let sphereGeometry = SCNSphere(radius: 0.4)
            box.geometry = sphereGeometry
            colorizeAtom(sphereGeometry, atom)
            box.name = atom.name + " " + atom.id
            box.position = SCNVector3Make(atom.x, atom.y, atom.z)
            scnScene.rootNode.addChildNode(box)
            createSticks(atom)
        }
    }
    
    func colorizeAtom(_ boxGeometry: SCNSphere, _ atom: Atom) {
        let boxMaterial = SCNMaterial()
        if atom.name == "C" {
            boxMaterial.diffuse.contents = UIColor.black
        } else if atom.name == "H" {
            boxMaterial.diffuse.contents = UIColor.white
        } else if atom.name == "N" {
            boxMaterial.diffuse.contents = UIColor(displayP3Red: 0.146, green: 0.197, blue: 0.961, alpha: 1)
        } else if atom.name == "O"{
            boxMaterial.diffuse.contents = UIColor(displayP3Red: 0.919, green: 0.244, blue: 0.145, alpha: 1)
        } else if atom.name == "F" || atom.name == "CL" {
            boxMaterial.diffuse.contents = UIColor(displayP3Red: 0.457, green: 0.985, blue: 0.298, alpha: 1)
        } else if atom.name == "BR" {
            boxMaterial.diffuse.contents = UIColor(displayP3Red: 0.553, green: 0.173, blue: 0.074, alpha: 1)
        } else if atom.name == "I" {
            boxMaterial.diffuse.contents = UIColor(displayP3Red: 0.364, green: 0.051, blue: 0.706, alpha: 1)
        } else if atom.name == "HE" || atom.name == "NE" || atom.name == "AR" || atom.name == "XE" || atom.name == "KR"{
            boxMaterial.diffuse.contents = UIColor(displayP3Red: 0.460, green: 0.984, blue: 0.992, alpha: 1)
        } else if atom.name == "P" {
            boxMaterial.diffuse.contents = UIColor(displayP3Red: 0.944, green: 0.619, blue: 0.219, alpha: 1)
        } else if atom.name == "S" {
            boxMaterial.diffuse.contents = UIColor(displayP3Red: 0.982, green: 0.902, blue: 0.329, alpha: 1)
        } else if atom.name == "B" {
            boxMaterial.diffuse.contents = UIColor(displayP3Red: 0.953, green: 0.680, blue: 0.502, alpha: 1)
        } else if atom.name == "LI" || atom.name == "NA" || atom.name == "K" || atom.name == "RB" || atom.name == "CS" {
            boxMaterial.diffuse.contents = UIColor(displayP3Red: 0.427, green: 0.068, blue: 0.961, alpha: 1)
        } else if atom.name == "BE" || atom.name == "MG" || atom.name == "CA" || atom.name == "SR" || atom.name == "BA" || atom.name == "RA" {
            boxMaterial.diffuse.contents = UIColor(displayP3Red: 0.199, green: 0.461, blue: 0.117, alpha: 1)
        } else if atom.name == "TI" {
            boxMaterial.diffuse.contents = UIColor(displayP3Red: 0.600, green: 0.600, blue: 0.600, alpha: 1)
        } else if atom.name == "FE" {
            boxMaterial.diffuse.contents = UIColor(displayP3Red: 0.815, green: 0.489, blue: 0.172, alpha: 1)
        } else {
            boxMaterial.diffuse.contents = UIColor(displayP3Red: 0.813, green: 0.489, blue: 0.973, alpha: 1)
        }
        boxGeometry.materials = [boxMaterial]
    }

    func createSticks(_ atom: Atom) {
        let ps = SCNVector3Make(atom.x, atom.y, atom.z)
        for conectionAtom in atom.connections {
            let pe = SCNVector3Make(conectionAtom.x, conectionAtom.y, conectionAtom.z)
            let stick = line(from: ps, to: pe, color: .white)
            scnScene.rootNode.addChildNode(stick)
        }
    }
    
    func line(from : SCNVector3, to : SCNVector3, color : UIColor) -> SCNNode {
        let vector = to - from,
        length = vector.length()
        
        let cylinder = SCNCylinder(radius: 0.1, height: CGFloat(length))

        cylinder.firstMaterial?.diffuse.contents = color
        
        let node = SCNNode(geometry: cylinder)
        
        let pos = (to + from) / 2
        node.position = SCNVector3(x: pos.x, y: pos.y, z: pos.z)
        node.eulerAngles = SCNVector3Make(Float(Double.pi/2), acos((to.z-from.z)/length), atan2((to.y-from.y), (to.x-from.x) ))
        
        return node
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToWeb" {
            let destinationVC = segue.destination as! WebViewController
            destinationVC.name = ligand?.name ?? ""
        }
    }
    
}

extension SCNVector3 {
    /**
     * Negates the vector described by SCNVector3 and returns
     * the result as a new SCNVector3.
     */
    func negate() -> SCNVector3 {
        return self * -1
    }
    
    /**
     * Negates the vector described by SCNVector3
     */
    mutating func negated() -> SCNVector3 {
        self = negate()
        return self
    }
    
    /**
     * Returns the length (magnitude) of the vector described by the SCNVector3
     */
    func length() -> Float {
        return sqrtf(x*x + y*y + z*z)
    }
    
    /**
     * Normalizes the vector described by the SCNVector3 to length 1.0 and returns
     * the result as a new SCNVector3.
     */
    func normalized() -> SCNVector3 {
        return self / length()
    }
    
    /**
     * Normalizes the vector described by the SCNVector3 to length 1.0.
     */
    mutating func normalize() -> SCNVector3 {
        self = normalized()
        return self
    }
    
    /**
     * Calculates the distance between two SCNVector3. Pythagoras!
     */
    func distance(vector: SCNVector3) -> Float {
        return (self - vector).length()
    }
    
    /**
     * Calculates the dot product between two SCNVector3.
     */
    func dot(vector: SCNVector3) -> Float {
        return x * vector.x + y * vector.y + z * vector.z
    }
    
    /**
     * Calculates the cross product between two SCNVector3.
     */
    func cross(vector: SCNVector3) -> SCNVector3 {
        return SCNVector3Make(y * vector.z - z * vector.y, z * vector.x - x * vector.z, x * vector.y - y * vector.x)
    }
}

/**
 * Adds two SCNVector3 vectors and returns the result as a new SCNVector3.
 */
func + (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)
}

/**
 * Increments a SCNVector3 with the value of another.
 */
func += ( left: inout SCNVector3, right: SCNVector3) {
    left = left + right
}

/**
 * Subtracts two SCNVector3 vectors and returns the result as a new SCNVector3.
 */
func - (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left.x - right.x, left.y - right.y, left.z - right.z)
}

/**
 * Decrements a SCNVector3 with the value of another.
 */
func -= ( left: inout SCNVector3, right: SCNVector3) {
    left = left - right
}

/**
 * Multiplies two SCNVector3 vectors and returns the result as a new SCNVector3.
 */
func * (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left.x * right.x, left.y * right.y, left.z * right.z)
}

/**
 * Multiplies a SCNVector3 with another.
 */
func *= ( left: inout SCNVector3, right: SCNVector3) {
    left = left * right
}

/**
 * Multiplies the x, y and z fields of a SCNVector3 with the same scalar value and
 * returns the result as a new SCNVector3.
 */
func * (vector: SCNVector3, scalar: Float) -> SCNVector3 {
    return SCNVector3Make(vector.x * scalar, vector.y * scalar, vector.z * scalar)
}

/**
 * Multiplies the x and y fields of a SCNVector3 with the same scalar value.
 */
func *= ( vector: inout SCNVector3, scalar: Float) {
    vector = vector * scalar
}

/**
 * Divides two SCNVector3 vectors abd returns the result as a new SCNVector3
 */
func / (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left.x / right.x, left.y / right.y, left.z / right.z)
}

/**
 * Divides a SCNVector3 by another.
 */
func /= ( left: inout SCNVector3, right: SCNVector3) {
    left = left / right
}

/**
 * Divides the x, y and z fields of a SCNVector3 by the same scalar value and
 * returns the result as a new SCNVector3.
 */
func / (vector: SCNVector3, scalar: Float) -> SCNVector3 {
    return SCNVector3Make(vector.x / scalar, vector.y / scalar, vector.z / scalar)
}

/**
 * Divides the x, y and z of a SCNVector3 by the same scalar value.
 */
func /= ( vector: inout SCNVector3, scalar: Float) {
    vector = vector / scalar
}

/**
 * Negate a vector
 */
func SCNVector3Negate(vector: SCNVector3) -> SCNVector3 {
    return vector * -1
}

/**
 * Returns the length (magnitude) of the vector described by the SCNVector3
 */
func SCNVector3Length(vector: SCNVector3) -> Float
{
    return sqrtf(vector.x*vector.x + vector.y*vector.y + vector.z*vector.z)
}

/**
 * Returns the distance between two SCNVector3 vectors
 */
func SCNVector3Distance(vectorStart: SCNVector3, vectorEnd: SCNVector3) -> Float {
    return SCNVector3Length(vector: vectorEnd - vectorStart)
}

/**
 * Returns the distance between two SCNVector3 vectors
 */
func SCNVector3Normalize(vector: SCNVector3) -> SCNVector3 {
    return vector / SCNVector3Length(vector: vector)
}

/**
 * Calculates the dot product between two SCNVector3 vectors
 */
func SCNVector3DotProduct(left: SCNVector3, right: SCNVector3) -> Float {
    return left.x * right.x + left.y * right.y + left.z * right.z
}

/**
 * Calculates the cross product between two SCNVector3 vectors
 */
func SCNVector3CrossProduct(left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left.y * right.z - left.z * right.y, left.z * right.x - left.x * right.z, left.x * right.y - left.y * right.x)
}

/**
 * Calculates the SCNVector from lerping between two SCNVector3 vectors
 */
func SCNVector3Lerp(vectorStart: SCNVector3, vectorEnd: SCNVector3, t: Float) -> SCNVector3 {
    return SCNVector3Make(vectorStart.x + ((vectorEnd.x - vectorStart.x) * t), vectorStart.y + ((vectorEnd.y - vectorStart.y) * t), vectorStart.z + ((vectorEnd.z - vectorStart.z) * t))
}

/**
 * Project the vector, vectorToProject, onto the vector, projectionVector.
 */
func SCNVector3Project(vectorToProject: SCNVector3, projectionVector: SCNVector3) -> SCNVector3 {
    let scale: Float = SCNVector3DotProduct(left: projectionVector, right: vectorToProject) / SCNVector3DotProduct(left: projectionVector, right: projectionVector)
    let v: SCNVector3 = projectionVector * scale
    return v
}

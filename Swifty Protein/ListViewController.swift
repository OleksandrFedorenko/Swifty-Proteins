//
//  ViewController.swift
//  Swifty Protein
//
//  Created by MacBook Pro on 8/28/19.
//  Copyright © 2019 MacBook Pro. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import LocalAuthentication
import SVProgressHUD

class ListViewController: UIViewController {
    
    var ligandsArray: [String] = []
    var searchLigands: [String] = []
    let networkingClient = NetworkingClient()
    var choosenLigand: Ligand?
    
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var ligandsTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ligandsTableView.dataSource = self
        ligandsTableView.delegate = self
        searchBar.delegate = self
        
        searchBar.barTintColor = UIColor.clear
        searchBar.backgroundImage = UIImage()
        UITextField.appearance(whenContainedInInstancesOf: [type(of: searchBar)]).tintColor = .black
        
        readFromTxt()
        searchLigands = ligandsArray
        setupView()
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //MARK:- Read from file
    
    private func readFromTxt() {
        if let path = Bundle.main.path(forResource: "ligands", ofType: "txt") {
            do {
                let text = try String(contentsOfFile: path , encoding: String.Encoding.utf8)
                ligandsArray = text.components(separatedBy: "\n")
                ligandsArray.removeLast()
            }catch{
                print("Error \(error)")
            }
        }
    }

    //MARK:- Background video block
    
    private func setupView() {
        let path = URL(fileURLWithPath:  Bundle.main.path(forResource: "backgroundvideo", ofType: "mp4")!)
        let player = AVPlayer(url: path)
        let newLayer = AVPlayerLayer(player: player)
        newLayer.frame = self.videoView.frame
        self.videoView.layer.addSublayer(newLayer)
        newLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        player.play()
        player.actionAtItemEnd = AVPlayer.ActionAtItemEnd.none
        NotificationCenter.default.addObserver(self, selector: #selector(ListViewController.videoDidPlayToEnd(_:)), name: NSNotification.Name("AVPlayerItemDidPlayToEndTimeNotification"), object: player.currentItem)
    }

    @objc func videoDidPlayToEnd(_ notification: Notification) {
        let player: AVPlayerItem = notification.object as! AVPlayerItem
//        player.seek(to: CMTime.zero)
        player.seek(to: CMTime.zero, completionHandler: nil)
    }
    
}

//MARK: - TableView Methods

extension ListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchLigands.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = ligandsTableView.dequeueReusableCell(withIdentifier: "ligandCell", for: indexPath) as! LigandsTableViewCell
        cell.libandName.text = searchLigands[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        SVProgressHUD.show()
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.allowsSelection = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
        if searchLigands[indexPath.row] == "UNL" || searchLigands[indexPath.row] == "UNX" {
            showAlert(title: "UNL/UNX", message: "You choosed Unknown ligand (UNL) or Unknown Atom or Ion (UNX)")
            SVProgressHUD.dismiss()
        } else {
            networkingClient.getLigand(ligandName: searchLigands[indexPath.row]) { (data, error) in
                if let ligandData = data {
                    if let dataString = String(data: ligandData, encoding: .utf8){
                        if let atoms = self.getAtoms(data: dataString) {
                            self.choosenLigand = Ligand(name: self.searchLigands[indexPath.row], atoms: atoms)
                            SVProgressHUD.dismiss()
                            if self.choosenLigand?.atoms.count == 0 {
                                self.showAlert(title: "File doesn't exist", message: ".pdb file for this ligand doesn't exist")
                            } else {
                                self.performSegue(withIdentifier: "goToScene", sender: nil)
                            }
                            tableView.allowsSelection = true
                        }
                    }
                }
                if let err = error {
                    print(err)
                    SVProgressHUD.dismiss()
                    self.showAlert(title: "Connection issues", message: "Please make sure that you are connected to the Internet")
                }
                self.searchLigands = self.ligandsArray
                self.ligandsTableView.reloadData()
            }
        }
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func getAtoms(data: String) -> [Atom]?{
        var retAtoms: [Atom] = []
        for str in data.split(separator: "\n"){
            if str.contains("ATOM"){
                let tmp = str.split(separator: " ")
                let atom = Atom(id: String(tmp[1]), name: String(tmp[11]), x: Float(tmp[6])!, y: Float(tmp[7])!, z: Float(tmp[8])!) //force unwrap is bad
                retAtoms.append(atom)
            } else if str.contains("CONECT"){
                var conect = str.split(separator: " ")
                conect.removeFirst()
                if let index = Int(conect[0]){
                    if index - 1 < retAtoms.count{
                        weak var atom = retAtoms[index - 1]
                        if conect.count > 1 {
                            conect.removeFirst()
                            for con in conect {
                                if let index = Int(con){
                                    if index - 1 < retAtoms.count{
                                        atom?.connections.append(retAtoms[index - 1])
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        return retAtoms
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToScene" {
            let destinationVC = segue.destination as! SceneViewController
            destinationVC.ligand = choosenLigand
        }
    }
    
}

//MARK: - SearchBar Methods

extension ListViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchLigands = searchText.isEmpty ? ligandsArray : ligandsArray.filter { (item: String) -> Bool in
            return item.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
        }
        ligandsTableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchLigands = ligandsArray
        ligandsTableView.reloadData()
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
    }
}

//
//  ListScreen.swift
//  CochleariOS
//
//  Created by Quadir on 12/15/19.
//  Copyright © 2019 Quadir. All rights reserved.
//

import UIKit
import GooglePlaces
import MapKit
import GoogleMaps
import FirebaseCore
import FirebaseFirestore
import CoreLocation

class ListScreen: UIViewController, UITableViewDelegate,  UITableViewDataSource {
   
    
    @IBOutlet weak var tableView: UITableView!
    // cell reuse id (cells that scroll out of view can be reused)
    let cellReuseIdentifier = "cellId"
    var db: Firestore!
    var currentLocation: CLLocation!
    
    var note: [String] = []
    var clocation: [CLLocationCoordinate2D] = []
    var finalList = [String: Double]()
    var List = [String: Double]()
    var info: [String] = []
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //get current location of user
        getLocation()
        
        //order locations sorted by distance
        sortLocations()

        //setup table view
        setupTableView()
        
        
    }
    
    func getLocation(){
       
        let locManager = CLLocationManager()
        locManager.requestWhenInUseAuthorization()
        if( CLLocationManager.authorizationStatus() == .authorizedWhenInUse ||
                CLLocationManager.authorizationStatus() ==  .authorizedAlways){
              currentLocation = locManager.location

        }
    }
    
    func sortLocations(){
        print(clocation.count)

        for index in 0...clocation.count - 1 {
            let coordinate₁ = CLLocation(latitude: clocation[index].latitude, longitude: clocation[index].longitude)
            print("Cordinate ",coordinate₁)
            print("Location ",currentLocation)
            let distanceInMeters = currentLocation.distance(from: coordinate₁)
            List[note[index]] = distanceInMeters
        }
        
        for (k,v) in (Array(List).sorted {$0.1 < $1.1}) {
            finalList[k] = v
        }
    
    }
    
    func setupTableView(){
        
        // Register the table view cell class and its reuse id
        self.tableView.register(LocationCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return finalList.count
        
     }
       
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as! LocationCell
        cell.backgroundColor = UIColor.white
        let unit = " metres "
        if(finalList.count != 0){
             let doubleStr = String(format: "%.2f", Array(finalList.values)[indexPath.row]) // "3.14"
            cell.dayLabel.text = Array(finalList.keys)[indexPath.row] + " , " + doubleStr + unit
            cell.titleLabel.text = Array(finalList.keys)[indexPath.row]
            cell.noteLabel.text = info[indexPath.row]
            
            let coordinate = CLLocation(latitude: clocation[indexPath.row].latitude, longitude: clocation[indexPath.row].longitude)
           
            cell.latLabel.text = String(clocation[indexPath.row].latitude)
            cell.lonLabel.text = String(clocation[indexPath.row].longitude)
        }
        
        cell.delegate = self as! LocationCellDelegate
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        print("cell clicked")

    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
       
        return 100
        
    }

    @IBAction func closeScreen(_ sender: Any) {
           
        self.dismiss(animated: true)
    }
}

//code to get delegate of cell to call detail screen
extension ListScreen: LocationCellDelegate {

    func moveToDetail(title:String,note:String,latitude:String,longitude:String){
         
              //declare storyboard
              let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
              let detailScreen = storyBoard.instantiateViewController(withIdentifier: "detailscreen") as! DetailScreen
              detailScreen.modalPresentationStyle = .fullScreen
              
              //display a detail screen
              detailScreen.text = title
              detailScreen.lat = latitude
              detailScreen.lon = longitude
              detailScreen.info = note
              self.present(detailScreen, animated:true, completion:nil)
          }

}

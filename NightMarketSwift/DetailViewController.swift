//
//  DetailViewController.swift
//  NightMarketSwift
//
//  Created by Hank on 2017/2/10.
//  Copyright © 2017年 Anderson. All rights reserved.
//

import UIKit
import GoogleMobileAds
import GoogleMaps
import AFNetworking



class DetailViewController: UIViewController ,GADBannerViewDelegate{
    
    var information : [String]!
    
    @IBOutlet weak var mapV: GMSMapView!
    @IBOutlet weak var businessDayL: UILabel!
    @IBOutlet weak var addressL: UILabel!
    @IBOutlet weak var bannerV: GADBannerView!
    @IBOutlet weak var distanceL: UILabel!
    @IBOutlet weak var typeWalk: UILabel!
    @IBOutlet weak var typeDrive: UILabel!
    @IBOutlet weak var typeBus: UILabel!
    @IBOutlet weak var goToL: UILabel!
    
    var marketCll : CLLocation!
    var locationManager = CLLocationManager()
    var didFindMyLoation = false
    var gpx = [String]()
    var myLocation : CLLocation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("information is \(information)")
        self.navigationItem.title = information[0]
        businessDayL.text = "營業時間：\(information[2])"
        addressL.text = information[1]
        
        //google admobs banner
        bannerV.adUnitID = "ca-app-pub-7797553041558574/5747980243"
        bannerV.rootViewController = self
        bannerV.delegate = self
        bannerV.adSize = kGADAdSizeSmartBannerPortrait
        let gadrequest = GADRequest()
        gadrequest.testDevices = [ kGADSimulatorID ]
        bannerV.load(gadrequest)
        
        //
        mapV.delegate = self
        gpx = information[3].components(separatedBy: ",")
        
        marketCll = CLLocation(latitude: Double(gpx[0])!, longitude: Double(gpx[1])!)

        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        //mylocation
        mapV.addObserver(self, forKeyPath: "myLocation", options: .new, context: nil)
        
        //self.setuploactionMark(coordinate: corrdinate)
        let drivingTGR = UITapGestureRecognizer(target: self, action: #selector(self.drivingMode(_:)))
        typeDrive.addGestureRecognizer(drivingTGR)
        let walkingTGR = UITapGestureRecognizer(target: self, action: #selector(self.walkingMode(_:)))
        typeWalk.addGestureRecognizer(walkingTGR)
        let busTGR = UITapGestureRecognizer(target: self, action: #selector(self.busMode(_:)))
        typeBus.addGestureRecognizer(busTGR)
        
        let gotoTGR = UITapGestureRecognizer(target: self, action: #selector(self.goToGoogleMap(_:)))
        goToL.addGestureRecognizer(gotoTGR)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        mapV.removeObserver(self, forKeyPath: "myLocation", context: nil)

    }
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        bannerV.isHidden = false
    }
    
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        bannerV.isHidden = true
    }
    
    func nightMarketLocationMarker() {
        //night market location marker
        let position = CLLocationCoordinate2D(latitude: Double(gpx[0])!, longitude: Double(gpx[1])!)
        let locationMarker = GMSMarker(position: position)
        locationMarker.title = information[0]
        locationMarker.appearAnimation = kGMSMarkerAnimationPop
        locationMarker.icon = GMSMarker.markerImage(with: UIColor.red)
        locationMarker.opacity = 0.75
        locationMarker.isFlat = true
        //locationMarker.snippet = "sub test"
        locationMarker.map = mapV
    }
    
    
    func calculateDistance(origin: CLLocation, destination: CLLocation, mode: String) {
        
        mapV.clear()
        nightMarketLocationMarker()
        
        let service = "https://maps.googleapis.com/maps/api/directions/json"
        let originLat = origin.coordinate.latitude
        let originLong = origin.coordinate.longitude
        let destLat = destination.coordinate.latitude
        let destLong = destination.coordinate.longitude
        
        //在AppDelegate已加入GMSServices.provideAPIKey 則request url不需要再加入 否則會出現
        //"error_message" : "This IP, site or mobile application is not authorized to use this API key.
        
        var urlString = "\(service)?origin=\(originLat),\(originLong)&destination=\(destLat),\(destLong)&mode=\(mode)"

        urlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        
        let manager = AFHTTPSessionManager()
        manager.requestSerializer = AFJSONRequestSerializer() as AFJSONRequestSerializer
        manager.responseSerializer = AFJSONResponseSerializer(readingOptions: .allowFragments) as AFJSONResponseSerializer
        
        
        manager.post(urlString, parameters: nil, progress: nil, success: { operation, response -> Void in
            if let result = response as? NSDictionary {
                if let routes = result["routes"] as? [NSDictionary] {
                
                    if let legs = routes[0]["legs"] as? [NSDictionary] {
                        let totalDis = legs[0]["distance"] as? NSDictionary
                        let totalDur = legs[0]["duration"] as? NSDictionary
                        self.distanceL.text? = "\(totalDur?["text"] as! String) ,\(totalDis?["text"] as! String)"
    
                    }
                    
                    if let lines = routes[0]["overview_polyline"] as? NSDictionary {
                        if let points = lines["points"] as? String {
                            
                            let path = GMSPath.init(fromEncodedPath: points)
                            //變更使用者的地圖檢視點
                            let bounds = GMSCoordinateBounds.init(path: path!)
                            let update = GMSCameraUpdate.fit(bounds)
                            let singleLine = GMSPolyline.init(path: path)
                            singleLine.strokeWidth = 3
                            singleLine.strokeColor = UIColor.blue
                            singleLine.map = self.mapV
                            self.mapV.moveCamera(update)
                            
                        }
                    }
                }
            }
            
            
        }) { operation, error -> Void in
            print(error)
            
        }
    }
    
    func drivingMode(_ sender: UITapGestureRecognizer) {
         self.calculateDistance(origin: myLocation, destination: marketCll, mode: "driving")
    }
    func walkingMode(_ sender: UITapGestureRecognizer) {
        self.calculateDistance(origin: myLocation, destination: marketCll, mode: "walking")
    }

    func busMode(_ sender: UITapGestureRecognizer) {
        self.calculateDistance(origin: myLocation, destination: marketCll, mode: "transit")
    }
    
    func goToGoogleMap(_ sender: UITapGestureRecognizer) {

            let dirurl = "https://maps.google.com?saddr=Current+Location&daddr=\(marketCll.coordinate.latitude),\(marketCll.coordinate.longitude)"
            UIApplication.shared.openURL(URL(string : dirurl)!)

    }
}


extension  DetailViewController : CLLocationManagerDelegate, GMSMapViewDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.authorizedWhenInUse {
            mapV.isMyLocationEnabled = true
            
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if !didFindMyLoation {
            myLocation = change![NSKeyValueChangeKey.newKey] as! CLLocation
            mapV.camera = GMSCameraPosition.camera(withTarget: myLocation.coordinate, zoom: 6.0)
            mapV.settings.myLocationButton = true
            
            didFindMyLoation = true
            self.calculateDistance(origin: myLocation, destination: marketCll, mode: "driving")
            
        }
    }
    
}


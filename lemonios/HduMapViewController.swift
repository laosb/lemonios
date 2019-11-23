////
////  HduMapViewController.swift
////  lemonios
////
////  Created by Wexpo Lyu on 2019/8/22.
////  Copyright © 2019 Inkwire Tech (Hangzhou) Co., Ltd. All rights reserved.
////
//
//import UIKit
//import MapKit
//import CoreLocation
//import GEOSwift
//import GEOSwiftMapKit
//
//enum HduMapOverlayType {
//    case zone
//    case schoolBuilding
//    case dorm
//}
//
//class HduMapOverlay: MKPolygon {
//    var type: HduMapOverlayType
//    
//    override init() {
//        self.type = .zone
//        super.init()
//    }
//}
//
//enum HduMapAnnotationType {
//    case schoolBuilding
//    case dorm
//    case other
//}
//
//class HduMapAnnotation: NSObject, MKAnnotation {
//    var coordinate: CLLocationCoordinate2D
//    var title: String?
//    var subtitle: String?
//    var type: HduMapAnnotationType
//    init (coordinate: CLLocationCoordinate2D) {
//        self.type = .other
//        self.coordinate = coordinate
//    }
//}
//
//class HduMapViewController: UIViewController {
//    
//    let locationManager = CLLocationManager()
//
//    @IBOutlet weak var mapView: MKMapView!
//    
//    override func viewWillAppear(_ animated: Bool) {
//        self.navigationController?.setNavigationBarHidden(false, animated: false)
//    }
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//                
////        mapView.setRegion(MKCoordinateRegion(
////            center: CLLocationCoordinate2D(latitude: 30.3145259, longitude: 120.3433057),
////            latitudinalMeters: 980,
////            longitudinalMeters: 550
////        ), animated: true)
//        mapView.delegate = self
//        mapView.showsCompass = true
//        mapView.showsUserLocation = true
//        mapView.showsBuildings = true
//        
//        locationManager.delegate = self
//        checkLocationServices()
//        
//        let decoder = JSONDecoder()
//        let zoneGeoJsonUrl = Bundle.main.url(forResource: "zones", withExtension: "geojson")
////        print("json file url", geoJSONURL)
//        let zonesData = try? Data(contentsOf: zoneGeoJsonUrl!)
////        print("zonesData", String(data: zonesData!, encoding: String.Encoding.utf8) ?? "")
//        let zones = try? decoder.decode(FeatureCollection.self, from: zonesData!)
////        print(zones?.features.count)
//        zones?.features.forEach { zone in
//            if case let .polygon(zoneShape)? = zone.geometry {
////                print(zoneShape.polygons.count)
//                let zoneOverlay = HduMapOverlay(polygon: zoneShape)
//                if case let .string(name)? = zone.properties?["name"] {
////                    print(name)
//                    zoneOverlay.title = name
//                }
//                zoneOverlay.type = .zone
//                mapView.addOverlay(zoneOverlay)
//                mapView.setRegion(try! MKCoordinateRegion(containing: zoneShape.geometry.buffer(by: 0.0005)), animated: true)
//            }
//        }
//        
//        let schoolBuildingGeoJsonUrl = Bundle.main.url(forResource: "majorSchoolBuildings", withExtension: "geojson")
//        let schoolBuildingsData = try? Data(contentsOf: schoolBuildingGeoJsonUrl!)
//        let schoolBuildings = try? decoder.decode(FeatureCollection.self, from: schoolBuildingsData!)
//        schoolBuildings?.features.forEach { building in
//            if case let .polygon(buildingShape)? = building.geometry {
//                let buildingOverlay = HduMapOverlay(polygon: buildingShape)
//                let buildingPin = HduMapAnnotation(coordinate: CLLocationCoordinate2D((try? building.geometry?.centroid())!))
//                if case let .string(name)? = building.properties?["name"] {
////                    print(name)
//                    buildingOverlay.title = name
//                    buildingPin.title = name
//                }
//                if case let .number(number)? = building.properties?["hdu:teachingbuilding"] {
////                    print(number)
//                    buildingPin.subtitle = "第 \(String(format: "%.0f", number)) 教学楼"
//                }
//                buildingOverlay.type = .schoolBuilding
//                buildingPin.type = .schoolBuilding
//                mapView.addOverlay(buildingOverlay)
//                mapView.addAnnotation(buildingPin)
//            }
//        }
//        
//        let dormGeoJsonUrl = Bundle.main.url(forResource: "dormArea", withExtension: "geojson")
//        let dormData = try? Data(contentsOf: dormGeoJsonUrl!)
//        let dorms = try? decoder.decode(FeatureCollection.self, from: dormData!)
//        dorms?.features.forEach { dorm in
//            if case let .polygon(buildingShape)? = dorm.geometry {
//                let buildingOverlay = HduMapOverlay(polygon: buildingShape)
//                let buildingPin = HduMapAnnotation(coordinate: CLLocationCoordinate2D((try? dorm.geometry?.centroid())!))
//                if case let .string(name)? = dorm.properties?["name"] {
//                    //                    print(name)
//                    buildingOverlay.title = name
//                    buildingPin.title = name
//                    buildingOverlay.type = .dorm
//                    buildingPin.type = .other
//                }
//                if case let .number(number)? = dorm.properties?["hdu:dorm"] {
////                    print(number)
//                    buildingPin.title = "\(String(format: "%.0f", number)) 号楼"
//                    buildingOverlay.type = .dorm
//                    buildingPin.type = .dorm
//                }
//                if case let .string(wing)? = dorm.properties?["hdu:dormwing"] {
//                    buildingPin.title? += wing
//                }
//                mapView.addOverlay(buildingOverlay)
//                mapView.addAnnotation(buildingPin)
//            }
//        }
//    }
//    
//    func setupLocationManager() {
//        locationManager.delegate = self
//        locationManager.desiredAccuracy = kCLLocationAccuracyBest
//    }
//    
////    func centerViewOnUserLocation() {
////        if let location = locationManager.location?.coordinate {
////            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
////            mapView.setRegion(region, animated: true)
////        }
////    }
//    
//    func checkLocationServices() {
//        if CLLocationManager.locationServicesEnabled() {
//            setupLocationManager()
//            checkLocationAuthorization()
//        } else {
//            // Show alert letting the user know they have to turn this on.
//        }
//    }
//    
//    
//    func checkLocationAuthorization() {
//        switch CLLocationManager.authorizationStatus() {
//            case .authorizedWhenInUse:
//                mapView.showsUserLocation = true
////                centerViewOnUserLocation()
//                locationManager.startUpdatingLocation()
//            case .notDetermined:
//                locationManager.requestWhenInUseAuthorization()
//            case .authorizedAlways:
//                break
//            default:
//                let alert = UIAlertController(title: "定位失败", message: "杭电助手无法确定您的当前位置。若需要在地图上显示您的位置，请确认您已打开定位服务，并授权杭电助手访问您的位置信息。", preferredStyle: .alert)
//                alert.addAction(UIAlertAction(title: "好", style: .default))
//                self.present(alert, animated: true, completion: nil)
//        }
//    }
//    
//
//    /*
//    // MARK: - Navigation
//
//    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        // Get the new view controller using segue.destination.
//        // Pass the selected object to the new view controller.
//    }
//    */
//
//}
//
//extension HduMapViewController: MKMapViewDelegate {
//    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
//        if overlay is HduMapOverlay {
//            let polygonView = MKPolygonRenderer(overlay: overlay)
//            polygonView.lineWidth = 1
//            
//            switch ((overlay as! HduMapOverlay).type) {
//                case .zone:
//                    polygonView.strokeColor = UIColor.blue
//                case .schoolBuilding:
//                    polygonView.strokeColor = UIColor(red: 0.20, green: 0.60, blue: 0.86, alpha: 1.0)
//                    polygonView.fillColor = UIColor(red: 0.20, green: 0.60, blue: 0.86, alpha: 0.5)
//                case .dorm:
//                    polygonView.strokeColor = UIColor(red: 0.98, green: 0.55, blue: 0.00, alpha: 1.0)
//                    polygonView.fillColor = UIColor(red: 0.98, green: 0.55, blue: 0.00, alpha: 0.5)
//            }
//            
//            return polygonView
//        }
//        
//        return MKOverlayRenderer()
//    }
//    
//    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//        if annotation is HduMapAnnotation {
//            let annotationView = MKMarkerAnnotationView()
//            annotationView.canShowCallout = true
//            
//            switch ((annotation as! HduMapAnnotation).type) {
//                case .schoolBuilding:
//                    annotationView.markerTintColor = UIColor(red: 0.20, green: 0.60, blue: 0.86, alpha: 1.0)
//                    annotationView.glyphImage = UIImage(imageLiteralResourceName: "business")
//                case .dorm:
//                    annotationView.markerTintColor = UIColor(red: 0.98, green: 0.55, blue: 0.00, alpha: 1.0)
//                    annotationView.glyphImage = UIImage(imageLiteralResourceName: "hotel")
//                default:
//                    annotationView.canShowCallout = false
//            }
//            
//            return annotationView
//        }
//        return MKMarkerAnnotationView()
//    }
//}
//
//extension HduMapViewController: CLLocationManagerDelegate {
//    
////    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
////        guard let location = locations.last else { return }
////        let region = MKCoordinateRegion.init(center: location.coordinate, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
////        mapView.setRegion(region, animated: true)
////    }
////
//    
//    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
//        checkLocationAuthorization()
//    }
//}

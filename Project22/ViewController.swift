//
//  ViewController.swift
//  Project22
//
//  Created by othman shahrouri on 10/4/21.
//
//Using location when the app isn’t running is of course highly sensitive information, so Apple flags it up in three ways:
//
//1.If you request Always access, users will still get the chance to choose When In Use.
//
//2.If they choose Always, iOS will automatically ask them again after a few days to confirm they still want to grant Always access.
//
//3.When your app is using location data in the background the iOS UI will update to reflect that – users will know it’s happening.
//
//4.Users can, at any point, go into the settings app and change from Always down to When In Use.


//Based on the beacon's distance to us, we'll show either "UNKNOWN", "FAR", "NEAR" or "RIGHT HERE".

//Apple restricts your ranging to these values because of the signal's low energy nature, but it's more than enough for most uses
//---------------------------------------------------------------------------------------

//Core Location class  lets us configure how we want to be notified about location, and will also deliver location updates to us

//Requesting location authorization is a non-blocking call, which means your code will carry on executing while the user reads your location message and decides whether to grant you access to their location
//-------------------------------------------------------------------------------------

//to range beacons:
//1.we use a new class called CLBeaconRegion, which is used to identify a beacon uniquely
//2.Second, we give that to our CLLocationManager object by calling its startMonitoring(for:) and startRangingBeacons(in:) methods
//---------------------------------------------------------------------------------------

//iBeacons are identified using three pieces of information: a universally unique identifier (UUID), plus a major number and a minor number
//If you don't need that level of detail you can skip minor or even major


//UUID: You're in a Acme Hardware Supplies store.
//Major: You're in the Glasgow branch.
//Minor: You're in the shoe department on the third floor.

//extra:
//major number is used to subdivide within the UUID. So, if you have 10,000 stores in your supermarket chain, you would use the same UUID for them all but give each one a different major number

//minor number can (if you wish) be used to subdivide within the major number. For example, if your flagship London store has 12 floors each of which has 10 departments, you would assign each of them a different minor number


//-----------------------------------------------------------------------------------------

//@unknown default, which is specifically there to catch future values. This allows you to cover all the other cases explicitly, then provide one extra case to handle as-yet-unknown cases in the future

//catch the ranging method from CLLocationManager. We'll be given the array of beacons it found for a given region, which allows for cases where there are multiple beacons transmitting the same UUID

import CoreLocation
import UIKit

class ViewController: UIViewController , CLLocationManagerDelegate{
    @IBOutlet var distanceReading: UILabel!
    var locationManager: CLLocationManager?
    var firstDetect = false
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        //request always on authorization for first time only
        // if you used the "when in use" key, you should call requestWhenInUseAuthorization() instead
        locationManager?.requestAlwaysAuthorization()
        
        view.backgroundColor = .gray
    }
    
    //get called when user made their mind about giving permission or not
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        //check if they gave us permission for alway
        if status == .authorizedAlways {
            //check if monitor is available,can this detect if a beacon exist or not
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
                //can we detect how far beacon is away from us
                if CLLocationManager.isRangingAvailable() {
                    //do stuff
                    starScanning()
                }
            }
            
        }
    }
    
    
    //catch the ranging method from CLLocationManager
    func locationManager(_ manager: CLLocationManager, didRange beacons: [CLBeacon], satisfying beaconConstraint: CLBeaconIdentityConstraint) {
        //array of beacons it found for a given region, which allows for cases where there are multiple beacons transmitting the same UUID
        if let beacon = beacons.first {
            //If we receive any beacons from this method, we'll pull out the first one and use its proximity
            update(distance: beacon.proximity)
        } else {
            //If there aren't any beacons, we'll just use .unknown
            update(distance: .unknown)
        }
    }
    
    
    //detection and ranging
    func starScanning() {
        //converting a string into a UUID rather than generating a UUID and converting it to a string. The UUID there is one of the ones that comes built into the Locate Beacon app
        let uuid = UUID(uuidString: "5A4BCFCE-174E-4BAC-A814-092E77F6B7E5")!
        //to range beacons:
        //1.we  CLBeaconRegion, which is used to identify a beacon uniquely
        let beaconIdentity = CLBeaconIdentityConstraint(uuid: uuid, major: 123, minor: 456)
           let beaconRegion = CLBeaconRegion(beaconIdentityConstraint: beaconIdentity, identifier: "MyBeacon")        //2.Second, we give that to our CLLocationManager object by calling its startMonitoring(for:) and startRangingBeacons(in:) methods
        locationManager?.startMonitoring(for: beaconRegion)
        locationManager?.startRangingBeacons(satisfying: beaconIdentity)
    }
    
    func update(distance: CLProximity) {
        UIView.animate(withDuration: 1) {
            let ac = UIAlertController(title: "Beacon detected", message: "", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Continue", style: .default))
           
            switch distance {
            
            
            case .far:
                self.view.backgroundColor = .blue
                self.distanceReading.text = "FAR"
                if !self.firstDetect {
                    self.present(ac, animated: true)
                    self.firstDetect = true
                }
            case .near:
                self.view.backgroundColor = .orange
                self.distanceReading.text = "NEAR"
                if !self.firstDetect {
                    self.present(ac, animated: true)
                    self.firstDetect = true
                }
            case .immediate:
                self.view.backgroundColor = .red
                self.distanceReading.text = "RIGHT HERE"
                if !self.firstDetect {
                    self.present(ac, animated: true)
                    self.firstDetect = true
                }
            default:
                self.view.backgroundColor = .gray
                self.distanceReading.text = "UNKOWN"
                
            }
        }
        
    }
    
}


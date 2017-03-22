//
//  ViewController.h
//  Geofencing - Objective-C
//
//  Created by Kaytee on 3/15/17.
//  Copyright © 2017 Kaytee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface ViewController : UIViewController <CLLocationManagerDelegate> 

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSArray *geofences;

@end


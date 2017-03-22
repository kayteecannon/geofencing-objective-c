//
//  ViewController.m
//  Geofencing - Objective-C
//
//  Created by Kaytee on 3/15/17.
//  Copyright © 2017 Kaytee. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Initialize location manager
    self.locationManager = [[CLLocationManager alloc] init];
    
    // Set the location manager delegate
    self.locationManager.delegate = self;
    
    // Request always authorization is required to monitor geofences
    [self.locationManager requestAlwaysAuthorization];
    
    // Start monitoring geofences; up to 20 can be monitored at one time
    [self startMonitoringRegionsFrom:self.geofences];
    
}
 
- (NSArray *)geofences {
    
    CLLocation *canvs = [[CLLocation alloc] initWithLatitude:28.540342 longitude:-81.381518];
    CLLocation *guam = [[CLLocation alloc] initWithLatitude:13.4443 longitude:144.7937];

    NSArray *locations = [[NSArray alloc] initWithObjects:canvs, guam, nil];
    
    NSArray *geofences = [self createGeofencesFrom:locations];
    
    return geofences;

}

-(void)startMonitoringRegionsFrom:(NSArray*)geofences {
    
    for (CLRegion *region in geofences) {
        
        [self.locationManager startMonitoringForRegion:region];
        
    }
}

-(NSArray *)createGeofencesFrom:(NSArray *)locations {
    
    NSMutableArray *mutableGeofences = [[NSMutableArray alloc] init];
    for (CLLocation *location in locations) {
        
        CLRegion *geofence = [self createGeofenceFrom:location];
        [mutableGeofences addObject:geofence];
    }
    
    NSArray *geofences = [[NSArray alloc] initWithArray:mutableGeofences];
    
    return geofences;
}

- (CLRegion*)createGeofenceFrom:(CLLocation*)location {
    
    CLLocationDegrees latitude = location.coordinate.latitude;
    CLLocationDegrees longitude = location.coordinate.longitude;
    
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(latitude, longitude);
    
    CLLocationDistance radius = 100;
    
    CLCircularRegion *geofence = [[CLCircularRegion alloc] initWithCenter:center radius:radius identifier:location.description];
    
    return geofence;

}


#pragma mark - Location Manager Delegate Methods

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    
    if (status == kCLAuthorizationStatusAuthorizedAlways) {
        [self.locationManager startUpdatingLocation];
    }
    //User denies location services
    if (status == kCLAuthorizationStatusDenied) {
        
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Location Services Disabled" message:@"Location services are required for geofencing. Go to app settings to turn location services on." preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:@"OK"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action)
                               {
                                   [alert dismissViewControllerAnimated:YES completion:nil];
    
                               }];
    
    UIAlertAction *goToSettings = [UIAlertAction
                                   actionWithTitle:@"Go to Settings"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * _Nonnull action) {
                                       [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:^(BOOL success) {
                                       }];
                                   }];
    
    [alert addAction:okAction];
    [alert addAction:goToSettings];
    [self presentViewController:alert animated:YES completion:nil];
    }
}

-(void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region {
    NSLog(@"Monitoring for %@", region.description);
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"Location manager failed with error %@", error.description);
}

-(void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    
    self.view.backgroundColor = [UIColor redColor];
    [self presentWelcomeAlertFor:region];
    
}

-(void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    
    self.view.backgroundColor = [UIColor blueColor];
    [self presentGoodbyAlertFor:region];
    
}


-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    
    CLLocation *currentLocation = locations.lastObject;
    
    CLCircularRegion *currentRegion = [[CLCircularRegion alloc] initWithCenter:currentLocation.coordinate radius:100 identifier:@"currentRegion"];

#pragma mark - User already inside geofence
    
    // Check to see if user is already inside of a geofence
    for (CLCircularRegion *region in self.geofences) {
        
        // If so, present alert
        if ([currentRegion containsCoordinate:region.center]) {
            
            self.view.backgroundColor = [UIColor redColor];
            
            [self presentWelcomeAlertFor:region];
            
            // Stop updating to prevent looping behavior
            [self.locationManager stopUpdatingLocation];
            
            // You can call startUpdatingLocation again later, but it is not necessary
            
        }
    }
}


#pragma mark - Alerts
-(void)presentWelcomeAlertFor:(CLRegion *)region {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Welcome!" message:@"You have entered a geofence" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:@"OK"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action)
                               {
                                   [alert dismissViewControllerAnimated:YES completion:nil];
                                   
                               }];
    
    [alert addAction:okAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)presentGoodbyAlertFor:(CLRegion *)region {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Goodbye!" message:@"You have exited a geofence" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:@"OK"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action)
                               {
                                   [alert dismissViewControllerAnimated:YES completion:nil];
                                   
                               }];
    
    [alert addAction:okAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

@end

































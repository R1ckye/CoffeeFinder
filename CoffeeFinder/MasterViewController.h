//
//  MasterViewController.h
//  CoffeeFinder
//
//  Created by Richard Murvai on 04/07/13.
//  Copyright (c) 2013 Richard Murvai. All rights reserved.
//

#define kClientID "IJUBWPBX4LLAZTQWXZ34VMKHRIGLWJOQ21U05KKEAHBPXZPR"
#define kClientSecret "IGZAAUSXZIOOEDT4CXXYTX3S0FIUA44D0JD1PZAKWWJUWQXV"

#import <UIKit/UIKit.h>
#import <RestKit/RestKit.h>
#import <CoreLocation/CoreLocation.h>

#import "Venue.h"
#import "Location.h"

@interface MasterViewController : UITableViewController <CLLocationManagerDelegate>

@end

//
//  Venue.h
//  CoffeeFinder
//
//  Created by Richard Murvai on 04/07/13.
//  Copyright (c) 2013 Richard Murvai. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Location.h"

@interface Venue : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) Location *location;

@end

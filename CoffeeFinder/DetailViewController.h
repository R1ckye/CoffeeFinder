//
//  DetailViewController.h
//  CoffeeFinder
//
//  Created by Richard Murvai on 04/07/13.
//  Copyright (c) 2013 Richard Murvai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end

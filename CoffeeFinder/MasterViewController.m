//
//  MasterViewController.m
//  CoffeeFinder
//
//  Created by Richard Murvai on 04/07/13.
//  Copyright (c) 2013 Richard Murvai. All rights reserved.
//

#import "MasterViewController.h"

#import "DetailViewController.h"

@interface MasterViewController () {
    NSMutableArray *_objects;
}

@property (strong, nonatomic) NSArray *coffeeArray;
@property (strong, nonatomic) CLLocation *lastLocation;

@end

@implementation MasterViewController

@synthesize coffeeArray = _coffeeArray;
@synthesize lastLocation = _lastLocation;

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithTitle:@"Map" style:UIBarButtonItemStylePlain target:self action:@selector(showMap)];
    self.navigationItem.leftBarButtonItem = item;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"YYYYMMdd"];
    NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
    
    NSURL *baseURL = [NSURL URLWithString:@"https://api.foursquare.com/v2"];
    AFHTTPClient *client = [AFHTTPClient clientWithBaseURL:baseURL];
    [client setDefaultHeader:@"Accept" value:RKMIMETypeJSON];
    RKObjectManager *objectManager = [[RKObjectManager alloc]initWithHTTPClient:client];
    RKObjectMapping *venueMapping = [RKObjectMapping mappingForClass:[Venue class]];
    [venueMapping addAttributeMappingsFromDictionary:@{
                                                       @"name": @"name"
                                                       }];
    
    RKObjectMapping *locationMapping = [RKObjectMapping mappingForClass:[Location class]];
    [locationMapping addAttributeMappingsFromDictionary:@{@"address"        : @"address",
                                                          @"city"           : @"city",
                                                          @"country"        : @"country",
                                                          @"crossStreet"    : @"crossStreet",
                                                          @"postalCode"     : @"postalCode",
                                                          @"state"          : @"state",
                                                          @"distance"       : @"distance",
                                                          @"lat"            : @"lat",
                                                          @"lng"            : @"lng"
                                                          }];
    
    [venueMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"location" toKeyPath:@"location" withMapping:locationMapping]];
    
    RKResponseDescriptor *respDirector = [RKResponseDescriptor responseDescriptorWithMapping:venueMapping pathPattern:nil keyPath:@"response.venues" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];

    [objectManager addResponseDescriptor:respDirector];
    
    CLLocationManager *locationManager = [[CLLocationManager alloc]init];
    [locationManager startUpdatingLocation];
        
    CLLocationCoordinate2D coord = locationManager.location.coordinate;
    
    NSString *coordinates = [NSString stringWithFormat:@"%g,%g", coord.latitude, coord.longitude]; // @"37.33,-122.03";
    
    NSLog(@"%@", coordinates);
    
    NSString *clientId = [NSString stringWithUTF8String:kClientID];
    NSString *clientSecret = [NSString stringWithUTF8String:kClientSecret];
    
    
    
    NSDictionary *params = @{@"ll" : coordinates,
                             @"client_id" : clientId,
                             @"client_secret" : clientSecret,
                             @"query" : @"coffee",
                             @"v" : dateString
                             };
    [objectManager getObjectsAtPath:@"https://api.foursquare.com/v2/venues/search" parameters:params success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSLog(@"Success");
        NSLog(@"Mapping: %@", mappingResult);
        self.coffeeArray = [mappingResult array];
        for (Venue *ven in self.coffeeArray) {
            NSLog(@"%@", ven.name);
            NSLog(@"%@", ven.location.distance);
        }
        self.coffeeArray = [self.coffeeArray sortedArrayUsingComparator:^NSComparisonResult(Venue *a, Venue *b) {
            NSNumber *aDist = a.location.distance;
            NSNumber *bDist = b.location.distance;
            return [aDist compare:bDist];
        }];
        [self.tableView reloadData];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [self locationsIntoArray:[self.coffeeArray copy]];
        });
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"Fail");
    }];
    
}

-(void)locationsIntoArray:(NSArray *)array {
    
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    self.lastLocation = [locations lastObject];
    NSLog(@"Got location");
}

-(void)showMap {
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)insertNewObject:(id)sender
{
    if (!_objects) {
        _objects = [[NSMutableArray alloc] init];
    }
    [_objects insertObject:[NSDate date] atIndex:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.coffeeArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    Venue *ven = self.coffeeArray[indexPath.row];
    cell.textLabel.text = ven.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ m", ven.location.distance];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_objects removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSDate *object = _objects[indexPath.row];
        [[segue destinationViewController] setDetailItem:object];
    }
}

@end

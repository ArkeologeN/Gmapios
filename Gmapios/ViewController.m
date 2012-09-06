//
//  ViewController.m
//  Gmapios
//
//  Created by Ali Hashmi on 9/6/12.
//  Copyright (c) 2012 The Plumtree Group. All rights reserved.
//

#import "ViewController.h"
#import "ASIHTTPRequest.h"
#import "MyLocation.h"
#import "SBJSON.h"
#import "MBProgressHUD.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize _mapview;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [self set_mapview:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)viewWillAppear:(BOOL)animated {
    
    CLLocationCoordinate2D zoomLocation;
    zoomLocation.latitude = 39.281516;
    zoomLocation.longitude = -76.580806;
    
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 0.5*METERS_PER_MILE, 0.5*METERS_PER_MILE);
    
    MKCoordinateRegion adjustRegion = [_mapview regionThatFits:viewRegion];
    
    [_mapview setRegion:adjustRegion animated:YES];
}

- (IBAction)refreshTapped:(id)sender {
    
    // 1
    MKCoordinateRegion mapRegion = [_mapview region];
    CLLocationCoordinate2D centerLocation = mapRegion.center;
    
    // 2
    NSString *jsonFile = [[NSBundle mainBundle] pathForResource:@"command" ofType:@"json"];
    NSString *formatString = [NSString stringWithContentsOfFile:jsonFile encoding:NSUTF8StringEncoding error:nil];
    NSString *json = [NSString stringWithFormat:formatString, 
                      centerLocation.latitude, centerLocation.longitude, 0.5*METERS_PER_MILE];
    
    // 3
    NSURL *url = [NSURL URLWithString:@"http://data.baltimorecity.gov/api/views/INLINE/rows.json?method=index"];
    
    // 4
    ASIHTTPRequest *_request = [ASIHTTPRequest requestWithURL:url];
    __weak ASIHTTPRequest *request = _request;
    
    request.requestMethod = @"POST";    
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request appendPostData:[json dataUsingEncoding:NSUTF8StringEncoding]];
    // 5
    [request setDelegate:self];
    [request setCompletionBlock:^{         
        NSString *responseString = [request responseString];
        NSLog(@"Response: %@", responseString);
        [self plotCrimePositions:responseString];
    }];
    [request setFailedBlock:^{
        NSError *error = [request error];
        NSLog(@"Error: %@", error.localizedDescription);
    }];
    
    // 6
    [request startAsynchronous];
    
    MBProgressHUD *hud = [MBProgressHUD  showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Loading Arrest..";
    
    [MBProgressHUD  hideHUDForView:self.view animated:YES];
    
}

- (void)plotCrimePositions:(NSString *)responseString {
    
    for (id<MKAnnotation> annotations in _mapview.annotations) {
        [_mapview removeAnnotation:annotations];
    }
    
    NSDictionary *root  = [responseString JSONValue];
    NSArray *data = [root objectForKey:@"data"];
    
    for (NSArray * row in data) {
        
        NSNumber * latitude = [[row objectAtIndex:21] objectAtIndex:1];
        NSNumber * longitude = [[row objectAtIndex:21] objectAtIndex:2];
        NSString * crimeDescription = [row objectAtIndex:17];
        NSString * address = [row objectAtIndex:13];
        
        CLLocationCoordinate2D coordinate;
        coordinate.latitude = latitude.doubleValue;
        coordinate.longitude = longitude.doubleValue;
        
        MyLocation *annotation = [[MyLocation  alloc] initWithName:crimeDescription address:address coordinate:coordinate];
        
        [_mapview addAnnotation:annotation];
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    
    static NSString *identifier = @"MyLocation";
    if ([annotation isKindOfClass:[MyLocation class]]) {
        
        MKAnnotationView *annotationView = [_mapview dequeueReusableAnnotationViewWithIdentifier:identifier];
        
        if ( annotationView == nil) {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        } else {
            annotationView.annotation = annotation;
        }
        
        annotationView.enabled = YES;
        annotationView.canShowCallout = YES;
        annotationView.image = [UIImage imageNamed:@"arrest.png"];
        
        return annotationView;
    }
    
    return nil;
}

@end

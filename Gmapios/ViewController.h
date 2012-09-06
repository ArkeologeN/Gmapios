//
//  ViewController.h
//  Gmapios
//
//  Created by Hamza Waqas on 9/6/12.
//  Copyright (c) 2012 The Plumtree Group. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

#define METERS_PER_MILE 1609.344

@interface ViewController : UIViewController <MKMapViewDelegate> {
    BOOL _doneInitialZoom;
}
@property (weak, nonatomic) IBOutlet MKMapView *_mapview;

- (IBAction)refreshTapped:(id)sender;

@end

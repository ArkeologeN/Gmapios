//
//  MyLocation.h
//  Gmapios
//
//  Created by Ali Hashmi on 9/6/12.
//  Copyright (c) 2012 The Plumtree Group. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MyLocation : NSObject <MKAnnotation> {
    NSString *_name;
    NSString *_address;
    CLLocationCoordinate2D _coordinate;
}

@property (copy) NSString *name;
@property (copy) NSString *address;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

- (id) initWithName: (NSString *) name address: (NSString *)adress coordinate: (CLLocationCoordinate2D) coordinate;

@end

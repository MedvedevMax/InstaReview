//
//  IRBooksContainerDelegate.h
//  InstaReview
//
//  Created by Max Medvedev on 3/8/14.
//  Copyright (c) 2014 Max Medvedev. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol IRBooksContainerDelegate <NSObject>

@required
@property (nonatomic, readonly) NSArray *books;

@end

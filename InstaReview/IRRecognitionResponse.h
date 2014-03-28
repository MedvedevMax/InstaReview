//
//  IRRecognitionResponse.h
//  InstaReview
//
//  Created by Max Medvedev on 3/29/14.
//  Copyright (c) 2014 Max Medvedev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IRRecognitionResponse : NSObject

@property (nonatomic) BOOL success;
@property (nonatomic) float confidence;

@property (nonatomic, strong) NSArray *books;

+ (IRRecognitionResponse*)responseWithJSON:(NSData*)jsonData;

@end

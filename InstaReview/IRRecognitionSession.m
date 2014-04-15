//
//  IRRecognitionSession.m
//  InstaReview
//
//  Created by Max Medvedev on 3/29/14.
//  Copyright (c) 2014 Max Medvedev. All rights reserved.
//

#import "IRRecognitionSession.h"
#import "IRHTTPClient.h"
#import "IRReviewsFetcher.h"
#import "IRPhotoPreparer.h"

@interface IRRecognitionSession ()

@property (nonatomic, strong) IRReviewsFetcher *reviewsFetcher;
@property (nonatomic, strong) IRPhotoPreparer *photoPreparer;

@property (nonatomic, strong) NSMutableArray *responses;
@property (atomic) int currentlyPushingCount;

@end

@implementation IRRecognitionSession

#define IMG_JPEG_QUALITY 0.4f

- (void)pushPhoto:(UIImage *)image
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self uploadAndQueueImage:image withCropCoefficient:1.0f];
    });
}

- (void)uploadAndQueueImage:(UIImage *)image withCropCoefficient:(float)coef
{
    self.currentlyPushingCount++;
    NSLog(@"Image pushed (crop coef = %f)", coef);

    UIImage *imageToUpload = [self.photoPreparer prepareImageForRecognition:image];
    NSData *imgData = UIImageJPEGRepresentation(imageToUpload, IMG_JPEG_QUALITY);
    
    IRRecognitionResponse *response = [self.reviewsFetcher getResponseForJPEGRepresentation:imgData];
    NSLog(@"Response received: %d; confidence = %f",
          response.success, response.confidence);
    if (response.success) {
        [self.responses addObject:response];
    }
    self.currentlyPushingCount--;
}

- (NSArray*)waitAndGetReviews
{
    // waiting for all uploads to be finished
    while (self.currentlyPushingCount > 0) {
        [NSThread sleepForTimeInterval:0.1f];
    }
    
    if (self.responses.count == 0) {
        return nil;
    }
    
    // finding most confindent result
    IRRecognitionResponse *bestResponse = nil;
    for (IRRecognitionResponse *response in self.responses) {
        if (!bestResponse || response.confidence > bestResponse.confidence) {
            bestResponse = response;
        }
    }
    
    return bestResponse.books;
}

#pragma mark - Properties lazy instantiation

- (IRReviewsFetcher*)reviewsFetcher
{
    if (!_reviewsFetcher)
        _reviewsFetcher = [[IRReviewsFetcher alloc] init];
    
    return _reviewsFetcher;
}

- (IRPhotoPreparer *)photoPreparer
{
    if (!_photoPreparer) {
        _photoPreparer = [[IRPhotoPreparer alloc] init];
    }
    
    return _photoPreparer;
}

- (NSMutableArray *)responses
{
    if (!_responses) {
        _responses = [[NSMutableArray alloc] init];
    }
    
    return _responses;
}

@end

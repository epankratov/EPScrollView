//
//  ImageDownloader.m
//  EPScrollView
//
//  Created by Eugene Pankratov on 23.04.15.
//  Copyright (c) 2015 ua.net.pankratov. All rights reserved.
//

#import "ImageDownloader.h"
#import "Global.h"

static ImageDownloader *_sharedImageDownloader;

NSString *const kStringKey_EmptyCacheValue      = @"empty data";

@interface ImageDownloader () {
    NSCache *_imagesCache;
}

- (id)init;

@end

@implementation ImageDownloader

#pragma mark - Singleton and lifetime methods

+ (ImageDownloader *)sharedInstance
{
    @synchronized(self)
    {
        if (_sharedImageDownloader == nil) {
            _sharedImageDownloader = [[ImageDownloader alloc] init];
        }
    }
    return _sharedImageDownloader;
}

- (id)init
{
    self = [super init];
    if (self != nil) {
        _imagesCache = [[NSCache alloc] init];
    }
    return self;
}

- (NSData *)downloadPictureDataWithURL:(NSString *)urlString status:(NSInteger *)statusValue
{
    NSData *receivedData = nil;
    *statusValue = 0;
    // Send synchronous GET query with given URL
    if ([_imagesCache objectForKey:urlString]) {
        // Check the cache and its' value
        if ([[_imagesCache objectForKey:urlString] isKindOfClass:[NSString class]] && [(NSString *)[_imagesCache objectForKey:urlString] isEqualToString:kStringKey_EmptyCacheValue]) {
        }
        else {
//            VLog(@"DEBUG: object found in cache: %@", urlString);
            receivedData = [_imagesCache objectForKey:urlString];
        }
    } else {
        NSError *err = nil;
        NSURLResponse *response = nil;
        NSURL *url = [NSURL URLWithString:urlString];
        NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:kNetworkTimeout];
        // Put temporary object to the cache
        [_imagesCache setObject:kStringKey_EmptyCacheValue forKey:urlString];
        receivedData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if ([httpResponse statusCode] != 200) {
            *statusValue = [httpResponse statusCode];
            // Catch an error
            if ([err localizedDescription])
                VLog(@"DEBUG: URL %@ ; HTTP error: %@", url, [err localizedDescription]);
            else {
                VLog(@"DEBUG: URL %@ ; HTTP status code: %ld", url, (long)[httpResponse statusCode]);
            }
            receivedData = nil;
            // Remove any objects from cache
            [_imagesCache removeObjectForKey:urlString];
        } else {
            [_imagesCache setObject:receivedData forKey:urlString];
        }
    }
    return receivedData;
}

- (NSData *)downloadPictureDataByImageOrigin:(NSString *)imageOrigin
                                    andWidth:(NSInteger)width
                                   andHeight:(NSInteger)height
                                      status:(NSInteger *)statusValue
{
    return [self downloadPictureDataWithURL:[NSString stringWithFormat:@"http://image.api.viewster.com/movies/%@/image?width=%lu&height=%lu", imageOrigin, (long)width, (long)height] status:statusValue];
}

@end

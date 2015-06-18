//
//  ImageDownloader.h
//  EPScrollView
//
//  Created by Eugene Pankratov on 23.04.15.
//  Copyright (c) 2015 ua.net.pankratov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageDownloader : NSObject {

}

+ (ImageDownloader *)sharedInstance;

// Quick synchronous download method intended to download data
- (NSData *)downloadPictureDataWithURL:(NSString *)urlString;
- (NSData *)downloadPictureDataByImageOrigin:(NSString *)imageOrigin andWidth:(NSInteger)width andHeight:(NSInteger)height;

@end

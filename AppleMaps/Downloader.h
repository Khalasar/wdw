//
//  ImageDownloader.h
//  WegDesWandels
//
//  Created by Andre St on 15.08.14.
//  Copyright (c) 2014 André Stuhrmann. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Downloader : NSObject <NSURLSessionDelegate, NSURLSessionDownloadDelegate>
+ (instancetype)shared;
- (NSURLSessionDownloadTask *)downloadTaskWithURL:(NSURL *)url;
@end

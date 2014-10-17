//
//  ImageDownloader.m
//  WegDesWandels
//
//  Created by Andre St on 15.08.14.
//  Copyright (c) 2014 André Stuhrmann. All rights reserved.
//

#import "Downloader.h"
#import "AppDelegate.h"
#import "SSZipArchive.h"

@interface Downloader ()
@property (strong, nonatomic) NSURLSession *session;
@end

@implementation Downloader

+ (instancetype)shared
{
    static dispatch_once_t onceToken;
    static Downloader *downloader = nil;
    dispatch_once(&onceToken, ^{
        downloader = [Downloader new];
    });
    return downloader;
}

- (id)init
{
    self = [super init];
    if (self) {
        NSURLSessionConfiguration *backgroundConfig = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"MySession"];
        
        self.session = [NSURLSession sessionWithConfiguration:backgroundConfig
                                                     delegate:self
                                                delegateQueue:nil];
    }
    
    return self;
}

#pragma mark - Public interface

- (NSURLSessionDownloadTask *)downloadTaskWithURL:(NSURL *)url
{
    return [self.session downloadTaskWithURL:url];
}

#pragma mark - NSURLSessionDownloadDelegate mthods

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    CGFloat progress = (CGFloat)totalBytesWritten / totalBytesExpectedToWrite;
    NSDictionary *userInfo = @{@"progress": @(progress)};
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DownloadProgress"
                                                        object:downloadTask
                                                      userInfo:userInfo];
}

-(void)URLSession:(NSURLSession *)session
     downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location
{
    // Build the file path based on the original requests URL
    NSString *fileName = [[NSString alloc] initWithString:[downloadTask.response suggestedFilename]];
    NSString *filePath = [self buildDownloadPath:downloadTask.originalRequest.URL withFilename:fileName];
    //copy the temp file to the filePath
    NSData *data = [[NSData alloc] initWithContentsOfURL:location];
    
    [[NSFileManager defaultManager] createFileAtPath:filePath
                                            contents:data
                                          attributes:nil];
    //[[NSFileManager defaultManager] copyItemAtPath:[location path] toPath:filePath error:nil];
    
    // create a userInfo dictionary to pass along the original URL
    NSString *url = [[NSString alloc] initWithFormat:@"%@", downloadTask.originalRequest.URL];
    NSDictionary *userInfo = @{@"url": url};
    
    if ([self zipFile:fileName]) {
        [self unzipFile:fileName atPath:filePath];
    }
    
    // Post the completion notification
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DownloadCompletion"
                                                        object:downloadTask
                                                      userInfo:userInfo];
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes
{
    
}

#pragma mark - Background delegate method

-(void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session;
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    if (appDelegate.backgroundSessionCompletionHandler) {
        appDelegate.backgroundSessionCompletionHandler();
        appDelegate.backgroundSessionCompletionHandler = nil;
    }
}

#pragma mark - unzip methods

-(void)unzipFile:(NSString *)file atPath:(NSString *)path
{
    NSString *directory = [[NSString alloc]initWithString:[file componentsSeparatedByString:@"."][0]];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsPath = [paths[0] stringByAppendingPathComponent:@"places"];
    docsPath = [docsPath stringByAppendingPathComponent:directory];
    
    [[NSFileManager defaultManager] createDirectoryAtPath:docsPath withIntermediateDirectories:NO attributes:nil error:nil];
    
    [SSZipArchive unzipFileAtPath:path toDestination:docsPath];
    [self deleteZipFile:path];
}

-(void)deleteZipFile:(NSString *)filePath
{
    NSError *error =nil;
    [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
}

#pragma mark - Helper methods

- (NSString *)buildDownloadPath:(NSURL *)imageURL withFilename:(NSString *)filename
{
    NSString *directory = [[NSString alloc]initWithString:[imageURL.lastPathComponent componentsSeparatedByString:@"."][0]];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsPath = [paths[0] stringByAppendingPathComponent:directory];
    
    [[NSFileManager defaultManager] createDirectoryAtPath:docsPath withIntermediateDirectories:NO attributes:nil error:nil];
    
    return [docsPath stringByAppendingPathComponent:filename];
}

- (BOOL)zipFile:(NSString *)filename
{
    return [[filename componentsSeparatedByString:@"."][1] isEqualToString:@"zip"];
}

@end

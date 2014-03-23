//
//  Downloader.m
//  ProgressChallenge
//
//  Created by Matt Galloway on 25/08/2013.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import "Downloader.h"

@interface Downloader () <NSURLConnectionDataDelegate, NSURLConnectionDelegate>

@property (nonatomic, strong) NSURL *url;

@property (nonatomic, copy) DownloaderHandler handler;
@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSMutableData *data;
@property (nonatomic, strong) NSProgress *progress;

@end

@implementation Downloader

#pragma mark -

- (instancetype)initWithURL:(NSURL*)url {
  if ((self = [super init])) {
    _url = url;
  }
  return self;
}


#pragma mark -

- (void)startWithHandler:(DownloaderHandler)handler {
  self.handler = handler;
  
  // TODO: Initialise progress, setting the parent to the thread's currentProgress
  self.progress = [[NSProgress alloc] initWithParent:[NSProgress currentProgress] userInfo:nil];
  
  NSURLRequest *request = [NSURLRequest requestWithURL:_url];
  
  self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
  [_connection start];
}

- (void)_finishWithError:(NSError*)error {
  // TODO: Set the completed unit count
  self.progress.completedUnitCount = self.progress.totalUnitCount;
  
  if (_handler) {
    _handler(_data, error);
    self.handler = nil;
  }
  
  self.data = nil;
  self.connection = nil;
}


#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
  self.data = [NSMutableData new];
  // TODO: Set the total unit count
  self.progress.totalUnitCount = [response expectedContentLength];
  
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
  [_data appendData:data];
  // TODO: Set the completed unit count
  self.progress.completedUnitCount = MIN(self.data.length, self.progress.totalUnitCount);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
  [self _finishWithError:nil];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
  self.data = nil;
  [self _finishWithError:error];
}

@end

//
//  DownloadProcessor.m
//  ProgressChallenge
//
//  Created by Matt Galloway on 25/08/2013.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import "DownloadProcessor.h"

#import "Download.h"
#import "Downloader.h"

#import "SSZipArchive.h"

@interface DownloadProcessor ()

@property (nonatomic, strong) Download *download;

@property (nonatomic, strong) Downloader *downloader;
@property (nonatomic, copy) DownloadProcessorHandler completion;
@property (nonatomic, strong) NSProgress *progress;

@end

@implementation DownloadProcessor

- (instancetype)initWithDownload:(Download*)download {
  if ((self = [super init])) {
    _download = download;
  }
  return self;
}

- (void)startWithHandler:(DownloadProcessorHandler)completion {
  self.completion = completion;
  
  // TODO: Initialise progress with a relevant total unit count
  self.progress = [NSProgress progressWithTotalUnitCount:10];
  
  // TODO: Become current progress, setting a number of pending units
  [self.progress becomeCurrentWithPendingUnitCount:8];
  
  self.downloader = [[Downloader alloc] initWithURL:_download.url];
  [_downloader startWithHandler:^(NSData *data, NSError *error) {
    // TODO: Set completed unit count
    self.progress.completedUnitCount = 8;
    
    NSString *tempDir = NSTemporaryDirectory();
    NSUUID *uuid = [NSUUID new];
    
    NSString *unzipFolder = [tempDir stringByAppendingPathComponent:[uuid UUIDString]];
    NSString *zipFilename = [unzipFolder stringByAppendingPathExtension:@"zip"];
    
    [data writeToFile:zipFilename atomically:YES];
    
    // TODO: Become current progress, setting a number of pending units
    [self.progress becomeCurrentWithPendingUnitCount:2];
    
    [SSZipArchive unzipFileAtPath:zipFilename toDestination:unzipFolder];
    
    // TODO: Resign current progress and set completed unit count
    [self.progress resignCurrent];
    self.progress.completedUnitCount = self.progress.totalUnitCount;
    
    _download.downloadedDirectoryPath = unzipFolder;
    
    if (_completion) {
      _completion();
      self.completion = nil;
    }
    
    self.progress = nil;
  }];
  
  // TODO: Resign current progress
  [self.progress resignCurrent];
}

@end

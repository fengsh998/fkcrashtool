//
//  FKArchiveFile.m
//  FKAnalysisCrash
//
//  Created by fengsh on 16/6/17.
//  Copyright © 2016年 fengsh. All rights reserved.
//

#import "FKArchiveFile.h"

@interface FKArchiveFile ()

@end

@implementation FKArchiveFile

- (id)initwithFileString:(NSString *)string
{
    id ret = [super init];
    if (ret) {
        _fileUrl = [NSURL fileURLWithPath:string];
        if (_fileUrl) {
            [self readArchiveFile:_fileUrl];
        }
    }
    
    return ret;
}

- (void)readArchiveFile:(NSURL *)archivefile
{
    _fileName = [archivefile lastPathComponent];
    
    _dSYMUrl = [archivefile URLByAppendingPathComponent:@"dSYMs"];
    _appUrl = [archivefile URLByAppendingPathComponent:@"Products/Applications/"];
    
    NSArray *filelist = [[NSFileManager defaultManager]contentsOfDirectoryAtPath:_dSYMUrl.path error:nil];
    _dSYMUrl = [_dSYMUrl URLByAppendingPathComponent:filelist[0]];
    
    filelist = [[NSFileManager defaultManager]contentsOfDirectoryAtPath:_appUrl.path error:nil];
    _appUrl = [_appUrl URLByAppendingPathComponent:filelist[0]];
    
    _appName = [[_appUrl lastPathComponent]stringByDeletingPathExtension];
}


@end

@implementation CPUAndUUID



@end

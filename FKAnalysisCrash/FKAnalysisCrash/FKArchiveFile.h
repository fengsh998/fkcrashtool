//
//  FKArchiveFile.h
//  FKAnalysisCrash
//
//  Created by fengsh on 16/6/17.
//  Copyright © 2016年 fengsh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CPUAndUUID : NSObject
@property (nonatomic,copy)  NSString                    *uuid;
@property (nonatomic,copy)  NSString                    *cpu;
@end


@interface FKArchiveFile : NSObject
@property (nonatomic,copy)      NSString                        *fileName;
@property (nonatomic,copy)      NSString                        *appName;
@property (nonatomic,readonly)  NSURL                           *fileUrl;
@property (nonatomic,readonly)  NSURL                           *dSYMUrl;
@property (nonatomic,readonly)  NSURL                           *appUrl;
@property (nonatomic,strong)    NSMutableArray<CPUAndUUID*>     *cpuArchs;


- (id)initwithFileString:(NSString *)string;

@end

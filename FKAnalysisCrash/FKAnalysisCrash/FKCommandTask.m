//
//  FKCommandTask.m
//  FKAnalysisCrash
//
//  Created by fengsh on 16/6/18.
//  Copyright © 2016年 fengsh. All rights reserved.
//

#import "FKCommandTask.h"

@implementation FKCommandTask

+ (NSString *)hexStringSum:(NSString *)ahex with:(NSString *)bhex
{
    //先以16为参数告诉strtoul字符串参数表示16进制数字，然后使用0x%X转为数字类型
    unsigned long long int avalue = strtoul([ahex UTF8String],0,16);
    unsigned long long int bvalue = strtoul([bhex UTF8String],0,16);
    
    unsigned long long int sumvalue = avalue + bvalue;
    
    return [NSString stringWithFormat:@"0x%llx",sumvalue];
}

+ (NSString *)hexStringSub:(NSString *)ahex with:(NSString *)bhex
{
    //先以16为参数告诉strtoul字符串参数表示16进制数字，然后使用0x%X转为数字类型
    unsigned long long int avalue = strtoul([ahex UTF8String],0,16);
    unsigned long long int bvalue = strtoul([bhex UTF8String],0,16);
    
    unsigned long long int subvalue = avalue - bvalue;
    
    return [NSString stringWithFormat:@"0x%llx",subvalue];
}



+ (NSString *)readArchive:(NSString *)cmd withArgs:(NSArray *)args
{
    NSTask *task;
    task = [[NSTask alloc] init];
    [task setLaunchPath:cmd];
    
    if (args) {
        [task setArguments: args];
    }
    
    NSPipe *pipe;
    pipe = [NSPipe pipe];
    [task setStandardOutput: pipe];
    
    NSFileHandle *file;
    file = [pipe fileHandleForReading];
    
    [task launch];
    
    NSData *data;
    data = [file readDataToEndOfFile];
    
    NSString *string;
    string = [[NSString alloc] initWithData: data
                                   encoding: NSUTF8StringEncoding];
    
    return string;
}

/*
 args = [NSArray arrayWithObjects: @"--uuid",[avf.dSYMUrl path],nil];
 //从app中取也可以
 //args = [NSArray arrayWithObjects: @"--uuid",[[avf.appUrl path] stringByAppendingPathComponent:avf.appName],nil];
 */

+ (NSArray *)readUUIDBydSYMInfo:(NSString *)dsympath
{
    NSString *string = [self readArchive:@"/usr/bin/dwarfdump" withArgs:[NSArray arrayWithObjects: @"--uuid",dsympath,nil]];
    NSArray *list = [string componentsSeparatedByString:@"\n"];
    return list;
}

+ (NSArray *)readUUIDByAppInfo:(NSString *)apppath
{
    return [self readUUIDBydSYMInfo:apppath];
}

+ (NSString *)parseCrashAddressFormdSYM:(NSString *)dsymfile withCrashAddress:(NSString *)crashaddr inCpuArch:(NSString *)arch
{
    if (!dsymfile || !arch) {
        return nil;
    }
    
    NSString * dsym = [dsymfile stringByAppendingPathComponent:@"Contents/Resources/DWARF"];
    NSArray *filelist = [[NSFileManager defaultManager]contentsOfDirectoryAtPath:dsym error:nil];
    dsym = [dsym stringByAppendingPathComponent:filelist[0]];
    
    NSString *string = [self readArchive:@"/usr/bin/xcrun" withArgs:[NSArray arrayWithObjects: @"atos",@"-o",dsym,@"-arch",arch,crashaddr,nil]];
    return string;
}

//xcrun atos -arch armv7 -o mobileguard.app/mobileguard 0x00037000
+ (NSString *)parseCrashAddressFormApp:(NSString *)appfile withCrashAddress:(NSString *)crashaddr inCpuArch:(NSString *)arch
{
    NSString *appbinary = [appfile stringByAppendingPathComponent:[[appfile lastPathComponent]stringByDeletingPathExtension]];
    NSString *string = [self readArchive:@"/usr/bin/xcrun" withArgs:[NSArray arrayWithObjects: @"atos",@"-arch",arch,@"-o",appbinary,crashaddr,nil]];
    return string;
}

@end

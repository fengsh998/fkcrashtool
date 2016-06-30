//
//  FKCommandTask.h
//  FKAnalysisCrash
//
//  Created by fengsh on 16/6/18.
//  Copyright © 2016年 fengsh. All rights reserved.
//
/*
 1、symbolicatecrash
 
 symbolicatecrash是一个将堆栈地址符号化的脚本，输入参数是苹果官方格式的崩溃日志及本地的.dSYM文件，执行方式如下：
 
 $ symbolicatecrash XX.crash [XX.app.dSYM] > xx.sym.crash# 如果输入.dSYM参数，将只解析系统库对应的符号
 使用symbolicatecrash工具的限制就在于只能分析官方格式的崩溃日志，需要从具体的设备中导出，获取和操作都不是很方便，而且，符号化的结果也是没有具体的行号信息的，也经常会出现符号化失败的情况。
 实际上Xcode的Organizer内置了symbolicatecrash工具，所以开发者才可以直接看到符号化的错误日志。
 
 2、atos
 
 更普遍的情况是，开发者能获取到错误堆栈信息，而使用atos工具就是把地址对应的具体符号信息找到。
 
 atos实际是一个可以把地址转换为函数名（包括行号）的工具，它的执行方式如下：
 //通过dsym解
 $ xcrun atos -o executable -arch architecture -l loadAddress
 address ...
 说明：
 
 错误地址堆栈
 
 3  CoreFoundation           0x254b5949 0x253aa000 + 1096008
 4  CoreFoundation           0x253e6b68 _CF_forwarding_prep_0 + 24
 5  SuperSDKTest             0x0010143b 0x000ef000 + 74808
 
 loadAddress 表示函数的动态加载地址，对应崩溃地址堆栈中 + 号前面的地址，即0x000ef000
 
 address 表示运行时地址、对应崩溃地址堆栈中第一个地址，即0x0010143b
 
 实际上，崩溃地址堆栈中+号前后的地址相加即是运行时地址，即0x000ef000 + 74808 = 0x0010143b
 
 执行命令查询地址的符号，可以看到如下结果：
 
 $ xcrun atos -o SuperSDKTest.app.dSYM/Contents/Resources/DWARF/SuperSDKTest -arch armv7 -l 0x000ef000
 0x0010143b
 -[ViewController didTriggerClick:] (in SuperSDKTest) (ViewController.m:35)
 开发者在具体的运用中，是可以通过编写一个脚本来实现符号化错误地址堆栈的。
 
 通过app解(即编译成功后在build/products里生成的app)
 $ xcrun atos -arch armv7 -o mobileguard.app/mobileguard 0x00037000
 */

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger,CPU_ARCH) {
    c_Arm64,
    c_Armv7,
    c_ArmV7s
};

@interface FKCommandTask : NSObject

/**
   eg:  @"0x44545" + @"0x4355"
 */
+ (NSString *)hexStringSum:(NSString *)ahex with:(NSString *)bhex;
//eg:  @"0x44545" - @"0x4355"
+ (NSString *)hexStringSub:(NSString *)ahex with:(NSString *)bhex;

///读dsym uuid
+ (NSArray *)readUUIDBydSYMInfo:(NSString *)dsympath;
///读app uuid
+ (NSArray *)readUUIDByAppInfo:(NSString *)apppath;
/** 
    使用dsym文件解crash地址
    dsymfile : dSYM文件
    crashaddr : 崩溃地址
    arch : 架构类型 从crash文件中可以看到是arm64还是v7
 */
+ (NSString *)parseCrashAddressFormdSYM:(NSString *)dsymfile withCrashAddress:(NSString *)crashaddr inCpuArch:(NSString *)arch;
/**
 使用app解crash地址
 appfile : 最源始输出的app文件,即可以从ipa中显示包文件里找到的app 一定要不改变app名改，否则失败
 crashaddr : 崩溃地址
 arch : 架构类型 从crash文件中可以看到是arm64还是v7
 */
+ (NSString *)parseCrashAddressFormApp:(NSString *)appfile withCrashAddress:(NSString *)crashaddr inCpuArch:(NSString *)arch;

@end

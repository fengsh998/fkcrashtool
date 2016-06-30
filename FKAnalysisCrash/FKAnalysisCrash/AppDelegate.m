//
//  AppDelegate.m
//  FKAnalysisCrash
//
//  Created by fengsh on 16/6/16.
//  Copyright © 2016年 fengsh. All rights reserved.
//
/*
 读取 slide 的 API
 这个 slide 的计算还是挺 恶心的 ，要 查看 binary image 的到 load address ，还要查看  对用 ELF 中 _TEXT 的 Load Command 虚拟空间范围.
 
 如果 自己写一个 模块 来 收集 NSException 的话 ，大可不必这么繁琐，因为 程序 运行时 有 api 是可以 直接获取这个 binary image 对应的  slide 值的 。
 
 如下：
 
 
 [objc] view plain copy 在CODE上查看代码片派生到我的代码片
 #import <mach-o/dyld.h>
 void calculate(void) {
 for (uint32_t i = 0; i < _dyld_image_count(); i++) {
 if (_dyld_get_image_header(i)->filetype == MH_EXECUTE) {
 long slide = _dyld_get_image_vmaddr_slide(i);
 break;
 }
 }
 }
 */

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end

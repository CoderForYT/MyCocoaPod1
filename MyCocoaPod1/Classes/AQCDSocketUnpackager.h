//
//  AQCDSocketUnpackager.h
//  UDP_Socket_Client
//
//  Created by MarkMyLove-Mac on 2017/6/28.
//  Copyright © 2017年 林钰堂. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface AQCDSocketUnpackager : NSObject
/// 接收数据包，当前包解包成功
- (void)unpackageTCP_MessagePackage:(NSData *)package complete: (void(^)())complete;
@end

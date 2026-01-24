//
//  HXRecordDeleteKeyModel.h
//  HXJBLESDK
//
//  Created by JQ on 2019/4/23.
//  Copyright © 2019年 JQ. All rights reserved.
//

#import "HXRecordBaseModel.h"

/**
en:
 Delete a key record
 For example, it can be parsed as: "User xxx deleted a xxx key"
 */
/**
cn:
 删除一个钥匙记录
 例如可解析为：“xxx用户删除了一枚xxx钥匙”
 */
@interface HXRecordDeleteKeyModel : HXRecordBaseModel

/**
en:
 Operator's user ID
 */
/**
cn:
 操作人的用户Id
 */
@property (nonatomic, assign) int operKeyGroupId;

/**
en:
 Deleted key Id
 */
/**
cn:
 被删除的钥匙Id
 */
@property (nonatomic, assign) int delLockKeyId;

- (NSDictionary *)dicFromObject;

@end


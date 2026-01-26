#import "OneShotResult.h"

@interface OneShotResult ()
@property (nonatomic, copy) FlutterResult result;
@property (atomic, assign) BOOL replied;
@end

@implementation OneShotResult

- (instancetype)initWithResult:(FlutterResult)result {
    self = [super init];
    if (self) {
        _result = [result copy];
        _replied = NO;
    }
    return self;
}

- (void)runOnMain:(dispatch_block_t)block {
    if ([NSThread isMainThread]) {
        block();
    } else {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}

- (void)success:(id)value {
    if (self.replied) return;
    self.replied = YES;
    FlutterResult r = self.result;
    [self runOnMain:^{
        if (r) r(value);
    }];
}

- (void)error:(NSString *)code message:(NSString *)message details:(id)details {
    if (self.replied) return;
    self.replied = YES;
    FlutterResult r = self.result;
    FlutterError *err = [FlutterError errorWithCode:code message:message details:details];
    [self runOnMain:^{
        if (r) r(err);
    }];
}

@end

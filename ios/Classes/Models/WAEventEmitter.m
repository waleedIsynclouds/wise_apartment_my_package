//
//  WAEventEmitter.m
//  wise_apartment
//
//  Thread-safe event emitter implementation
//

#import "WAEventEmitter.h"

@interface WAEventEmitter ()
@property (nonatomic, copy, nullable) FlutterEventSink eventSink;
@property (nonatomic, strong) dispatch_queue_t eventQueue;
@end

@implementation WAEventEmitter

- (instancetype)init {
    self = [super init];
    if (self) {
        // Create serial queue for thread-safe access to event sink
        _eventQueue = dispatch_queue_create("com.wiseapartment.event_emitter", DISPATCH_QUEUE_SERIAL);
        NSLog(@"[WAEventEmitter] Event emitter initialized");
    }
    return self;
}

- (void)setEventSink:(FlutterEventSink)eventSink {
    NSLog(@"[WAEventEmitter] Setting event sink");
    dispatch_async(self.eventQueue, ^{
        self.eventSink = eventSink;
        NSLog(@"[WAEventEmitter] Event sink set successfully");
    });
}

- (void)clearEventSink {
    NSLog(@"[WAEventEmitter] Clearing event sink");
    dispatch_async(self.eventQueue, ^{
        self.eventSink = nil;
        NSLog(@"[WAEventEmitter] Event sink cleared");
    });
}

- (void)emitEvent:(NSDictionary *)event {
    if (!event || ![event isKindOfClass:[NSDictionary class]]) {
        NSLog(@"[WAEventEmitter] ERROR: Invalid event format: %@", event);
        return;
    }
    
    // Validate event has "type" key
    if (!event[@"type"]) {
        NSLog(@"[WAEventEmitter] ERROR: Event missing 'type' key: %@", event);
        return;
    }
    
    NSLog(@"[WAEventEmitter] Emitting event: %@", event[@"type"]);
    
    // Thread-safe emission
    dispatch_async(self.eventQueue, ^{
        if (self.eventSink) {
            NSLog(@"[WAEventEmitter] Dispatching event to Flutter: %@", event);
            // Flutter callbacks MUST be on main thread
            dispatch_async(dispatch_get_main_queue(), ^{
                self.eventSink(event);
                NSLog(@"[WAEventEmitter] Event dispatched successfully");
            });
        } else {
            NSLog(@"[WAEventEmitter] WARNING: No active event sink, dropping event: %@", event[@"type"]);
        }
    });
}

- (BOOL)hasActiveListener {
    __block BOOL hasListener = NO;
    dispatch_sync(self.eventQueue, ^{
        hasListener = (self.eventSink != nil);
    });
    return hasListener;
}

@end

#import "Quest.h"

@implementation Quest
@synthesize questImage;
@synthesize questName;
@synthesize questPoint;

- (id)init {
    if(self = [super init]) {
        
    }
    return self;
}

+ (id) quest:(NSString *)name point:(NSInteger)point imageName:(NSString *)imageName {
    Quest *p = [[[Quest alloc] init] autorelease];
    
    p.questName = name;
    p.questPoint = point;
    p.questImage = [UIImage imageNamed:imageName];
    
    return p;
}

- (void)dealloc {
    [questImage release];
    [questName release];
    
    [super dealloc];
}
@end

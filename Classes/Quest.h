#import <Foundation/Foundation.h>

@interface Quest : NSObject

@property (nonatomic, retain) UIImage *questImage;
@property (retain) NSString *questName;
@property NSInteger questPoint;

+ (id) quest:(NSString *)name point:(NSInteger)point imageName:(NSString *)imageName;

@end

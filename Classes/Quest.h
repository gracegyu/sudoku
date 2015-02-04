#import <Foundation/Foundation.h>

@interface Quest : NSObject


typedef enum {
    eQuestHint = 0,
    eQuestUndo,
    eQuestRedo,
    eQuestClearDaily0,
    eQuestClearDaily1,
    eQuestClearDaily2,
    eQuestClearDaily3,
    eQuestClearLevel0,
    eQuestClearLevel1,
    eQuestClearLevel2,
    eQuestClearLevel3,
    eQuestClearLevel4,
    eQuestCheckScore,
    eQuestCheckHelp,
    eQuestSendfeedback,
    eQuestResetGame,
    eQuestPuzzleShare,
    eQuestRecordShare,
    eQuestVisitRanking,
    eQuestBookmarking,
    eQuestGoBack,
    eQuestAutomemo,
    eQuestChangeLang,    
    eQuestDoubleTab,     
    eQuestLongTouch,
    eQuestAppReview,
    eQuestChangeName,
    eQuestCheckRanking,
    eQuestMax
} eQuest;

typedef struct sQuest {
    eQuest id;          // can be changed
    NSString *key;      // save, never change
    BOOL done;          // save
    NSInteger point;
    NSString *desc;     // english
} sQuest;

extern sQuest listQuest[];

// id (new), name, (...), point (30), done (bool) 

@property (nonatomic, retain) UIImage *questImage;
@property (retain) NSString *questName;
@property NSInteger questPoint;
@property BOOL questDone;

+ (id) quest:(NSString *)name point:(NSInteger)point imageName:(NSString *)imageName done:(BOOL)done;
+ (NSInteger) DoneQuest:(eQuest)quest;
+ (void) loadQuestData;
+ (void) saveQuestData;
+ (NSInteger) gerQuestPercentage;



@end

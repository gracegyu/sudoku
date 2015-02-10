#import "Quest.h"
#import "Constants.h"
#import "GameCenterUtil.h"
#import "Locale.h"

@implementation Quest
@synthesize questImage;
@synthesize questName;
@synthesize questPoint;


sQuest listQuest[] = {
    {   eQuestHint,             @"hint",            NO, 10, @"Try using hint"},         // 힌트 사용해보기
    {   eQuestUndo,             @"undo",            NO, 3,  @"Try using undo"},
    {   eQuestRedo,             @"redo",            NO, 3,  @"Try using redo"},
    {   eQuestClearDaily0,      @"cleardaily0",     NO, 30, @"Clear daily original sudoku"},
    {   eQuestClearDaily1,      @"cleardaily1",     NO, 30, @"Clear daily greater than sudoku"},
    {   eQuestClearDaily2,      @"cleardaily2",     NO, 30, @"Clear daily sumdoku"},
    {   eQuestClearDaily3,      @"cleardaily3",     NO, 30, @"Clear daily calcudoku"},
    {   eQuestClearLevel0,      @"clearlevel0",     NO, 99, @"Clear very hard puzzle"},
    {   eQuestClearLevel1,      @"clearlevel1",     NO, 50, @"Clear hard puzzle"},
    {   eQuestClearLevel2,      @"clearlevel2",     NO, 25, @"Clear normal puzzle"},
    {   eQuestClearLevel3,      @"clearlevel3",     NO, 15, @"Clear easy puzzle"},
    {   eQuestClearLevel4,      @"clearlevel4",     NO, 10, @"Clear very eash puzzle"},
    {   eQuestCheckScore,       @"checkscore",      NO, 5,  @"Check your score"},
    {   eQuestCheckHelp,        @"checkhelp",       NO, 5,  @"Check help page"},
    {   eQuestSendfeedback,     @"sendfeedback",    NO, 30, @"Send feedback"},
    {   eQuestResetGame,        @"resetgame",       NO, 10, @"Reset the game"},
    {   eQuestPuzzleShare,      @"puzzleshare",     NO, 30, @"Share a puzzle to your friends"},
    {   eQuestRecordShare,      @"recordshare",     NO, 30, @"Share your record to your friends"},
    {   eQuestVisitRanking,     @"visitranking",    NO, 10, @"Visit to ranking page"},
    {   eQuestBookmarking,      @"bookmarking",     NO, 5,  @"Bookmarking"},
    {   eQuestGoBack,           @"goback",          NO, 10, @"Go back to bookmark"},
    {   eQuestAutomemo,         @"automemo",        NO, 5,  @"Play an auto memo game"},
    {   eQuestChangeLang,       @"changelang",      NO, 3,  @"Change your language setting"},
    {   eQuestDoubleTap,        @"doubletap",       NO, 5,  @"Memo mode using double tap"},
    {   eQuestLongTouch,        @"longtouch",       NO, 20, @"Press and hold a number button in memo mode"},
    {   eQuestAppReview,        @"appreview",       NO, 99, @"Review this app from setting page"},
    {   eQuestChangeName,       @"changename",      NO, 10, @"Change your nickname"},
    {   eQuestCheckRanking,     @"checkranking",    NO, 50, @"Check your ranking after clearing puzzle"},

    
    
    
    
    {   eQuestMax },
};


- (id)init {
    if(self = [super init]) {
        
    }
    return self;
}

+ (id) quest:(NSString *)name point:(NSInteger)point imageName:(NSString *)imageName done:(BOOL)done; {
    Quest *p = [[[Quest alloc] init] autorelease];
    
    p.questName = name;
    p.questPoint = point;
    p.questImage = [UIImage imageNamed:imageName];
    p.questDone = done;
    
    return p;
}

+ (NSInteger) DoneQuest:(eQuest)quest
{
    if (listQuest[quest].done == NO) {
        listQuest[quest].done = YES;
        [Quest saveQuestData];
        
        [[GKAchievementHandler defaultHandler]
         notifyAchievementTitle:gettext(@"You performed a quest.", nil)
         andMessage:[NSString stringWithFormat:gettext(@"%@ (%d points)", nil) ,
                     gettext(listQuest[quest].desc, nil),
                     (int)listQuest[quest].point]];
        
        return listQuest[quest].point;
    }
    return -1;
}

+ (void) loadQuestData
{
    DLog(@"loadQuestData");
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    for (int i=0; i<eQuestMax; i++) {
        listQuest[i].done = [defaults boolForKey:[NSString stringWithFormat:@"kQuest_%@", listQuest[i].key]];
    }
}

+ (void) saveQuestData
{
    DLog(@"saveQuestData");
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    for (int i=0; i<eQuestMax; i++) {
        [defaults setBool:listQuest[i].done forKey:[NSString stringWithFormat:@"kQuest_%@", listQuest[i].key]];
    }
    [defaults synchronize];
}

+ (NSInteger) gerQuestPercentage
{
    NSInteger nDone = 0;
    for (int i=0; i<eQuestMax; i++) {
        if (listQuest[i].done)
            nDone++;
    }
    return 100 * nDone / eQuestMax;
}

- (void)dealloc {
    [questImage release];
    [questName release];
    
    [super dealloc];
}

@end

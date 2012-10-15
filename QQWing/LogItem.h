//
//  LogItem.h
//  QQWingPorting
//
//  Created by Raymond on 10/15/12.
//  Copyright (c) 2012 Raymond. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "config.h"

enum LogType {
	LOG_GIVEN,
	LOG_SINGLE,
	LOG_HIDDEN_SINGLE_ROW,
	LOG_HIDDEN_SINGLE_COLUMN,
	LOG_HIDDEN_SINGLE_SECTION,
	LOG_GUESS,
	LOG_ROLLBACK,
	LOG_NAKED_PAIR_ROW,
	LOG_NAKED_PAIR_COLUMN,
	LOG_NAKED_PAIR_SECTION,
	LOG_POINTING_PAIR_TRIPLE_ROW,
	LOG_POINTING_PAIR_TRIPLE_COLUMN,
	LOG_ROW_BOX,
	LOG_COLUMN_BOX,
	LOG_HIDDEN_PAIR_ROW,
	LOG_HIDDEN_PAIR_COLUMN,
	LOG_HIDDEN_PAIR_SECTION,
};
typedef enum LogType LogType;

void LogIt (NSString *format, ...);

@interface LogItem : NSObject
{

 	/**
     * The recursion level at which this item was gathered.
     * Used for backing out log items solve branches that
     * don't lead to a solution.
     */
    int round;
    
    /**
     * The type of log message that will determine the
     * message printed.
     */
    LogType type;
    
    /**
     * Value that was set by the operation (or zero for no value)
     */
    int value;
    
    /**
     * position on the board at which the value (if any) was set.
     */
    int position;
}


- (id) initWithLogType:(int)r type:(LogType)t;
- (id) initWithLogPosition:(int)r type:(LogType)y value:(int)v position:(int)p;
- (int) getRound;
- (void) print;
- (LogType) getType;

@end

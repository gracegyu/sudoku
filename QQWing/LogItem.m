//
//  LogItem.m
//  QQWingPorting
//
//  Created by Raymond on 10/15/12.
//  Copyright (c) 2012 Raymond. All rights reserved.
//

#import "Constants.h"
#import "LogItem.h"
#import "SudokuBoard.h"

#define GRID_SIZE 3
#define ROW_LENGTH          (GRID_SIZE*GRID_SIZE)
#define COL_HEIGHT          (GRID_SIZE*GRID_SIZE)
#define SEC_SIZE            (GRID_SIZE*GRID_SIZE)
#define SEC_COUNT           (GRID_SIZE*GRID_SIZE)
#define SEC_GROUP_SIZE      (SEC_SIZE*GRID_SIZE)
#define NUM_POSS            (GRID_SIZE*GRID_SIZE)
#define BOARD_SIZE          (ROW_LENGTH*COL_HEIGHT)
#define POSSIBILITY_SIZE    (BOARD_SIZE*NUM_POSS)

/**
 * Given the index of a cell (0-80) calculate
 * the column (0-8) in which that cell resides.
 */
static inline int cellToColumn(int cell)
{
    return cell%COL_HEIGHT;
}

/**
 * Given the index of a cell (0-80) calculate
 * the row (0-8) in which it resides.
 */
static inline int cellToRow(int cell)
{
    return cell/ROW_LENGTH;
}

void LogIt (NSString *format, ...)
{
    va_list args;
    va_start (args, format);
    NSString *string;
    string = [[NSString alloc] initWithFormat: format  arguments: args];
    va_end (args);
    printf ("%s", [string cStringUsingEncoding:NSASCIIStringEncoding]);
    [string release];
} // LogIt



@implementation LogItem



- (id) initLogItem:(int)r type:(LogType)t value:(int)v position:(int)p
{
    round = r;
    type = t;
    value = v;
    position = p;
	
	return self;
}

- (id) initWithLogType:(int)r type:(LogType)t
{
	[self initLogItem:r type:t value:0 position:-1];
	
	return self;
}

- (id) initWithLogPosition:(int)r type:(LogType)t value:(int)v position:(int)p
{
	[self initLogItem:r type:t value:v position:p];
	
	return self;
}

- (int) getRound
{
	return round;
}

- (void) print
{
	LogIt(@"Round: %d - ", [self getRound]);
    switch(type){
        case LOG_GIVEN:{
            LogIt(@"Mark given");
        } break;
        case LOG_ROLLBACK:{
            LogIt(@"Roll back round");
        } break;
        case LOG_GUESS:{
            LogIt(@"Mark guess (start round)");
        } break;
        case LOG_HIDDEN_SINGLE_ROW:{
            LogIt(@"Mark single possibility for value in row");
        } break;
        case LOG_HIDDEN_SINGLE_COLUMN:{
            LogIt(@"Mark single possibility for value in column");
        } break;
        case LOG_HIDDEN_SINGLE_SECTION:{
            LogIt(@"Mark single possibility for value in section");
        } break;
        case LOG_SINGLE:{
            LogIt(@"Mark only possibility for cell");
        } break;
        case LOG_NAKED_PAIR_ROW:{
            LogIt(@"Remove possibilities for naked pair in row");
        } break;
        case LOG_NAKED_PAIR_COLUMN:{
            LogIt(@"Remove possibilities for naked pair in column");
        } break;
        case LOG_NAKED_PAIR_SECTION:{
            LogIt(@"Remove possibilities for naked pair in section");
        } break;
        case LOG_POINTING_PAIR_TRIPLE_ROW: {
            LogIt(@"Remove possibilities for row because all values are in one section");
        } break;
        case LOG_POINTING_PAIR_TRIPLE_COLUMN: {
            LogIt(@"Remove possibilities for column because all values are in one section");
        } break;
        case LOG_ROW_BOX: {
            LogIt(@"Remove possibilities for section because all values are in one row");
        } break;
        case LOG_COLUMN_BOX: {
            LogIt(@"Remove possibilities for section because all values are in one column");
        } break;
        case LOG_HIDDEN_PAIR_ROW: {
            LogIt(@"Remove possibilities from hidden pair in row");
        } break;
        case LOG_HIDDEN_PAIR_COLUMN: {
            LogIt(@"Remove possibilities from hidden pair in column");
        } break;
        case LOG_HIDDEN_PAIR_SECTION: {
            LogIt(@"Remove possibilities from hidden pair in section");
        } break;
        default:{
            LogIt(@"!!! Performed unknown optimization !!!");
        } break;
    }
    if (value > 0 || position > -1){
        LogIt(@" (");
        bool printed = false;
        if (position > -1){
            if (printed)
				LogIt(@" - ");
            LogIt(@"Row: %d - Column: %d", cellToRow(position)+1, cellToColumn(position)+1);
            printed = true;
        }
        if (value > 0){
            if (printed) LogIt(@" - ");
            LogIt(@"Value: ", value);
            printed = true;
        }
        LogIt(@")");
    }
}

- (LogType) getType
{
	return type;
}





@end

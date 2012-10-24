//
//  SudokuBoard.m
//  QQWingPorting
//
//  Created by Raymond on 10/15/12.
//  Copyright (c) 2012 Raymond. All rights reserved.
//

#import "Constants.h"
#import "SudokuBoard.h"
#import "LogItem.h"


long getMicroseconds();
void shuffleArray(int* array, int size);
bool readPuzzleFromStdIn(int* puzzle);


int getLogCount(NSMutableArray* v, LogType type);

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

/**
 * Given the index of a cell (0-80) calculate
 * the section (0-8) in which it resides.
 */
static inline int cellToSection(int cell)
{
    return (cell/SEC_GROUP_SIZE*GRID_SIZE)
	+ (cellToColumn(cell)/GRID_SIZE);
}

/**
 * Given the index of a cell (0-80) calculate
 * the cell (0-80) that is the upper left start
 * cell of that section.
 */
static inline int cellToSectionStartCell(int cell)
{
    return (cell/SEC_GROUP_SIZE*SEC_GROUP_SIZE)
	+ (cellToColumn(cell)/GRID_SIZE*GRID_SIZE);
}

/**
 * Given a row (0-8) calculate the first cell (0-80)
 * of that row.
 */
static inline int rowToFirstCell(int row)
{
    return 9*row;
}

/**
 * Given a column (0-8) calculate the first cell (0-80)
 * of that column.
 */
static inline int columnToFirstCell(int column)
{
    return column;
}

/**
 * Given a section (0-8) calculate the first cell (0-80)
 * of that section.
 */
static inline int sectionToFirstCell(int section)
{
    return (section%GRID_SIZE*GRID_SIZE)
	+ (section/GRID_SIZE*SEC_GROUP_SIZE);
}

/**
 * Given a value for a cell (0-8) and a cell (0-80)
 * calculate the offset into the possibility array (0-728).
 */
static inline int getPossibilityIndex(int valueIndex, int cell)
{
    return valueIndex+(NUM_POSS*cell);
}

/**
 * Given a row (0-8) and a column (0-8) calculate the
 * cell (0-80).
 */
static inline int rowColumnToCell(int row, int column)
{
    return (row*COL_HEIGHT)+column;
}

/**
 * Given a section (0-8) and an offset into that section (0-8)
 * calculate the cell (0-80)
 */
static inline int sectionToCell(int section, int offset)
{
    return sectionToFirstCell(section)
	+ ((offset/GRID_SIZE)*SEC_SIZE)
	+ (offset%GRID_SIZE);
}

/**
 * Given a vector of LogItems, determine how many
 * log items in the vector are of the specified type.
 */
int getLogCount(NSMutableArray* v, LogType type)
{
    int count = 0;
    {for (int i=0; i<[v count]; i++){
        if([[v objectAtIndex:i] getType] == type) count++;
    }}
    return count;
}

/**
 * Get the current time in microseconds.
 */
long getMicroseconds()
{
#if HAVE_GETTIMEOFDAY == 1
	return (long) CFAbsoluteTimeGetCurrent();
#else
	return 0;
#endif
}

/**
 * Shuffle the values in an array of integers.
 */
void shuffleArray(int* array, int size)
{
    {for (int i=0; i<size; i++)
	{
        int tailSize = size-i;
        int randTailPos = rand()%tailSize+i;
        int temp = array[i];
        array[i] = array[randTailPos];
        array[randTailPos] = temp;
    }}
}

/**
 * Read a sudoku puzzle from standard input.
 * STDIN is processed one character at a time
 * until the sudoku is filled in.  Any digit
 * or period is used to fill the sudoku, any
 * other character is ignored.
 */
bool readPuzzleFromStdIn(int* puzzle)
{
    int read = 0;
    while (read < BOARD_SIZE){
        char c = getchar();
        if (c == EOF) return false;
        if (c >= '1' && c <='9'){
            puzzle[read] = c-'0';
            read++;
        }
        if (c == '.' || c == '0'){
            puzzle[read] = 0;
            read++;
        }
    }
    return true;
}




@implementation SudokuBoard

- (int*) getPuzzle
{ return puzzle; }
- (int*) getSolution
{ return solution; }


- (id)init
{
    self = [super init];
    if (self) {
		puzzle = malloc(sizeof(int)*BOARD_SIZE);
		DLog(@"init(puzzle = %p)", puzzle);
		solution = malloc(sizeof(int)*BOARD_SIZE);
		solutionRound = malloc(sizeof(int)*BOARD_SIZE);
		possibilities = malloc(sizeof(int)*POSSIBILITY_SIZE);
		recordHistory = false;
		printStyle = PRINT_READABLE;
		randomBoardArray = malloc(sizeof(int)*BOARD_SIZE);
		randomPossibilityArray = malloc(sizeof(int)*NUM_POSS);
		
		solveHistory = [[NSMutableArray alloc] init];
		solveInstructions = [[NSMutableArray alloc] init];
		
		{for (int i=0; i<BOARD_SIZE; i++){
			randomBoardArray[i] = i;
		}}
		{for (int i=0; i<NUM_POSS; i++){
			randomPossibilityArray[i] = i;
		}}
    }
    return self;
}

- (void)dealloc
{
    [self clearPuzzle];
    free(puzzle);
    free(solution);
    free(possibilities);
    free(solutionRound);
    free(randomBoardArray);
    free(randomPossibilityArray);
    free(solveHistory);
    free(solveInstructions);
	[super dealloc];
}

/**
 * Set the board to the given puzzle.
 * The given puzzle must be an array of 81 integers.
 */
- (bool) setPuzzle:(int*)initPuzzle
{
	for (int i=0; i<BOARD_SIZE; i++)
	{
		puzzle[i] = (initPuzzle==NULL)?0:initPuzzle[i];
	}
    return [self reset];
}


- (void) print:(int*) sudoku
{
    for(int i=0; i<BOARD_SIZE; i++){
        if (printStyle == PRINT_READABLE){
            LogIt(@" ");
        }
        if (sudoku[i]==0){
            LogIt(@".");
        } else {
			LogIt(@"%d", sudoku[i]);
        }
        if (i == BOARD_SIZE-1){
            if (printStyle == PRINT_CSV){
                LogIt(@",");
            } else {
                LogIt(@"\n");
            }
            if (printStyle == PRINT_READABLE || printStyle == PRINT_COMPACT){
                LogIt(@"\n");
            }
        } else if (i%9==8){
            if (printStyle == PRINT_READABLE || printStyle == PRINT_COMPACT){
                LogIt(@"\n");
            }
            if (i%SEC_GROUP_SIZE==SEC_GROUP_SIZE-1){
                if (printStyle == PRINT_READABLE){
					LogIt(@"-------|-------|-------\n");
                }
            }
        } else if (i%3==2){
            if (printStyle == PRINT_READABLE){
                LogIt(@" |");
            }
        }
    }
}


/**
 * print the given BOARD_SIZEd array of ints
 * as a sudoku puzzle.  Use print options from
 * member variables.
 */
- (void) printPuzzle
{
	[self print:puzzle];
}

- (void) printSolution
{
	[self print:solution];
}


/**
* Get the number of cells that are
* set in the puzzle (as opposed to
* figured out in the solution
*/
- (int) getGivenCount
{
	int count = 0;
	{for (int i=0; i<BOARD_SIZE; i++){
		if (puzzle[i] != 0) count++;
	}}
	return count;
}


/**
 * Get the number of cells for which the solution was determined
 * because there was only one possible value for that cell.
 */
- (int) getSingleCount
{
    return getLogCount(solveInstructions, LOG_SINGLE);
}

/**
 * Get the number of cells for which the solution was determined
 * because that cell had the only possibility for some value in
 * the row, column, or section.
 */
- (int) getHiddenSingleCount
{
	return getLogCount(solveInstructions, LOG_HIDDEN_SINGLE_ROW) +
	getLogCount(solveInstructions, LOG_HIDDEN_SINGLE_COLUMN) +
	getLogCount(solveInstructions, LOG_HIDDEN_SINGLE_SECTION);
}






/**
* Get the difficulty rating.
*/
- (Difficulty) getDifficulty
{
	if ([self getGuessCount] > 0)
		return DIFF_EXPERT;
    if ([self getBoxLineReductionCount] > 0)
		return DIFF_INTERMEDIATE;
    if ([self getPointingPairTripleCount] > 0)
		return DIFF_INTERMEDIATE;
    if ([self getHiddenPairCount] > 0)
		return DIFF_INTERMEDIATE;
    if ([self getNakedPairCount] > 0)
		return DIFF_INTERMEDIATE;
    if ([self getHiddenSingleCount] > 0)
		return DIFF_EASY;
    if ([self getSingleCount] > 0)
		return DIFF_SIMPLE;
    return DIFF_UNKNOWN;
}

/**
 * Get the difficulty rating.
 */
- (NSString*) getDifficultyAsString
{
	Difficulty difficulty = [self getDifficulty];
    switch (difficulty){
        case DIFF_EXPERT: return @"Expert"; break;
        case DIFF_INTERMEDIATE: return @"Intermediate"; break;
        case DIFF_EASY: return @"Easy"; break;
        case DIFF_SIMPLE: return @"Simple"; break;
        default: return @"Unknown"; break;
    }
}

/**
* Reset the board to its initial state with
* only the givens.
* This method clears any solution, resets statistics,
* and clears any history messages.
*/
- (bool) reset
{
	//DLog(@"reset(puzzle = %p)", puzzle);
	
    for (int i=0; i<BOARD_SIZE; i++)
	{
        solution[i] = 0;
    }
    for (int i=0; i<BOARD_SIZE; i++)
	{
        solutionRound[i] = 0;
    }
    for (int i=0; i<POSSIBILITY_SIZE; i++)
	{
        possibilities[i] = 0;
    }

	[solveHistory removeAllObjects];
	[solveInstructions removeAllObjects];
	
/*	solution[0]=1;
	solution[1]=2;
	solution[2]=3;
	solution[9]=4;
	solution[10]=5;
	solution[11]=6;
	solution[18]=7;
	solution[19]=8;
	solution[20]=9;
	[self printSolution];
*/
	
    int round = 1;
    for (int position=0; position<BOARD_SIZE; position++)
	{
        if (puzzle[position] > 0)
		{
            int valIndex = puzzle[position]-1;
            int valPos = getPossibilityIndex(valIndex,position);
            int value = puzzle[position];
            if (possibilities[valPos] != 0)
				return false;
			[self mark:position round:round value:value];
            if (logHistory || recordHistory)
			{
				[self addHistoryItem:[[LogItem alloc] initWithLogPosition:round type:LOG_GIVEN value:value position:position]];
			}
        }
    }

    return true;
}


- (void) addHistoryItem:(LogItem*) l
{
    if (logHistory)
	{
        [l print];
        DLog(@"");
    }
    if (recordHistory)
	{
		[solveHistory addObject:l];
        [solveInstructions addObject:l];
    } else {
        [l release];
    }
}




/**
* Get the number of naked pair reductions that were performed
* in solving this puzzle.
*/
- (int) getNakedPairCount
{
    return getLogCount(solveInstructions, LOG_NAKED_PAIR_ROW) +
	getLogCount(solveInstructions, LOG_NAKED_PAIR_COLUMN) +
	getLogCount(solveInstructions, LOG_NAKED_PAIR_SECTION);
}

/**
 * Get the number of hidden pair reductions that were performed
 * in solving this puzzle.
 */
- (int) getHiddenPairCount
{
    return getLogCount(solveInstructions, LOG_HIDDEN_PAIR_ROW) +
	getLogCount(solveInstructions, LOG_HIDDEN_PAIR_COLUMN) +
	getLogCount(solveInstructions, LOG_HIDDEN_PAIR_SECTION);
}

/**
 * Get the number of pointing pair/triple reductions that were performed
 * in solving this puzzle.
 */
- (int) getPointingPairTripleCount
{
    return getLogCount(solveInstructions, LOG_POINTING_PAIR_TRIPLE_ROW)+
	getLogCount(solveInstructions, LOG_POINTING_PAIR_TRIPLE_COLUMN);
}

/**
 * Get the number of box/line reductions that were performed
 * in solving this puzzle.
 */
- (int) getBoxLineReductionCount
{
    return getLogCount(solveInstructions, LOG_ROW_BOX)+
	getLogCount(solveInstructions, LOG_COLUMN_BOX);
}

/**
 * Get the number lucky guesses in solving this puzzle.
 */
- (int) getGuessCount
{
    return getLogCount(solveInstructions, LOG_GUESS);
}

/**
 * Get the number of backtracks (unlucky guesses) required
 * when solving this puzzle.
 */
- (int) getBacktrackCount
{
    return getLogCount(solveHistory, LOG_ROLLBACK);
}

- (void) markRandomPossibility:(int) round
{
    int remainingPossibilities = 0;
    {for (int i=0; i<POSSIBILITY_SIZE; i++){
        if (possibilities[i] == 0) remainingPossibilities++;
    }}
	
    int randomPossibility = rand()%remainingPossibilities;
	
    int possibilityToMark = 0;
    {for (int i=0; i<POSSIBILITY_SIZE; i++){
        if (possibilities[i] == 0){
            if (possibilityToMark == randomPossibility){
                int position = i/NUM_POSS;
                int value = i%NUM_POSS+1;
                [self mark:position round:round value:value];
                return;
            }
            possibilityToMark++;
        }
    }}
}

- (void) shuffleRandomArrays
{
    shuffleArray(randomBoardArray, BOARD_SIZE);
    shuffleArray(randomPossibilityArray, NUM_POSS);
}

- (void) clearPuzzle
{
    // Clear any existing puzzle
	//DLog(@"clearPuzzle(puzzle = %p)", puzzle);
    {for (int i=0; i<BOARD_SIZE; i++){
        puzzle[i] = 0;
    }}
    [self reset];
}

- (bool) generatePuzzle
{
	DLog(@"generatePuzzle");
	
    // Don't record history while generating.
    bool recHistory = recordHistory;
    [self setRecordHistory:false];
    bool lHistory = logHistory;
    [self setLogHistory:false];
	
    [self clearPuzzle];
	
    // Start by getting the randomness in order so that
    // each puzzle will be different from the last.
    [self shuffleRandomArrays];
	
    // Now solve the puzzle the whole way.  The solve
    // uses random algorithms, so we should have a
    // really randomly totally filled sudoku
    // Even when starting from an empty grid
	

	
    [self solve];
//	[self printSolution];

	
    // Rollback any square for which it is obvious that
    // the square doesn't contribute to a unique solution
    // (ie, squares that were filled by logic rather
    // than by guess)
    [self rollbackNonGuesses];


	
    // Record all marked squares as the puzzle so
    // that we can call countSolutions without losing it.
    {for (int i=0; i<BOARD_SIZE; i++){
        puzzle[i] = solution[i];
    }}

	
    // Rerandomize everything so that we test squares
    // in a different order than they were added.
    [self shuffleRandomArrays];

	
    // Remove one value at a time and see if
    // the puzzle still has only one solution.
    // If it does, leave it0 out the point because
    // it is not needed.
    {for (int i=0; i<BOARD_SIZE; i++){
        // check all the positions, but in shuffled order
        int position = randomBoardArray[i];
        if (puzzle[position] > 0){
            // try backing out the value and
            // counting solutions to the puzzle
            int savedValue = puzzle[position];
            puzzle[position] = 0;
            [self reset];
            if ([self countSolutions:2 limitToTwo:true] > 1){
                // Put it back in, it is needed
                puzzle[position] = savedValue;
            }
        }
    }}

	
    // Clear all solution info, leaving just the puzzle.
    [self reset];

	
    // Restore recording history.
    [self setRecordHistory:recHistory];
    [self setLogHistory:lHistory];
	
    return true;
	
}

- (void) rollbackNonGuesses
{
    // Guesses are odd rounds
    // Non-guesses are even rounds
    {for (int i=2; i<=lastSolveRound; i+=2){
        [self rollbackRound:i];
    }}
}

- (void) setPrintStyle:(PrintStyle) ps
{
    printStyle = ps;
}

- (void) setRecordHistory:(bool)recHistory
{
    recordHistory = recHistory;
}

- (void) setLogHistory:(bool)logHist
{
    logHistory = logHist;
}


- (void) printHistory:(NSMutableArray*) v
{
    if (!recordHistory){
        LogIt(@"History was not recorded.");
        if (printStyle == PRINT_CSV){
            LogIt(@" -- ");
        } else {
            LogIt(@"\n");
        }
    }
    {for (int i=0;i<[v count];i++){
        LogIt(@"%d. ", i+1);
		[[v objectAtIndex:i] print];

        if (printStyle == PRINT_CSV)
		{
            LogIt(@" -- ");
        } else {
            LogIt(@"\n");
        }
    }}
    if (printStyle == PRINT_CSV){
        LogIt(@",");
    } else {
        LogIt(@"\n");
    }
}

- (void) printSolveInstructions
{
    if ([self isSolved]){
        [self printHistory:solveInstructions];
    } else {
        LogIt(@"No solve instructions - Puzzle is not possible to solve.\n");
    }
}

- (void) printSolveHistory
{
    [self printHistory:solveHistory];
}

- (bool) solve
{
    [self reset];
	

	
    [self shuffleRandomArrays];
    return [self solve:2];
}

- (bool) solve:(int)round
{


    lastSolveRound = round;
	
    while ([self singleSolveMove:round])
	{
        if ([self isSolved]) return true;
        if ([self isImpossible]) return false;
    }
	
	//[self printSolution];

	
/*	solution[0]=1;
	solution[1]=2;
	solution[2]=3;
	solution[9]=4;
	solution[10]=5;
	solution[11]=6;
	solution[18]=7;
	solution[19]=8;
	solution[20]=9;
	solution[30]=1;
	solution[31]=2;
	solution[32]=3;
	solution[39]=4;
	solution[40]=5;
	solution[41]=6;
	solution[48]=7;
	solution[49]=8;
	solution[50]=9;
	[self printSolution];
*/
	
    int nextGuessRound = round+1;
    int nextRound = round+2;
    for (int guessNumber=0; [self guess:nextGuessRound guessNumber:guessNumber]; guessNumber++)
	{
		//[self printSolution];
        if ([self isImpossible] || ![self solve:nextRound]){
            [self rollbackRound:nextRound];
            [self rollbackRound:nextGuessRound];
        } else {
            return true;
        }
    }
    return false;
}

- (int) countSolutions
{
    // Don't record history while generating.
    bool recHistory = recordHistory;
    [self setRecordHistory:false];
    bool lHistory = logHistory;
    [self setLogHistory:false];
	
    [self reset];
    int solutionCount = [self countSolutions:2  limitToTwo:false];
	
    // Restore recording history.
    [self setRecordHistory:recHistory];
    [self setLogHistory:lHistory];
	
    return solutionCount;
}

- (int) countSolutions:(int) round limitToTwo:(bool) limitToTwo
{
    while ([self singleSolveMove:round])
	{
        if ([self isSolved]){
            [self rollbackRound:round];
            return 1;
        }
        if ([self isImpossible]){
            [self rollbackRound:round];
            return 0;
        }
    }
	
    int solutions = 0;
    int nextRound = round+1;
    for (int guessNumber=0; [self guess:nextRound guessNumber:guessNumber]; guessNumber++){
        solutions += [self countSolutions:nextRound limitToTwo:limitToTwo];
        if (limitToTwo && solutions >=2){
            [self rollbackRound:round];
            return solutions;
        }
    }
    [self rollbackRound:round];
    return solutions;
}

- (void) rollbackRound:(int) round
{
    if (logHistory || recordHistory)
		[self addHistoryItem:[[LogItem alloc] initWithLogType:round type:LOG_ROLLBACK]];
	
	
    {for (int i=0; i<BOARD_SIZE; i++){
        if (solutionRound[i] == round){
            solutionRound[i] = 0;
            solution[i] = 0;
        }
    }}
    {for (int i=0; i<POSSIBILITY_SIZE; i++){
        if (possibilities[i] == round){
            possibilities[i] = 0;
        }
    }}

	
    while([solveInstructions count] > 0 && [[solveInstructions lastObject] getRound] == round)
	{
		[solveInstructions removeLastObject];
    }
}

- (bool) isSolved
{
    {for (int i=0; i<BOARD_SIZE; i++){
        if (solution[i] == 0){
            return false;
        }
    }}
    return true;
}

- (bool) isImpossible
{
    for (int position=0; position<BOARD_SIZE; position++){
        if (solution[position] == 0){
            int count = 0;
            for (int valIndex=0; valIndex<NUM_POSS; valIndex++){
                int valPos = getPossibilityIndex(valIndex,position);
                if (possibilities[valPos] == 0) count++;
            }
            if (count == 0) {
                return true;
            }
        }
    }
    return false;
}

- (int) findPositionWithFewestPossibilities
{
    int minPossibilities = 10;
    int bestPosition = 0;
 
	{for (int i=0; i<BOARD_SIZE; i++){
        int position = randomBoardArray[i];
        if (solution[position] == 0){
            int count = 0;
            for (int valIndex=0; valIndex<NUM_POSS; valIndex++){
                int valPos = getPossibilityIndex(valIndex,position);
                if (possibilities[valPos] == 0) count++;
            }
            if (count < minPossibilities){
                minPossibilities = count;
                bestPosition = position;
            }
        }
    }}
    return bestPosition;
}

- (bool) guess:(int) round guessNumber:(int) guessNumber
{
    int localGuessCount = 0;
    int position = [self findPositionWithFewestPossibilities];
    {for (int i=0; i<NUM_POSS; i++){
        int valIndex = randomPossibilityArray[i];
        int valPos = getPossibilityIndex(valIndex,position);
        if (possibilities[valPos] == 0){
            if (localGuessCount == guessNumber){
                int value = valIndex+1;
                if (logHistory || recordHistory)
					[self addHistoryItem:[[LogItem alloc] initWithLogPosition:round type:LOG_GUESS value:value position:position]];
				
				[self mark:position round:round value:value];
			    return true;
            }
            localGuessCount++;
        }
    }}
    return false;
}

- (bool) singleSolveMove:(int) round
{
    if ([self onlyPossibilityForCell:round]) return true;
    if ([self onlyValueInSection:round]) return true;
    if ([self onlyValueInRow:round]) return true;
    if ([self onlyValueInColumn:round]) return true;
    if ([self handleNakedPairs:round]) return true;
    if ([self pointingRowReduction:round]) return true;
    if ([self pointingColumnReduction:round]) return true;
    if ([self rowBoxReduction:round]) return true;
    if ([self colBoxReduction:round]) return true;
    if ([self hiddenPairInRow:round]) return true;
    if ([self hiddenPairInColumn:round]) return true;
    if ([self hiddenPairInSection:round]) return true;
    return false;
}

- (bool) colBoxReduction:(int) round
{
    for (int valIndex=0; valIndex<NUM_POSS; valIndex++){
        for (int col=0; col<9; col++){
            int colStart = columnToFirstCell(col);
            bool inOneBox = true;
            int colBox = -1;
            {for (int i=0; i<3; i++){
                for (int j=0; j<3; j++){
                    int row = i*3+j;
                    int position = rowColumnToCell(row, col);
                    int valPos = getPossibilityIndex(valIndex,position);
                    if(possibilities[valPos] == 0){
                        if (colBox == -1 || colBox == i){
                            colBox = i;
                        } else {
                            inOneBox = false;
                        }
                    }
					
                }
            }}
            if (inOneBox && colBox != -1){
                bool doneSomething = false;
                int row = 3*colBox;
                int secStart = cellToSectionStartCell(rowColumnToCell(row, col));
                int secStartRow = cellToRow(secStart);
                int secStartCol = cellToColumn(secStart);
                {for (int i=0; i<3; i++){
                    for (int j=0; j<3; j++){
                        int row2 = secStartRow+i;
                        int col2 = secStartCol+j;
                        int position = rowColumnToCell(row2, col2);
                        int valPos = getPossibilityIndex(valIndex,position);
                        if (col != col2 && possibilities[valPos] == 0){
                            possibilities[valPos] = round;
                            doneSomething = true;
                        }
                    }
                }}
                if (doneSomething){
                    if (logHistory || recordHistory)
						[self addHistoryItem:[[LogItem alloc] initWithLogPosition:round type:LOG_COLUMN_BOX value:valIndex+1 position:colStart]];
                    return true;
                }
            }
        }
    }
    return false;
}

- (bool) rowBoxReduction:(int) round
{
    for (int valIndex=0; valIndex<NUM_POSS; valIndex++){
        for (int row=0; row<9; row++){
            int rowStart = rowToFirstCell(row);
            bool inOneBox = true;
            int rowBox = -1;
            {for (int i=0; i<3; i++){
                for (int j=0; j<3; j++){
                    int column = i*3+j;
                    int position = rowColumnToCell(row, column);
                    int valPos = getPossibilityIndex(valIndex,position);
                    if(possibilities[valPos] == 0){
                        if (rowBox == -1 || rowBox == i){
                            rowBox = i;
                        } else {
                            inOneBox = false;
                        }
                    }
					
                }
            }}
            if (inOneBox && rowBox != -1){
                bool doneSomething = false;
                int column = 3*rowBox;
                int secStart = cellToSectionStartCell(rowColumnToCell(row, column));
                int secStartRow = cellToRow(secStart);
                int secStartCol = cellToColumn(secStart);
                {for (int i=0; i<3; i++){
                    for (int j=0; j<3; j++){
                        int row2 = secStartRow+i;
                        int col2 = secStartCol+j;
                        int position = rowColumnToCell(row2, col2);
                        int valPos = getPossibilityIndex(valIndex,position);
                        if (row != row2 && possibilities[valPos] == 0){
                            possibilities[valPos] = round;
                            doneSomething = true;
                        }
                    }
                }}
                if (doneSomething){
                    if (logHistory || recordHistory)
						[self addHistoryItem:[[LogItem alloc] initWithLogPosition:round type:LOG_ROW_BOX value:valIndex+1 position:rowStart]];
					
                    return true;
                }
            }
        }
    }
    return false;
}

- (bool) pointingRowReduction:(int) round
{
    for (int valIndex=0; valIndex<NUM_POSS; valIndex++){
        for (int section=0; section<9; section++){
            int secStart = sectionToFirstCell(section);
            bool inOneRow = true;
            int boxRow = -1;
            for (int j=0; j<3; j++){
                {for (int i=0; i<3; i++){
                    int secVal=secStart+i+(9*j);
                    int valPos = getPossibilityIndex(valIndex,secVal);
                    if(possibilities[valPos] == 0){
                        if (boxRow == -1 || boxRow == j){
                            boxRow = j;
                        } else {
                            inOneRow = false;
                        }
                    }
                }}
            }
            if (inOneRow && boxRow != -1){
                bool doneSomething = false;
                int row = cellToRow(secStart) + boxRow;
                int rowStart = rowToFirstCell(row);
				
                {for (int i=0; i<9; i++){
                    int position = rowStart+i;
                    int section2 = cellToSection(position);
                    int valPos = getPossibilityIndex(valIndex,position);
                    if (section != section2 && possibilities[valPos] == 0){
                        possibilities[valPos] = round;
                        doneSomething = true;
                    }
                }}
                if (doneSomething){
                    if (logHistory || recordHistory)
						[self addHistoryItem:[[LogItem alloc] initWithLogPosition:round type:LOG_POINTING_PAIR_TRIPLE_ROW value:valIndex+1 position:rowStart]];
					
                    return true;
                }
            }
        }
    }
    return false;
}

- (bool) pointingColumnReduction:(int) round
{
    for (int valIndex=0; valIndex<NUM_POSS; valIndex++){
        for (int section=0; section<9; section++){
            int secStart = sectionToFirstCell(section);
            bool inOneCol = true;
            int boxCol = -1;
            {for (int i=0; i<3; i++){
                for (int j=0; j<3; j++){
                    int secVal=secStart+i+(9*j);
                    int valPos = getPossibilityIndex(valIndex,secVal);
                    if(possibilities[valPos] == 0){
                        if (boxCol == -1 || boxCol == i){
                            boxCol = i;
                        } else {
                            inOneCol = false;
                        }
                    }
                }
            }}
            if (inOneCol && boxCol != -1){
                bool doneSomething = false;
                int col = cellToColumn(secStart) + boxCol;
                int colStart = columnToFirstCell(col);
				
                {for (int i=0; i<9; i++){
                    int position = colStart+(9*i);
                    int section2 = cellToSection(position);
                    int valPos = getPossibilityIndex(valIndex,position);
                    if (section != section2 && possibilities[valPos] == 0){
                        possibilities[valPos] = round;
                        doneSomething = true;
                    }
                }}
                if (doneSomething){
                    if (logHistory || recordHistory)
						[self addHistoryItem:[[LogItem alloc] initWithLogPosition:round type:LOG_POINTING_PAIR_TRIPLE_COLUMN value:valIndex+1 position:colStart]];
					
                    return true;
                }
            }
        }
    }
    return false;
}

- (int) countPossibilities:(int) position
{
    int count = 0;
    for (int valIndex=0; valIndex<NUM_POSS; valIndex++){
        int valPos = getPossibilityIndex(valIndex,position);
        if (possibilities[valPos] == 0) count++;
    }
    return count;
}

- (bool) arePossibilitiesSame:(int) position1 position2:(int) position2
{
    for (int valIndex=0; valIndex<NUM_POSS; valIndex++){
        int valPos1 = getPossibilityIndex(valIndex,position1);
        int valPos2 = getPossibilityIndex(valIndex,position2);
        if ((possibilities[valPos1] == 0 || possibilities[valPos2] == 0) && (possibilities[valPos1] != 0 || possibilities[valPos2] != 0)){
            return false;
        }
    }
    return true;
}

- (bool) removePossibilitiesInOneFromTwo:(int) position1 position2:(int) position2 round:(int) round
{
    bool doneSomething = false;
    for (int valIndex=0; valIndex<NUM_POSS; valIndex++){
        int valPos1 = getPossibilityIndex(valIndex,position1);
        int valPos2 = getPossibilityIndex(valIndex,position2);
        if (possibilities[valPos1] == 0 && possibilities[valPos2] == 0){
            possibilities[valPos2] = round;
            doneSomething = true;
        }
    }
    return doneSomething;
}

- (bool) hiddenPairInColumn:(int) round
{
    for (int column=0; column<9; column++){
        for (int valIndex=0; valIndex<9; valIndex++){
            int r1 = -1;
            int r2 = -1;
            int valCount = 0;
            for (int row=0; row<9; row++){
                int position = rowColumnToCell(row,column);
                int valPos = getPossibilityIndex(valIndex,position);
                if (possibilities[valPos] == 0){
                    if (r1 == -1 || r1 == row){
                        r1 = row;
                    } else if (r2 == -1 || r2 == row){
                        r2 = row;
                    }
                    valCount++;
                }
            }
            if (valCount==2){
                for (int valIndex2=valIndex+1; valIndex2<9; valIndex2++){
                    int r3 = -1;
                    int r4 = -1;
                    int valCount2 = 0;
                    for (int row=0; row<9; row++){
                        int position = rowColumnToCell(row,column);
                        int valPos = getPossibilityIndex(valIndex2,position);
                        if (possibilities[valPos] == 0){
                            if (r3 == -1 || r3 == row){
                                r3 = row;
                            } else if (r4 == -1 || r4 == row){
                                r4 = row;
                            }
                            valCount2++;
                        }
                    }
                    if (valCount2==2 && r1==r3 && r2==r4){
                        bool doneSomething = false;
                        for (int valIndex3=0; valIndex3<9; valIndex3++){
                            if (valIndex3 != valIndex && valIndex3 != valIndex2){
                                int position1 = rowColumnToCell(r1,column);
                                int position2 = rowColumnToCell(r2,column);
                                int valPos1 = getPossibilityIndex(valIndex3,position1);
                                int valPos2 = getPossibilityIndex(valIndex3,position2);
                                if (possibilities[valPos1] == 0){
                                    possibilities[valPos1] = round;
                                    doneSomething = true;
                                }
                                if (possibilities[valPos2] == 0){
                                    possibilities[valPos2] = round;
                                    doneSomething = true;
                                }
                            }
                        }
                        if (doneSomething){
                            if (logHistory || recordHistory)
								[self addHistoryItem:[[LogItem alloc] initWithLogPosition:round type:LOG_HIDDEN_PAIR_COLUMN value:valIndex+1 position:rowColumnToCell(r1,column)]];
							
                            return true;
                        }
                    }
                }
            }
        }
    }
    return false;
}

- (bool) hiddenPairInSection:(int) round
{
    for (int section=0; section<9; section++){
        for (int valIndex=0; valIndex<9; valIndex++){
            int si1 = -1;
            int si2 = -1;
            int valCount = 0;
            for (int secInd=0; secInd<9; secInd++){
                int position = sectionToCell(section,secInd);
                int valPos = getPossibilityIndex(valIndex,position);
                if (possibilities[valPos] == 0){
                    if (si1 == -1 || si1 == secInd){
                        si1 = secInd;
                    } else if (si2 == -1 || si2 == secInd){
                        si2 = secInd;
                    }
                    valCount++;
                }
            }
            if (valCount==2){
                for (int valIndex2=valIndex+1; valIndex2<9; valIndex2++){
                    int si3 = -1;
                    int si4 = -1;
                    int valCount2 = 0;
                    for (int secInd=0; secInd<9; secInd++){
                        int position = sectionToCell(section,secInd);
                        int valPos = getPossibilityIndex(valIndex2,position);
                        if (possibilities[valPos] == 0){
                            if (si3 == -1 || si3 == secInd){
                                si3 = secInd;
                            } else if (si4 == -1 || si4 == secInd){
                                si4 = secInd;
                            }
                            valCount2++;
                        }
                    }
                    if (valCount2==2 && si1==si3 && si2==si4){
                        bool doneSomething = false;
                        for (int valIndex3=0; valIndex3<9; valIndex3++){
                            if (valIndex3 != valIndex && valIndex3 != valIndex2){
                                int position1 = sectionToCell(section,si1);
                                int position2 = sectionToCell(section,si2);
                                int valPos1 = getPossibilityIndex(valIndex3,position1);
                                int valPos2 = getPossibilityIndex(valIndex3,position2);
                                if (possibilities[valPos1] == 0){
                                    possibilities[valPos1] = round;
                                    doneSomething = true;
                                }
                                if (possibilities[valPos2] == 0){
                                    possibilities[valPos2] = round;
                                    doneSomething = true;
                                }
                            }
                        }
                        if (doneSomething){
                            if (logHistory || recordHistory)
								[self addHistoryItem:[[LogItem alloc] initWithLogPosition:round type:LOG_HIDDEN_PAIR_SECTION value:valIndex+1 position:sectionToCell(section,si1)]];
							
                            return true;
                        }
                    }
                }
            }
        }
    }
    return false;
}

- (bool) hiddenPairInRow:(int) round
{
    for (int row=0; row<9; row++){
        for (int valIndex=0; valIndex<9; valIndex++){
            int c1 = -1;
            int c2 = -1;
            int valCount = 0;
            for (int column=0; column<9; column++){
                int position = rowColumnToCell(row,column);
                int valPos = getPossibilityIndex(valIndex,position);
                if (possibilities[valPos] == 0){
                    if (c1 == -1 || c1 == column){
                        c1 = column;
                    } else if (c2 == -1 || c2 == column){
                        c2 = column;
                    }
                    valCount++;
                }
            }
            if (valCount==2){
                for (int valIndex2=valIndex+1; valIndex2<9; valIndex2++){
                    int c3 = -1;
                    int c4 = -1;
                    int valCount2 = 0;
                    for (int column=0; column<9; column++){
                        int position = rowColumnToCell(row,column);
                        int valPos = getPossibilityIndex(valIndex2,position);
                        if (possibilities[valPos] == 0){
                            if (c3 == -1 || c3 == column){
                                c3 = column;
                            } else if (c4 == -1 || c4 == column){
                                c4 = column;
                            }
                            valCount2++;
                        }
                    }
                    if (valCount2==2 && c1==c3 && c2==c4){
                        bool doneSomething = false;
                        for (int valIndex3=0; valIndex3<9; valIndex3++){
                            if (valIndex3 != valIndex && valIndex3 != valIndex2){
                                int position1 = rowColumnToCell(row,c1);
                                int position2 = rowColumnToCell(row,c2);
                                int valPos1 = getPossibilityIndex(valIndex3,position1);
                                int valPos2 = getPossibilityIndex(valIndex3,position2);
                                if (possibilities[valPos1] == 0){
                                    possibilities[valPos1] = round;
                                    doneSomething = true;
                                }
                                if (possibilities[valPos2] == 0){
                                    possibilities[valPos2] = round;
                                    doneSomething = true;
                                }
                            }
                        }
                        if (doneSomething){
                            if (logHistory || recordHistory)
								[self addHistoryItem:[[LogItem alloc] initWithLogPosition:round type:LOG_HIDDEN_PAIR_ROW value:valIndex+1 position:rowColumnToCell(row,c1)]];
							
                            return true;
                        }
                    }
                }
            }
        }
    }
    return false;
}

- (bool) handleNakedPairs:(int) round
{
	
    for (int position=0; position<BOARD_SIZE; position++)
	{
        int _possibilities = [self countPossibilities:position];
        if (_possibilities == 2)
		{
            int row = cellToRow(position);
            int column = cellToColumn(position);
            int section = cellToSectionStartCell(position);
            for (int position2=position; position2<BOARD_SIZE; position2++)
			{
                if (position != position2)
				{
                    int possibilities2 = [self countPossibilities:position2];
                    if (possibilities2 == 2 && [self arePossibilitiesSame:position position2:position2])
					{
                        if (row == cellToRow(position2))
						{
                            bool doneSomething = false;
                            for (int column2=0; column2<9; column2++)
							{
                                int position3 = rowColumnToCell(row,column2);
                                if (position3 != position && position3 != position2 && [self removePossibilitiesInOneFromTwo:position position2:position3 round:round])
								{
                                    doneSomething = true;
                                }
                            }
                            if (doneSomething)
							{
                                if (logHistory || recordHistory)
									[self addHistoryItem:[[LogItem alloc] initWithLogPosition:round type:LOG_NAKED_PAIR_ROW value:0 position:position]];
									 
									 return true;
							}
						}
						if (column == cellToColumn(position2))
						{
							bool doneSomething = false;
							for (int row2=0; row2<9; row2++)
							{
								int position3 = rowColumnToCell(row2,column);
								if (position3 != position && position3 != position2 && [self removePossibilitiesInOneFromTwo:position position2:position3 round:round]){
									doneSomething = true;
								}
							}
							if (doneSomething){
								if (logHistory || recordHistory)
									[self addHistoryItem:[[LogItem alloc] initWithLogPosition:round type:LOG_NAKED_PAIR_COLUMN value:0 position:position]];
								
								return true;
							}
						}
						if (section == cellToSectionStartCell(position2))
						{
							bool doneSomething = false;
							int secStart = cellToSectionStartCell(position);
							{for (int i=0; i<3; i++){
								for (int j=0; j<3; j++){
									int position3=secStart+i+(9*j);
									if (position3 != position && position3 != position2 && [self removePossibilitiesInOneFromTwo:position position2:position3 round:round]){
										doneSomething = true;
									}
								}
							}}
							if (doneSomething)
							{
								if (logHistory || recordHistory)
									[self addHistoryItem:[[LogItem alloc] initWithLogPosition:round type:LOG_NAKED_PAIR_SECTION value:0 position:position]];
								
								return true;
							}
						}
					}
				}
			}
		}
	}
	return false;
}

/**
 * Mark exactly one cell which is the only possible value for some row, if
 * such a cell exists.
 * This method will look in a row for a possibility that is only listed
 * for one cell.  This type of cell is often called a "hidden single"
 */
- (bool) onlyValueInRow:(int) round
{
	for (int row=0; row<ROW_LENGTH; row++)
	{
		for (int valIndex=0; valIndex<NUM_POSS; valIndex++)
		{
			int count = 0;
			int lastPosition = 0;
			for (int col=0; col<COL_HEIGHT; col++)
			{
				
				int position = (row*ROW_LENGTH)+col;
				int valPos = getPossibilityIndex(valIndex,position);
				if (possibilities[valPos] == 0){
					count++;
					lastPosition = position;
				}
			}
			if (count == 1)
			{
				int value = valIndex+1;
				if (logHistory || recordHistory)
					[self addHistoryItem:[[LogItem alloc] initWithLogPosition:round type:LOG_HIDDEN_SINGLE_ROW value:value position:lastPosition]];
					 
					 
				[self mark:lastPosition round:round value:value];
				return true;
			}
		}
	}
	return false;
}

/**
 * Mark exactly one cell which is the only possible value for some column, if
 * such a cell exists.
 * This method will look in a column for a possibility that is only listed
 * for one cell.  This type of cell is often called a "hidden single"
 */
- (bool) onlyValueInColumn:(int) round
{
	for (int col=0; col<COL_HEIGHT; col++)
	{
		for (int valIndex=0; valIndex<NUM_POSS; valIndex++)
		{
			int count = 0;
			int lastPosition = 0;
			for (int row=0; row<ROW_LENGTH; row++)
			{
				int position = rowColumnToCell(row,col);
				int valPos = getPossibilityIndex(valIndex,position);
				if (possibilities[valPos] == 0)
				{
					count++;
					lastPosition = position;
				}
			}
			if (count == 1)
			{
				int value = valIndex+1;
				if (logHistory || recordHistory)
					[self addHistoryItem:[[LogItem alloc] initWithLogPosition:round type:LOG_HIDDEN_SINGLE_COLUMN value:value position:lastPosition]];
					 
				[self mark:lastPosition round:round value:value];
				return true;
			}
		}
	}
	return false;
}

/**
 * Mark exactly one cell which is the only possible value for some section, if
 * such a cell exists.
 * This method will look in a section for a possibility that is only listed
 * for one cell.  This type of cell is often called a "hidden single"
 */
- (bool) onlyValueInSection:(int) round
{
	for (int sec=0; sec<SEC_COUNT; sec++)
	{
		int secPos = sectionToFirstCell(sec);
		for (int valIndex=0; valIndex<NUM_POSS; valIndex++)
		{
			int count = 0;
			int lastPosition = 0;
			{for (int i=0; i<3; i++){
				for (int j=0; j<3; j++){
					int position = secPos + i + 9*j;
					int valPos = getPossibilityIndex(valIndex,position);
					if (possibilities[valPos] == 0){
						count++;
						lastPosition = position;
					}
				}
			}}
			if (count == 1)
			{
				int value = valIndex+1;
				if (logHistory || recordHistory)
					[self addHistoryItem:[[LogItem alloc] initWithLogPosition:round type:LOG_HIDDEN_SINGLE_SECTION value:value position:lastPosition]];
					 
					 
				[self mark:lastPosition round:round value:value];
				return true;
			}
		}
	}
	return false;
}

/**
 * Mark exactly one cell that has a single possibility, if such a cell exists.
 * This method will look for a cell that has only one possibility.  This type
 * of cell is often called a "single"
 */
- (bool) onlyPossibilityForCell:(int) round
{
	for (int position=0; position<BOARD_SIZE; position++)
	{
		if (solution[position] == 0)
		{
			int count = 0;
			int lastValue = 0;
			for (int valIndex=0; valIndex<NUM_POSS; valIndex++)
			{
				int valPos = getPossibilityIndex(valIndex,position);
				if (possibilities[valPos] == 0){
					count++;
					lastValue=valIndex+1;
				}
			}
			if (count == 1){
				[self mark:position round:round value:lastValue];
				if (logHistory || recordHistory)
					[self addHistoryItem:[[LogItem alloc] initWithLogPosition:round type:LOG_SINGLE value:lastValue position:position]];
				
				return true;
			}
		}
	}
	return false;
}

/**
 * Mark the given value at the given position.  Go through
 * the row, column, and section for the position and remove
 * the value from the possibilities.
 *
 * @param position Position into the board (0-80)
 * @param round Round to mark for rollback purposes
 * @param value The value to go in the square at the given position
 */
- (void) mark:(int)position round:(int)round value:(int)value
{
	
	if (solution[position] != 0)
		DLog(@"Marking position that already has been marked.");
	if (solutionRound[position] !=0)
		DLog(@"Marking position that was marked another round.");
	int valIndex = value-1;
	solution[position] = value;
	
	int possInd = getPossibilityIndex(valIndex,position);
	if (possibilities[possInd] != 0)
		DLog(@"Marking impossible position.");
	
	// Take this value out of the possibilities for everything in the row
	solutionRound[position] = round;
	int rowStart = cellToRow(position)*9;
	for (int col=0; col<COL_HEIGHT; col++){
		int rowVal=rowStart+col;
		int valPos = getPossibilityIndex(valIndex,rowVal);
		//LogIt(@"Row Start: " << rowStart << " Row Value: " << rowVal << " Value Position: " << valPos << endl;
		if (possibilities[valPos] == 0){
			possibilities[valPos] = round;
		}
	}
	
	// Take this value out of the possibilities for everything in the column
	int colStart = cellToColumn(position);
	{for (int i=0; i<9; i++){
		int colVal=colStart+(9*i);
		int valPos = getPossibilityIndex(valIndex,colVal);
		//LogIt(@"Col Start: " << colStart << " Col Value: " << colVal << " Value Position: " << valPos << endl;
		if (possibilities[valPos] == 0){
			possibilities[valPos] = round;
		}
	}}
	
	// Take this value out of the possibilities for everything in section
	int secStart = cellToSectionStartCell(position);
	{for (int i=0; i<3; i++){
		for (int j=0; j<3; j++){
			int secVal=secStart+i+(9*j);
			int valPos = getPossibilityIndex(valIndex,secVal);
			//LogIt(@"Sec Start: " << secStart << " Sec Value: " << secVal << " Value Position: " << valPos << endl;
			if (possibilities[valPos] == 0){
				possibilities[valPos] = round;
			}
		}
	}}
	
	//This position itself is determined, it should have possibilities.
	{for (int valIndex=0; valIndex<9; valIndex++){
		int valPos = getPossibilityIndex(valIndex,position);
		if (possibilities[valPos] == 0){
			possibilities[valPos] = round;
		}
	}}
	
	//LogIt(@"Col Start: " << colStart << " Row Start: " << rowStart << " Section Start: " << secStart<< " Value: " << value << endl;
	//printPossibilities();
}

/**
 * Print a human readable list of all the possibilities for the
 * squares that have not yet been filled in.
 */
- (void) printPossibilities
{
	for(int i=0; i<BOARD_SIZE; i++){
		LogIt(@" ");
		for (int valIndex=0; valIndex<NUM_POSS; valIndex++){
			int posVal = (9*i)+valIndex;
			int value = valIndex+1;
			if (possibilities[posVal]==0){
				LogIt(@"%d", value);
			} else {
				LogIt(@".");
			}
		}
		if (i != BOARD_SIZE-1 && i%SEC_GROUP_SIZE==SEC_GROUP_SIZE-1){
			LogIt(@"\n-------------------------------|-------------------------------|-------------------------------\n");
		} else if (i%9==8){
			LogIt(@"\n");
		} else if (i%3==2){
			LogIt(@" |");
		}
	}
	LogIt(@"\n");
}



@end



SudokuBoard* GenerateSudoku(Difficulty level)
{
	// Initialize the random number generator
	int timeSeed = time(NULL);
	srand(timeSeed);
	
	SudokuBoard* _sb = [[SudokuBoard alloc] init];
	
    
    [_sb setRecordHistory:true];
    
    bool haveLevelPuzzle = false;
    
    DLog(@"Generating Sudoku (level=%d)...",level);
    
    while (haveLevelPuzzle == false)
    {
        bool havePuzzle = [_sb generatePuzzle];
        
        if ( havePuzzle )
        {
            bool haveSolution = [_sb solve];
            
            if ( ( haveSolution ) && ( ( level == DIFF_UNKNOWN ) || ( [_sb getDifficulty] == level ) ) )
            {
                haveLevelPuzzle = true;
            }
        }
    }
    
    DLog(@"...done!");
    
    
    [_sb printSolution];
	[_sb printPuzzle];
    
	return _sb;
}



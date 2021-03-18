//
//  SudokuBoard.h
//  QQWingPorting
//
//  Created by Raymond on 10/15/12.
//  Copyright (c) 2012 Raymond. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "config.h"
#import "LogItem.h"




static inline int cellToColumn(int cell);
static inline int cellToRow(int cell);
static inline int cellToSectionStartCell(int cell);
static inline int cellToSection(int cell);
static inline int rowToFirstCell(int row);
static inline int columnToFirstCell(int column);
static inline int sectionToFirstCell(int section);
static inline int getPossibilityIndex(int valueIndex, int cell);
static inline int rowColumnToCell(int row, int column);
static inline int sectionToCell(int section, int offset);



@interface SudokuBoard : NSObject
{
	/**
     * The 81 integers that make up a sudoku puzzle.
     * Givens are 1-9, unknows are 0.
     * Once initialized, this puzzle remains as is.
     * The answer is worked out in "solution".
     */
    int* puzzle;
    
    /**
     * The 81 integers that make up a sudoku puzzle.
     * The solution is built here, after completion
     * all will be 1-9.
     */
    int* solution;
    
    /**
     * Recursion depth at which each of the numbers
     * in the solution were placed.  Useful for backing
     * out solve branches that don't lead to a solution.
     */
    int* solutionRound;
    
    /**
     * The 729 integers that make up a the possible
     * values for a suduko puzzle. (9 possibilities
     * for each of 81 squares).  If possibilities[i]
     * is zero, then the possibility could still be
     * filled in according to the sudoku rules.  When
     * a possibility is eliminated, possibilities[i]
     * is assigned the round (recursion level) at
     * which it was determined that it could not be
     * a possibility.
     */
    int* possibilities;
    
    /**
     * An array the size of the board (81) containing each
     * of the numbers 0-n exactly once.  This array may
     * be shuffled so that operations that need to
     * look at each cell can do so in a random order.
     */
    int* randomBoardArray;
    
    /**
     * An array with one element for each position (9), in
     * some random order to be used when trying each
     * position in turn during guesses.
     */
    int* randomPossibilityArray;
    
    /**
     * Whether or not to record history
     */
    bool recordHistory;
    
    /**
     * Whether or not to print history as it happens
     */
    bool logHistory;
    
    /**
     * A list of moves used to solve the puzzle.
     * This list contains all moves, even on solve
     * branches that did not lead to a solution.
     */
	
	NSMutableArray* solveHistory;
    
    /**
     * A list of moves used to solve the puzzle.
     * This list contains only the moves needed
     * to solve the puzzle, but doesn't contain
     * information about bad guesses.
     */
    NSMutableArray* solveInstructions;
    
    /**
     * The style with which to print puzzles and solutions
     */
    PrintStyle printStyle;
	
	int lastSolveRound;
}

- (bool) setPuzzle:(int*)initPuzzle;
- (void) printPuzzle;
- (void) printSolution;
- (bool) solve;
- (int) countSolutions;
- (void) printPossibilities;
- (bool) isSolved;
- (void) printSolveHistory;
- (void) setRecordHistory:(bool)recHistory;
- (void) setLogHistory:(bool)logHist;
- (void) setPrintStyle:(PrintStyle) ps;
- (bool) generatePuzzle;
- (int) getGivenCount;
- (int) getSingleCount;
- (int) getHiddenSingleCount;
- (int) getNakedPairCount;
- (int) getHiddenPairCount;
- (int) getBoxLineReductionCount;
- (int) getPointingPairTripleCount;
- (int) getGuessCount;
- (int) getBacktrackCount;
- (void) printSolveInstructions;
- (Difficulty) getDifficulty;
- (NSString*) getDifficultyAsString;
- (int*) getPuzzle; 
- (int*) getSolution; 


- (bool) reset;
- (bool) singleSolveMove:(int) round;
- (bool) onlyPossibilityForCell:(int) round;
- (bool) onlyValueInRow:(int) round;
- (bool) onlyValueInColumn:(int) round;
- (bool) onlyValueInSection:(int) round;
- (bool) solve:(int) round;
- (int) countSolutions:(int) round limitToTwo:(bool) limitToTwo;
- (bool) guess:(int) round guessNumber:(int) guessNumber;
- (bool) isImpossible;
- (void) rollbackRound:(int) round;
- (bool) pointingRowReduction:(int) round;
- (bool) rowBoxReduction:(int) round;
- (bool) colBoxReduction:(int) round;
- (bool) pointingColumnReduction:(int) round;
- (bool) hiddenPairInRow:(int) round;
- (bool) hiddenPairInColumn:(int) round;
- (bool) hiddenPairInSection:(int) round;
- (void) mark:(int) position round:(int) round value:(int) value;
- (int) findPositionWithFewestPossibilities;
- (bool) handleNakedPairs:(int) round;
- (int) countPossibilities:(int) position;
- (bool) arePossibilitiesSame:(int) position1 position2:(int) position2;
- (void) addHistoryItem:(LogItem*) l;
- (void) markRandomPossibility:(int) round;
- (void) shuffleRandomArrays;
- (void) print:(int*) sudoku;
- (void) rollbackNonGuesses;
- (void) clearPuzzle;
- (void) printHistory:(NSMutableArray*) v;
- (bool) removePossibilitiesInOneFromTwo:(int) position1 position2:(int) position2 round:(int) round;

@end

SudokuBoard* GenerateSudoku(Difficulty level);

#!/bin/sh

xcodebuild  -project ../sudokuall.xcodeproj  -scheme "sudoku6free" clean archive
xcodebuild  -project ../sudokuall.xcodeproj  -scheme "sudoku6paid" clean archive
xcodebuild  -project ../sudokuall.xcodeproj  -scheme "sudoku7free" clean archive
xcodebuild  -project ../sudokuall.xcodeproj  -scheme "sudoku9free" clean archive
xcodebuild  -project ../sudokuall.xcodeproj  -scheme "sudoku9paid" clean archive
xcodebuild  -project ../sudokuall.xcodeproj  -scheme "gtsudoku6free" clean archive
xcodebuild  -project ../sudokuall.xcodeproj  -scheme "gtsudoku6paid" clean archive
xcodebuild  -project ../sudokuall.xcodeproj  -scheme "gtsudoku9free" clean archive
xcodebuild  -project ../sudokuall.xcodeproj  -scheme "gtsudoku9paid" clean archive
xcodebuild  -project ../sudokuall.xcodeproj  -scheme "killersudoku6free" clean archive
xcodebuild  -project ../sudokuall.xcodeproj  -scheme "killersudoku6paid" clean archive
xcodebuild  -project ../sudokuall.xcodeproj  -scheme "killersudoku9free" clean archive
xcodebuild  -project ../sudokuall.xcodeproj  -scheme "killersudoku9paid" clean archive


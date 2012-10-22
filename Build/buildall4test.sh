#!/bin/sh

xcodebuild  -project ../sudokuall.xcodeproj  -scheme "sudoku6free" test
xcodebuild  -project ../sudokuall.xcodeproj  -scheme "sudoku6paid" test
xcodebuild  -project ../sudokuall.xcodeproj  -scheme "sudoku7free" test
xcodebuild  -project ../sudokuall.xcodeproj  -scheme "sudoku9free" test
xcodebuild  -project ../sudokuall.xcodeproj  -scheme "sudoku9paid" test
xcodebuild  -project ../sudokuall.xcodeproj  -scheme "gtsudoku6free" test
xcodebuild  -project ../sudokuall.xcodeproj  -scheme "gtsudoku6paid" test
xcodebuild  -project ../sudokuall.xcodeproj  -scheme "gtsudoku9free" test
xcodebuild  -project ../sudokuall.xcodeproj  -scheme "gtsudoku9paid" test


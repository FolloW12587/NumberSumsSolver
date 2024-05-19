//
//  Solver.swift
//  NumberSumsSolver
//
//  Created by Сергей Дубовой on 19.05.2024.
//

import Foundation


class Solver: ObservableObject {
    let dimensions: (rows: Int, columns: Int)
    @Published var board: [[Int?]]
    var boardOpenings: [[Bool?]] = []
    @Published var sums: (rows: [Int?], columns: [Int?])
    
    @Published var hasSolution = false
    @Published var isSolving = false
    
    private var _isBoardValidated = false
    
    init(dimensions: (rows: Int, columns: Int)) {
        self.dimensions = dimensions
        
        board = Array(repeating: Array(repeating: nil, count: dimensions.columns), count: dimensions.rows)
        sums = (Array(repeating: nil, count: dimensions.rows), Array(repeating: nil, count: dimensions.columns))
    }
    
    private func validateBoard() -> Bool {
        guard !_isBoardValidated else { return true }
        guard board.count == dimensions.rows, 
                sums.rows.count == dimensions.rows, 
                sums.columns.count == dimensions.columns else { return false }
        
        for row in board {
            guard row.count == dimensions.columns else { return false }
            for num in row {
                guard num != nil else { return false }
            }
        }
        
        for sum in sums.rows {
            guard sum != nil else { return false }
        }
        
        for sum in sums.columns {
            guard sum != nil else { return false }
        }
        
        _isBoardValidated = true
        return true
    }
    
    func solve() {
        isSolving = true
        guard validateBoard() else { 
            isSolving = false
            print("Invalid board")
            return
        }
        
        guard solveBoard() else {
            print("Solution not found!")
            isSolving = false
            return
        }
        
        print("Solution found")
        print(boardOpenings)
        isSolving = false
    }
    
    private func solveBoard() -> Bool{
        guard validateBoard() else { return false }
        
        var possibleVariations: [SumRow: Set<Set<Int>>] = [:]
        boardOpenings = Array(repeating: Array(repeating: nil, count: dimensions.columns), count: dimensions.rows)
        
        // for a certain number of the row/column we can either take it or not.
        // So check over all possible solutions
        func dp(isOverRow: Bool, row: Int, column: Int, usedIndexes: Set<Int>, currentSum: Int, target: Int) {
            guard row < dimensions.rows, column < dimensions.columns else { return }
            
            let index = isOverRow ? column : row
            let num = board[row][column]!
            let state = boardOpenings[row][column]
            
            // take this number (but only if its not marked as closed)
            if state == nil || state == true {
                let newSum = currentSum + num
                var newSet = usedIndexes
                newSet.insert(index)
                if newSum == target {
                    possibleVariations[SumRow(isOverRow: isOverRow, 
                                              num: isOverRow ? row : column),
                                       default: []]
                        .insert(newSet)
                } else if newSum < target {
                    dp(isOverRow: isOverRow,
                       row: isOverRow ? row : row+1, 
                       column: isOverRow ? column+1 : column,
                       usedIndexes: newSet,
                       currentSum: newSum,
                       target: target)
                } // do nothing if newSum > target
            }
            
            // don't take this number (but only if its not marked as opened
            if state == nil || state == false {
                dp(isOverRow: isOverRow,
                   row: isOverRow ? row : row+1,
                   column: isOverRow ? column+1 : column,
                   usedIndexes: usedIndexes,
                   currentSum: currentSum,
                   target: target)
            }
        }
        
        func checkForSolution() throws -> Bool {
            guard possibleVariations.keys.count == dimensions.columns + dimensions.rows else {
                print("Not all possible variations found! Count: \(possibleVariations.keys.count)")
                throw CustomError.invalidBoard
            }
            
            for value in possibleVariations.values {
                guard !value.isEmpty else {
                    print("Possible variation is empty")
                    throw CustomError.invalidBoard
                }
                if value.count > 1 {
                    return false
                }
            }
            return true
        }
        
        // find all possible combinations for all rows
        for row in 0..<dimensions.rows {
            dp(isOverRow: true, row: row, column: 0, usedIndexes: [], currentSum: 0, target: sums.rows[row]!)
            
            let sumRow = SumRow(isOverRow: true, num: row)
            guard let variations = possibleVariations[sumRow] else {
                print("No variations found for row \(row)")
                return false
            }
            let indexes = Set(0..<dimensions.columns)
            
            // looking for indexes, that were in all sets
            let intersection = variations.reduce(indexes) { prev, current in
                prev.intersection(current)
            }
            
            // marking them in openings
            for index in intersection {
                boardOpenings[row][index] = true
            }
            
            // looking for indexes that are not appeared in any set
            let toExclude = variations.reduce(indexes) { prev, current in
                prev.subtracting(current)
            }
            
            for index in toExclude {
                boardOpenings[row][index] = false
            }
        }
        
        // find all possible combinations for all columns
        for column in 0..<dimensions.columns {
            dp(isOverRow: false, row: 0, column: column, usedIndexes: [], currentSum: 0, target: sums.columns[column]!)
            
            let sumRow = SumRow(isOverRow: false, num: column)
            guard let variations = possibleVariations[sumRow] else {
                print("No variations found for column \(column)")
                return false
            }
            var indexes = Set<Int>()
            for i in 0..<dimensions.rows where boardOpenings[i][column] != false {
                indexes.insert(i)
            }
            
            // looking for indexes, that were in all sets
            let intersection = variations.reduce(indexes) { prev, current in
                prev.intersection(current)
            }
            
            // marking them in openings
            for index in intersection {
                boardOpenings[index][column] = true
            }

            // looking for indexes that are not appeared in any set
            let toExclude = variations.reduce(indexes) { prev, current in
                prev.subtracting(current)
            }
            
            for index in toExclude {
                boardOpenings[index][column] = false
            }
        }
        
//        print("Possible variations: \(possibleVariations)")
        var iteration = 0
        while true {
            guard let isSolutionFound = try? checkForSolution() else {
                print("Something wrong in cheking the solutions!")
                return false
            }
            if isSolutionFound {
                print("Solution found!")
                return true
            }
            
            if iteration % 100 == 0 {
                print("Iteration \(iteration)")
            }
            var changesMade = false
            
            for row in 0..<dimensions.rows {
                let sumRow = SumRow(isOverRow: true, num: row)
                guard var variations = possibleVariations[sumRow] else { return false }
                var indexes = Set<Int>()
                var neededIndexes = Set<Int>()
                for i in 0..<dimensions.columns where boardOpenings[row][i] != false {
                    indexes.insert(i)
                    if boardOpenings[row][i] == true {
                        neededIndexes.insert(i)
                    }
                }
                
                for variation in variations {
                    if !neededIndexes.isSubset(of: variation) || !variation.isSubset(of: indexes) {
                        possibleVariations[sumRow]?.remove(variation)
                        changesMade = true
                    }
                }
                
                variations = possibleVariations[sumRow]!
                
                if variations.count == 1 {
                    let variation = variations.first!
                    for i in 0..<dimensions.columns where boardOpenings[row][i] == nil {
                        boardOpenings[row][i] = variation.contains(i)
                        changesMade = true
                    }
                } else {
                    
                    // looking for indexes, that were in all sets
                    let intersection = variations.reduce(indexes) { prev, current in
                        prev.intersection(current)
                    }
                    
                    // marking them in openings
                    for index in intersection where boardOpenings[row][index] == nil {
                        boardOpenings[row][index] = true
                        changesMade = true
                    }
                    
                    // looking for indexes that are not appeared in any set
                    let toExclude = variations.reduce(indexes) { prev, current in
                        prev.subtracting(current)
                    }
                    
                    for index in toExclude where boardOpenings[row][index] == nil {
                        boardOpenings[row][index] = false
                        changesMade = true
                    }
                    
                }
            }
            
            for column in 0..<dimensions.columns {
                let sumRow = SumRow(isOverRow: false, num: column)
                guard var variations = possibleVariations[sumRow] else { return false }
                var indexes = Set<Int>()
                var neededIndexes = Set<Int>()
                for i in 0..<dimensions.rows where boardOpenings[i][column] != false {
                    indexes.insert(i)
                    if boardOpenings[i][column] == true {
                        neededIndexes.insert(i)
                    }
                }
                
                for variation in variations {
                    if !neededIndexes.isSubset(of: variation) || !variation.isSubset(of: indexes) {
                        possibleVariations[sumRow]?.remove(variation)
                        changesMade = true
                    }
                }
                
                variations = possibleVariations[sumRow]!
                
                if variations.count == 1 {
                    let variation = variations.first!
                    for i in 0..<dimensions.rows where boardOpenings[i][column] == nil {
                        boardOpenings[i][column] = variation.contains(i)
                        changesMade = true
                    }
                } else {
                    
                    // looking for indexes, that were in all sets
                    let intersection = variations.reduce(indexes) { prev, current in
                        prev.intersection(current)
                    }
                    
                    // marking them in openings
                    for index in intersection where boardOpenings[index][column] == nil {
                        boardOpenings[index][column] = true
                        changesMade = true
                    }
                    
                    // looking for indexes that are not appeared in any set
                    let toExclude = variations.reduce(indexes) { prev, current in
                        prev.subtracting(current)
                    }
                    
                    for index in toExclude where boardOpenings[index][column] == nil {
                        boardOpenings[index][column] = false
                        changesMade = true
                    }
                }
            }
            
            iteration += 1
            guard changesMade else {
                print("No changes made on iteration: \(iteration)")
                return false
            }
        }
    }
}

private enum CustomError: Error {
    case invalidBoard
}

struct SumRow: Hashable {
    let isOverRow: Bool
    let num: Int
}

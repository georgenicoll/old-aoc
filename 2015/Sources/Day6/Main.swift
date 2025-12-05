import Core
import Foundation
import RegexBuilder

let gridWidth = 1000

struct Coord {
    let x: Int
    let y: Int
}

enum Operation: String {
    case on = "turn on"
    case off = "turn off"
    case toggle = "toggle"
}

struct Instruction {
    let operation: Operation
    let start: Coord
    let end: Coord
}

private func parse(_ content: String) -> [Instruction] {
    let regex = /(?<operation>turn on|toggle|turn off) (?<startX>\d+),(?<startY>\d+) through (?<endX>\d+),(?<endY>\d+)/
        .anchorsMatchLineEndings()
    return content.matches(of: regex).map { match in
        Instruction(
            operation: Operation(rawValue: String(match.operation))!,
            start: Coord(x: Int(match.startX)!, y: Int(match.startY)!),
            end: Coord(x: Int(match.endX)!, y: Int(match.endY)!)
        )
    }
}

private func flattenedIndex(x: Int, y: Int) -> Int {
    y * gridWidth + x
}

private func part1(_ instructions: [Instruction]) -> Int {
    var grid = Array(repeating: false, count: gridWidth * gridWidth)
    for instruction in instructions {
        for y in instruction.start.y ... instruction.end.y {
            for x in instruction.start.x ... instruction.end.x {
                let index = flattenedIndex(x: x, y: y)
                switch instruction.operation {
                case .on:
                    grid[index] = true
                case .off:
                    grid[index] = false
                case .toggle:
                    grid[index] = !grid[index]
                }
            }
        }
    }
    return grid.filter { $0 }.count
}

private func part2(_ instructions: [Instruction]) -> Int {
    var grid = Array(repeating: 0, count: gridWidth * gridWidth)
    for instruction in instructions {
        for y in instruction.start.y ... instruction.end.y {
            for x in instruction.start.x ... instruction.end.x {
                let index = flattenedIndex(x: x, y: y)
                switch instruction.operation {
                case .on:
                    grid[index] = grid[index] + 1
                case .off:
                    grid[index] = max(grid[index] - 1, 0)
                case .toggle:
                    grid[index] = grid[index] + 2
                }
            }
        }
    }
    return grid.reduce(0) { $0 + $1 }
}

@main
struct Main {
    static func main() {
        let file = getSourceFileSibling(#filePath, "Files/input.txt")
        let content = try! readEntireFile(file)
        let instructions = parse(content)

        let part1 = part1(instructions)
        print(part1)

        let part2 = part2(instructions)
        print(part2)
    }
}

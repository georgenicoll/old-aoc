import Core
import Foundation
import RegexBuilder

private struct Coord : Hashable {
    let x: Int
    let y: Int
}

private enum Move : String, CustomStringConvertible {
    case up = "^"
    case left = ">"
    case down = "v"
    case right = "<"

    var description: String {
        return self.rawValue
    }
}

private func doMove(_ current: Coord, _ move: Move) -> Coord {
    switch move {
    case .up:
        return Coord(x: current.x, y: current.y - 1)
    case .left:
        return Coord(x: current.x - 1, y: current.y)
    case .down:
        return Coord(x: current.x, y: current.y + 1)
    case .right:
        return Coord(x: current.x + 1, y: current.y)
    }
}

private func part1(_ moves: [Move]) -> Int {
    var current = Coord(x: 0, y: 0)
    var visited = [Coord: Int]()
    visited[current] = 1
    for move in moves {
        current = doMove(current, move)
        visited[current] = (visited[current] ?? 0) + 1
    }
    return visited.count
}

private func part2(_ moves: [Move]) -> Int {
    var currentSanta = Coord(x: 0, y: 0)
    var currentRobo = Coord(x: 0, y: 0)
    var visited = [Coord: Int]()
    visited[currentSanta] = 1
    for santaIndex in stride(from: 0, to: moves.count, by: 2) {
        currentSanta = doMove(currentSanta, moves[santaIndex])
        visited[currentSanta] = (visited[currentSanta] ?? 0) + 1

        let roboIndex = santaIndex + 1
        currentRobo = doMove(currentRobo, moves[roboIndex])
        visited[currentRobo] = (visited[currentRobo] ?? 0) + 1
    }
    return visited.count
}

@main
struct Main {
    static func main() {
        // let file = getSourceFileSibling(#filePath, "Files/example.txt")
        let file = getSourceFileSibling(#filePath, "Files/input.txt")
        let content = try! readEntireFile(file)
        let moves = Array(content).reduce(into: [Move]()) { (acc, char) in
            let move = Move(rawValue: String(char))!
            return acc.append(move)
        }

        let part1 = part1(moves)
        print(part1)

        let part2 = part2(moves)
        print(part2)
    }
}

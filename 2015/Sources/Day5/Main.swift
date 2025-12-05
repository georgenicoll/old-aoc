import Core
import Foundation


private func isNice1(_ string: String) -> Bool {
    var vowelCount = 0
    var containsRepeat = false
    for i in 0..<string.count {
        let char = string[string.index(string.startIndex, offsetBy: i)]
        // Perform 2 char checks
        if i < string.count - 1 {
            let nextChar = string[string.index(string.startIndex, offsetBy: i + 1)]
            if char == nextChar {
                containsRepeat = true
            }
            switch (char, nextChar) {
                case ("a", "b"), ("c", "d"), ("p", "q"), ("x", "y"):
                    return false //Immediate not-nice
                default:
                    break
            }
        }
        // Perform 1 char checks
        if "aeiou".contains(char) {
            vowelCount += 1
        }
    }
    return vowelCount >= 3 && containsRepeat
}

struct Pair: Hashable, CustomStringConvertible, CustomDebugStringConvertible {
    let first: Character
    let second: Character

    var description: String {
        "\(first)\(second)"
    }

    var debugDescription: String {
        description
    }
}

private func containsRepeatedPair(_ string: String) -> Bool {
    var pairs = [Pair:Int]()
    for i in 0..<(string.count - 1) {
        let first = string[string.index(string.startIndex, offsetBy: i)]
        let second = string[string.index(string.startIndex, offsetBy: i + 1)]
        let pair = Pair(first: first, second: second)

        if let previousPairIndex = pairs[pair] {
            if previousPairIndex < i - 1 {
                return true //we found a non-overlapping pair
            }
        } else {
            pairs[pair] = i
        }
    }
    return false
}

private func containsSeparatedPair(_ string: String) -> Bool {
    for i in 0..<(string.count - 2) {
        let firstChar = string[string.index(string.startIndex, offsetBy: i)]
        let charButOne = string[string.index(string.startIndex, offsetBy: i + 2)]
        if firstChar == charButOne {
            return true
        }
    }
    return false
}

private func isNice2(_ string: String) -> Bool {
    return containsRepeatedPair(string) && containsSeparatedPair(string)
}

@main
struct Main {
    static func main() {
        //let file = getSourceFileSibling(#filePath, "Files/example.txt")
        let file = getSourceFileSibling(#filePath, "Files/input.txt")
        let lines = try! readFileLineByLine(file: file, into: [String]()) { $0.append($1) }

        let part1 = lines.count(where: isNice1)
        print(part1)

        let part2 = lines.count(where: isNice2)
        print(part2)
    }
}

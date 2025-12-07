import Core
import Foundation
import RegexBuilder

private func calcInMemorySize(_ s: String) -> Int {
  let withoutOuterQuotes = String(s.dropFirst().dropLast())
  let outerQuotesReduction = 2
  let escapedRegEx = /(?<escaped>\\\"|\\\\|\\x[0-9a-f]{2})/
  let escapedReduction = withoutOuterQuotes.matches(of: escapedRegEx).reduce(0) { sum, match in
    let reduction = match.escaped.count == 2 ? 1 : 3
    return sum + reduction
  }
  return s.count - outerQuotesReduction - escapedReduction
}

private func calcReencodedSize(_ s: String) -> Int {
  let outerQuotesExpansion = 2 //new quotes at either end
  let toEncodeRegex = /(?<toEncode>\"|\\)/
  let matches = s.matches(of: toEncodeRegex)
  let matchesExpansion = matches.count //each match will introduce an additional escape char
  return s.count + outerQuotesExpansion + matchesExpansion
}

@main
struct App {

  static func main() {
    // let file = getFileSibling(#filePath, "Files/example.txt")
    let file = getFileSibling(#filePath, "Files/input.txt")
    let lines = try! readFileLineByLine(file: file, into: [String](), { $0.append($1) })

    let part1 = lines.reduce(0) { sum, line in
      let inMemorySize = calcInMemorySize(line)
      return sum + (line.count - inMemorySize)
    }
    print(part1)

    let part2 = lines.reduce(0) { sum, line in
      let reencodedSize = calcReencodedSize(line)
      return sum + (reencodedSize - line.count)
    }
    print(part2)
  }
}
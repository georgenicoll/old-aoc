import Collections
import Core
import Foundation
import RegexBuilder

struct Journey: Hashable {
  let from: String
  let to: String
}

class Context {
  var distances: [Journey: Int] = [:]
  var locations: OrderedSet<String> = []
}

private func handleLine(_ context: inout Context, _ line: String) {
  let journeyRegex = /(?<from>\S+) to (?<to>\S+) = (?<distance>\d+)/
  if let match = line.firstMatch(of: journeyRegex) {
    let journey1 = Journey(from: String(match.from), to: String(match.to))
    let journey2 = Journey(from: String(match.to), to: String(match.from))
    context.distances[journey1] = Int(match.distance)
    context.distances[journey2] = Int(match.distance)
    context.locations.append(String(match.from))
    context.locations.append(String(match.to))
  }
}

private func calculateJourneys(
  context: Context,
  visitedLocations: [String],
  remainingLocations: [String],
  distanceToHere: Int,
  fullJourneys: inout [([String], Int)]
) {
  //Nowhere else to go?  We're done
  if remainingLocations.isEmpty {
    fullJourneys.append((visitedLocations, distanceToHere))
    return
  }
  //Go to all the remaining destinations from here
  for i in 0..<remainingLocations.count {
    let next = remainingLocations[i]

    //If we had already visited somewhere, we can work out the hop to the next place
    var newDistanceToHere = distanceToHere
    if let previous = visitedLocations.last {
      newDistanceToHere += context.distances[Journey(from: previous, to: next)]!
    }

    var newVisitedLocations = visitedLocations
    newVisitedLocations.append(next)
    var newRemainingLocations = remainingLocations
    newRemainingLocations.remove(at: i)
    calculateJourneys(
      context: context,
      visitedLocations: newVisitedLocations,
      remainingLocations: newRemainingLocations,
      distanceToHere: newDistanceToHere,
      fullJourneys: &fullJourneys,
    )
  }
}

///Returns (part1, part2)
private func solution(_ context: Context) -> (Int, Int) {
  let locations = context.locations.elements

  var fullJourneys: [([String], Int)] = []

  // Work out all combinations of journeys with distances encompassing all of the locations
  calculateJourneys(
    context: context,
    visitedLocations: [],
    remainingLocations: locations,
    distanceToHere: 0,
    fullJourneys: &fullJourneys
  )

  //Sort to get the lowest first
  fullJourneys.sort { $0.1 < $1.1 }

  return (fullJourneys.first!.1, fullJourneys.last!.1)
}

@main
struct App {

  static func main() {
    // let file = getFileSibling(#filePath, "Files/example.txt")
    let file = getFileSibling(#filePath, "Files/input.txt")
    let context = try! readFileLineByLine(file: file, into: Context(), handleLine)

    let (part1, part2) = solution(context)
    print(part1)
    print(part2)
  }
}
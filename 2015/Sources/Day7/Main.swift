import Collections
import Core
import Foundation
import RegexBuilder


typealias Wire = UInt16

enum Gate: CustomStringConvertible, CustomDebugStringConvertible {
  case CONNECTION(input: String, output: String)
  case AND(left: String, right: String, output: String)
  case OR(left: String, right: String, output: String)
  case LSHIFT(input: String, shift: Int, output: String)
  case RSHIFT(input: String, shift: Int, output: String)
  case NOT(input: String, output: String)

  var description: String {
    switch self {
    case .CONNECTION(let input, let output):
      return "\(input) -> \(output)"
    case .AND(let left, let right, let output):
      return "\(left) AND \(right) -> \(output)"
    case .OR(let left, let right, let output):
      return "\(left) OR \(right) -> \(output)"
    case .LSHIFT(let input, let shift, let output):
      return "\(input) LSHIFT \(shift) -> \(output)"
    case .RSHIFT(let input, let shift, let output):
      return "\(input) RSHIFT \(shift) -> \(output)"
    case .NOT(let input, let output):
      return "NOT \(input) -> \(output)"
    }
  }

  var debugDescription: String {
    description
  }
}

class Node {
  let id: String
  var outputs: [Gate] = []

  init(id: String) {
    self.id = id
  }
}

class Circuit {
  var startNodeValues: [String:Wire] = [:]
  var nodes: [String:Node] = [:]
}

private func handleLine(_ circuit: inout Circuit, line: String) {
  func getNode(id: String) -> Node {
    let node = circuit.nodes[id]
    if let node = node {
      return node
    }
    let newNode = Node(id: id)
    circuit.nodes[id] = newNode
    return newNode
  }

  let startNodeRegex = /(?<value>\d+) -> (?<id>\S+)/
  if let match = line.wholeMatch(of: startNodeRegex) {
    circuit.startNodeValues[String(match.id)] = Wire(match.value)
    return
  }
  let connectionRegex = /(?<input>\S+) -> (?<out>\S+)/
  if let match = line.wholeMatch(of: connectionRegex) {
    let input = getNode(id: String(match.input))
    let output = getNode(id: String(match.out))
    let gate = Gate.CONNECTION(input: input.id, output: output.id)
    input.outputs.append(gate)
    return
  }
  let andRegex = /(?<left>\S+) AND (?<right>\S+) -> (?<out>\S+)/
  if let match = line.wholeMatch(of: andRegex) {
    let leftNode = getNode(id: String(match.left))
    let rightNode = getNode(id: String(match.right))
    let outputNode = getNode(id: String(match.out))
    let gate = Gate.AND(left: leftNode.id, right: rightNode.id, output: outputNode.id)
    leftNode.outputs.append(gate)
    rightNode.outputs.append(gate)
    return
  }
  let orRegex = /(?<left>\S+) OR (?<right>\S+) -> (?<out>\S+)/
  if let match = line.wholeMatch(of: orRegex) {
    let leftNode = getNode(id: String(match.left))
    let rightNode = getNode(id: String(match.right))
    let outputNode = getNode(id: String(match.out))
    let gate = Gate.OR(left: leftNode.id, right: rightNode.id, output: outputNode.id)
    leftNode.outputs.append(gate)
    rightNode.outputs.append(gate)
    return
  }
  let lshiftRegex = /(?<in>\S+) LSHIFT (?<shift>\d+) -> (?<out>\S+)/
  if let match = line.wholeMatch(of: lshiftRegex) {
    let inputNode = getNode(id: String(match.in))
    let outputNode = getNode(id: String(match.out))
    let gate = Gate.LSHIFT(input: inputNode.id, shift: Int(match.shift)!, output: outputNode.id)
    inputNode.outputs.append(gate)
    return
  }
  let rshiftRegex = /(?<in>\S+) RSHIFT (?<shift>\d+) -> (?<out>\S+)/
  if let match = line.wholeMatch(of: rshiftRegex) {
    let inputNode = getNode(id: String(match.in))
    let outputNode = getNode(id: String(match.out))
    let gate = Gate.RSHIFT(input: inputNode.id, shift: Int(match.shift)!, output: outputNode.id)
    inputNode.outputs.append(gate)
    return
  }
  let notRegex = /NOT (?<in>\S+) -> (?<out>\S+)/
  if let match = line.wholeMatch(of: notRegex) {
    let inputNode = getNode(id: String(match.in))
    let outputNode = getNode(id: String(match.out))
    let gate = Gate.NOT(input: inputNode.id, output: outputNode.id)
    inputNode.outputs.append(gate)
    return
  }
}

private func runCircuit(_ circuit: Circuit, _ outputs: Set<String>) -> [String:Wire] {
  var (values, queue) = circuit.startNodeValues.reduce(into: ([String:Wire](), Deque<String>())) { acc, keyValue in
    acc.0[keyValue.key] = keyValue.value
    acc.1.append(keyValue.key)
  }
  //populate value nodes - these are any nodes that have a Wire value as its id
  circuit.nodes
    .compactMapValues { Wire($0.id) }
    .forEach { key, value in
      // print("Node \(key) has value \(value)")
      values[key] = value
      queue.append(key)
    }

  func updateOutput(id: String, value: Wire) {
    // if the value has changed, update and append the new value to the queue, otherwise just ignore the update
    if let currentValue = values[id], currentValue == value {
      // print("Value for \(id) has not changed from \(value)")
      return
    }
    // print("Value for \(id) is now \(value)")
    values[id] = value
    queue.append(id)
  }

  while !queue.isEmpty {
    let id = queue.popFirst()!
    let node = circuit.nodes[id]!
    //Check each output gate and if everything is set then post an item to process it to the queue
    if node.outputs.isEmpty {
      // print("No outputs for \(id)")
      continue
    }
    // print("Processing node \(id) with outputs \(node.outputs)")
    for gate in node.outputs {
      switch gate {
        case .CONNECTION(let input, let output):
          if let input = values[input] {
            updateOutput(id: output, value: input)
          }
        case .AND(let left, let right, let output):
          if let left = values[left], let right = values[right] {
            updateOutput(id: output, value: left & right)
          }
        case .OR(let left, let right, let output):
          if let left = values[left], let right = values[right] {
            updateOutput(id: output, value: left | right)
          }
        case .LSHIFT(let input, let shift, let output):
          if let input = values[input] {
            updateOutput(id: output, value: input << shift)
          }
        case .RSHIFT(let input, let shift, let output):
          if let input = values[input] {
            updateOutput(id: output, value: input >> shift)
          }
        case .NOT(let input, let output):
          if let input = values[input] {
            updateOutput(id: output, value: ~input)
          }
      }
    }
  }

  return outputs.reduce(into: [String:Wire]()) { acc, output in
    if let value = values[output] {
      acc[output] = value
    }
  }
}

@main
struct App {

  static func main() {
    //let file = getFileSibling(#filePath, "Files/example.txt")
    let file = getFileSibling(#filePath, "Files/input.txt")
    let circuit = try! readFileLineByLine(file: file, into: Circuit(), handleLine)

    // print(circuit.nodes)

    //let part1 = runCircuit(circuit, ["d","e","f","g","h","i","x","y","z"])
    let part1 = runCircuit(circuit, ["a"])
    print(part1)

    // Override the value of 'b' to the result we got from 'a' for part 1 and re-run
    circuit.startNodeValues["b"] = part1["a"]!
    let part2 = runCircuit(circuit, ["a"])
    print(part2)
  }

}
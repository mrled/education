//
//  CalculatorBrain.swift
//  StanfordCalculator
//
//  Created by Micah R Ledbetter on 2015-04-01.
//  Copyright (c) 2015 Micah R Ledbetter. All rights reserved.
//

import Foundation

public class CalculatorBrain {
    private enum Op: Printable {
        case Operand(symbol: String?, value: Double)
        case Variable(symbol: String, value: Double?)
        case UnaryOperation (symbol: String, operation: (Double)         -> Double)
        case BinaryOperation(symbol: String, operation: (Double, Double) -> Double)
        
        var description: String {
            switch self {
            case .Operand(let symbol, let number):
                if (symbol != nil) { return symbol! }
                else { return "\(number)" }
            case .Variable(let symbol, _): return symbol
            case .UnaryOperation(let symbol, _): return symbol
            case .BinaryOperation(let symbol, _): return symbol
            }
        }
    }

    private class CalculatorEvaluation: Printable {
        var result: Double?
        var desc: String
        var ops: [Op]
        var remainingOps: [Op]
        var remainingEvaluation: CalculatorEvaluation?
        init() {
            self.result = nil
            self.desc = ""
            self.ops = []
            self.remainingOps = []
            self.remainingEvaluation = nil
        }
        var description: String {
            if self.result == nil {
                return ""
            }
            switch self.ops[0] {
            case .Operand, .Variable:
                return "\(self.desc)"
            case .UnaryOperation, .BinaryOperation:
                return "\(self.desc) = \(self.result!)"
            }
        }
    }
    
    private var opStack = [Op]()
    private var knownOps = [String:Op]()
    private var variableValues = [String:Double]()

    public init() {
        knownOps["×"] = Op.BinaryOperation(symbol: "×", operation: *)
        knownOps["÷"] = Op.BinaryOperation(symbol: "÷", operation: {$1 / $0})
        knownOps["+"] = Op.BinaryOperation(symbol: "+", operation: +)
        knownOps["−"] = Op.BinaryOperation(symbol: "−", operation: {$1 - $0})
        knownOps["√"]   = Op.UnaryOperation(symbol: "√", operation: sqrt)
        knownOps["sin"] = Op.UnaryOperation(symbol: "sin", operation: sin)
        knownOps["cos"] = Op.UnaryOperation(symbol: "cos", operation: cos)
        knownOps["+/-"] = Op.UnaryOperation(symbol: "+/-", operation: {$0 * -1})
        knownOps["π"] = Op.Operand(symbol: "π", value: M_PI)
        variableValues["X"] = nil
        variableValues["Y"] = nil
        variableValues["Z"] = nil
    }
    
    public var description: String {
        get {
            var ops = opStack
            var calculating = true
            var iterator = 0
            let ev = evaluate(ops, silent: true)
            var desc = "\(ev)"
            if !ev.remainingOps.isEmpty {
                desc += ", remaining: "
                for ro in ev.remainingOps {
                    desc += "\(ro) "
                }
            }
            return desc
        }
    }
    
    private func evaluate(ops: [Op], silent: Bool=false, iterator: Int32=0) -> CalculatorEvaluation {
        let emptyEval = CalculatorEvaluation()  // Just for clarity in function
        var evaluation = CalculatorEvaluation()
        evaluation.ops = ops
        if ops.isEmpty {
            return emptyEval
        }

        var myIterator = iterator
        if !silent {
            var padding = ""
            for _ in 0...myIterator {
                padding += "  "
            }
            println("\(padding)evaluate(ops: [Op]) #\(myIterator++) called with \(ops).")
        }
        
        var remainOps = ops
        let op = remainOps.removeLast()
        
        switch op {
            
        case .Operand(let symbol, let operand):
            evaluation.result = operand
            evaluation.desc = "\(operand)"
            if let s = symbol {
                evaluation.desc = s
            }
            evaluation.remainingOps = remainOps
            evaluation.remainingEvaluation = nil
            if (!remainOps.isEmpty) {
                evaluation.remainingEvaluation = evaluate(remainOps, silent:silent, iterator:myIterator)
            }
            
        case .UnaryOperation(let symbol, let operation):
            let opEval = evaluate(remainOps, silent:silent, iterator:myIterator)
            if opEval.result == nil {
                return emptyEval
            }
            evaluation.result = operation(opEval.result!)
            evaluation.desc = "\(symbol)(\(opEval.description))"
            evaluation.remainingOps = opEval.remainingOps
            evaluation.remainingEvaluation = opEval.remainingEvaluation
            
        case .BinaryOperation(let symbol, let operation):
            if !(remainOps.count >= 2) {
                return emptyEval
            }
            let eval1 = evaluate(remainOps, silent:silent, iterator:myIterator)
            if eval1.result == nil {
                return emptyEval
            }
            let eval2 = evaluate(eval1.remainingOps, silent:silent, iterator:myIterator)
            if eval2.result == nil {
                return emptyEval
            }
            evaluation.result = operation(eval1.result!, eval2.result!)
            evaluation.desc = "(\(eval2.description) \(symbol) \(eval1.description))"
            evaluation.remainingOps = eval2.remainingOps
            evaluation.remainingEvaluation = eval2.remainingEvaluation
            
        case .Variable(let symbol, let value):
            evaluation.result = value
            evaluation.desc = symbol
            evaluation.remainingOps = []
            evaluation.remainingEvaluation = nil
            if !remainOps.isEmpty {
                evaluation.remainingOps = remainOps
                evaluation.remainingEvaluation = evaluate(remainOps, silent:silent, iterator:myIterator)
            }
        }
        return evaluation
    }

    public func evaluate(verbose: Bool = false) -> Double? {
        let evaluation = evaluate(opStack)
        if verbose {
            if evaluation.result == nil {
                println("evaluate(): bad input")
            }
            else {
                println("evaluate(): result: \(evaluation.result!)")
            }
            println("evaluate(): remainingOps: \(evaluation.remainingOps)")
            println("evaluate(): Full stack: \(opStack)")
            println("evaluate(): memory: \(variableValues)")
        }
        return evaluation.result
    }
    
    public func pushInput(value: Double?) -> Double? {
        if let unwrappedValue = value {
            let operand = Op.Operand(symbol: nil, value: unwrappedValue)
            opStack.append(operand)
            return evaluate()
        }
        return nil
    }
    
    public func pushInput(symbol: String?) -> Double? {
        var appendOp: Op? = nil
        if let unwrappedSymbol = symbol {
            if let knownOp = knownOps[unwrappedSymbol] {
                appendOp = knownOp
            }
            else if let knownVar = variableValues[unwrappedSymbol] {
                appendOp = Op.Operand(symbol: unwrappedSymbol, value: knownVar)
            }
        }
        
        if (appendOp != nil) {
            opStack.append(appendOp!)
            return evaluate()
        }
        else {
            return nil
        }
    }
    
    public func pushVariable(symbol: String) -> Double? {
        let appendVar = Op.Variable(symbol: symbol, value: variableValues[symbol])
        opStack.append(appendVar)
        return evaluate()
    }
    public func assignVariable(symbol: String, value: Double) -> Double? {
        variableValues[symbol] = value
        return evaluate()
    }
    
    public func clearStack() {
        opStack.removeAll()
    }
}
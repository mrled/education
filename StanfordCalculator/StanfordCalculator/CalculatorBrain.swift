//
//  CalculatorBrain.swift
//  StanfordCalculator
//
//  Created by Micah R Ledbetter on 2015-04-01.
//  Copyright (c) 2015 Micah R Ledbetter. All rights reserved.
//

import Foundation

class CalculatorBrain {
    private enum Op : Printable {
        case Operand(symbol: String?, value: Double)
        case Variable(symbol: String, value: Double?)
        case UnaryOperation (symbol: String, operation: (Double)         -> Double)
        case BinaryOperation(symbol: String, operation: (Double, Double) -> Double)
        
        var description : String {
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
    private var opStack = [Op]()
    private var knownOps = [String:Op]()
    private var variableValues = [String:Double]()

    init() {
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
    
    var description: String {
        get {
            let (_, _, d) = evaluate(opStack)
            return d
        }
    }
    
    //private typealias evalRetVal = (result: Double?, remainingOps: [Op], description: String)
    private typealias evalRetVal = (
        result: Double?,
        description: String,
        remainingOps: [Op],
        remainingOpDesc: String)
    private func evaluate(ops: [Op]) -> evalRetVal {
        var retval: evalRetVal = (
            result: nil,
            description: "",
            remainingOps: ops,
            remainingOpDesc: "")
        
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
    
            switch op {

            case .Operand(let symbol, let operand):
                // TODO: not ideal b/c the remainingOps aren't in the description. Maybe??
                var opDesc = "\(operand)"
                if (symbol != nil) { opDesc = symbol! }
                var roDesc = ""
                if (!remainingOps.isEmpty) {
                    // Return the opDesc from evaluating remaining ops as remainingOpDesc
                    (_, roDesc, _, _) = evaluate(remainingOps)
                }
                retval = (operand, opDesc, remainingOps, roDesc)

            case .UnaryOperation(let symbol, let operation):
                let operandEvaluation = evaluate(remainingOps)
                if let operand = operandEvaluation.result {
                    retval = (
                        result:          operation(operand),
                        description:     "\(symbol)(\(operandEvaluation.description))",
                        remainingOps:    operandEvaluation.remainingOps,
                        remainingOpDesc: operandEvaluation.remainingOpDesc
                    )
                }

            case .BinaryOperation(let symbol, let operation):
                let op1eval = evaluate(remainingOps)
                if let op1 = op1eval.result {
                    let op2eval = evaluate(op1eval.remainingOps)
                    if let op2 = op2eval.result {
                        retval = (
                            result:       operation(op1, op2),
                            remainingOps: op2eval.remainingOps,
                            description:  "(\(op2eval.description) \(symbol) \(op1eval.description))"
                        )
                    }
                }
            
            case .Variable(let symbol, let value):
                var v: Double? = nil
                if (value != nil) {
                    v = value
                }
                var opDesc = symbol
                if (!remainingOps.isEmpty) {
                    var remainingOpDesc: String
                    (_, _, remainingOpDesc) = evaluate(remainingOps)
                    opDesc = "\(remainingOpDesc), \(opDesc)"
                }
                retval = (v, remainingOps, symbol)
            
            }
        }
        return retval
    }

    func evaluate() -> Double? {
        let (result, remainder, description) = evaluate(opStack)

        if result == nil {
            println("evaluate(): bad input")
        }
        else {
            println("evaluate(): result: \(result!)")
        }
        println("evaluate(): remainingOps: \(remainder)")
        println("evaluate(): Full stack: \(opStack)")
        println("evaluate(): memory: \(variableValues)")
        
        return result
    }
    
    func pushInput(value: Double?) -> Double? {
        if let unwrappedValue = value {
            let operand = Op.Operand(symbol: nil, value: unwrappedValue)
            opStack.append(operand)
            return evaluate()
        }
        return nil
    }
    
    func pushInput(symbol: String?) -> Double? {
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
    
    func pushVariable(symbol: String) -> Double? {
        let appendVar = Op.Variable(symbol: symbol, value: variableValues[symbol])
        opStack.append(appendVar)
        return evaluate()
    }
    func assignVariable(symbol: String, value: Double) -> Double? {
        variableValues[symbol] = value
        return evaluate()
    }
    
    func clearStack() {
        opStack.removeAll()
    }
}
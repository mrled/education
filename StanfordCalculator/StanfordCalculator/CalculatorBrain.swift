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
    

    private class CalculatorEvaluation {
        var result: Double? = nil
        var description: String = ""
        var remainingOps: [Op] = []
        var remainingEvaluation: CalculatorEvaluation? = nil
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
            var ops: [Op]? = opStack
            var desc = ""
            while ops != nil {
                let evaluation = evaluate(ops!)
                if desc.isEmpty {
                    desc = evaluation.description
                }
                else {
                    desc = "\(evaluation.description), \(desc)"
                }
                ops = evaluation.remainingEvaluation?.remainingOps
            }
            println("var description: \(desc)")
            return desc
        }
    }
    
    private func evaluate(ops: [Op]) -> CalculatorEvaluation {
        var retval = CalculatorEvaluation()
        
        if !ops.isEmpty {
            var remainOps = ops
            let op = remainOps.removeLast()
            
            switch op {

            case .Operand(let symbol, let operand):
                var desc = "\(operand)"
                if let s = symbol {
                    desc = s
                }
                var remainEval: CalculatorEvaluation? = nil
                if (!remainOps.isEmpty) {
                    remainEval = evaluate(remainOps)
                }
                retval.result = operand
                retval.description = desc
                retval.remainingOps = remainOps
                retval.remainingEvaluation = remainEval

            case .UnaryOperation(let symbol, let operation):
                let opEval = evaluate(remainOps)
                if let operand = opEval.result {
                    retval.result = operand
                    retval.description = "\(symbol)(\(opEval.description))"
                    retval.remainingOps = opEval.remainingOps
                    retval.remainingEvaluation = opEval.remainingEvaluation
                }

            case .BinaryOperation(let symbol, let operation):
                if remainOps.count > 0 {
                    let eval1 = evaluate(remainOps)
                    if let operand1 = eval1.result {
                        if eval1.remainingOps.count > 0 {
                            let remainOps2 = eval1.remainingOps
                            let eval2 = evaluate(remainOps2)
                            if let operand = eval2.result {
                                retval.result = operand
                                retval.description = "(\(eval2.description) \(symbol) \(eval1.description))"
                                retval.remainingOps = eval2.remainingOps
                                retval.remainingEvaluation = eval2.remainingEvaluation
                            }
                        }
                    }
                }

            case .Variable(let symbol, let value):
                retval.result = value
                retval.description = symbol
                retval.remainingOps = []
                retval.remainingEvaluation = nil
                if !remainOps.isEmpty {
                    retval.remainingOps = remainOps
                    retval.remainingEvaluation = evaluate(remainOps)
                }
                
            
            }
        }
        return retval
    }

    func evaluate() -> Double? {
        let evaluation = evaluate(opStack)

        if evaluation.result == nil {
            println("evaluate(): bad input")
        }
        else {
            println("evaluate(): result: \(evaluation.result!)")
        }
        println("evaluate(): remainingOps: \(evaluation.remainingOps)")
        println("evaluate(): Full stack: \(opStack)")
        println("evaluate(): memory: \(variableValues)")
        
        return evaluation.result
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
//
//  CalculatorBrain.swift
//  StanfordCalculator
//
//  Created by Micah R Ledbetter on 2015-04-01.
//  Copyright (c) 2015 Micah R Ledbetter. All rights reserved.
//

import Foundation

class CalculatorBrain {
    private enum Op {
        case Operand(Double)
        case UnaryOperation(String, Double -> Double)
        case BinaryOperation(String, (Double, Double) -> Double)
    }
    private var opStack = [Op]()
    private var inputStack = [Op]()
    private var knownOps = [String:Op]()

    init() {
        knownOps["×"] = Op.BinaryOperation("×", *)
        knownOps["÷"] = Op.BinaryOperation("÷") {$1 / $0}
        knownOps["+"] = Op.BinaryOperation("+", +)
        knownOps["−"] = Op.BinaryOperation("−") {$1 - $0}
        knownOps["√"]   = Op.UnaryOperation("√", sqrt)
        knownOps["sin"] = Op.UnaryOperation("sin", sin)
        knownOps["cos"] = Op.UnaryOperation("cos", cos)
        knownOps["+/-"] = Op.UnaryOperation("+/-") {$0 * -1}
        knownOps["π"] = Op.Operand(M_PI)
    }
    
    private func evaluate(ops: [Op]) -> (result: Double?, remainingOps: [Op]) {
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()

            switch op {
            case .Operand(let operand):
                return (operand, remainingOps)
            case .UnaryOperation(_, let operation):
                let operandEvaluation = evaluate(remainingOps)
                if let operand = operandEvaluation.result {
                    return (operation(operand), operandEvaluation.remainingOps)
                }
            case .BinaryOperation(_, let operation):
                let op1eval = evaluate(remainingOps)
                if let op1 = op1eval.result {
                    let op2eval = evaluate(op1eval.remainingOps)
                    if let op2 = op2eval.result {
                        return (operation(op1, op2), op2eval.remainingOps)
                    }
                }
            }
        }
        return (nil, ops)
    }
    
    func evaluate() -> Double? {
        let (result, remainder) = evaluate(opStack)
        return result 
    }

    func pushInput(op: Double?) -> Double? {
        if let unwrappedOp = op {
            let operand = Op.Operand(unwrappedOp)
            inputStack.append(operand)
            opStack.append(operand)
            return evaluate()
        }
        return nil
    }
    
    func pushInput(op: String?) -> Double? {
        if let unwrappedOp = op {
            if let knownOp = knownOps[unwrappedOp] {
                inputStack.append(knownOp)
                opStack.append(knownOp)
                return evaluate()
            }
        }
        return nil
    }
    
    func performOperation(symbol: String) -> Double? {
        if let operation = knownOps[symbol] {
            opStack.append(operation)
        }
        return evaluate()
    }

    func clearStack() {
        inputStack.removeAll()
        opStack.removeAll()
    }
    
    func retrieveInputs() -> String {
        return "\(inputStack)"
    }
}
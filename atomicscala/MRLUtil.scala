package com.micahrl.MRLUtil

class ExPrinter {
  var exidx = 1
  def printintro(): Unit = 
    println("Code from chapter:")
  def printex(): Unit = {
    println("Exercise " + exidx)
    exidx += 1
  }
}

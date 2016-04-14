//package com.micahrl.atomicscala

import com.atomicscala.AtomicTest._

class Family(members: String*) {
  def familySize = { members.size }
}

val family1 = new Family("Mom", "Dad", "Sally", "Dick")
val family2 = new Family("Dad", "Mom", "Harry")

println("Exercise 1")
family1.familySize is 4
family2.familySize is 3

println("Exercise 2")
class FlexibleFamily(father: String, mother: String, children: String*) {
  def familySize = { 2 + children.size }
}
val family3 = new FlexibleFamily("Dad", "Mom", "Sally", "Dick")
val family4 = new FlexibleFamily("Dad", "Mom", "Harry")
family3.familySize is 4
family2.familySize is 3

println("Exercise 3")
val familyNoKids = new FlexibleFamily("Mom", "Dad")
familyNoKids.familySize is 2

println("Exercise 4")
println("Nope - only one variadic parameter is permitted")

println("Exercise 5")
println("Nope - the variadic parameter must be the last")

println("Exercise 6")
//Fields contained a class Cup2 with a field percentFull. Rewrite that class definition, using a class argument instead of defining a field.
println("Done")
class Cup3(var percentFull: Int) {
  val max = 100
  val min = 0
  def increase(values: Int*) = {
    for (v <- values) {
      percentFull += v
      if (percentFull > max) percentFull = max
      else if (percentFull < min) percentFull = min
    }
    percentFull
  }
}

println("Exercise 7")
//Using your solution for Exercise 6, can you get and set the value of percentFull without writing any new methods? Try it!
val cup = new Cup3(78)
cup.percentFull is 78
cup.percentFull = 32
cup.percentFull is 32

println("Exercise 8")
/* 
Continue working with the Cup2 class. Modify the add method to take a variable argument list. Specify any number of pours (increase) and spills (decrease = increase with a negative value) and return the resulting value. Satisfy the following tests:
val cup5 = new Cup5(0)
cup5.increase(20, 30, 50,
  20, 10, -10, -40, 10, 50) is 100
cup5.increase(10, 10, -10, 10,
  90, 70, -70) is 30
*/
val cup5 = new Cup3(0)
cup5.increase(20, 30, 50, 20, 10, -10, -40, 10, 50) is 100
cup5.increase(10, 10, -10, 10, 90, 70, -70) is 30

println("Exercise 8")
/*
Write a method that squares a variable argument list of numbers and returns the sum. Satisfy the following tests:
squareThem(2) is 4
squareThem(2, 4) is 20
squareThem(1, 2, 4) is 21”
*/
def squareThem(numbers: Int*) = {
  var sum = 0
  for (number <- numbers) {
    sum += number*number 
  }
  sum
}
squareThem(2) is 4
squareThem(2, 4) is 20
squareThem(1, 2, 4) is 21




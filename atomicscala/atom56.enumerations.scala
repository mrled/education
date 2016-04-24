import com.atomicscala.AtomicTest._
import com.micahrl.MRLUtil._

val exprinter = new ExPrinter

exprinter.printex()
/*
Create an enumeration for MonthName, using January, February, etc. Satisfy the following test:
MonthName.February is "February"
MonthName.February.id is 1
*/
object MonthName extends Enumeration {
  type MonthName = Value
  val January, February, March, April, May, June, July, August, September, October, November, December = Value
}
MonthName.February is "February"
MonthName.February.id is 1

exprinter.printex()
/*
In the previous exercise, an id of 1 isn’t really what we expected for February. We want that to be 2, since February is the second month. Try explicitly setting January to Value(1) and leaving the others alone. What does that tell you about what Value does? Satisfy the following tests:
MonthName2.February is "February"
MonthName2.February.id is 2
MonthName2.December.id is 12
MonthName2.July.id is 7
*/
object MonthName2 extends Enumeration {
  type MonthName2 = Value
  val January = Value(1)
  val February, March, April, May, June, July, August, September, October, November, December = Value
}
MonthName2.February is "February"
MonthName2.February.id is 2
MonthName2.December.id is 12
MonthName2.July.id is 7

exprinter.printex()
/*
Building from the previous exercise, demonstrate how to use import so you don’t have to qualify the name space. Create a method monthNumber that returns the appropriate value. Satisfy the following tests:
July is "July"
monthNumber(July) is 7
*/
import MonthName2._
def monthNumber(month: MonthName2) = month.id
July is "July"
monthNumber(July) is 7

exprinter.printex()
/*
Create a method season that takes a MonthName type (from Exercise 1) and returns “Winter” if the month is December, January, or February, “Spring” if March, April, or May, “Summer” if June, July, or August, and “Autumn” if September, October, or November. Satisfy the following tests:
season(January) is "Winter"
season(April) is "Spring"
season(August) is "Summer"
season(November) is "Autumn"
*/

exprinter.printex()
//Modify TicTacToe.scala from Summary 2 to use enumerations.

exprinter.printex()
/*
Modify the Level enumeration code from Level.scala. Create a new val and add another set of values for “Draining, Pooling, and Dry” to the Level enumeration. Update the code on lines 14-28 as necessary. Satisfy the following tests:
Level.Draining is Draining
Level.Draining.id is 5
checkLevel(Low) is "Level Low OK"
“checkLevel(Empty) is "Alert"
checkLevel(Draining) is "Level Draining OK"
checkLevel(Pooling) is "Warning!"
checkLevel(Dry) is "Alert"
*/
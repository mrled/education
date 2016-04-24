import com.atomicscala.AtomicTest._
import com.micahrl.MRLUtil._

val exprinter = new ExPrinter

case class Person(name:String)

exprinter.printex()
/*
Create a method plus1 that pluralizes a String, adds 1 to an Int, and adds “+ guest” to a Person. Satisfy the following tests:
plus1("car") is "cars"
plus1(67) is 68
plus1(Person("Joanna")) is "Person(Joanna) + guest"
*/
def plus1 (singular: Any) = singular match {
  case inputString: String => inputString + "s"
  case inputInt: Int => inputInt + 1
  case inputPerson: Person => inputPerson.toString() + " + guest"
  case _ => "???"
}
plus1("car") is "cars"
plus1(67) is 68
plus1(Person("Joanna")) is "Person(Joanna) + guest"

exprinter.printex()
/*
Create a method convertToSize that converts a String to its length, uses Int and Double directly, and converts a Person to 1. Return 0 if you don’t have a matching type. What was the return type of your method? Satisfy the following tests:
convertToSize(45) is 45
convertToSize("car") is 3
convertToSize("truck") is 5
convertToSize(Person("Joanna")) is 1
convertToSize(45.6F) is 45.6F
convertToSize(Vector(1, 2, 3)) is 0
*/
def convertToSize(input: Any) = input match {
  case inString: String => inString.length
  case inInt: Int => inInt
  case inDbl: Float => inDbl
  case inPerson: Person => 1
  case _ => 0
}
convertToSize(45) is 45
convertToSize("car") is 3
convertToSize("truck") is 5
convertToSize(Person("Joanna")) is 1
convertToSize(45.6F) is 45.6F
convertToSize(Vector(1, 2, 3)) is 0

exprinter.printex()
/*
Modify convertToSize from the previous exercise so it returns an Int. Use the scala.math.round method to round the Double first. Did you need to declare the return type? Do you see an advantage to doing so? Satisfy the following tests:
convertToSize2(45) is 45
convertToSize2("car") is 3
convertToSize2("truck") is 5
convertToSize2(Person("Joanna")) is 1
convertToSize2(45.6F) is 46
convertToSize2(Vector(1, 2, 3)) is 0
*/
def convertToSize2(input: Any): Int = input match {
  case inString: String => inString.length
  case inInt: Int => inInt
  case inDbl: Float => scala.math.round(inDbl)
  case inPerson: Person => 1
  case _ => 0
}
convertToSize2(45) is 45
convertToSize2("car") is 3
convertToSize2("truck") is 5
convertToSize2(Person("Joanna")) is 1
convertToSize2(45.6F) is 46
convertToSize2(Vector(1, 2, 3)) is 0

exprinter.printex()
/*
Create a new method quantify to return “small” if the argument is less than 100, “medium” if the argument is between 100 and 1000, and “large” if the argument is greater than 1000. Support both Doubles and Ints. Satisfy the following tests:
quantify(100) is "medium"
quantify(20.56) is "small"
quantify(100000) is "large"
quantify(-15999) is "small"
*/
def quantify (input: Any): String = input match {
  case input: Int if (input < 100) => "small"
  case input: Int if (input < 1000) => "medium"
  case input: Int if (input >= 1000) => "large"
  case input: Double if (input < 100.0) => "small"
  case input: Double if (input < 1000.0) => "medium"
  case input: Double if (input >= 1000.0) => "large"
}
quantify(100) is "medium"
quantify(20.56) is "small"
quantify(100000) is "large"
quantify(-15999) is "small"

exprinter.printex()
/*
“Pattern Matching included an exercise to check the forecast, based on sunniness. We tested using discrete values. Revisit that exercise with ranges of values. Create a method forecast that represents the percentage of cloudiness, and use it to produce a “weather forecast” string such as “Sunny” (100), “Mostly Sunny” (80), “Partly Sunny” (50), “Mostly Cloudy” (20), and “Cloudy” (0). Satisfy the following tests:
forecast(100) is "Sunny"
forecast(81) is "Sunny"
forecast(80) is "Mostly Sunny"
forecast(51) is "Mostly Sunny"
forecast(50) is "Partly Sunny"
forecast(21) is "Partly Sunny"
forecast(20) is "Mostly Cloudy"
forecast(1) is "Mostly Cloudy"
forecast(0) is "Cloudy"
forecast(-1) is "Unknown"
*/


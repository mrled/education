import com.atomicscala.AtomicTest._
import com.micahrl.MRLUtil._

val exprinter = new ExPrinter

exprinter.printex()
/*
Modify DisplayVectorWithAnonymous.scala to store results in a String, as in DisplayDuckTestable.scala. Satisfy the following test:
str is "1234"
*/
def displayVectorWithAnonymous2 [T] (vector: Vector[T]) = {
  var result = ""
  vector.foreach(item => result += item.toString())
  result
}
val v = Vector(1, 2, 3, 4)
displayVectorWithAnonymous2(v) is "1234"

exprinter.printex()
/*
Working from your solution to the exercise above, add a comma between each number. Satisfy the following test:
str is "1,2,3,4,"
*/
def displayVectorWithAnonymous3 [T] (vector: Vector[T]) = {
  var result = ""
  vector.foreach(item => result += "${item.toString(),")
  result
}
displayVectorWithAnonymous3(v) is "1,2,3,4,"

exprinter.printex()
/*
Create an anonymous function that calculates age in “dog years” (by multiplying years by 7). Assign it to a val and then call your function. Satisfy the following test:
val dogYears = // Your function here
dogYears(10) is 70
*/
val dogYears = y => y*7
dogYears(10) is 70

exprinter.printex()
/*
Create a Vector and append the result of dogYears to a String for each value in the Vector. Satisfy the following test:
var s = ""
val v = Vector(1, 5, 7, 8)
v.foreach(/* Fill this in */)
s is "7 35 49 56 "
*/
var dogYearsResult = ""
val humanYears = Vector(1, 5, 7, 8)
humanYears.foreach(y => dogYearsResult += "${dogYears(y)} ")
dogYearsResult is "7 35 49 56"

exprinter.printex()
/*
Repeat Exercise 4 without using the dogYears method:
var s = ""
val v = Vector(1, 5, 7, 8)
v.foreach(/* Fill this in */)
s is "7 35 49 56 "
*/
var dogYearsResult2 = ""
humanYears.foreach(y => dogYearsResult += "${y*7} ")
dogYearsResult2 is "7 35 49 56"

exprinter.printex()
/*
Create an anonymous function with three arguments (temperature, low, and high). The anonymous function will return true if the temperature is between high and low, and false otherwise. Assign the anonymous function to a def and then call your function. Satisfy the following tests:
between(70, 80, 90) is false
between(70, 60, 90) is true
*/

exprinter.printex()
/*
Create an anonymous function to square a list of numbers. Call the function for every element in a Vector, using foreach. Satisfy the following test:
var s = ""
val numbers = Vector(1, 2, 5, 3, 7)
numbers.foreach(/* Fill this in */)
s is "1 4 25 9 49 "
*/

exprinter.printex()
/*
Create an anonymous function and assign it to the name pluralize. It should construct the (simple) plural form of a word by just adding an “s.” Satisfy the following tests:
pluralize("cat") is "cats"
pluralize("dog") is "dogs"
pluralize("silly") is "sillys"
*/

exprinter.printex()
/*
Use pluralize from the previous exercise. Use foreach on a Vector of Strings and print the plural form of each word. Satisfy the following test:
var s = ""
val words = Vector("word", "cat", "animal")
words.foreach(/* Fill this in */)
s is "words cats animals "  
*/
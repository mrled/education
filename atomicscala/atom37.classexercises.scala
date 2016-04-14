import com.atomicscala.AtomicTest._
import com.micahrl.MRLUtil._

val exprinter = new ExPrinter

exprinter.printex()
/*
Make a class Dimension that has an integer field height and an integer field width that can be both retrieved and modified from outside the class. Satisfy the following tests:
val c = new Dimension(5,7)
c.height is 5
c.height = 10
c.height is 10
c.width = 19
c.width is 19
*/
class Dimension(var height: Int, var width: Int) {}
val c = new Dimension(5,7)
c.height is 5
c.height = 10
c.height is 10
c.width = 19
c.width is 19

exprinter.printex()
/*
Make a class Info that has a String field name that can be retrieved from outside the class (but not modified) and a String field description that can be both modified and retrieved from outside the class. Satisfy the following tests:
val info = new Info("stuff", "Something")
info.name is "stuff"
info.description is "Something"
info.description = "Something else"
info.description is "Something else"
*/
class Info(var name: String, var description: String) {}
val info = new Info("stuff", "Something")
info.name is "stuff"
info.description is "Something"
info.description = "Something else"
info.description is "Something else"

exprinter.printex()
/*
Working from your solution to Exercise 2, modify the Info class to satisfy the following test:
info.name = "This is the new name"
info.name is "This is the new name"
*/
info.name = "This is the new name"
info.name is "This is the new name"

exprinter.printex()
/*
Modify SimpleTime (from Named & Default Arguments) to add a method subtract that subtracts one SimpleTime object from another. If the second time is greater than the first, just return zero. Satisfy the following tests:
val t1 = new SimpleTime(10, 30)
val t2 = new SimpleTime(9, 30)
val st = t1.subtract(t2)
st.hours is 1
st.minutes is 0
val st2 = new SimpleTime(10, 30).subtract(new SimpleTime(9, 45))
st2.hours is 0
st2.minutes is 45
val st3 = new SimpleTime(9, 30).subtract(new SimpleTime(10, 0))
st3.hours is 0
st3.minutes is 0
*/

// terminology: in "X - Y = Z", X is the "minuend", Y is the "subtrahend", and Z is the "difference"

// class SimpleTime(minutes: Int = 0, hours: Int = 0) {
//   val mins = minutes + (hours*60)
//   def hours: Int = mins / 60
//   def minutes: Int = mins % 60
//   def subtract(subtrahend: SimpleTime) = {
//     val resultmins = this.mins - subtrahend.mins
//     if (result < 0) resultmins = 0
//     SimpleTime(minutes=resultmins)
//   }
// }

class SimpleTime(val hours: Int = 0, val minutes: Int = 0) {
  def totalMinutes(): Int = this.minutes + (this.hours * 60)
  def subtract(subtrahend: SimpleTime): SimpleTime = {
    var differenceTotalMins = this.totalMinutes - subtrahend.totalMinutes
    if (differenceTotalMins < 0) differenceTotalMins = 0

    val differenceMinutes: Int = differenceTotalMins % 60
    val differenceHours: Int = differenceTotalMins / 60 // rounded down to nearest whole number b/c type Int

    new SimpleTime(differenceHours, differenceMinutes)
  }
  override def toString() = "(H" + this.hours + " M" + this.minutes + ") TotalMinutes: " + this.totalMinutes
}

val t1 = new SimpleTime(10, 30)
val t2 = new SimpleTime(9, 30)
val st = t1.subtract(t2)
st.hours is 1
st.minutes is 0
val st2 = new SimpleTime(10, 30).subtract(new SimpleTime(9, 45))
st2.hours is 0
st2.minutes is 45
val st3 = new SimpleTime(9, 30).subtract(new SimpleTime(10, 0))
st3.hours is 0
st3.minutes is 0

exprinter.printex()
/*
Modify your SimpleTime solution to use default arguments for minutes (see Named & Default Arguments). Satisfy the following tests:
val anotherT1 = new SimpleTimeDefault(10, 30)
val anotherT2 = new SimpleTimeDefault(9)
val anotherST = anotherT1.subtract(anotherT2)
anotherST.hours is 1
anotherST.minutes is 30
val anotherST2 = new SimpleTimeDefault(10).subtract(new SimpleTimeDefault(9, 45))
anotherST2.hours is 0
anotherST2.minutes is 15
*/
val anotherT1 = new SimpleTime(10, 30)
val anotherT2 = new SimpleTime(9)
val anotherST = anotherT1.subtract(anotherT2)
anotherST.hours is 1
anotherST.minutes is 30
val anotherST2 = new SimpleTime(10).subtract(new SimpleTime(9, 45))
anotherST2.hours is 0
anotherST2.minutes is 15

exprinter.printex()
/*
Modify your solution for Exercise 5 to use an auxiliary constructor. Again, satisfy the following tests:
val auxT1 = new SimpleTimeAux(10, 5)
val auxT2 = new SimpleTimeAux(6)
val auxST = auxT1.subtract(auxT2)
auxST.hours is 4
auxST.minutes is 5
val auxST2= new SimpleTimeAux(12).subtract(new SimpleTimeAux(9, 45))
auxST2.hours is 2
auxST2.minutes is 15
*/
println("this is boring")

exprinter.printex()
/*
Defaulting both hours and minutes in the previous exercise is problematic. Can you see why? Can you figure out how to use named arguments to solve this problem? Did you have to change any code?
*/
println("this is obvious")

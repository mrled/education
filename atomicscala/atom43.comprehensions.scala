import com.atomicscala.AtomicTest._
import com.micahrl.MRLUtil._

val exprinter = new ExPrinter

exprinter.printex()
//Change yielding to a more descriptive name.

exprinter.printex()
/*
Modify yielding2 to accept a List instead of a Vector. Return a List. Satisfy the following test:
val theList = List(1,2,3,5,6,7,8,10,13,14,17)
yielding2(theList) is List(1,3,5,7)
*/
def yielding2(v:Vector[Int]):Vector[Int]={
  for {
    n <- v
    if n < 10
    isOdd = (n % 2 != 0)
    if(isOdd)
  } yield n
}
def yielding2(list: List[Int]): List[Int] = {
  for {
    n <- list
    if n < 10
    isOdd = (n % 2 != 0)
    if(isOdd)
  } yield n
}
val theList = List(1,2,3,5,6,7,8,10,13,14,17)
yielding2(theList) is List(1,3,5,7)

exprinter.printex()
//Start with yielding3 and rewrite the comprehension so it is as compact as possible (reduce isOdd and the yield clause). Now assign the comprehension to an explicitly-typed value called result, and return result at the end of the method. Continue to satisfy the existing tests in Yielding3.scala.
def yielding3(v: Vector[Int]): Vector[Int] = {
  val result: Vector[Int] = for {
    n <- v
    if n < 10
    if n % 2 != 0
  } yield {
    n * 10 + 2
  }
  result
}
val y3v = Vector(1,2,3,5,6,7,8,10,13,14,17)
yielding3(y3v) is Vector(12, 32, 52, 72)

exprinter.printex()
//Confirm that you can’t modify n or isOdd in yielding3. Declare them as vars. What happened? Did you find a way to do this? Did it make sense to you?

exprinter.printex()
/*
Create a case class named Activity that contains a String for the date (like “01-30”) and a String for the activity you did that day (like “Bike,” “Run,” “Ski”). Store your activities in a Vector. Create a method getDates that returns a Vector of String corresponding to the days that you did the specified activity. Satisfy the following tests:
val activities = Vector(
  Activity("01-01", "Run"),
  Activity("01-03", "Ski"),
  Activity("01-04", "Run"),
  Activity("01-10", "Ski"),
  Activity("01-03", "Run"))
getDates("Ski", activities) is Vector("01-03", "01-10")
getDates("Run", activities) is Vector("01-01", "01-04", "01-03")
getDates("Bike", activities) is Vector()
*/
case class Activity(date: String, name: String)
def getDates(activityName: String, activityList: Vector[Activity]) = {
  for {
    activity <- activityList
    if activity.name == activityName
  } yield activity.date
}
val activities = Vector(
  Activity("01-01", "Run"),
  Activity("01-03", "Ski"),
  Activity("01-04", "Run"),
  Activity("01-10", "Ski"),
  Activity("01-03", "Run"))
getDates("Ski", activities) is Vector("01-03", "01-10")
getDates("Run", activities) is Vector("01-01", "01-04", "01-03")
getDates("Bike", activities) is Vector()

exprinter.printex()
/*
Building on the previous exercise, create a method getActivities that flips things around by returning a Vector of Strings corresponding to the names of the activities that you did on the specified day. Satisfy the following tests:
getActivities("01-01", activities) is Vector("Run")
getActivities("01-02", activities) is Vector()
getActivities("01-03", activities) is Vector("Ski", "Run")
getActivities("01-04", activities) is Vector("Run")
getActivities("01-10", activities) is Vector("Ski")
*/
def getActivities(activityDate: String, activityList: Vector[Activity]) = {
  for {
    activity <- activityList
    if activity.date == activityDate
  } yield activity.name
}
getActivities("01-01", activities) is Vector("Run")
getActivities("01-02", activities) is Vector()
getActivities("01-03", activities) is Vector("Ski", "Run")
getActivities("01-04", activities) is Vector("Run")
getActivities("01-10", activities) is Vector("Ski")

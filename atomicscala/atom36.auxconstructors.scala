import com.atomicscala.AtomicTest._

println("Code from chapter")
class GardenGnome(val height:Double, val weight:Double, val happy:Boolean) {
  println("Inside primary constructor")
  var painted = true
  def magic(level:Int):String = {
    "Poof! " + level
  }
  def this(height:Double) {
    this(height, 100.0, true)
  }
  def this(name:String) = {
    this(15.0)
    painted is true
  }
  def show():String = {
    height + " " + weight + " " + happy + " " + painted
  }
}
new GardenGnome(20.0, 110.0, false).show() is "20.0 110.0 false true"
new GardenGnome("Bob").show() is "15.0 100.0 true true"

println("Exercise 1")
//Create a class called ClothesWasher with a default constructor and two auxiliary constructors, one that specifies model (as a String) and one that specifies capacity (as a Double).
class ClothesWasher(val name: String, val capacity: Double) {
  def this(name: String) = this(name=name, capacity=1.0)
  def this(capacity: Double) = this(name="Default Washer Name", capacity=capacity)
}

println("Exercise 2")
//Create a class ClothesWasher2 that looks just like your solution for Exercise 1, but use named and default arguments instead so you produce the same results with just a default constructor.
class ClothesWasher2(val name: String = "Washer", val capacity: Double = 1.0) {}

println("Exercise 3")
//Show that the first line of an auxiliary constructor must be a call to the primary constructor.
println("ok")

println("Exercise 4")
/*
Recall from Overloading that methods can be overloaded in Scala, and that this is different from the way that we overload constructors (writing auxiliary constructors). Add two methods to your solution for Exercise 1 to show that methods can be overloaded. Satisfy the following tests:
val washer = new ClothesWasher3("LG 100", 3.6)
washer.wash(2, 1) is  "Wash used 2 bleach and 1 fabric softener"
washer.wash() is "Simple wash"
*/
class ClothesWasher3(val name: String, val capacity: Double) {
  def this(name: String) = this(name=name, capacity=1.0)
  def this(capacity: Double) = this(name="Default Washer Name", capacity=capacity)
  def wash(bleaches: Int, softeners: Int) = "Wash used " + bleaches + " bleach and " + softeners + " fabric softener"
  def wash() = "Simple wash"
}
val washer = new ClothesWasher3("LG 100", 3.6)
washer.wash(2, 1) is  "Wash used 2 bleach and 1 fabric softener"
washer.wash() is "Simple wash"

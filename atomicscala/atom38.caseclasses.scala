import com.atomicscala.AtomicTest._
import com.micahrl.MRLUtil._

val exprinter = new ExPrinter

exprinter.printintro()
case class Dog(name:String)
val dog1 = Dog("Henry")
val dog2 = Dog("Cleo")
val dogs = Vector(dog1, dog2)
dogs is Vector(Dog("Henry"), Dog("Cleo"))

case class Cat(name:String, age:Int)
val cats = Vector(Cat("Miffy", 3), Cat("Rags", 2))
cats is  "Vector(Cat(Miffy,3), Cat(Rags,2))"

exprinter.printex()
/*
Create a case class to represent a Person in an address book, complete with Strings for the name and a String for contact information. Satisfy the following tests:
val p = Person("Jane", "Smile", "jane@smile.com")
p.first is "Jane"
p.last is "Smile"
p.email is "jane@smile.com"
*/
case class Person(first: String, last: String, email: String)
val p = Person("Jane", "Smile", "jane@smile.com")
p.first is "Jane"
p.last is "Smile"
p.email is "jane@smile.com"

exprinter.printex()
/*
Create some Person objects. Put the Person objects in a Vector. Satisfy the following tests:
val people = Vector(
  Person("Jane","Smile","jane@smile.com"),
  Person("Ron","House","ron@house.com"),
  Person("Sally","Dove","sally@dove.com"))
people(0) is "Person(Jane,Smile,jane@smile.com)"
people(1) is "Person(Ron,House,ron@house.com)"
people(2) is "Person(Sally,Dove,sally@dove.com)"
*/
val people = Vector(
  Person("Jane","Smile","jane@smile.com"),
  Person("Ron","House","ron@house.com"),
  Person("Sally","Dove","sally@dove.com"))
people(0) is "Person(Jane,Smile,jane@smile.com)"
people(1) is "Person(Ron,House,ron@house.com)"
people(2) is "Person(Sally,Dove,sally@dove.com)"

exprinter.printex()
/*
First, create a case class that represents a Dog, using a String for name and a String for breed. Then, create a Vector of Dogs. Satisfy the following tests:
val dogs = Vector(
  /* Insert Vector initialization */
)
dogs(0) is "Dog(Fido,Golden Lab)"
dogs(1) is "Dog(Ruff,Alaskan Malamute)"
dogs(2) is "Dog(Fifi,Miniature Poodle)"
*/
case class Dog2(name: String, breed: String)
val dogs2 = Vector(
  Dog2("Fido", "Golden Lab"),
  Dog2("Ruff", "Alaskan Malamute"),
  Dog2("Fifi", "Miniature Poodle"))
dogs2(0) is "Dog2(Fido,Golden Lab)"
dogs2(1) is "Dog2(Ruff,Alaskan Malamute)"
dogs2(2) is "Dog2(Fifi,Miniature Poodle)"

exprinter.printex()
/*
As in Class Exercises, make a case class Dimension that has an integer field height and an integer field width that can be both retrieved and modified from outside of the class. Create and print an object of this class. How does this solution differ from your solution for Exercise 1 in Class Exercises? Satisfy the following tests:
val c = new Dimension(5,7)
c.height is 5
c.height = 10
c.height is 10
c.width = 19
c.width is 19
*/
case class Dimension(var height: Int, var width: Int)
val c = new Dimension(5,7)
c.height is 5
c.height = 10
c.height is 10
c.width = 19
c.width is 19

exprinter.printex()
/*
Modify your solution for Exercise 4, using one ordinary ( val) argument for height and one var argument for width. Demonstrate that one is read-only and the other is modifiable.
*/
println("is this for real")

exprinter.printex()
/*
Can you use default arguments with case classes? Repeat Exercise 5 from Class Exercises to find out. How does your solution differ, if at all? Satisfy the following tests:
val anotherT1 = new SimpleTimeDefault(10, 30)
val anotherT2 = new SimpleTimeDefault(9)
val anotherST = anotherT1.subtract(anotherT2)
anotherST.hours is 1
anotherST.minutes is 30
val anotherST2 = new SimpleTimeDefault(10).subtract(new SimpleTimeDefault(9, 45))
anotherST2.hours is 0
anotherST2.minutes is 15
*/

case class SimpleTimeDefault(hours: Int = 0, minutes: Int = 0) {
  def totalMinutes(): Int = this.minutes + (this.hours * 60)
  def subtract(subtrahend: SimpleTimeDefault): SimpleTimeDefault = {
    var differenceTotalMins = this.totalMinutes - subtrahend.totalMinutes
    if (differenceTotalMins < 0) differenceTotalMins = 0

    val differenceMinutes: Int = differenceTotalMins % 60
    val differenceHours: Int = differenceTotalMins / 60 // rounded down to nearest whole number b/c type Int

    new SimpleTimeDefault(differenceHours, differenceMinutes)
  }
  override def toString() = "(H" + this.hours + " M" + this.minutes + ") TotalMinutes: " + this.totalMinutes
}

val anotherT1 = new SimpleTimeDefault(10, 30)
val anotherT2 = new SimpleTimeDefault(9)
val anotherST = anotherT1.subtract(anotherT2)
anotherST.hours is 1
anotherST.minutes is 30
val anotherST2 = new SimpleTimeDefault(10).subtract(new SimpleTimeDefault(9, 45))
anotherST2.hours is 0
anotherST2.minutes is 15

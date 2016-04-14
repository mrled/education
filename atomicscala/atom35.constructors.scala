import com.atomicscala.AtomicTest._

println("Code from chapter")
class Coffee(val shots:Int = 2,
             val decaf:Boolean = false,
             val milk:Boolean = false,
             val toGo:Boolean = false,
             val syrup:String = "") {
  var result = ""
  println(shots, decaf, milk, toGo, syrup)
  def getCup():Unit = {
    if(toGo)
      result += "ToGoCup "
    else
      result += "HereCup "
  }
  def pourShots():Unit = {
    for(s <- 0 until shots)
      if(decaf)
        result += "decaf shot "
      else
        result += "shot "
  }
  def addMilk():Unit = {
    if(milk)
      result += "milk "
  }
  def addSyrup():Unit = {
    result += syrup
  }
  getCup()
  pourShots()
  addMilk()
  addSyrup()
}

val usual = new Coffee
usual.result is "HereCup shot shot "
val mocha = new Coffee(decaf = true, toGo = true, syrup = "Chocolate")
mocha.result is "ToGoCup decaf shot decaf shot Chocolate"


println("Exercise 1")
/*
Modify Coffee.scala to specify some caffeinated shots and some decaf shots. Satisfy the following tests:
val doubleHalfCaf =
  new Coffee(shots=2, decaf=1)
val tripleHalfCaf =
  new Coffee(shots=3, decaf=2)
doubleHalfCaf.decaf is 1
doubleHalfCaf.caf is 1
doubleHalfCaf.shots is 2
tripleHalfCaf.decaf is 2
tripleHalfCaf.caf is 1
tripleHalfCaf.shots is 3
*/
class Coffee2(
  val shots: Int = 2,
  val decaf: Int = 0,
  val milk: Boolean = false,
  val toGo: Boolean = false,
  val syrup: String = "")
{

  var result = ""
  var caf = 0
  println(shots, decaf, milk, toGo, syrup)

  def getCup(): Unit = {
    if (toGo) result += "ToGoCup "
    else result += "HereCup "
  }
  def pourShots(): Unit = {
    for (decafCtr <- 0 until decaf) {
      result += "DecafShot"
    }
    for (cafCtr <- decaf until shots) {
      result += "CafShot"
      caf += 1
    }
    //for (s <- 0 until shots) result += "CafShot "
    //for (d <- 0 until decaf) result += "DecafShot "
  }
  def addMilk(): Unit = if (milk) result += "milk "
  def addSyrup(): Unit = result += syrup

  getCup()
  pourShots()
  addMilk()
  addSyrup()
}
val doubleHalfCaf = new Coffee2(shots=2, decaf=1)
val tripleHalfCaf = new Coffee2(shots=3, decaf=2)
doubleHalfCaf.decaf is 1
doubleHalfCaf.caf is 1
doubleHalfCaf.shots is 2
tripleHalfCaf.decaf is 2
tripleHalfCaf.caf is 1
tripleHalfCaf.shots is 3

println("Exercise 2")
/*
Create a new class Tea that has 2 methods: describe, which includes information about whether the tea includes milk, sugar, is decaffeinated, and includes the name; and calories, which adds 100 calories for milk and 16 calories for sugar. Satisfy the following tests:
val tea = new Tea
tea.describe is "Earl Grey"
tea.calories is 0
val lemonZinger = new Tea(decaf = true, name="Lemon Zinger")
lemonZinger.describe is "Lemon Zinger decaf"
lemonZinger.calories is 0
val sweetGreen = new Tea(name="Jasmine Green", sugar=true)
sweetGreen.describe is "Jasmine Green + sugar"
sweetGreen.calories is 16
val teaLatte = new Tea( sugar=true, milk=true)
teaLatte.describe is "Earl Grey + milk + sugar"
teaLatte.calories is 116
*/
class Tea(
  val name: String = "Earl Grey",
  val decaf: Boolean = false,
  val milk: Boolean = false,
  val sugar: Boolean = false)
{
  def describe(): String = {
    var desc = name
    if (decaf) desc += " decaf"
    if (milk) desc += " + milk"
    if (sugar) desc += " + sugar"
    desc
  }
  def calories(): Int = {
    var cals = 0
    if (milk) cals += 100
    if (sugar) cals += 16
    cals
  }
}
val tea = new Tea
tea.describe is "Earl Grey"
tea.calories is 0
val lemonZinger = new Tea(decaf=true, name="Lemon Zinger")
lemonZinger.describe is "Lemon Zinger decaf"
lemonZinger.calories is 0
val sweetGreen = new Tea(name="Jasmine Green", sugar=true)
sweetGreen.describe is "Jasmine Green + sugar"
sweetGreen.calories is 16
val teaLatte = new Tea( sugar=true, milk=true)
teaLatte.describe is "Earl Grey + milk + sugar"
teaLatte.calories is 116

println("Exercise 3")
/*
Use your solution for Exercise 2 as a starting point. Make decaf, milk, sugar and name accessible outside of the class. Satisfy the following tests:
val tea = new Tea2
tea.describe is "Earl Grey"
tea.calories is 0
tea.name is "Earl Grey"
val lemonZinger = new Tea2(decaf = true, name="Lemon Zinger")
lemonZinger.describe is "Lemon Zinger decaf"
lemonZinger.calories is 0
lemonZinger.decaf is true
val sweetGreen = new Tea2(name="Jasmine Green", sugar=true)
sweetGreen.describe is "Jasmine Green + sugar"
sweetGreen.calories is 16
sweetGreen.sugar is true
val teaLatte = new Tea2(sugar=true, milk=true)
teaLatte.describe is "Earl Grey + milk + sugar"
teaLatte.calories is 116
teaLatte.milk is true
*/
class Tea2(
  var name: String = "Earl Grey",
  var decaf: Boolean = false,
  var milk: Boolean = false,
  var sugar: Boolean = false)
{
  def describe(): String = {
    var desc = name
    if (decaf) desc += " decaf"
    if (milk) desc += " + milk"
    if (sugar) desc += " + sugar"
    desc
  }
  def calories(): Int = {
    var cals = 0
    if (milk) cals += 100
    if (sugar) cals += 16
    cals
  }
}

val tea2 = new Tea2
tea2.describe is "Earl Grey"
tea2.calories is 0
tea2.name is "Earl Grey"
val lemonZinger2 = new Tea2(decaf = true, name="Lemon Zinger")
lemonZinger2.describe is "Lemon Zinger decaf"
lemonZinger2.calories is 0
lemonZinger2.decaf is true
val sweetGreen2 = new Tea2(name="Jasmine Green", sugar=true)
sweetGreen2.describe is "Jasmine Green + sugar"
sweetGreen2.calories is 16
sweetGreen2.sugar is true
val teaLatte2 = new Tea2(sugar=true, milk=true)
teaLatte2.describe is "Earl Grey + milk + sugar"
teaLatte2.calories is 116
teaLatte2.milk is true

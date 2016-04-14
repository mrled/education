import com.atomicscala.AtomicTest._

println("Exercise 1")
//Modify Overloading.scala so the argument lists for all the methods are identical. Observe the error messages.
println("ok")

println("Exercise 2")
/*
Create five overloaded methods that sum their arguments. Create the first with no arguments, the second with one argument, etc. Satisfy the following tests: 
f() is 0
f(1) is 1
f(1, 2) is 3
f(1, 2, 3) is 6
f(1, 2, 3, 4) is 10
*/
def f(): Int = 0
def f(a: Int): Int = a
def f(a: Int, b: Int): Int = a + b
def f(a: Int, b: Int, c: Int): Int = a + b + c
def f(a: Int, b: Int, c: Int, d: Int): Int = a + b + c + d
f() is 0
f(1) is 1
f(1, 2) is 3
f(1, 2, 3) is 6
f(1, 2, 3, 4) is 10

println("Exercise 3")
// Modify Exercise 2 to define the methods inside of a class.
class Overloading3 {
  def f(): Int = 0
  def f(a: Int): Int = a
  def f(a: Int, b: Int): Int = a + b
  def f(a: Int, b: Int, c: Int): Int = a + b + c
  def f(a: Int, b: Int, c: Int, d: Int): Int = a + b + c + d
}
val ol3 = new Overloading3
ol3.f() is 0
ol3.f(1) is 1
ol3.f(1, 2) is 3
ol3.f(1, 2, 3) is 6
ol3.f(1, 2, 3, 4) is 10

println("Exercise 4")
//Modify your solution for Exercise 3 to add a method with the same name and arguments, but a different return type. Does that work? Does it matter if you use an explicit return type or type inference for the return type?
println("... lolno")

import com.atomicscala.AtomicTest._
import com.micahrl.MRLUtil._

val exprinter = new ExPrinter

exprinter.printex()
/*
Modify SimpleMap.scala so the anonymous function multiplies each value by 11 and adds 10. Satisfy the following tests:
val v = Vector(1, 2, 3, 4)
v.map(/* Fill this in */) is Vector(21, 32, 43, 54)
*/
val v1 = Vector(1, 2, 3, 4)
v1.map(n => (n * 11) + 10) is Vector(21, 32, 43, 54)

// skipping most of these bc I worked with this already in the red book

exprinter.printex()
//Can you replace map with foreach in the above solution? What happens? Test the result.

exprinter.printex()
// Rewrite the solution for the previous exercise using for. Was this more or less complex than using map? Which approach has the greater potential for errors?

exprinter.printex()
//Rewrite SimpleMap.scala using a for loop instead of map, and observe the additional complexity this introduces.

exprinter.printex()
//Rewrite Reduce.scala using for loops.

exprinter.printex()
/*
Use reduce to implement a method sumIt that takes a variable argument list and sums those arguments. Satisfy the following tests:
sumIt(1, 2, 3) is 6
sumIt(45, 45, 45, 60) is 195
*/
def sumIt (items: Int *): Int = 
  items.reduce((sum, i) => sum + i)
sumIt(1, 2, 3) is 6
sumIt(45, 45, 45, 60) is 195

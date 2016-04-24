import com.atomicscala.AtomicTest._
import com.micahrl.MRLUtil._

val exprinter = new ExPrinter

exprinter.printintro()
sealed trait Color
// trait Color // Works just as well without this
case object Red extends Color
case object Red extends Color
case object Blue extends Color
case object Green extends Color
case object Purple extends Color
object Color {
  val Values = Vector(Red, Blue, Green)
}

def display(color: Color) = color match {
  case Red => "crimson"
  case Blue => "cerulean"
  case Green => "verdant"
}

Color.Values.map(display) is "Vector(crimson, cerulean, verdant)"

exprinter.printex()
println("running `display(Purple)` will throw a MatchError")

exprinter.printex()
object EnumColor extends Enumeration {
  type EnumColor = Value
  val Red, Green, Blue, Purple = Value
}
EnumColor.Red is "Red"
EnumColor.Purple is "Purple"

exprinter.printex()
println("Compile error - 'Red is already defined as value Red'")

exprinter.printex()
println("Compile error - 'Red is already defined as case class Red'")

import com.atomicscala.AtomicTest._
import com.micahrl.MRLUtil._

val exprinter = new ExPrinter

/*
Case classes cannot be subclasses - this is a compile error ("case-to-case inheritance is prohibited")
Case classes can be declared as superclasses, but any subclasses thereof are not available at runtime ("not found: value YourSubClassName")
*/

class SuperNormal(one: Int)
class SubNormal(one: Int, two: Int) extends SuperNormal(one)
val subnorm = new SubNormal(1, 2)

case class SubCaseOfNormal(one: Int, two: Int) extends SuperNormal(one) // error
val subcaseofnorm = new SubCaseOfNormal(1, 2)

case class SuperCase(one: Int)
case class SubCase(one: Int, two: Int) extends SuperCase(one) // error
class SubCase(one: Int, two: Int) extends SuperCase(one) // works, but trying to initialize this class fails
val subcase = SubCase(1, 2)

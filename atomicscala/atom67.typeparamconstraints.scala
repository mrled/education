import com.atomicscala.AtomicTest._
import com.micahrl.MRLUtil._

val exprinter = new ExPrinter

exprinter.printintro()

trait Resilience

object Bounciness extends Enumeration {
  case class _Val() extends Val with Resilience
  type Bounciness = _Val
  val level1, level2, level3 = _Val
}
import Bounciness._

object Flexibility extends Enumeration {
  case class _Val() extends Val with Resilience
  type Flexibility = _Val
  val type1, type2, typ3 = _Val
}
import Flexibility._

trait Spring [R <: Resilience] {
  val res: R
}


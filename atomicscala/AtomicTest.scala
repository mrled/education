/* AtomicTest
 * A tiny little testing framework, to display results and introduce & promote
 * unit testing early in the learning curve. To use in a script or app, 
 * include:
 * import com.atomicscala.AtomicTest._
 */

package com.atomicscala
import language.implicitConversions
import java.io.FileWriter

class AtomicTest [T] (val target: T) { 

  val errorLog = "_AtomicTestErrors.txt"

  def tst [E] (expected: E) (test: => Boolean) {
    println(target)
    if (test == false) {
      val message = "[Error] expected:\n" + expected
      println(message)
      val el = new FileWriter(errorLog, true)
      el.write(target + message + "\n")
      el.close()
    }
  }

  // Safely convert to a String
  def targetStr = Option(target).getOrElse("").toString

  def is (expected: String) = tst(expected) {
    expected.replaceAll("\r\n", "\n") == targetStr
  }

  def is [E] (expected: E) = tst(expected) {
    expected == target
  }

  def beginsWith (expected: String) = tst(expected) {
    targetStr.startsWith(expected.replaceAll("\r\n", "\n"))
  }

}

object AtomicTest {
  implicit def any2Atomic [T] (target: T) = new AtomicTest(target)
}

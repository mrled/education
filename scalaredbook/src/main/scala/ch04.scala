package ch04

import util.Utility

sealed trait RedOption[+A] {

  //// The signatures they give me to implement
  // def map [B] (f: A => B): RedOption[B]
  // def flatMap [B] (f: A => RedOption[B]): RedOption[B]
  // def getOrElse [B >: A] (default: => B): B
  // def orElse [B >: A] (ob: => RedOption[B]): RedOption[B]
  // def filter (f: A => Boolean): RedOption[A]

  def map [B] (transmogrify: A => B): RedOption[B] = this match {
    case RedNone => RedNone
    case RedSome(value) => RedSome(transmogrify(value))
  }
  def flatMap [B] (transmogrify: A => RedOption[B]): RedOption[B] = this match {
    case RedNone => RedNone
    case RedSome(value) => transmogrify(value)
  }
  def flatMapFromAnswerKey [B] (transmogrify: A => RedOption[B]): RedOption[B] = {
    this map transmogrify getOrElse RedNone
  }
  def getOrElse [B >: A] (default: => B): B = this match {
    case RedNone => default
    case RedSome(value) => value
  }
  def orElse [B >: A] (alternative: => RedOption[B]): RedOption[B] = this match {
    case RedNone => alternative
    case RedSome(value) => RedSome(value)
  }
  def filter (test: A => Boolean): RedOption[A] = this match {
    case RedSome(value) if test(value) => this
    case _ => RedNone
  }

}

case class RedSome[+A] (get: A) extends RedOption[A]
case object RedNone extends RedOption[Nothing]

object RedOption {
  def mean (sequence: Seq[Double]): RedOption[Double] = {
    if (sequence.length == 0) RedNone
    else RedSome(sequence.sum / sequence.length)
  }

  def varianceAnswer(xs: Seq[Double]): RedOption[Double] =
    mean(xs) flatMap (m => mean(xs.map(x => math.pow(x - m, 2))))

  def variance (sequence: Seq[Double]): RedOption[Double] = {
    mean(sequence) flatMap (meanval => mean(sequence.map(element => math.pow(element - meanval, 2))))
  }

  // Combine two RedOption values using a binary function
  // If either RedOption object is RedNone, return RedNone
  // Otherwise, apply the mogrify function to both unwrapped RedOption values, and make return a new RedOption containing the result value
  def map2 [A,B,C] (a: RedOption[A], b: RedOption[B]) (mogrify: (A,B) => C): RedOption[C] = {
    // Calling 'flatMap' on 'a' and 'map' on 'b' is intentional...
    // Recall that flatMap returns a collection of the same type as the input collection, 
    // while map returns a collection of a new type. 
    // Also recall that RedOption is a collection type, which can hold exactly zero or exactly one item.
    a flatMap (unwrappeda => b map (unwrappedb => mogrify(unwrappeda, unwrappedb)))
  }

  // This is just me copying the answer
  // This is so fucking confusing I'm fucking going fucking crazy FUCK
  def sequenceFromAnswer [A] (list: List[RedOption[A]]): RedOption[List[A]] = list match {
    case Nil => RedNone
    case Cons(head, tail) => head flatMap (unwrappedhead => sequence(tail) map Cons(unwrappedhead, _))
  }

  def sequenceExplicitRecursive [A] (list: List[RedOption[A]]): RedOption[List[A]] = list match {
    case Nil => Some(Nil)
    case Cons(head, tail) => {
      head flatMap (unwrappedHead => {
        sequence(tail) map Cons(unwrappedhead, _)
      })
    }
  }

  def sequence [A] (list: List[RedOption[A]]): RedOption[List[A]] = {
    def mogrify(item: RedOption[A], acc: List[A]): List[A] = item match {
      case RedNone => throw "whatever"
      case RedSome(value) => value
    }
    try {
      RedSome(list.foldRight(RedNone)(mogrify))
    }
    catch {
      RedNone
    }
  }

  def sequenceNonfunctional [A] (list: List[RedOption[A]]): RedOption[List[A]] = {
    var newList: List[A]
    try {
      for (item <- list) newList += item.getOrElse(throw "whatever")
      return RedSome(newList)
    }
    catch {
      return RedNone
    }
  }
}

object ChapterFour {
  def demo(): Unit = {
    val WrappedNone = RedNone: RedOption[Int]
    Utility.printex(4, 1, "RedOption basic functions"
      , "RedSome(10) map (_*2) = " + (RedSome(10) map (_*2))
      , "RedSome(10).map (_*2) = " + (RedSome(10).map(_*2))
      , "(RedNone: RedOption[Int]) map (_*2) = " + ((RedNone: RedOption[Int]) map (_*2))
      , "WrappedNone map (_*2) = " + (WrappedNone map (_*2))
      , "RedSome(10) flatMap ((i: Int) => RedSome(i*2))) = " + (RedSome(10) flatMap ((i: Int) => RedSome(i*2)))
      , "WrappedNone flatMap ((i: Int) => RedSome(i*2))) = " + (WrappedNone flatMap ((i: Int) => RedSome(i*2)))
      , "RedSome(10) flatMapFromAnswerKey ((i: Int) => RedSome(i*2))) = " + 
        (RedSome(10) flatMapFromAnswerKey ((i: Int) => RedSome(i*2)))
      , "WrappedNone flatMapFromAnswerKey ((i: Int) => RedSome(i*2))) = " + 
        (WrappedNone flatMapFromAnswerKey ((i: Int) => RedSome(i*2)))
      , "RedSome(10) getOrElse 100 = " + (RedSome(10) getOrElse 100)
      , "WrappedNone getOrElse 100 = " + (WrappedNone getOrElse 100)
      , "RedSome(10) orElse RedSome(20) = " + (RedSome(10) orElse RedSome(20))
      , "WrappedNone orElse RedSome(20) = " + (WrappedNone orElse RedSome(20))
      , "RedSome(10) filter (_%2==0) = " + (RedSome(10) filter (_%2==0))
      , "RedSome(11) filter (_%2==0) = " + (RedSome(11) filter (_%2==0))
      , "WrappedNone filter (_%2==0) = " + (WrappedNone filter (_%2==0))
      )
    val someSeq = Seq(1.0, 5.0, 2.0, 4.0)
    val emptySeq = Seq()
    val mogrify = (x: Int, y: Int) => x + y
    Utility.printex(4, 2, "variance"
      , "variance(someSeq) = " + RedOption.variance(someSeq)
      , "variance(emptySeq) = " + RedOption.variance(emptySeq)
      )
    Utility.printex(4, 3, "map2"
      , "map2(RedSome(1), RedSome(2))(mogrify) = " + RedOption.map2(RedSome(1), RedSome(2))(mogrify)
      , "map2(RedNone, RedSome(2))(mogrify) = " + RedOption.map2(RedNone, RedSome(2))(mogrify)
      , "map2(RedSome(1), RedNone)(mogrify) = " + RedOption.map2(RedSome(1), RedNone)(mogrify)
      )
    Utility.printex(4, 4, "sequence",
      )
  }
}

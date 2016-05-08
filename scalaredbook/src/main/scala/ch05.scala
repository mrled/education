package ch05

import util.Utility

import RedStream._

sealed trait RedStream[+A] {

  // Write a function to convert a Stream to a List, which will force its evaluation and let you look at it in the REPL. You can convert to the regular List type in the standard library. You can place this and other functions that operate on a Stream inside the Stream trait.
  def toList: List[A] = {
    @annotation.tailrec
    def go[A] (inStream: RedStream[A], acc: List[A]): List[A] = inStream match {
      case RedEmpty => acc
      case RedCons(head, tail) => go(tail(), head() :: acc)
    }
    go(this, List()).reverse
  }

  // Write the function take(n) for returning the first n elements of a Stream, and drop(n) for skipping the first n elements of a Stream.
  // def appendStream[A] (addend: RedStream[A]): RedStream[A] = {
  //   @annotation.tailrec
  //   def go[A] (augend: RedStream[A], addend: RedStream[A]): RedStream[A] = augend match {
  //     case RedEmpty => addend // if the input stream is empty, just return the item
  //     case RedCons(head, tail) => go(tail, addend)
  //   }
  //   go(this, addend)
  // }

  // def appendItem[A] (addend: A): RedStream[A] = {
  //   val newStream = RedCons(addend, Nil)
  //   this.appendStream(newStream)
  // }

  def take(number: Int): RedStream[A] = {
    @annotation.tailrec
    def go(num: Int, inStream: RedStream[A], acc: ()=>RedStream[A]): RedStream[A] = inStream match {
      case RedEmpty => RedStream.empty
      case RedCons(head, tail) if num <  1 => acc()
      case RedCons(head, tail) if num >= 1 => go(num -1, tail(), ()=>RedStream.cons(head(), acc()))
    }
    RedStream.applyList(go(number, this, ()=>RedStream.empty[A]).toList.reverse)
  }

  def drop(number: Int): RedStream[A] = {
    @annotation.tailrec
    def go(num: Int, stream: RedStream[A]): RedStream[A] = stream match {
      case RedEmpty => RedStream.empty
      case RedCons(head, tail) if num <  1 => stream
      case RedCons(head, tail) if num >= 1 => go(num -1, tail())
    }
    go(number, this)
  }

  override def toString: String = {
    this.toList.toString
  }
}

case object RedEmpty extends RedStream[Nothing]
case class RedCons[+A] (head: ()=>A, tail: ()=>RedStream[A]) extends RedStream[A]

object RedStream {
  def cons[A] (head: =>A, tail: =>RedStream[A]): RedStream[A] = {
    lazy val evaluatedhead = head
    lazy val evaluatedtail = tail
    return RedCons(()=>evaluatedhead, ()=>evaluatedtail)
  }

  def empty[A]: RedStream[A] = RedEmpty

  def apply[A] (list: A*): RedStream[A] = {
    if (list.isEmpty) empty
    else cons(list.head, apply(list.tail: _*))
  }

  def applyList[A] (list: List[A]): RedStream[A] = {
    if (list.isEmpty) empty
    else cons(list.head, apply(list.tail: _*))
  }
}

object ChapterFive {
  def demo(): Unit = {
    val strm = RedStream.apply(1, 2, 3, 4, 5)
    val lst = strm.toList

    Utility.printex(5, 1, "toList"
      , "Redstream.apply(1, 2, 3, 4, 5).toList = " + strm.toList
      )
    Utility.printex(5, 2, "drop / take"
      , "strm.drop(2) = " + strm.drop(2)
      , "strm.take(2) = " + strm.take(2)
      )
  }
}

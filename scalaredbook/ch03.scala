package ch03

sealed trait FPISList[+A]
case object Nil extends FPISList[Nothing]
case class FPISCons[+A](head: A, tail: FPISList[A]) extends FPISList[A]

object FPISList {
    def sum(ints: FPISList[Int]): Int = ints match {
        case Nil => 0
        case FPISCons(x, xs) => x + sum(xs)
    }
    def product(ds: FPISList[Double]): Double = ds match {
        case Nil => 1.0
        case FPISCons(0.0, _) => 0.0
        case FPISCons(x, xs) => x * product(xs)
    }
    def apply[A](list: A*): FPISList[A] = {
        if (list.isEmpty) Nil
        else FPISCons(list.head, apply(list.tail: _*))
    }

    def tail[A](as: FPISList[A]): FPISList[A] = as match {
        case Nil => Nil
        case FPISCons(h, t) => t
    }
    def setHead[A](newHead: A, as: FPISList[A]) = as match {
        case Nil => FPISCons(newHead, Nil)
        case FPISCons(head, tail) => FPISCons(newHead, tail)
    }
    def drop[A](num: Int, as: FPISList[A]): FPISList[A] = {
        def loop(ctr: Int, as: FPISList[A]): FPISList[A] = {
            val newList: FPISList[A] = FPISList.tail(as)
            if (ctr > 0) loop(ctr -1, newList)
            else newList
        }
        loop(num -1, as)
    }

    /*
    def append[A](newElement: A, list: A*): FPISList[A] = {
        if (list.isEmpty) FPISList(newElement)
        else FPISCons(list.head, apply(newElement, list.tail: _*))
    }

    def dropWhile[A](list: FPISList[A], matchFunc: A=>Boolean): FPISList[A] = {
        // Take a list and a function that returns true or false
        // Check the head. 
        //   If the function returns true on the head, add it to the return value
        //   If the function returns false on the head, do not add it to the return value
        // Call self recursively with the tail of the FPISList
        def loop(
            inList: FPISList[A], 
            outList: FPISList[A], 
            matchFunc: A=>Boolean
            ): FPISList[A] = inList match 
        {
            case Nil => outList
            //case FPISCons(head, _) => loop( tail(inList), if matchFunc(head) outList.append(head) else outList, matchFunc )
            case FPISCons(head, tail) => {
                val newOutList: FPISList[A] = if (matchFunc(head)) { FPISList.append(head, outList) } else { outList }
                loop ( tail, newOutList, matchFunc )
            }
        }
        loop(list, Nil, matchFunc)

        // def loop(inList: FPISList[A], matchFunc A=>Boolean): FPISList[A] = inList match {
        //     case Nil => Nil
        //     case FPISCons(head, _) {
        //         if matchFunc(head) => loop
        //     }
        // }
    }
    */
}

object ChapterThree {

    def demo(): Unit = {
        println("\n\n==== Chapter Three ====")
        val qwerty = FPISList(1,2,3,4,5) match {
            case FPISCons(x, FPISCons(2, FPISCons(4, _))) => x
            case Nil => 42
            case FPISCons(x, FPISCons(y, FPISCons(3, FPISCons(4, _)))) => x + y
            case FPISCons(h, t) => h + FPISList.sum(t)
            case _ => 101
        }
        println("qwerty = " + qwerty)

        val longerList = FPISList(1,2,3,4,5)
        val shorterList = FPISList.tail(longerList)
        val replacedHeadList = FPISList.setHead(10, longerList)
        val evenShorterList = FPISList.drop(3, longerList)

        println("longerList =        " + longerList)
        println("shorterList =       " + shorterList)
        println("replacedHeadList =  " + replacedHeadList)
        println("evenShorterList =   " + evenShorterList)
    }

}

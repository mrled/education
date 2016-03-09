package ch03

import util.Utility

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
    def drop[A](num: Int, list: FPISList[A]): FPISList[A] = {
        def loop(ctr: Int, list: FPISList[A]): FPISList[A] = {
            val newList: FPISList[A] = FPISList.tail(list)
            if (ctr > 0) loop(ctr -1, newList)
            else newList
        }
        loop(num -1, list)
    }

    //@annotation.tailrec
    def append[A](list: FPISList[A], newElement: A): FPISList[A] = list match {
        case Nil => FPISCons(newElement, Nil)
        case FPISCons(head, tail) => FPISCons(head, append(tail, newElement))
    }

    // HOLY FUCK I SPENT FOREVER FIGURING OUT HOW TO DO THIS AND IT'S NOT WHAT THEY WANTED
    // They wanted me to only remove things from "the list prefix"
    // What the fuck is a list prefix
    // ... oh. You just meant from the beginng. 
    // Which I couldn't figure out until I saw the answer
    // Which used syntax that was new to me
    // Fucking fantastic
    // Fantasstic
    // FantASStic
    def dropWhile[A](list: FPISList[A], matchFunc: A => Boolean): FPISList[A] = {

        def loop[A](list: FPISList[A], newList: FPISList[A], matchFunc: A => Boolean): FPISList[A] = list match {
            case Nil => newList
            case FPISCons(head, tail) => {
                val newNewList = if (matchFunc(head)) { FPISList.append(newList, head) } else { newList }
                println("Calling loop("+tail+", "+newNewList+", "+matchFunc+")...")
                loop(tail, newNewList, matchFunc)
            }
        }
        loop(list, Nil, matchFunc)
    }

    def dropWhileAnswer[A](as: FPISList[A])(f: A => Boolean): FPISList[A] = as match {
        case FPISCons(h,t) if f(h) => dropWhileAnswer(t)(f)
        case _ => as
    }

    // Take a list; return a copy of that list without the final element
    // Why is this called init
    // Why do functional programmers think they are capable of naming things
    // Why do they think the way that they think
    // What is wrong with them
    // Science does not know
    def init[A](list: FPISList[A]): FPISList[A] = {
        def loop[A](list: FPISList[A], newList: FPISList[A]): FPISList[A] = list match {
            case Nil => newList
            case FPISCons(head, Nil) => newList
            case FPISCons(head, tail) => loop (tail, FPISList.append(newList, head))
        }
        loop(list, Nil)
    }



    def foldRight[A,B](as: FPISList[A], z: B)(f: (A,B) => B): B = as match {
        case Nil => z
        case FPISCons(x,xs) => f(x, foldRight(xs, z)(f))
    }
    def foldRightReadable[A,B](inList: FPISList[A], emptyVal: B)(accumulateFunc: (A,B) => B): B = inList match {
        case Nil => emptyVal
        case FPISCons(head, tail) => accumulateFunc(head, foldRight(tail, emptyVal)(accumulateFunc))
    }

    def sum2(ns: FPISList[Int]) = 
        foldRight(ns, 0)(_ + _)
    def product2(ns: FPISList[Double]) =
        foldRight(ns, 1.0)(_ * _)

    def productShortCircuit(list: FPISList[Double]) = {
        def accumulateFunc(x: Double, y: Double): Double = x match {
            case 0.0 => 0.0
            case _ => x * y 
        }
        foldRight(list, 1.0)(accumulateFunc)
    }

    def length[A](as: FPISList[A]): Int = {
        foldRight(as, 0)( (x,y) => 1 + y )
    }


    def testAllListMembersAreEven(list: FPISList[Int]): Boolean = {
        val evenTest = (listItem: Int, accumulatedTruth: Boolean) => listItem%2==0 && accumulatedTruth
        foldRightReadable(list, true)(evenTest)
    }


    //def foldLeft[A]B(as: List[A], z: B)(f: (B,A) => B): B
    @annotation.tailrec
    def foldLeft[A,B](inList: FPISList[A], default: B)(accumulateFunc: (B,A) => B): B = inList match {
        case Nil => default
        case FPISCons(head, tail) => foldLeft(tail, accumulateFunc(default, head))(accumulateFunc)
    }

    def foldLeftReadable[A,B](inList: FPISList[A], default: B)(accumulateFunc: (B,A)=>B): B = inList match {
        case Nil => default
        case FPISCons(head, tail) => {
            val accumulated = accumulateFunc(default, head)
            foldLeftReadable(tail, accumulated)(accumulateFunc)
        }
    }

    def leftSum(intList: FPISList[Int]) = 
        foldLeft(intList, 0)(_ + _)
    def leftProduct(doubleList: FPISList[Double]) =
        foldLeft(doubleList, 1.0)(_ * _)
    def leftLength[A](list: FPISList[A]) = {
        val ctrFunc = (acc: Int, listItem: A) => acc + 1
        foldLeft(list, 0)(ctrFunc)
    }

    def reverse[A](list: FPISList[A]) = {
        val accumulatorFunc = (accumulated: FPISList[A], head: A) => FPISCons(head, accumulated)
        foldLeftReadable(list, FPISList[A]() )(accumulatorFunc)
    }

    def foldRightViaFoldLeft[A,B](inList: FPISList[A], default: B)(accFunc: (A,B) => B): B = {
        foldLeft(reverse(inList), default)( (a,b) => accFunc(b,a) )
    }

    // def foldRightReadable[A,B](inList: FPISList[A], emptyVal: B)(accumulateFunc: (A,B) => B): B = inList match {
    //     case Nil => emptyVal
    //     case FPISCons(head, tail) => accumulateFunc(head, foldRight(tail, emptyVal)(accumulateFunc))
    // }
    def appendViaFoldRight[A](list1: FPISList[A], list2: FPISList[A]): FPISList[A] = {
        foldRightReadable(list1, list2)(FPISCons(_,_))
    }

    def concatenateLists[A](metaList: FPISList[FPISList[A]]): FPISList[A] = {
        val accumulatorFunc = (default: FPISList[A], head: FPISList[A]) => appendViaFoldRight(default, head)
        foldRightReadable(metaList, Nil:FPISList[A])(accumulatorFunc)
        //foldLeftReadable(metaList, Nil:FPISList[A])(accumulatorFunc) // BROKEN
    }

    def incrementAllListItems(inList: FPISList[Int]): FPISList[Int] = {
        //foldLeft(inList, Nil:FPISList[Int])( (default, head) => FPISCons(head+1, default) ) // BROKEN
        foldRight(inList, Nil:FPISList[Int])( (head, tail) => FPISCons(head+1, tail) )
    }
    def stringify(inList: FPISList[Double]) = {
        //foldLeft(inList, Nil:FPISList[String])( (default, head) => FPISCons(head.toString(), default) ) // BROKEN
        foldRight(inList, Nil:FPISList[String])( (head, tail) => FPISCons(head.toString(), tail) )
    }

    def map[A,B](inList: FPISList[A])(transmogrify: A => B): FPISList[B] = {
        //foldLeft(inList, Nil:FPISList[B])( (default, head) => FPISCons(transmogrify(head), default)) // BROKEN
        foldRight(inList, Nil:FPISList[B])( (head, tail) => FPISCons(transmogrify(head), tail))
    }


    def filter[A](inList: FPISList[A])(testFunc: A => Boolean): FPISList[A] = {
        val accFunc = (head: A, tail: FPISList[A]) => {
            if (testFunc(head)) FPISCons(head, tail)
            else tail
        }
        foldRight(inList, Nil:FPISList[A])(accFunc)
    }

    def flatMap[A,B](inList: FPISList[A])(transmogrify: A => FPISList[B]): FPISList[B] = {
        concatenateLists( map(inList)(transmogrify) )
    }

    def filterViaFlatMap[A](inList: FPISList[A])(testFunc: A => Boolean): FPISList[A] = {
        val transmogrify = (item: A) => {
            if (testFunc(item)) FPISList(item)
            else Nil:FPISList[A]
        }
        flatMap(inList)(transmogrify)
    }

    def addListItems(list1: FPISList[Int], list2: FPISList[Int]): FPISList[Int] = (list1, list2) match {
        case (Nil, _) => Nil
        case (_, Nil) => Nil
        case (FPISCons(head1, tail1), FPISCons(head2, tail2)) => 
            FPISCons(head1+head2, addListItems(tail1, tail2))
    }

    def zipWith[A](list1: FPISList[A], list2: FPISList[A]) ( zip: (A,A)=>A ) : FPISList[A] = (list1, list2) match {
        case (Nil, _) => Nil
        case (_, Nil) => Nil
        case (FPISCons(head1, tail1), FPISCons(head2, tail2)) => 
            FPISCons(zip(head1, head2), zipWith(tail1, tail2)(zip) )
    }

    // def hasSubsequence[A](list: FPISList[A], subsequence: FPISList[A]): Boolean = {
    // 
    // }
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
        val doubList = FPISList(1.0, 2.0, 3.0, 4.0)
        val shorterList = FPISList.tail(longerList)
        val replacedHeadList = FPISList.setHead(10, longerList)
        val evenShorterList = FPISList.drop(3, longerList)
        val evenLongerList = FPISList.append(longerList, 6)
        val evenList = FPISList.dropWhile(longerList, (i: Int) => i%2==0 )
        val evenListMinusOne = FPISList.init(evenList)
        val metaList = FPISList( FPISList(1, 2), FPISList(3, 4), FPISList(5, 6) )

        println("longerList =        " + longerList)
        println("shorterList =       " + shorterList)
        println("replacedHeadList =  " + replacedHeadList)
        println("evenShorterList =   " + evenShorterList)
        println("evenLongerList =    " + evenLongerList)
        println("evenList =          " + evenList)
        println("evenListMinusOne =  " + evenListMinusOne)

        val listWithZero = FPISList(1.0, 4.0, 0.0, 5.0)
        val listNoZero = FPISList(1.0, 4.0, 5.0)
        println("productShortCircuit(listWithZero) = " + FPISList.productShortCircuit(listWithZero))
        println("productShortCircuit(listNoZero) =   " + FPISList.productShortCircuit(listNoZero))

        println("Passing Nil and FPISCons to foldRight: " +
            FPISList.foldRight(FPISList(1,2,3), Nil:FPISList[Int])(FPISCons(_,_)))

        println("length(longerList) = " + FPISList.length(longerList))

        Utility.printex(
            3, 10, "foldLeft", 
            "foldLeft(longerList, 1.0)(_*_) = " + FPISList.foldLeft(longerList, 1.0)(_*_))
        Utility.printex(
            3, 11, "foldLeft() versions of sum, product, and length", 
            "leftSum(longerList)     = " + FPISList.leftSum(longerList),
            "leftProduct(doubList)   = " + FPISList.leftProduct(doubList),
            "leftLength(longerList)  = " + FPISList.leftLength(longerList))
        Utility.printex(
            3, 12, "reverse", 
            "reverse(longerList) = " + FPISList.reverse(longerList))
        Utility.printex(
            3, 13, "foldLeft via foldRight & vice versa", 
            "The sum algorithm is: foldRight(longerList, 0)(_ + _)",
            "via normal foldRight:      " + FPISList.foldRight(longerList, 0)(_ + _),
            "via foldRightViaFoldLeft:  " + FPISList.foldRightViaFoldLeft(longerList, 0)(_ + _))
        Utility.printex(
            3, 14, "append via a fold", 
            "appendViaFoldRight(longerList, longerList) = " + FPISList.appendViaFoldRight(longerList, longerList))
        Utility.printex(
            3, 15, "concatenateLists", 
            "metaList = " + metaList,
            "concatenateLists(metaList) = " + FPISList.concatenateLists(metaList))
        Utility.printex(
            3, 16, "incrementAllListItems", 
            "incrementAllListItems(longerList) = " + FPISList.incrementAllListItems(longerList))
        Utility.printex(
            3, 17, "stringify", 
            "stringify(doubList) = " + FPISList.stringify(doubList))
        Utility.printex(
            3, 18, "map", 
            "map(longerList)( (i: Int)=>(i*2) ) = " + FPISList.map(longerList)( (i: Int)=>(i*2) ))
        Utility.printex(
            3, 19, "filter", 
            "filter(longerList)(_%2==0) = " + FPISList.filter(longerList)(_%2==0))
        Utility.printex(
            3, 20, "flatMap", 
            "flatMap(longerList)(item=>FPISList(item,item)) = " + FPISList.flatMap(longerList)(item=>FPISList(item,item)))
        Utility.printex(
            3, 21, "filter via flatMap", 
            "filterViaFlatMap(longerList)(_%2==0) = " + FPISList.filterViaFlatMap(longerList)(_%2==0))
        Utility.printex(
            3, 22, "addListItems", 
            "addListItems(longerList, longerList) = " + FPISList.addListItems(longerList, longerList))
        Utility.printex(
            3, 23, "zipWith", 
            "zipWith(longerList, longerList)(_+_) = " + FPISList.zipWith(longerList, longerList)(_+_))
        Utility.printex(
            3, 24, "hasSubsequence", "UNIMPLEMENTED")
    }

}

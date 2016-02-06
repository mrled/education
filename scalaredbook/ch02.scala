package ch02

object ChapterTwo {

    //@annotation.tailrec
    def fib(n: Int): Int = {
        /*
        Write a recursive function to get the nth Fibonacci number
        This is supposed to be tail recursive?? apparently. fuck
        */
        if (n <= 1) 0
        else if (n == 2) 1
        else fib(n -1) + fib(n -2)
    }

    def fibDemo(): Unit = {
        @annotation.tailrec
        def printloop(n: Int): Unit = {
            println("fib(%d) = %d".format(n, fib(n)))
            if (n > 0) printloop(n -1)
        }
        printloop(10)
    }

    def isSorted[A](as: Array[A], ordered: (A,A) => Boolean): Boolean = {
        @annotation.tailrec
        def loop(n: Int): Boolean = {
            if (n+1 >= as.length) true
            else if (ordered(as(n), as(n+1))) loop(n+1)
            else false
        }
        loop(0)
    }

    def isSortedDemo(): Unit = {
        def orderedInts(x: Int, y: Int): Boolean = {
            // Treat x=y as true
            if (x>y) false
            else true
        }
        val demoArray: Array[Array[Int]] = Array(
            Array(1, 2, 3, 4),
            Array(10, 15, 20, 100),
            Array(1, 1, 2, 3),
            Array(1, 2, 1, 3),
            Array(1, 2, 4, 3)
        )
        def loop(idx: Int): Unit = {
            println("isSorted() #%d == %b".format(idx, isSorted(demoArray(idx), orderedInts)))
            if (idx+1 < demoArray.length) loop(idx +1)
        }
        loop(0)
    }

    // parameter f: a function that takes an A argument and a B argument and returns:
    //     a C value
    // return value: a function that takes an A argument and returns:
    //     a function that takes a B argument and returns: 
    //         a C value
    def curry[A,B,C](f: (A, B) => C): A => (B => C) = {
        (a: A) => ((b: B) => f(a, b))
    }

    // f: A => B => C       ...is the same as: 
    // f: A => (B => C)     ...because "the => operator associates right"
    // ... fuckers! this adds no clarity! why would you allow it at all! 
    // parameter f: a function that takes an A argument and returns:
    //     a function that takes a B argument and returns: 
    //         a C value
    // return value: a function that takes an A argument and a B argument and returns:
    //     a C value
    def uncurry[A,B,C](f: A => B => C): (A, B) => C = {
        //(a: A, b: B) => (val g = f(a); g(b))
        (a: A, b: B) => f(a)(b)
    }

    def curryUncurryDemo(): Unit = {

        val dumbExample = (i: Int, l: Long) => "int:" + i.toString() + " long:" + l.toString()
        println("dumbExample:       " + dumbExample)
        println("dumbExample(1,2):  " + dumbExample(1, 2))

        val curriedExample = curry(dumbExample)
        println("curriedExample:    " + curriedExample)
        val stage1 = curriedExample(1)
        println("stage1:            " + stage1)
        val result = stage1(2)
        println("result:            " + result)

        val uncurried = uncurry(curriedExample)
        println("uncurried:         " + uncurried)
        println("uncurried(1,2):    " + uncurried(1, 2))
    }

    def compose[A,B,C](f: B => C, g: A => B): A => C = {
        (a: A) => f(g(a))
    }

    //def main(args: Array[String]): Unit = {
    def demo(): Unit = {
        println("\n\n==== Chapter Two ====")
        fibDemo()
        isSortedDemo()
        curryUncurryDemo()
    }
}


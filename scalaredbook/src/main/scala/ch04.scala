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
        case None => None
        case RedSome(value) => RedSome(transmogrify(value))
    }
    def flatMap [B] (transmogrify: A => RedOption[B]): RedOption[B] = this match {
        case None => None
        case RedSome(value) => transmogrify(value)
    }
    def flatMapFromAnswerKey [B] (transmogrify: A => RedOption[B]): RedOption[B] = {
        this map transmogrify getOrElse None
    }
    def getOrElse [B >: A] (default: => B): B = this match {
        case None => default
        case RedSome(value) => value
    }
    def orElse [B >: A] (alternative: => RedOption[B]): RedOption[B] = this match {
        case None => alternative
        case RedSome(value) => RedSome(value)
    }
    def filter (test: A => Boolean): RedOption[A] = this match {
        case RedSome(value) if test(value) => this
        case _ => None
    }

}

case class RedSome[+A] (get: A) extends RedOption[A]
case object None extends RedOption[Nothing]

object RedOption {
    def mean (sequence: Seq[Double]): RedOption[Double] = {
        if (sequence.length == 0) None
        else RedSome(sequence.sum / sequence.length)
    }

    def varianceAnswer(xs: Seq[Double]): RedOption[Double] =
        mean(xs) flatMap (m => mean(xs.map(x => math.pow(x - m, 2))))

    //def variance (sequence: Seq[Double]): Seq[Double] = {
    def variance (sequence: Seq[Double]): RedOption[Double] = {
        //mean(sequence).flatMap(meanval => RedSome(sequence.map(element => math.pow(element - meanval, 2)): RedOption[Double] ))

        // def calcSingleVariance (element: Double): Double = math.pow(element - meanval, 2)
        // mean(sequence).flatMap(meanval => RedSome(sequence.map(calcSingleVariance)))

        mean(sequence) flatMap (meanval => mean(sequence.map(element => math.pow(element - meanval, 2))))
    }

}

object ChapterFour {
    def demo(): Unit = {
        val WrappedNone = None: RedOption[Int]
        Utility.printex(4, 1, "RedOption basic functions"
            , "RedSome(10) map (_*2) = " + (RedSome(10) map (_*2))
            , "RedSome(10).map (_*2) = " + (RedSome(10).map(_*2))
            , "(None: RedOption[Int]) map (_*2) = " + ((None: RedOption[Int]) map (_*2))
            , "WrappedNone map (_*2) = " + (WrappedNone map (_*2))
            , "RedSome(10) flatMap ((i: Int) => RedSome(i*2))) = " + (RedSome(10) flatMap ((i: Int) => RedSome(i*2)))
            , "WrappedNone flatMap ((i: Int) => RedSome(i*2))) = " + (WrappedNone flatMap ((i: Int) => RedSome(i*2)))
            ,   "RedSome(10) flatMapFromAnswerKey ((i: Int) => RedSome(i*2))) = " + 
                (RedSome(10) flatMapFromAnswerKey ((i: Int) => RedSome(i*2)))
            ,   "WrappedNone flatMapFromAnswerKey ((i: Int) => RedSome(i*2))) = " + 
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
        Utility.printex(4, 2, "variance"
            , "variance(someSeq) = " + RedOption.variance(someSeq)
            )
    }
}

package runtime

import ch02.ChapterTwo
import ch03.ChapterThree
import ch04.ChapterFour
import ch05.ChapterFive

object Main  {
    def main(args: Array[String]): Unit = {
        ChapterTwo.demo()
        ChapterThree.demo()
        ChapterFour.demo()
        ChapterFive.demo()
    }
}

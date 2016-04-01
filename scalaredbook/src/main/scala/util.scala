package util

object Utility {
    def printex(chapter: Int, exercise: Int, title: String, messages: String*): Unit = {
        println("Ex "+chapter+"."+exercise+": "+title)
        messages.foreach( (message: String) => (println("    "+message)) )
    }
}

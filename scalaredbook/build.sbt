lazy val root = (project in file(".")).
  settings(
    name := "redbook",
    version := "0.1",
    scalaVersion := "2.11.7",
    libraryDependencies += "org.scalacheck" %% "scalacheck" % "1.13.0" % "test"
  )
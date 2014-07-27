name := """play-scala-backbone-todo"""

version := "1.0-SNAPSHOT"

scalaVersion := "2.11.1"

lazy val root = (project in file(".")).enablePlugins(PlayScala)

libraryDependencies ++= Seq(
  ws,
  "org.webjars" % "jquery" % "2.1.1",
  "org.webjars" % "requirejs" % "2.1.14-1",
  "org.webjars" % "underscorejs" % "1.6.0-3",
  "org.webjars" % "angularjs" % "1.2.20",
  "org.webjars" % "ngInfiniteScroll" % "1.1.2",
  "com.typesafe.play" %% "play-slick" % "0.8.0-M1",
  "org.seleniumhq.selenium" % "selenium-firefox-driver" % "2.34.0",
  "postgresql" % "postgresql" % "9.1-901-1.jdbc4"
)

libraryDependencies += filters

includeFilter in (Assets, LessKeys.less) := "main.less"

excludeFilter in (Assets, LessKeys.less) := "_*.less"

pipelineStages := Seq(rjs, digest, gzip)

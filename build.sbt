scalaVersion := "2.13.12"

scalacOptions ++= Seq(
  "-deprecation",
  "-feature",
  "-unchecked",
  "-Xfatal-warnings",
  "-language:reflectiveCalls",
)

// Chisel 6.5
addCompilerPlugin("org.chipsalliance" % "chisel-plugin" % "6.5.0" cross CrossVersion.full)
libraryDependencies += "org.chipsalliance" %% "chisel" % "6.5.0"


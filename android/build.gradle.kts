// LiteRT-LM 0.18.0 contains Kotlin 2.4 metadata. This supported R8 patch
// avoids metadata parsing warnings without upgrading Flutter/AGP/Kotlin.
buildscript {
    repositories { google(); mavenCentral() }
    dependencies { classpath("com.android.tools:r8:9.1.56") }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

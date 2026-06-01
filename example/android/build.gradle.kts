allprojects {
    repositories {
        // Resolve vendor AARs published by the plugin to the local maven-repo
        maven {
            // Resolve from the root project directory to avoid relative path issues
            url = uri("${rootProject.projectDir}/../../android/maven-repo")
        }
        google()
        mavenLocal()
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

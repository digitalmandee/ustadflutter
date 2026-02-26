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

//////////////////////////////////////////////////////////////
// ✅ FIREBASE & GOOGLE SIGN-IN SUPPORT
//////////////////////////////////////////////////////////////

buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {

        // ✅ Required for Firebase
        classpath("com.google.gms:google-services:4.4.2")

        // ✅ Android Gradle Plugin (match your project version)
        classpath("com.android.tools.build:gradle:8.1.0")

        // ✅ Kotlin Plugin (match your version)
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:2.0.0")
    }
}

// ✅ JVM toolchain for consistent Java/Kotlin version
tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile> {
    kotlinOptions {
        jvmTarget = "17"
    }
}
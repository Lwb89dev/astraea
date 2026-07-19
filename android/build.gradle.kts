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

// Force every plugin module to compile against SDK 36. amberflutter 0.0.9 is
// compiled against android-33, but the androidx libraries it (and the app)
// pull in — fragment 1.7.1, activity 1.8.x, window 1.2.0, lifecycle 2.7.0,
// core-ktx 1.18.0 — require their consumers to compile against SDK 34..36, so
// the AAR-metadata check fails otherwise. With android.newDsl=false the
// Android extension is BaseExtension, so compileSdkVersion(int) applies
// cleanly. Registered BEFORE the evaluationDependsOn block below so
// afterEvaluate isn't attached to an already-evaluated project.
subprojects {
    afterEvaluate {
        val androidExt = extensions.findByName("android")
        if (androidExt is com.android.build.gradle.BaseExtension) {
            androidExt.compileSdkVersion(36)
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

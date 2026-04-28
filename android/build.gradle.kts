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

fun Project.setNamespaceIfMissing() {
    if (extensions.findByName("android") == null) return
    val android = extensions.getByName("android") as com.android.build.gradle.BaseExtension
    if (android.namespace == null) {
        android.namespace =
            if (group.toString().isNotEmpty()) group.toString()
            else "com.heroapp.${name.replace("-", "_")}"
    }
}

subprojects {
    plugins.withId("com.android.application") { setNamespaceIfMissing() }
    plugins.withId("com.android.library") { setNamespaceIfMissing() }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

package buildscripts

import org.gradle.api.Project

interface TaskHandler {
    fun apply(project: Project)
}
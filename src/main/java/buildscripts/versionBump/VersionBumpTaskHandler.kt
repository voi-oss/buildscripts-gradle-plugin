package buildscripts.versionBump

import buildscripts.Script
import buildscripts.ScriptRunner
import buildscripts.TaskHandler
import org.gradle.api.Project

/**
 * Creates a new gradle task that bumps the current version and commits the change
 * to the current branch.
 *
 * Usage:
 *      gradle bumpMinorVersion
 */
class VersionBumpTaskHandler(private val scriptRunner: ScriptRunner) : TaskHandler {

    override fun apply(project: Project) {
        project.task("bumpMinorVersion") {
            it.doLast {
                val script = Script(fileName = "bump_minor_version.sh", dependencies = listOf("utils.sh", "semver.sh"))
                scriptRunner.run(project.projectDir, script)
            }
        }
    }
}
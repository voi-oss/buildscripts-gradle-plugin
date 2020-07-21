package buildscripts.releaseBranch

import buildscripts.Script
import buildscripts.ScriptRunner
import buildscripts.TaskHandler
import org.gradle.api.Project

/**
 * Creates a new gradle task that checkout a release branch for the current version
 * and adds an internal release tag.
 *
 * If the branch already exists, or any error occurs, the task will fail gracefully.
 *
 * Usage:
 *      gradle createReleaseBranch
 */
class ReleaseBranchTaskHandler(private val scriptRunner: ScriptRunner) : TaskHandler {

    override fun apply(project: Project) {
        project.task("createReleaseBranch") {
            it.doLast {
                val script = Script(fileName = "create_release_branch.sh", dependencies = listOf("utils.sh"))
                scriptRunner.run(project.projectDir, script)
            }
        }
    }
}
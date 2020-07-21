package buildscripts

import buildscripts.releaseBranch.ReleaseBranchTaskHandler
import org.gradle.api.Plugin
import org.gradle.api.Project
import buildscripts.releaseNotes.ReleaseNotesTaskHandler
import buildscripts.updateTranslations.UpdateTranslationsTaskHandler
import buildscripts.versionBump.VersionBumpTaskHandler
import org.slf4j.LoggerFactory

class VoiBuildScriptsPlugin : Plugin<Project> {

    private val logger = LoggerFactory.getLogger(this::class.java)
    private val scriptRunner = JarScriptRunner(JarResourceLoader(), logger)
    private val taskRegistry: List<TaskHandler> = listOf(
        ReleaseNotesTaskHandler(scriptRunner),
        ReleaseBranchTaskHandler(scriptRunner),
        VersionBumpTaskHandler(scriptRunner),
        UpdateTranslationsTaskHandler(scriptRunner)
    )

    /**
     * Main plugin entry point.
     *
     * Starts every taskHandler in the [taskRegistry].
     */
    override fun apply(project: Project) {
        taskRegistry.forEach { taskHandler -> taskHandler.apply(project) }
    }
}

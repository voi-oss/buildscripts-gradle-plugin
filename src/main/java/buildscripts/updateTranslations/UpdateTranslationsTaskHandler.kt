package buildscripts.updateTranslations

import buildscripts.Script
import buildscripts.ScriptRunner
import buildscripts.TaskHandler
import org.gradle.api.Project

/**
 * Creates a new gradle task that downloads the phraseapp executable and
 * pulls the latest translations.
 *
 * The task assumes that the phraseapp configuration file (.phraseapp.yml)
 * is in the root git directory.
 *
 * Usage:
 *      gradle updateTranslations
 */
class UpdateTranslationsTaskHandler(private val scriptRunner: ScriptRunner) : TaskHandler {

    override fun apply(project: Project) {
        project.task("updateTranslationsPhrase") {
            it.doLast {
                val script = Script(fileName = "update_translations_phrase_v1.17.1.sh", dependencies = listOf("utils.sh"))
                scriptRunner.run(project.projectDir, script)
            }
        }
        project.task("updateTranslationsLokalise"){
            it.doLast {
                val script = Script(fileName = "update_translations_lokalise_v2.sh", dependencies = listOf("utils.sh"))
                scriptRunner.run(project.projectDir, script)
            }
        }
    }
}
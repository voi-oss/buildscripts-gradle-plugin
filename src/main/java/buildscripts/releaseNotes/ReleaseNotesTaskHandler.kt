package buildscripts.releaseNotes

import buildscripts.Script
import buildscripts.ScriptRunner
import buildscripts.TaskHandler
import org.gradle.api.Project
import java.io.File
import java.util.UUID

/**
 * Creates a new gradle task that generates release notes from git commit messages.
 *
 * The output may be the standard output (default behavior) or a given file.
 *
 * Configuration example (build.gradle file):
 *      releaseNotes {
 *          outputFileName = "release_notes.txt"
 *      }
 *
 * Usage:
 *      gradle generateReleaseNotes
 */
class ReleaseNotesTaskHandler(private val scriptRunner: ScriptRunner) : TaskHandler {

    override fun apply(project: Project) {
        val extension = project.extensions.create("releaseNotes", ReleaseNotesExtension::class.java)
        project.task("generateReleaseNotes") {
            it.doLast {
                generateReleaseNotes(project.projectDir, extension)
            }
        }
    }

    private fun generateReleaseNotes(directory: File, extension: ReleaseNotesExtension) {
        val outputFile = getReleaseNotesOutputFile(extension, directory)
        with(outputFile) {
            val script = Script(fileName = "generate_release_notes.sh", dependencies = listOf("utils.sh"))
            scriptRunner.run(directory, script, "-o", fileName)
            printResult()
            deleteIfRequired()
        }
    }

    private fun getReleaseNotesOutputFile(extension: ReleaseNotesExtension, dir: File) =
        extension.outputFileName
            ?.let { OutputFile(dir, it, false) }
            ?: OutputFile(dir, "${UUID.randomUUID()}-release-notes.txt", true)

    data class OutputFile(val directory: File, val fileName: String, val deleteAfterUse: Boolean) {

        fun printResult() {
            val file = File(directory, fileName)
            if (file.exists()) {
                println(file.readText(Charsets.UTF_8))
            }
        }

        fun deleteIfRequired() {
            if (deleteAfterUse) {
                val file = File(directory, fileName)
                if (file.exists()) {
                    file.delete()
                }
            }
        }
    }
}

open class ReleaseNotesExtension {
    var outputFileName: String? = null
}
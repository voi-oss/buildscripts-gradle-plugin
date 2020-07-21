package buildscripts

import org.gradle.api.GradleException
import org.slf4j.Logger
import java.io.File
import java.io.InputStream
import java.lang.ProcessBuilder.Redirect
import kotlin.concurrent.thread

data class Script(
    val fileName: String,
    val dependencies: List<String> = emptyList()
)

interface ScriptRunner {

    /**
     * Executes the script [script], from the given [directory], with given [options]
     *
     * - [directory] the file directory from which the script will be initiated
     * - [script] the script object
     * - [options] any extra flags or inputs needed for the script
     *
     * @throws IllegalStateException if the script cannot be found in the resources
     */
    fun run(directory: File, script: Script, vararg options: String)
}

/**
 * In order to make a script packaged inside a JAR become runnable, this script runner
 * makes a copy of the script file from the JAR resources into an external directory.
 *
 * The external directory is temporary and deleted after script execution.
 */
class JarScriptRunner(
    private val resourceLoader: ResourceLoader,
    private val logger: Logger
) : ScriptRunner {

    override fun run(directory: File, script: Script, vararg options: String) {
        val tempDir = createTempDir(directory = directory)
        script.dependencies.forEach { dependency -> copyScript(tempDir, dependency) }
        val scriptCopy = copyScript(tempDir, script.fileName)

        // Execute the script
        val execScript = scriptCopy.absolutePath
        val command = listOf(execScript) + options
        val process = ProcessBuilder(*command.toTypedArray())
            .directory(directory)
            .redirectErrorStream(true)
            .redirectOutput(Redirect.PIPE)
            .redirectError(Redirect.PIPE)
            .start()
        val outputThread = readOutputThread(process.inputStream)
        val exitCode = process.waitFor()
        outputThread.join()

        // Remove the temp folder from disk
        tempDir.deleteRecursively()

        if (exitCode != 0) throw GradleException("Failed with exit code: $exitCode")
    }

    private fun readOutputThread(inputStream: InputStream) =
        thread {
            val reader = inputStream.bufferedReader(Charsets.UTF_8)
            var line: String? = reader.readLine()
            while (line != null) {
                logger.info(line)
                line = reader.readLine()
            }
            reader.close()
        }

    private fun copyScript(dir: File, scriptName: String) = File(dir, scriptName)
        .apply { writeText(readScriptFile(scriptName)) }
        .also { dir.givePermissions(it, "+x") }

    private fun readScriptFile(scriptName: String) =
        resourceLoader.load(scriptName)
            .bufferedReader(Charsets.UTF_8)
            .use { it.readText() }
}

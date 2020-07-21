package buildscripts

import com.nhaarman.mockitokotlin2.anyOrNull
import com.nhaarman.mockitokotlin2.mock
import com.nhaarman.mockitokotlin2.verify
import org.gradle.api.GradleException
import org.junit.Test
import org.slf4j.Logger
import java.io.InputStream

class JarScriptRunnerTest {

    private val failureScript =
        """
        echo "test"
        exit 1
        """.trimIndent()

    private val successScript =
        """
        echo "test"
        exit 0
        """.trimIndent()

    private val testLogger: Logger = mock {
        on { info(anyOrNull()) }.then { println("INFO: ${it.getArgument<String?>(0)}") }
    }

    @Test(expected = GradleException::class)
    fun `run - forwards failure as gradle exception`() {
        val runner = JarScriptRunner(TestResourceLoader(failureScript), testLogger)
        runner.run(createTempDir(), Script("anyscript.sh"))
    }

    @Test
    fun `run - prints script output on logger`() {
        val runner = JarScriptRunner(TestResourceLoader(successScript), testLogger)
        runner.run(createTempDir(), Script("anyscript.sh"))
        verify(testLogger).info("test")
    }

    private class TestResourceLoader(val scriptString: String) : ResourceLoader {
        override fun load(resourceName: String): InputStream {
            return scriptString.byteInputStream(Charsets.UTF_8)
        }
    }
}

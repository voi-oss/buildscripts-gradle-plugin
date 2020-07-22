package buildscripts

import org.gradle.api.Project
import org.gradle.testfixtures.ProjectBuilder
import org.junit.Assert.*
import org.junit.Before
import org.junit.Test

class VoiBuildScriptsPluginTest {

    private lateinit var project: Project

    @Before
    fun setUp() {
        project = ProjectBuilder.builder().build()
        project.pluginManager.apply("io.voiapp.android.buildscripts")
    }
    @Test
    fun `generateReleaseNotes - plugin creates generateReleaseNotes task`() {
        assertNotNull(project.tasks.findByName("generateReleaseNotes"))
    }

    @Test
    fun `createReleaseBranch - plugin creates createReleaseBranch task`() {
        assertNotNull(project.tasks.findByName("createReleaseBranch"))
    }

    @Test
    fun `bumpMinorVersion - plugin creates bumpMinorVersion task`() {
        assertNotNull(project.tasks.findByName("bumpMinorVersion"))
    }

    @Test
    fun `updateTranslations - plugin creates updateTranslations task`() {
        assertNotNull(project.tasks.findByName("updateTranslations"))
    }
}
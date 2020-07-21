package buildscripts

import java.io.InputStream

interface ResourceLoader {
    fun load(resourceName: String): InputStream
}

class JarResourceLoader : ResourceLoader {

    override fun load(resourceName: String): InputStream =
        javaClass.classLoader.getResourceAsStream(resourceName)
            ?: throw IllegalArgumentException("Resource not found")

}
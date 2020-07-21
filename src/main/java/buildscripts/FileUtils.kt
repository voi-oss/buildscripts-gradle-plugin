package buildscripts

import java.io.File

fun File.givePermissions(childFile: File, permissionFlag: String) {
    check(this.isDirectory) { "givePermissions works only on directories" }
    ProcessBuilder("chmod", permissionFlag, childFile.absolutePath)
        .directory(this)
        .redirectOutput(ProcessBuilder.Redirect.INHERIT)
        .redirectError(ProcessBuilder.Redirect.INHERIT)
        .start()
        .waitFor()
}
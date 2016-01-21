package org.zikula.modulestudio.generator.application

import java.io.File
import org.zikula.modulestudio.generator.exceptions.DirectoryNotEmptyException
import org.zikula.modulestudio.generator.exceptions.ExceptionBase
import org.zikula.modulestudio.generator.exceptions.NoCartridgesSelected

/**
 * Pre processing providing convenience methods for single cartridges.
 */
class WorkflowPreProcess {
    WorkflowSettings settings

    def run(WorkflowSettings settings) throws ExceptionBase {
        this.settings = settings
        cartridgeTasks
        directoryTasks
    }

    def private cartridgeTasks() throws NoCartridgesSelected {
        if (settings.getSelectedCartridges.empty) {
            throw new NoCartridgesSelected
        }
    }

    def private directoryTasks() throws DirectoryNotEmptyException {
        val existingFiles = settings.getOutputDir.listFiles
        if (!existingFiles.empty) {
            throw new DirectoryNotEmptyException
        }
    }

    def emptyDestinationDirectory() {
        emptyDir(this.settings.getOutputDir)
    }

    def private Boolean emptyDir(File dir) {
        var hasErrors = false
        val files = dir.listFiles

        if (null === files) {
            return hasErrors
        }

        for (file : files) {
            if (file.isDirectory) {
                emptyDir(file)
            }
            if (!file.delete) {
                hasErrors = true
            }
        }

        hasErrors
    }
}

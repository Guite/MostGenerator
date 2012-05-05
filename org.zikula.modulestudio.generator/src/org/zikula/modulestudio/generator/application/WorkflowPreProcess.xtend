package org.zikula.modulestudio.generator.application

import java.io.File
import org.zikula.modulestudio.generator.exceptions.DirectoryNotEmptyException
import org.zikula.modulestudio.generator.exceptions.ExceptionBase
import org.zikula.modulestudio.generator.exceptions.NoCartridgesSelected

/**
 * Pre processing providing convenience methods for single cartridges.
 */
public class WorkflowPreProcess {
    WorkflowSettings settings

    def run(WorkflowSettings settings) throws ExceptionBase {
        this.settings = settings;
        cartridgeTasks
        directoryTasks
    }

    def private cartridgeTasks() throws NoCartridgesSelected {
        if (settings.selectedCartridges.size == 0) {
            throw new NoCartridgesSelected()
        }
    }

    def private directoryTasks() throws DirectoryNotEmptyException {
        val existingFiles = settings.outputDir.listFiles
        if (existingFiles.size > 0) {
            throw new DirectoryNotEmptyException()
        }
    }

    def emptyDestinationDirectory() {
        emptyDir(this.settings.outputDir)
    }

    def private emptyDir(File dir) {
        val files = dir.listFiles
        if (files != null) {
            for (file : files) {
                if (file.isDirectory) {
                    emptyDir(file)
                    file.delete
                } else {
                    file.delete
                }
            }
        }
    }
}

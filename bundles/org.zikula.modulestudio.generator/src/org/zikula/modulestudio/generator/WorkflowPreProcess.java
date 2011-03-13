package org.zikula.modulestudio.generator;

import java.io.File;

import org.zikula.modulestudio.generator.exceptions.DirectoryNotEmptyException;
import org.zikula.modulestudio.generator.exceptions.ExceptionBase;
import org.zikula.modulestudio.generator.exceptions.NoCartridgesSelected;

public class WorkflowPreProcess {
    WorkflowSettings settings;

    public void run(WorkflowSettings settings) throws ExceptionBase {
        this.settings = settings;
        this._cartridgeTasks();
        this._directoryTasks();
    }

    private void _cartridgeTasks() throws NoCartridgesSelected {
        if (this.settings.selectedCartridges.length == 0) {
            throw new NoCartridgesSelected();
        }
    }

    private void _directoryTasks() throws DirectoryNotEmptyException {
        final File[] existingFiles = this.settings.outputDir.listFiles();
        if (existingFiles.length > 0) {
            throw new DirectoryNotEmptyException();
        }
    }

    public void emptyDestinationDirectory() {

        this._emptyDir(this.settings.outputDir);

    }

    private void _emptyDir(File dir) {
        final File[] files = dir.listFiles();
        if (files != null) {
            for (final File file : files) {
                if (file.isDirectory()) {
                    this._emptyDir(file);
                    file.delete();
                }
                else {
                    file.delete();
                }
            }
        }
    }
}

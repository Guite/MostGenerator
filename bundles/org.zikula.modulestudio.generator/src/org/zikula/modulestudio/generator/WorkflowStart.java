package org.zikula.modulestudio.generator;

import org.eclipse.core.runtime.CoreException;
import org.zikula.modulestudio.generator.application.ModuleStudioBeautifier;
import org.zikula.modulestudio.generator.exceptions.ExceptionBase;

/** TODO: javadocs needed for class, members and methods */
public class WorkflowStart {

    public WorkflowSettings settings = new WorkflowSettings();
    public WorkflowPreProcess preProcess = new WorkflowPreProcess();

    public void run() throws ExceptionBase {
        final WorkflowM2T M2T = new WorkflowM2T(this.settings);
        M2T.run();

        if (this.settings.selectedCartridges.contains("zclassic")) {
            final WorkflowZClassic zClassic = new WorkflowZClassic(
                    this.settings);
            zClassic.run();
        }

        if (this.settings.selectedCartridges.contains("reporting")) {
            final WorkflowReporting reporting = new WorkflowReporting(
                    this.settings);
            reporting.run();
        }

    }

    public void runBeautifier() throws CoreException {
        // now apply the beautifier
        final ModuleStudioBeautifier msBeautifier = new ModuleStudioBeautifier(
                this.settings.outputPath);
        final Integer processedFiles = msBeautifier.start();
    }
}

package org.zikula.modulestudio.generator;

import org.eclipse.core.runtime.CoreException;
import org.zikula.modulestudio.generator.application.ModuleStudioBeautifier;
import org.zikula.modulestudio.generator.exceptions.ExceptionBase;

public class WorkflowStart {

    public WorkflowSettings settings = new WorkflowSettings();
    public WorkflowPreProcess preProcess = new WorkflowPreProcess();

    public void run() throws ExceptionBase {
        final WorkflowM2T M2T = new WorkflowM2T(this.settings);
        M2T.run();

        for (final java.lang.Object object : this.settings.selectedCartridges) {
            if (object.toString() == "zclassic") {
                final WorkflowZClassic zClassic = new WorkflowZClassic(
                        this.settings);
                zClassic.run();
            }
            else if (object.toString() == "reporting") {
                final WorkflowDiagramExporter diagramExporter = new WorkflowDiagramExporter(
                        this.settings);
                diagramExporter.run();
                final WorkflowReporting reporting = new WorkflowReporting(
                        this.settings);
                reporting.run();
            }
        }

    }

    public void runBeautifier() throws CoreException {
        // now apply the beautifier
        final ModuleStudioBeautifier msBeautifier = new ModuleStudioBeautifier(
                this.settings.outputPath);
        final Integer processedFiles = msBeautifier.start();
    }
}

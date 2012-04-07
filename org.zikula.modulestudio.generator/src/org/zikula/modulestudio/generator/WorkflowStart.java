package org.zikula.modulestudio.generator;

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
}

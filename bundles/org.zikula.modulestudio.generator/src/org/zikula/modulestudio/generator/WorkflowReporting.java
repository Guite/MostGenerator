package org.zikula.modulestudio.generator;

import java.io.File;

import org.eclipse.core.runtime.FileLocator;
import org.eclipse.core.runtime.Path;
import org.eclipse.core.runtime.Platform;
import org.osgi.framework.Bundle;
import org.zikula.modulestudio.generator.application.Activator;
import org.zikula.modulestudio.generator.output.ReportingFacade;

/** TODO: javadocs needed for class, members and methods */
public class WorkflowReporting {
    WorkflowSettings settings;

    public WorkflowReporting(WorkflowSettings settings) {
        this.settings = settings;
    }

    public void run() {
        try {
            final Bundle bundle = Platform.getBundle(Activator.PLUGIN_ID);
            final java.net.URL[] resources = FileLocator.findEntries(bundle,
                    new Path(this.settings.reportPath));

            final File dir = new File(FileLocator.toFileURL(resources[0])
                    .toURI());

            final ReportingFacade reportingFacade = new ReportingFacade();
            reportingFacade.setOutputPath(this.settings.outputPath
                    + "/reporting/");
            reportingFacade.setModelPath(this.settings.modelPath);
            reportingFacade.setUp();
            for (final Object report : this.settings.selectedReports) {
                settings.progressMonitor.subTask("Reporting: "
                        + report.toString());
                reportingFacade
                        .startExport(dir.toString() + "/" + report.toString()
                                + ".rptdesign", report.toString() + ".pdf");
                settings.progressMonitor.subTask("");
            }

            reportingFacade.shutDown();
        } catch (final Exception e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
    }
}

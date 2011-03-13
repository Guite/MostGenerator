package org.zikula.modulestudio.generator;

import java.io.File;

import org.eclipse.core.runtime.FileLocator;
import org.eclipse.core.runtime.Path;
import org.eclipse.core.runtime.Platform;
import org.osgi.framework.Bundle;
import org.zikula.modulestudio.generator.application.Activator;
import org.zikula.modulestudio.generator.output.ReportingFacade;

public class WorkflowReporting {
    WorkflowSettings settings;

    public WorkflowReporting(WorkflowSettings settings) {
        this.settings = settings;
    }

    public void run() {
        try {

            final Bundle bundle = Platform.getBundle(Activator.PLUGIN_ID);
            final java.net.URL[] resources = FileLocator.findEntries(bundle,
                    new Path("/src/templates/reporting/reports"));

            final File dir = new File(FileLocator.toFileURL(resources[0])
                    .toURI());

            final String test = "platform:/plugin/org.zikula.modulestudio.generator/templates/reporting/reports";

            final ReportingFacade reportingFacade = new ReportingFacade();
            reportingFacade.setOutputPath(this.settings.outputPath);
            reportingFacade.setUp();
            reportingFacade.startExport(dir.toString()
                    + "/dokumentation.rptdesign", "dokumentation.pdf");
            reportingFacade.shutDown();

        } catch (final Exception e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
    }

}

package org.zikula.modulestudio.generator.cartridges.reporting

import java.io.File
import org.eclipse.core.runtime.FileLocator
import org.eclipse.core.runtime.Path
import org.eclipse.core.runtime.Platform

/**
 * Report-related utility methods.
 */
class ReportingServices {
    /**
     * Collects and returns the available reports.
     *
     * @param reportPath The report directory.
     * @return List of found reports.
     * @throws Exception
     *             In case something goes wrong.
     */
    def static collectAvailableReports(String reportPath) throws Exception {
        var resources = FileLocator.findEntries(
                Platform.getBundle(Activator.PLUGIN_ID), new Path('/src' //$NON-NLS-1$
                        + reportPath))
        val resourcesExported = FileLocator.findEntries(
                Platform.getBundle(Activator.PLUGIN_ID), new Path(reportPath))
        if (resources.empty) {
            resources = resourcesExported
        }

        if (resources.empty) {
            throw new Exception('Could not find report directory.')
        }

        var reports = newArrayList
        val reportDir = new File(FileLocator.toFileURL(resources.head).toURI)
        for (file : reportDir.list(new ReportFilenameFilter)) {
            reports += file.replace('.rptdesign', '') //$NON-NLS-1$ //$NON-NLS-2$
        }

        reports
    }   
}

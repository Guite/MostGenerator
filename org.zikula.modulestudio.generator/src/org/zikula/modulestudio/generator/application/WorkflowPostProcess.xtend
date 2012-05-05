package org.zikula.modulestudio.generator.application

import java.io.File
import java.io.IOException
import org.eclipse.core.runtime.FileLocator
import org.eclipse.core.runtime.Path
import org.eclipse.core.runtime.Platform
import org.eclipse.emf.mwe.utils.FileCopy
import org.zikula.modulestudio.generator.application.Activator
import org.zikula.modulestudio.generator.cartridges.reporting.ReportingFacade

/**
 * Workflow post processing for copying the admin image (zclassic) and
 * exporting the report files (reporting).
 */
class WorkflowPostProcess {
    WorkflowSettings settings

    new(WorkflowSettings settings) {
        this.settings = settings
    }

    /**
     * Executes the workflow.
     */
    def run() {
        if (settings.selectedCartridges.contains('zclassic')) {
        	copyAdminImage
        }

        if (settings.selectedCartridges.contains('reporting')) {
        	exportBirtReports
        }
    }

    /**
     * Copies the admin image for zclassic cartridge.
     */
    def private copyAdminImage() {
        val fileCopy = new FileCopy()
        val bundle = Platform::getBundle(Activator::PLUGIN_ID)
        var resources = FileLocator::findEntries(bundle, new Path('/src/resources/images/MOST_48.png'))
        val resourcesExported = FileLocator::findEntries(bundle, new Path(/* 'src' + */'/resources/images/MOST_48.png'))
        if (resources.size == 0) {
            resources = resourcesExported
        }
        if (resources.size > 0) {
            try {
                val url = resources.head
                val fileUrl = FileLocator::toFileURL(url)
                val file = new File(fileUrl.getPath)
                fileCopy.sourceFile = file.absolutePath
                fileCopy.targetFile = settings.outputPath + '/zclassic/'
                                    + settings.app.name + '/src/modules/'
                                    + settings.app.name + '/images/admin.png'
                fileCopy.invoke(null)
            } catch (IOException e) {
                // TODO Auto-generated catch block
                e.printStackTrace
            }
        }
    }

    /**
     * Exports the BIRT reports for reporting cartridge.
     */
    def private exportBirtReports() {
        try {
            val bundle = Platform::getBundle(Activator::PLUGIN_ID)
            val resources = FileLocator::findEntries(bundle, new Path(settings.reportPath))

            val dir = new File(FileLocator::toFileURL(resources.head).toURI)

            val reportingFacade = new ReportingFacade()
            reportingFacade.outputPath = settings.outputPath
            reportingFacade.modelPath = settings.modelPath
            reportingFacade.setUp
            for (report : settings.selectedReports) {
                settings.progressMonitor.subTask('Reporting: ' + report.toString)
                reportingFacade.startExport(dir.toString + '/' + report.toString + '.rptdesign', report.toString + '.pdf')
                settings.progressMonitor.subTask('')
            }
            reportingFacade.shutDown
        } catch (Exception e) {
            // TODO Auto-generated catch block
            e.printStackTrace
        }
    }
}

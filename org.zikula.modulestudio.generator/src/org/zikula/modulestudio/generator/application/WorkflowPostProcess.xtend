package org.zikula.modulestudio.generator.application

import java.io.File
import java.io.IOException
import org.eclipse.core.runtime.FileLocator
import org.eclipse.core.runtime.Path
import org.eclipse.core.runtime.Platform
import org.eclipse.emf.mwe.utils.FileCopy
import org.zikula.modulestudio.generator.cartridges.reporting.ReportingFacade
import org.zikula.modulestudio.generator.workflow.components.ModelFileCopier

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
        copyModelFiles
        if (settings.getSelectedCartridges.contains('zclassic')) { //$NON-NLS-1$
            copyAdminImage
        }

        if (settings.getSelectedCartridges.contains('reporting')) { //$NON-NLS-1$
            exportBirtReports
        }
    }

    /**
     * Copies the model files into the output folder.
     */
    def private copyModelFiles() {
        val srcPath = settings.modelPath.replaceFirst('file:', '') //$NON-NLS-1$ //$NON-NLS-2$
        val modelFileName = new File(srcPath).name
        val copier = new ModelFileCopier => [
            sourceModelFile = srcPath
            targetModelFile = settings.modelDestinationPath + modelFileName
            sourceModelFileEnriched = srcPath.replace('.mostapp', '_enriched.mostapp') //$NON-NLS-1$ //$NON-NLS-2$
            targetModelFileEnriched = settings.modelDestinationPath + modelFileName.replace('.mostapp', '_enriched.mostapp') //$NON-NLS-1$ //$NON-NLS-2$
            sourceDiagramFile = srcPath.replace('.mostapp', '.mostdiagram') //$NON-NLS-1$ //$NON-NLS-2$
            targetDiagramFile = settings.modelDestinationPath + modelFileName.replace('.mostapp', '.mostdiagram') //$NON-NLS-1$ //$NON-NLS-2$
        ]
        copier.invoke
    }

    /**
     * Copies the admin image for zclassic cartridge.
     */
    def private copyAdminImage() {
        val fileCopy = new FileCopy
        val bundle = Platform.getBundle(Activator.PLUGIN_ID)
        var resources = FileLocator.findEntries(bundle, new Path('/src/resources/images/MOST_48.png')) //$NON-NLS-1$
        val resourcesExported = FileLocator.findEntries(bundle, new Path('/resources/images/MOST_48.png')) //$NON-NLS-1$
        if (resources.empty) {
            resources = resourcesExported
        }
        if (!resources.empty) {
            try {
                val url = resources.head
                val fileUrl = FileLocator.toFileURL(url)
                val file = new File(fileUrl.getPath)
                fileCopy.sourceFile = file.absolutePath

                val targetBasePath = settings.outputPath + File.separator + 'zclassic' + File.separator + settings.appName.toFirstUpper + File.separator //$NON-NLS-1$
                var imageFolder = 'Resources' + File.separator + 'public' + File.separator + 'images' //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$
                var targetFolder = new File(targetBasePath + imageFolder)
                if (!targetFolder.exists) {
                    // BC support for 1.3.x
                    imageFolder = 'src' + File.separator + 'modules' + File.separator + settings.appName.toFirstUpper + File.separator + 'images' //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$
                    targetFolder = new File(targetBasePath + imageFolder)
                }
                if (targetFolder.exists) {
                    fileCopy.targetFile = targetBasePath + imageFolder + File.separator + 'admin.png' //$NON-NLS-1$
                    fileCopy.invoke(null)
                }
            } catch (IOException e) {
                // TODO Auto-generated catch block
                e.printStackTrace
            }
        }
    }

    /**
     * Exports the BIRT reports for reporting cartridge.
     */
    def private void exportBirtReports() {
        try {
            val reportingBundle = Platform.getBundle(org.zikula.modulestudio.generator.cartridges.reporting.Activator.PLUGIN_ID)
            var resources = FileLocator.findEntries(reportingBundle, new Path(settings.getReportPath))
            val resourcesExported = FileLocator.findEntries(reportingBundle, new Path('src/' + settings.getReportPath)) //$NON-NLS-1$
            if (resources.size < 1) {
                resources = resourcesExported
            }
            var File dir = new File(FileLocator.toFileURL(resources.head).toURI)

            val reportingFacade = new ReportingFacade
            reportingFacade.outputPath = settings.getOutputPath
            reportingFacade.modelPath = settings.getModelPath.replaceFirst('file:', '') //$NON-NLS-1$ //$NON-NLS-2$
            reportingFacade.setUp
            for (report : settings.getSelectedReports) {
                settings.getProgressMonitor.subTask('Reporting: ' + report.toString) //$NON-NLS-1$
                reportingFacade.startExport(dir.toString + File.separator + report.toString + '.rptdesign', report.toString) //$NON-NLS-1$
                settings.getProgressMonitor.subTask('')
            }
            reportingFacade.shutDown
        } catch (Exception e) {
            // TODO Auto-generated catch block
            e.printStackTrace
        }
    }
}

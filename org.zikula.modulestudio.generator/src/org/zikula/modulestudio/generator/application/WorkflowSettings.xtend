package org.zikula.modulestudio.generator.application

import java.io.File
import java.util.ArrayList
import org.eclipse.core.runtime.IProgressMonitor
import org.eclipse.core.runtime.IStatus
import org.eclipse.xtend.lib.annotations.Accessors
import org.zikula.modulestudio.generator.cartridges.reporting.ReportingServices

/**
 * This class collects required workflow properties.
 */
class WorkflowSettings {

    /**
     * List of available cartridges.
     */
    @Accessors(PUBLIC_GETTER)
    ArrayList<String> availableCartridges = new ArrayList<String>

    /**
     * List of selected cartridges.
     */
    @Accessors(PUBLIC_GETTER)
    ArrayList<Object> selectedCartridges = new ArrayList<Object>

    /**
     * The output path.
     */
    @Accessors(PUBLIC_GETTER)
    String outputPath = null

    /**
     * File handle for output directory.
     */
    @Accessors(PUBLIC_GETTER)
    File outputDir = null

    /**
     * The model path.
     */
    @Accessors
    String modelPath = null

    /**
     * The destination path for copying the model.
     */
    @Accessors
    String modelDestinationPath = null

    /**
     * Name of the vendor of the application instance described by the model.
     */
    @Accessors
    String appVendor = ''

    /**
     * Name of the application instance described by the model.
     */
    @Accessors
    String appName = ''

    /**
     * Version of the application instance described by the model.
     */
    @Accessors
    String appVersion = ''

    /**
     * The progress monitor.
     */
    @Accessors
    IProgressMonitor progressMonitor = null

    /**
     * List of available reports.
     */
    @Accessors(PUBLIC_GETTER)
    ArrayList<String> availableReports = new ArrayList<String>

    /**
     * List of selected reports.
     */
    @Accessors
    Object[] selectedReports = null

    /**
     * Path containing the report files.
     */
    @Accessors
    String reportPath = '/org/zikula/modulestudio/generator/cartridges/reporting/reports' //$NON-NLS-1$

    /**
     * The constructor.
     */
    new() {
        availableCartridges += 'zclassic' //$NON-NLS-1$
        availableCartridges += 'reporting' //$NON-NLS-1$
        selectedCartridges += 'zclassic' //$NON-NLS-1$
        selectedCartridges += 'reporting' //$NON-NLS-1$

        try {
            collectAvailableReports
        } catch (Exception e) {
            ModuleStudioGeneratorActivator.log(IStatus.ERROR, e.toString, e)
        }
    }

    /**
     * Collect available reports.
     * 
     * @throws Exception
     *             In case something goes wrong.
     */
    def private final collectAvailableReports() throws Exception {
        availableReports = ReportingServices.collectAvailableReports(reportPath)
    }

    /**
     * Sets the output path.
     * 
     * @param path
     *            The given path string.
     */
    def setOutputPath(String path) {
        outputPath = path
        outputDir = new File(path)
    }

    /**
     * Sets the list of selected cartridges.
     * 
     * @param objects
     *            The given cartridge list.
     */
    def setSelectedCartridges(Object[] objects) {
        selectedCartridges.clear
        for (cartridge : objects) {
            selectedCartridges.add(cartridge)
        }
    }
}

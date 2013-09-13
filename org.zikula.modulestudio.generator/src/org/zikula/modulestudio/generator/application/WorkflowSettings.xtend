package org.zikula.modulestudio.generator.application

import java.io.File
import java.io.IOException
import java.net.URISyntaxException
import java.util.ArrayList
import org.eclipse.core.runtime.FileLocator
import org.eclipse.core.runtime.IProgressMonitor
import org.eclipse.core.runtime.Path
import org.eclipse.core.runtime.Platform
import org.eclipse.gmf.runtime.diagram.core.preferences.PreferencesHint
import org.eclipse.gmf.runtime.notation.Diagram
import org.zikula.modulestudio.generator.cartridges.reporting.ReportFilenameFilter

/**
 * This class collects required workflow properties.
 */
class WorkflowSettings {

    /**
     * List of available cartridges.
     */
    ArrayList<String> availableCartridges = new ArrayList<String>

    /**
     * List of selected cartridges.
     */
    ArrayList<Object> selectedCartridges = new ArrayList<Object>

    /**
     * The output path.
     */
    String outputPath = null

    /**
     * File handle for output directory.
     */
    File outputDir = null

    /**
     * The model path.
     */
    @Property
    String modelPath = null

    /**
     * Reference to current diagram.
     */
    @Property
    Diagram diagram = null

    /**
     * Name of the vendor of the application instance described by the model.
     */
    @Property
    String appVendor = ''

    /**
     * Name of the application instance described by the model.
     */
    @Property
    String appName = ''

    /**
     * Version of the application instance described by the model.
     */
    @Property
    String appVersion = ''

    /**
     * Preference hint for reporting.
     */
    @Property
    PreferencesHint diagramPreferencesHint = null

    /**
     * The progress monitor.
     */
    @Property
    IProgressMonitor progressMonitor = null

    /**
     * List of available reports.
     */
    ArrayList<String> availableReports = new ArrayList<String>

    /**
     * List of selected reports.
     */
    @Property
    Object[] selectedReports = null

    /**
     * Path containing the report files.
     */
    @Property
    String reportPath = '/org/zikula/modulestudio/generator/cartridges/reporting/reports' //$NON-NLS-1$

    /**
     * The constructor.
     */
    new() {
        availableCartridges.add('zclassic') //$NON-NLS-1$
        availableCartridges.add('reporting') //$NON-NLS-1$
        selectedCartridges.add('zclassic') //$NON-NLS-1$
        selectedCartridges.add('reporting') //$NON-NLS-1$

        try {
            collectAvailableReports
        } catch (Exception exc) {
            // TODO Auto-generated catch block
            exc.printStackTrace
        }
    }

    /**
     * Collect available reports.
     * 
     * @throws Exception
     *             In case something goes wrong.
     */
    def private collectAvailableReports() throws Exception {
        var resources = FileLocator.findEntries(
                Platform.getBundle(Activator.PLUGIN_ID), new Path('/src' //$NON-NLS-1$
                        + reportPath))
        val resourcesExported = FileLocator.findEntries(
                Platform.getBundle(Activator.PLUGIN_ID), new Path(reportPath))
        if (resources.size == 0) {
            resources = resourcesExported
        }

        if (resources.size == 0) {
            throw new Exception('Could not find report directory.')
        }

        try {
            val reportDir = new File(FileLocator.toFileURL(resources.head).toURI)
            for (file : reportDir.list(new ReportFilenameFilter)) {
                availableReports.add(file.replace('.rptdesign', '')) //$NON-NLS-1$ //$NON-NLS-2$
            }

        } catch (URISyntaxException e) {
            // TODO Auto-generated catch block
            e.printStackTrace
        } catch (IOException e) {
            // TODO Auto-generated catch block
            e.printStackTrace
        }
    }

    /**
     * Returns the list of available cartridges.
     * 
     * @return Cartridge list.
     */
    def getAvailableCartridges() {
        availableCartridges
    }

    /**
     * Returns the list of selected cartridges.
     * 
     * @return Cartridge list.
     */
    def getSelectedCartridges() {
        selectedCartridges
    }

    /**
     * Returns the list of available reports.
     * 
     * @return Report list.
     */
    def getAvailableReports() {
        availableReports
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

    /**
     * Returns the output directory.
     * 
     * @return the outputDir
     */
    def getOutputDir() {
        outputDir
    }

    /**
     * Returns the output path.
     * 
     * @return the outputPath
     */
    def getOutputPath() {
        outputPath
    }
}

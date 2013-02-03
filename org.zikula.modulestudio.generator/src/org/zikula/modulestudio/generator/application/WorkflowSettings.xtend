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
public class WorkflowSettings {

    /**
     * List of available cartridges.
     */
    ArrayList<String> availableCartridges = new ArrayList<String>()

    /**
     * List of selected cartridges.
     */
    ArrayList<Object> selectedCartridges = new ArrayList<Object>()

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
    String modelPath = null

    /**
     * Reference to current diagram.
     */
    Diagram diagram = null

    /**
     * Name of the application instance described by the model.
     */
    String appName = ''

    /**
     * Version of the application instance described by the model.
     */
    String appVersion = ''

    /**
     * Preference hint for reporting.
     */
    PreferencesHint diagramPreferencesHint = null

    /**
     * The progress monitor.
     */
    IProgressMonitor progressMonitor = null

    /**
     * List of available reports.
     */
    ArrayList<String> availableReports = new ArrayList<String>()

    /**
     * List of selected reports.
     */
    Object[] selectedReports = null

    /**
     * Path containing the report files.
     */
    String reportPath = '/org/zikula/modulestudio/generator/cartridges/reporting/reports'; //$NON-NLS-1$

    /**
     * The constructor.
     * 
     * @throws Exception
     *             In case something goes wrong.
     */
    new() throws Exception {
        availableCartridges.add('zclassic') //$NON-NLS-1$
        availableCartridges.add('reporting') //$NON-NLS-1$
        selectedCartridges.add('zclassic') //$NON-NLS-1$
        selectedCartridges.add('reporting') //$NON-NLS-1$

        collectAvailableReports
    }

    /**
     * Collect available reports.
     * 
     * @throws Exception
     *             In case something goes wrong.
     */
    def private collectAvailableReports() throws Exception {
        var resources = FileLocator::findEntries(
                Platform::getBundle(Activator::PLUGIN_ID), new Path('/src' //$NON-NLS-1$
                        + reportPath))
        val resourcesExported = FileLocator::findEntries(
                Platform::getBundle(Activator::PLUGIN_ID), new Path(reportPath))
        if (resources.size == 0) {
            resources = resourcesExported
        }

        if (resources.size == 0) {
            throw new Exception('Could not find report directory.')
        }

        try {
            val reportDir = new File(FileLocator::toFileURL(resources.head).toURI)
            for (file : reportDir.list(new ReportFilenameFilter())) {
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
     * Returns the progress monitor.
     * 
     * @return {@link IProgressMonitor} The progress monitor instance.
     */
    def getProgressMonitor() {
        progressMonitor
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
     * Sets the application name.
     * 
     * @param name
     *            The given name.
     */
    def setAppName(String name) {
        appName = name
    }

    /**
     * Sets the application version.
     * 
     * @param version
     *            The given version.
     */
    def setAppVersion(String version) {
        appVersion = version
    }

    /**
     * Sets the diagram instance.
     * 
     * @param d
     *            The given diagram.
     */
    def setDiagram(Diagram d) {
        diagram = d
    }

    /**
     * Sets the diagram preferences hint for reporting.
     * 
     * @param hint
     *            The given diagram preferences hint.
     */
    def setDiagramPreferencesHint(PreferencesHint hint) {
        diagramPreferencesHint = hint
    }

    /**
     * Sets the progress monitor.
     * 
     * @param monitor
     *            The given progress monitor instance.
     */
    def setProgressMonitor(IProgressMonitor monitor) {
        progressMonitor = monitor
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
     * Sets the model path.
     * 
     * @param path
     *            The given path string.
     */
    def setModelPath(String path) {
        modelPath = path
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
     * Sets the list of selected reports.
     * 
     * @param reports
     *            The given report list.
     */
    def setSelectedReports(Object[] reports) {
        selectedReports = reports
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
     * Returns the report path.
     * 
     * @return the reportPath
     */
    def getReportPath() {
        reportPath
    }

    /**
     * Returns the output path.
     * 
     * @return the outputPath
     */
    def getOutputPath() {
        outputPath
    }

    /**
     * Returns the model path.
     * 
     * @return the modelPath
     */
    def getModelPath() {
        modelPath
    }

    /**
     * Returns the diagram reference.
     * 
     * @return the diagram
     */
    def getDiagram() {
        diagram
    }

    /**
     * Returns the application name.
     * 
     * @return the name
     */
    def getAppName() {
        appName
    }

    /**
     * Returns the application version.
     * 
     * @return the version
     */
    def getAppVersion() {
        appVersion
    }

    /**
     * Returns the diagram preferences hint for reporting.
     * 
     * @return the diagramPreferencesHint
     */
    def getDiagramPreferencesHint() {
        diagramPreferencesHint
    }

    /**
     * Returns the list of selected reports.
     * 
     * @return the report list
     */
    def getSelectedReports() {
        selectedReports
    }
}

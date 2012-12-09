package org.zikula.modulestudio.generator.application

import de.guite.modulestudio.metamodel.modulestudio.Application
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
     * The application instance described by the model.
     */
    Application app = null

    /**
     * Preference hint.
     */
    PreferencesHint diagramPreferencesHint = null

    /**
     * The progress monitor.
     */
    IProgressMonitor progressMonitor = null

    /**
     * File handle for report directory.
     */
    File reportDir = null

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
        availableCartridges.add('zoo') //$NON-NLS-1$
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
            reportDir = new File(FileLocator::toFileURL(resources.head).toURI)

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
     * Sets the application instance.
     * 
     * @param application
     *            The given application.
     */
    def setApp(Application application) {
        app = application
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
     * Sets the diagram preferences hint.
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
     * Sets the output directory.
     * 
     * @param dir
     *            the given value.
     * /
    public void setOutputDir(File dir) {
        this.outputDir = dir;
    }

    /**
     * Returns the report directory.
     * 
     * @return the reportDir
     * /
    public File getReportDir() {
        return this.reportDir;
    }

    /**
     * Sets the report directory.
     *
     * @param dir
     *            the reportDir to set
     * /
    public void setReportDir(File dir) {
        this.reportDir = dir;
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
     * Sets the report path.
     *
     * @param path
     *            the reportPath to set
     * /
    public void setReportPath(String path) {
        this.reportPath = path;
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
     * Returns the application instance.
     * 
     * @return the application
     */
    def getApp() {
        app
    }

    /**
     * Returns the diagram preferences hint.
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

    /**
     * Sets the list of available cartridges.
     * 
     * @param cartridges
     *            the given list.
     * /
    public void setAvailableCartridges(ArrayList<String> cartridges) {
        this.availableCartridges = cartridges;
    }

    /**
     * Sets the list of selected cartridges.
     * 
     * @param cartridges
     *            the given list.
     * /
    public void setSelectedCartridges(ArrayList<Object> cartridges) {
        this.selectedCartridges = cartridges;
    }

    /**
     * Sets the list of available reports.
     * 
     * @param reports
     *            the given list.
     * /
    public void setAvailableReports(ArrayList<String> reports) {
        this.availableReports = reports;
    }*/
}

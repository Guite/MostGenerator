package org.zikula.modulestudio.generator.application;

import java.io.File;
import java.io.FilenameFilter;
import java.io.IOException;
import java.net.URISyntaxException;
import java.util.ArrayList;

import org.eclipse.core.runtime.FileLocator;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.core.runtime.Path;
import org.eclipse.core.runtime.Platform;
import org.eclipse.gmf.runtime.diagram.core.preferences.PreferencesHint;
import org.eclipse.gmf.runtime.notation.Diagram;
import org.eclipse.ui.IWorkbench;
import org.eclipse.ui.IWorkbenchWindow;

import de.guite.modulestudio.metamodel.modulestudio.Application;

/**
 * This class collects required workflow properties.
 */
public class WorkflowSettings {

    /**
     * List of available cartridges.
     */
    private ArrayList<String> availableCartridges = new ArrayList<String>();

    /**
     * List of selected cartridges.
     */
    private ArrayList<Object> selectedCartridges = new ArrayList<Object>();

    /**
     * The output path.
     */
    private String outputPath = null;

    /**
     * File handle for output directory.
     */
    private File outputDir = null;

    /**
     * The model path.
     */
    private String modelPath = null;

    /**
     * Reference to current diagram.
     */
    private Diagram diagram = null;

    /**
     * The application instance described by the model.
     */
    private Application app = null;

    /**
     * Preference hint.
     */
    private PreferencesHint diagramPreferencesHint = null;

    /**
     * The progress monitor.
     */
    private IProgressMonitor progressMonitor = null;

    /**
     * File handle for report directory.
     */
    private File reportDir = null;

    /**
     * List of available reports.
     */
    private ArrayList<String> availableReports = new ArrayList<String>();

    /**
     * List of selected reports.
     */
    private Object[] selectedReports = null;

    /**
     * The workbench window reference.
     */
    private IWorkbenchWindow workbenchWindow = null;

    /**
     * The workbench reference.
     */
    private IWorkbench workbench = null;

    /**
     * Path containing the report files.
     */
    private String reportPath = "/org/zikula/modulestudio/generator/cartridges/reporting/reports"; //$NON-NLS-1$

    /**
     * The constructor.
     * 
     * @throws Exception
     *             In case something goes wrong.
     */
    public WorkflowSettings() throws Exception {
        this.availableCartridges.add("zclassic"); //$NON-NLS-1$
        this.availableCartridges.add("zoo"); //$NON-NLS-1$
        this.availableCartridges.add("reporting"); //$NON-NLS-1$
        this.selectedCartridges.add("zclassic"); //$NON-NLS-1$
        this.selectedCartridges.add("reporting"); //$NON-NLS-1$

        collectAvailableReports();
    }

    /**
     * Collect available reports.
     * 
     * @throws Exception
     *             In case something goes wrong.
     */
    private void collectAvailableReports() throws Exception {
        java.net.URL[] resources = FileLocator.findEntries(
                Platform.getBundle(Activator.PLUGIN_ID), new Path("/src" //$NON-NLS-1$
                        + this.reportPath));
        final java.net.URL[] resourcesExported = FileLocator.findEntries(
                Platform.getBundle(Activator.PLUGIN_ID), new Path(
                        this.reportPath));
        if (resources.length == 0) {
            resources = resourcesExported;
        }

        if (resources.length == 0) {
            throw new Exception("Could not find report directory.");
        }

        try {
            this.reportDir = new File(FileLocator.toFileURL(resources[0])
                    .toURI());

            for (final String file : this.reportDir.list(new FilenameFilter() {

                @Override
                public boolean accept(File dir, String name) {
                    if (name.contains(".rptdesign")) { //$NON-NLS-1$
                        return true;
                    }
                    return false;
                }
            })) {
                this.availableReports.add(file.replace(".rptdesign", "")); //$NON-NLS-1$ //$NON-NLS-2$
            }

        } catch (final URISyntaxException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        } catch (final IOException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
    }

    /**
     * Returns the workbench window.
     * 
     * @return {@link IWorkbenchWindow} The workbench window instance.
     */
    public IWorkbenchWindow getWorkbenchWindow() {
        return this.workbenchWindow;
    }

    /**
     * Sets the workbench window.
     * 
     * @param window
     *            The workbench window instance.
     */
    public void setWorkbenchWindow(IWorkbenchWindow window) {
        this.workbenchWindow = window;
    }

    /**
     * Returns the workbench.
     * 
     * @return {@link IWorkbench} The workbench instance.
     */
    public IWorkbench getWorkbench() {
        return this.workbench;
    }

    /**
     * Sets the workbench.
     * 
     * @param w
     *            The workbench instance.
     */
    public void setWorkbench(IWorkbench w) {
        this.workbench = w;
    }

    /**
     * Returns the progress monitor.
     * 
     * @return {@link IProgressMonitor} The progress monitor instance.
     */
    public IProgressMonitor getProgressMonitor() {
        return this.progressMonitor;
    }

    /**
     * Returns the list of available cartridges.
     * 
     * @return Cartridge list.
     */
    public ArrayList<String> getAvailableCartridges() {
        return this.availableCartridges;
    }

    /**
     * Returns the list of selected cartridges.
     * 
     * @return Cartridge list.
     */
    public ArrayList<Object> getSelectedCartridges() {
        return this.selectedCartridges;
    }

    /**
     * Returns the list of available reports.
     * 
     * @return Report list.
     */
    public ArrayList<String> getAvailableReports() {
        return this.availableReports;
    }

    /**
     * Sets the application instance.
     * 
     * @param application
     *            The given application.
     */
    public void setApp(Application application) {
        this.app = application;
    }

    /**
     * Sets the diagram instance.
     * 
     * @param d
     *            The given diagram.
     */
    public void setDiagram(Diagram d) {
        this.diagram = d;
    }

    /**
     * Sets the diagram preferences hint.
     * 
     * @param hint
     *            The given diagram preferences hint.
     */
    public void setDiagramPreferencesHint(PreferencesHint hint) {
        this.diagramPreferencesHint = hint;
    }

    /**
     * Sets the progress monitor.
     * 
     * @param monitor
     *            The given progress monitor instance.
     */
    public void setProgressMonitor(IProgressMonitor monitor) {
        this.progressMonitor = monitor;
    }

    /**
     * Sets the output path.
     * 
     * @param path
     *            The given path string.
     */
    public void setOutputPath(final String path) {
        this.outputPath = path;
        this.outputDir = new File(path);
    }

    /**
     * Sets the model path.
     * 
     * @param path
     *            The given path string.
     */
    public void setModelPath(final String path) {
        this.modelPath = path;
    }

    /**
     * Sets the list of selected cartridges.
     * 
     * @param objects
     *            The given cartridge list.
     */
    public void setSelectedCartridges(final Object[] objects) {
        for (final Object cartridge : objects) {
            this.selectedCartridges.add(cartridge);
        }
    }

    /**
     * Sets the list of selected reports.
     * 
     * @param reports
     *            The given report list.
     */
    public void setSelectedReports(Object[] reports) {
        this.selectedReports = reports;
    }

    /**
     * Returns the output directory.
     * 
     * @return the outputDir
     */
    public File getOutputDir() {
        return this.outputDir;
    }

    /**
     * Sets the output directory.
     * 
     * @param dir
     *            the given value.
     */
    public void setOutputDir(File dir) {
        this.outputDir = dir;
    }

    /**
     * Returns the report directory.
     * 
     * @return the reportDir
     */
    public File getReportDir() {
        return this.reportDir;
    }

    /**
     * @param dir
     *            the reportDir to set
     */
    public void setReportDir(File dir) {
        this.reportDir = dir;
    }

    /**
     * Returns the report path.
     * 
     * @return the reportPath
     */
    public String getReportPath() {
        return this.reportPath;
    }

    /**
     * @param path
     *            the reportPath to set
     */
    public void setReportPath(String path) {
        this.reportPath = path;
    }

    /**
     * Returns the output path.
     * 
     * @return the outputPath
     */
    public String getOutputPath() {
        return this.outputPath;
    }

    /**
     * Returns the model path.
     * 
     * @return the modelPath
     */
    public String getModelPath() {
        return this.modelPath;
    }

    /**
     * Returns the diagram reference.
     * 
     * @return the diagram
     */
    public Diagram getDiagram() {
        return this.diagram;
    }

    /**
     * Returns the application instance.
     * 
     * @return the application
     */
    public Application getApp() {
        return this.app;
    }

    /**
     * Returns the diagram preferences hint.
     * 
     * @return the diagramPreferencesHint
     */
    public PreferencesHint getDiagramPreferencesHint() {
        return this.diagramPreferencesHint;
    }

    /**
     * Returns the list of selected reports.
     * 
     * @return the report list
     */
    public Object[] getSelectedReports() {
        return this.selectedReports;
    }

    /**
     * Sets the list of available cartridges.
     * 
     * @param cartridges
     *            the given list.
     */
    public void setAvailableCartridges(ArrayList<String> cartridges) {
        this.availableCartridges = cartridges;
    }

    /**
     * Sets the list of selected cartridges.
     * 
     * @param cartridges
     *            the given list.
     */
    public void setSelectedCartridges(ArrayList<Object> cartridges) {
        this.selectedCartridges = cartridges;
    }

    /**
     * Sets the list of available reports.
     * 
     * @param reports
     *            the given list.
     */
    public void setAvailableReports(ArrayList<String> reports) {
        this.availableReports = reports;
    }
}

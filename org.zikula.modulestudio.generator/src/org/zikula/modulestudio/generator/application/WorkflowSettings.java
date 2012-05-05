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

    ArrayList availableCartridges = new ArrayList();
    ArrayList selectedCartridges = new ArrayList();
    public String outputPath = null;
    File outputDir = null;
    String modelPath = null;
    public Diagram diagram = null;
    Application app = null;
    public PreferencesHint diagramPreferencesHint = null;
    IProgressMonitor progressMonitor = null;
    File reportDir = null;
    ArrayList availableReports = new ArrayList();
    Object[] selectedReports = null;
    IWorkbenchWindow workbenchWindow = null;
    IWorkbench workbench = null;
    String reportPath = "/org/zikula/modulestudio/generator/cartridges/reporting/reports";

    public WorkflowSettings() throws Exception {
        this.availableCartridges.add("zclassic");
        this.availableCartridges.add("zoo");
        this.availableCartridges.add("reporting");
        this.selectedCartridges.add("zclassic");
        this.selectedCartridges.add("reporting");

        collectAvailableReports();
    }

    private void collectAvailableReports() throws Exception {
        java.net.URL[] resources = FileLocator.findEntries(
                Platform.getBundle(Activator.PLUGIN_ID), new Path("/src"
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
                    if (name.contains(".rptdesign")) {
                        return true;
                    }
                    return false;
                }
            })) {
                this.availableReports.add(file.replace(".rptdesign", ""));
            }

        } catch (final URISyntaxException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        } catch (final IOException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
    }

    public IWorkbenchWindow getWorkbenchWindow() {
        return this.workbenchWindow;
    }

    public void setWorkbenchWindow(IWorkbenchWindow window) {
        this.workbenchWindow = window;
    }

    public IWorkbench getWorkbench() {
        return this.workbench;
    }

    public IProgressMonitor getProgressMonitor() {
        return this.progressMonitor;
    }

    public void setWorkbench(IWorkbench workbench) {
        this.workbench = workbench;
    }

    public ArrayList getAvailableCartridges() {
        return this.availableCartridges;
    }

    public ArrayList getSelectedCartridges() {
        return this.selectedCartridges;
    }

    public ArrayList getAvailableReports() {
        return this.availableReports;
    }

    public void setApp(Application app) {
        this.app = app;
    }

    public void setDiagram(Diagram diagram) {
        this.diagram = diagram;
    }

    public void setDiagramPreferencesHint(PreferencesHint hint) {
        this.diagramPreferencesHint = hint;
    }

    public void setProgressMonitor(IProgressMonitor monitor) {
        this.progressMonitor = monitor;
    }

    public void setOutputPath(String path) {
        this.outputPath = path;
        this.outputDir = new File(outputPath);
    }

    public void setModelPath(String path) {
        this.modelPath = path;
    }

    public void setSelectedCartridges(Object[] cartridges) {
        for (final Object object : cartridges) {
            this.selectedCartridges.add(object);
        }
    }

    public void setSelectedReports(Object[] reports) {
        this.selectedReports = reports;
    }
}

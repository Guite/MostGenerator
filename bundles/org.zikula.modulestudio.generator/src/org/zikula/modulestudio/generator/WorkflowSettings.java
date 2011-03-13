package org.zikula.modulestudio.generator;

import java.io.File;
import java.util.ArrayList;

import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.gmf.runtime.diagram.core.preferences.PreferencesHint;
import org.eclipse.gmf.runtime.notation.Diagram;

import de.guite.modulestudio.metamodel.modulestudio.Application;

public class WorkflowSettings {

    ArrayList aviableCartridges = new ArrayList();
    Object[] selectedCartridges;
    String outputPath = null;
    File outputDir = null;
    String modelPath = null;
    Diagram diagram = null;
    Application app = null;
    PreferencesHint diagramPreferencesHint = null;
    IProgressMonitor progressMonitor = null;

    public WorkflowSettings() {
        this.aviableCartridges.add("zclassic");
        this.aviableCartridges.add("zoo");
        this.aviableCartridges.add("reporting");
    }

    public ArrayList getAviableCartridges() {
        return this.aviableCartridges;
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
        this.selectedCartridges = cartridges;
    }

}

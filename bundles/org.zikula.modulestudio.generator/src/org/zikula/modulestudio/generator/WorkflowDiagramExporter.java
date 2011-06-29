package org.zikula.modulestudio.generator;

import org.zikula.modulestudio.generator.output.DiagramExporter;

/** TODO: javadocs needed for class, members and methods */
public class WorkflowDiagramExporter {
    WorkflowSettings settings;

    public WorkflowDiagramExporter(WorkflowSettings settings) {
        this.settings = settings;
    }

    public void run() {
        try {
            final DiagramExporter diagramExporter = new DiagramExporter(
                    this.settings);
            diagramExporter.processDiagram(this.settings.diagram,
                    this.settings.outputPath,
                    this.settings.diagramPreferencesHint);
        } catch (final Exception e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
    }
}

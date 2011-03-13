package org.zikula.modulestudio.generator;

import org.zikula.modulestudio.generator.output.DiagramExporter;

public class WorkflowDiagramExporter {
    WorkflowSettings settings;

    public WorkflowDiagramExporter(WorkflowSettings settings) {
        this.settings = settings;
    }

    public void run() {
        try {
            final DiagramExporter diagramExporter = new DiagramExporter();
            diagramExporter.processDiagram(this.settings.diagram,
                    this.settings.outputPath,
                    this.settings.diagramPreferencesHint);
        } catch (final Exception e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
    }
}

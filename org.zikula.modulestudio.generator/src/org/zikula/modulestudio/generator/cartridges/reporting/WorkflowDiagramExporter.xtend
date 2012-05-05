package org.zikula.modulestudio.generator.cartridges.reporting

import org.zikula.modulestudio.generator.application.WorkflowSettings

/**
 * TODO: javadocs needed for class, members and methods
 */
class WorkflowDiagramExporter {
    WorkflowSettings settings

    new(WorkflowSettings settings) {
        this.settings = settings
    }

    def run() {
        try {
            val diagramExporter = new DiagramExporter(settings)
            diagramExporter.processDiagram(settings.diagram, settings.outputPath, settings.diagramPreferencesHint)
        } catch (Exception e) {
            // TODO Auto-generated catch block
            e.printStackTrace
        }
    }
}

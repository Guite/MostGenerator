package org.zikula.modulestudio.generator.cartridges.reporting

import org.zikula.modulestudio.generator.application.WorkflowSettings
import org.zikula.modulestudio.generator.cartridges.reporting.DiagramExporter

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
            diagramExporter.processDiagram(settings.getDiagram, settings.getOutputPath, settings.getDiagramPreferencesHint)
        } catch (Exception e) {
            // TODO Auto-generated catch block
            e.printStackTrace
        }
    }
}

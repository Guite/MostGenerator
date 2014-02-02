package org.zikula.modulestudio.generator.cartridges.reporting

import org.zikula.modulestudio.generator.application.WorkflowSettings
import org.zikula.modulestudio.generator.cartridges.reporting.DiagramExporter

/**
 * Diagram exporter facade.
 */
class WorkflowDiagramExporter {
    WorkflowSettings settings

    /**
     * Constructor accepting the workflow settings.
     *
     * @param settings Given workflow settings.
     */
    new(WorkflowSettings settings) {
        this.settings = settings
    }

    /**
     * Start exporting the diagrams by delegating to DiagramExporter instance.
     */
    def run() {
        val diagramExporter = new DiagramExporter(settings)
        diagramExporter.processDiagram(settings.getDiagram, settings.getOutputPath, settings.getDiagramPreferencesHint)
    }
}

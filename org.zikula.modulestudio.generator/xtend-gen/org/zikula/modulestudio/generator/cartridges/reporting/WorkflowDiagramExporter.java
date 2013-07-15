package org.zikula.modulestudio.generator.cartridges.reporting;

import org.eclipse.gmf.runtime.diagram.core.preferences.PreferencesHint;
import org.eclipse.gmf.runtime.notation.Diagram;
import org.eclipse.xtext.xbase.lib.Exceptions;
import org.zikula.modulestudio.generator.application.WorkflowSettings;
import org.zikula.modulestudio.generator.cartridges.reporting.DiagramExporter;

/**
 * Diagram exporter facade.
 */
@SuppressWarnings("all")
public class WorkflowDiagramExporter {
  private WorkflowSettings settings;
  
  /**
   * Constructor accepting the workflow settings.
   * 
   * @param WorkflowSettings settings
   */
  public WorkflowDiagramExporter(final WorkflowSettings settings) {
    this.settings = settings;
  }
  
  /**
   * Start exporting the diagrams by delegating to DiagramExporter instance.
   */
  public void run() {
    try {
      DiagramExporter _diagramExporter = new DiagramExporter(this.settings);
      final DiagramExporter diagramExporter = _diagramExporter;
      Diagram _diagram = this.settings.getDiagram();
      String _outputPath = this.settings.getOutputPath();
      PreferencesHint _diagramPreferencesHint = this.settings.getDiagramPreferencesHint();
      diagramExporter.processDiagram(_diagram, _outputPath, _diagramPreferencesHint);
    } catch (final Throwable _t) {
      if (_t instanceof Exception) {
        final Exception e = (Exception)_t;
        e.printStackTrace();
      } else {
        throw Exceptions.sneakyThrow(_t);
      }
    }
  }
}

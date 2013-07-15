package org.zikula.modulestudio.generator.cartridges.reporting;

import de.guite.modulestudio.metamodel.modulestudio.Application;
import de.guite.modulestudio.metamodel.modulestudio.Controllers;
import de.guite.modulestudio.metamodel.modulestudio.Models;
import de.guite.modulestudio.metamodel.modulestudio.Views;
import java.io.File;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.core.runtime.Path;
import org.eclipse.emf.common.util.EList;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.ResourceSet;
import org.eclipse.gmf.runtime.diagram.core.preferences.PreferencesHint;
import org.eclipse.gmf.runtime.diagram.ui.image.ImageFileFormat;
import org.eclipse.gmf.runtime.diagram.ui.render.util.CopyToImageUtil;
import org.eclipse.gmf.runtime.emf.core.resources.GMFResource;
import org.eclipse.gmf.runtime.notation.Diagram;
import org.eclipse.xtext.xbase.lib.Exceptions;
import org.eclipse.xtext.xbase.lib.InputOutput;
import org.zikula.modulestudio.generator.application.WorkflowSettings;

/**
 * This class serves for exporting diagram files to image file formats.
 */
@SuppressWarnings("all")
public class DiagramExporter {
  /**
   * The diagram type (0 = main, 1 = model, 2 = controller, 3 = view).
   */
  private Integer inputDiagramType;
  
  /**
   * The output path chosen for generation.
   */
  private String outputPath;
  
  /**
   * Prefix for output files, will be set to application name.
   */
  private String outputPrefix;
  
  /**
   * Counter for iterating model sub diagrams.
   */
  private Integer diagCounterM;
  
  /**
   * Counter for iterating controller sub diagrams.
   */
  private Integer diagCounterC;
  
  /**
   * Counter for iterating view sub diagrams.
   */
  private Integer diagCounterV;
  
  /**
   * Reference to workflow settings.
   */
  private WorkflowSettings settings;
  
  /**
   * Preferences hint.
   */
  private PreferencesHint preferencesHint;
  
  /**
   * The constructor.
   * 
   * @param wfSettings
   *            Given {@link WorkflowSettings} instance.
   */
  public DiagramExporter(final WorkflowSettings wfSettings) {
    this.settings = wfSettings;
  }
  
  /**
   * Process an application diagram.
   * 
   * @param appDiagram
   *            Instance of {@link Diagram}.
   * @param outPath
   *            The desired output path.
   * @param prefHint
   *            Instance of {@link PreferencesHint}.
   */
  public void processDiagram(final Diagram appDiagram, final String outPath, final PreferencesHint prefHint) {
    this.inputDiagramType = Integer.valueOf(0);
    this.preferencesHint = prefHint;
    this.diagCounterM = Integer.valueOf(0);
    this.diagCounterC = Integer.valueOf(0);
    this.diagCounterV = Integer.valueOf(0);
    String _plus = (outPath + "/diagrams/");
    this.outputPath = _plus;
    File _file = new File(this.outputPath);
    final File diagramDirectory = _file;
    boolean _and = false;
    boolean _exists = diagramDirectory.exists();
    boolean _not = (!_exists);
    if (!_not) {
      _and = false;
    } else {
      boolean _mkdir = diagramDirectory.mkdir();
      boolean _not_1 = (!_mkdir);
      _and = (_not && _not_1);
    }
    if (_and) {
      String _plus_1 = ("Error: could not create directory: " + this.outputPath);
      InputOutput.<String>println(_plus_1);
    }
    EObject _element = appDiagram.getElement();
    final Application app = ((Application) _element);
    String _name = app.getName();
    this.outputPrefix = _name;
    final ResourceSet resourceSet = this.getResourceSetFromApp(app);
    final EList<Resource> resources = resourceSet.getResources();
    for (final Resource resource : resources) {
      {
        URI _uRI = resource.getURI();
        final String resourceUri = _uRI.toString();
        boolean _and_1 = false;
        boolean _endsWith = resourceUri.endsWith("mostdiagram");
        if (!_endsWith) {
          _and_1 = false;
        } else {
          _and_1 = (_endsWith && (resource instanceof GMFResource));
        }
        if (_and_1) {
          EList<EObject> _contents = resource.getContents();
          for (final EObject resourceElement : _contents) {
            if ((resourceElement instanceof Diagram)) {
              boolean _saveCurrentDiagramInAllFormats = this.saveCurrentDiagramInAllFormats(((Diagram) resourceElement));
              boolean _not_2 = (!_saveCurrentDiagramInAllFormats);
              if (_not_2) {
                InputOutput.<String>println("An error occurred during exporting the diagram.");
              }
            }
          }
        }
      }
    }
  }
  
  /**
   * Exports the given {@link Diagram} into all possible file formats.
   * 
   * @param inputDiagram
   *            The given input diagram.
   * @return Whether everything worked fine or not.
   */
  private boolean saveCurrentDiagramInAllFormats(final Diagram inputDiagram) {
    boolean _xblockexpression = false;
    {
      final EObject diagramElement = inputDiagram.getElement();
      this.inputDiagramType = Integer.valueOf(0);
      boolean _matched = false;
      if (!_matched) {
        if (diagramElement instanceof Models) {
          final Models _models = (Models)diagramElement;
          _matched=true;
          this.inputDiagramType = Integer.valueOf(1);
          int _plus = ((this.diagCounterM).intValue() + 1);
          this.diagCounterM = Integer.valueOf(_plus);
        }
      }
      if (!_matched) {
        if (diagramElement instanceof Controllers) {
          final Controllers _controllers = (Controllers)diagramElement;
          _matched=true;
          this.inputDiagramType = Integer.valueOf(2);
          int _plus = ((this.diagCounterC).intValue() + 1);
          this.diagCounterC = Integer.valueOf(_plus);
        }
      }
      if (!_matched) {
        if (diagramElement instanceof Views) {
          final Views _views = (Views)diagramElement;
          _matched=true;
          this.inputDiagramType = Integer.valueOf(3);
          int _plus = ((this.diagCounterV).intValue() + 1);
          this.diagCounterV = Integer.valueOf(_plus);
        }
      }
      boolean result = false;
      try {
        boolean _saveCurrentDiagramAs = this.saveCurrentDiagramAs(ImageFileFormat.BMP, inputDiagram);
        result = _saveCurrentDiagramAs;
        boolean _saveCurrentDiagramAs_1 = this.saveCurrentDiagramAs(ImageFileFormat.GIF, inputDiagram);
        result = _saveCurrentDiagramAs_1;
        boolean _saveCurrentDiagramAs_2 = this.saveCurrentDiagramAs(ImageFileFormat.JPG, inputDiagram);
        result = _saveCurrentDiagramAs_2;
        boolean _saveCurrentDiagramAs_3 = this.saveCurrentDiagramAs(ImageFileFormat.PDF, inputDiagram);
        result = _saveCurrentDiagramAs_3;
        boolean _saveCurrentDiagramAs_4 = this.saveCurrentDiagramAs(ImageFileFormat.PNG, inputDiagram);
        result = _saveCurrentDiagramAs_4;
        boolean _saveCurrentDiagramAs_5 = this.saveCurrentDiagramAs(ImageFileFormat.SVG, inputDiagram);
        result = _saveCurrentDiagramAs_5;
      } catch (final Throwable _t) {
        if (_t instanceof CoreException) {
          final CoreException e = (CoreException)_t;
          e.printStackTrace();
        } else {
          throw Exceptions.sneakyThrow(_t);
        }
      }
      _xblockexpression = (result);
    }
    return _xblockexpression;
  }
  
  /**
   * Exports the given {@link Diagram} into a certain {@link ImageFileFormat}.
   * 
   * @param format
   *            The given image file format.
   * @param inputDiagram
   *            The given input diagram.
   * @return Whether everything worked fine or not.
   * @throws CoreException
   *             In case an error occurred.
   */
  private boolean saveCurrentDiagramAs(final ImageFileFormat format, final Diagram inputDiagram) throws CoreException {
    boolean _xblockexpression = false;
    {
      final Integer diagramType = this.inputDiagramType;
      String outputSuffix = "";
      boolean _equals = ((diagramType).intValue() == 0);
      if (_equals) {
        outputSuffix = "_main";
      } else {
        boolean _equals_1 = ((diagramType).intValue() == 1);
        if (_equals_1) {
          String _plus = ("_model_" + this.diagCounterM);
          outputSuffix = _plus;
        } else {
          boolean _equals_2 = ((diagramType).intValue() == 2);
          if (_equals_2) {
            String _plus_1 = ("_controller_" + this.diagCounterC);
            outputSuffix = _plus_1;
          } else {
            boolean _equals_3 = ((diagramType).intValue() == 3);
            if (_equals_3) {
              String _plus_2 = ("_view_" + this.diagCounterV);
              outputSuffix = _plus_2;
            }
          }
        }
      }
      String _plus_3 = (this.outputPath + this.outputPrefix);
      String _plus_4 = (_plus_3 + outputSuffix);
      String _plus_5 = (_plus_4 + ".");
      String _string = format.toString();
      String _lowerCase = _string.toLowerCase();
      final String filePath = (_plus_5 + _lowerCase);
      Path _path = new Path(filePath);
      final Path destination = _path;
      try {
        CopyToImageUtil _copyToImageUtil = new CopyToImageUtil();
        IProgressMonitor _progressMonitor = this.settings.getProgressMonitor();
        _copyToImageUtil.copyToImage(inputDiagram, destination, format, _progressMonitor, 
          this.preferencesHint);
      } catch (final Throwable _t) {
        if (_t instanceof IllegalStateException) {
          final IllegalStateException e = (IllegalStateException)_t;
        } else {
          throw Exceptions.sneakyThrow(_t);
        }
      }
      _xblockexpression = (true);
    }
    return _xblockexpression;
  }
  
  /**
   * Retrieve a resource set from a given application.
   * 
   * @param app
   *            The given application instance.
   * @return The determined resource set.
   */
  private ResourceSet getResourceSetFromApp(final Application app) {
    ResourceSet _xblockexpression = null;
    {
      final Resource resource = app.eResource();
      final ResourceSet resourceSet = resource.getResourceSet();
      _xblockexpression = (resourceSet);
    }
    return _xblockexpression;
  }
}

package org.zikula.modulestudio.generator.application;

import com.google.inject.Injector;
import de.guite.modulestudio.metamodel.Application;
import de.guite.modulestudio.metamodel.SettingsContainer;
import java.io.File;
import java.io.IOException;
import java.util.Collections;
import java.util.List;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.emf.common.util.Diagnostic;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.util.Diagnostician;
import org.eclipse.xtend.lib.annotations.Accessors;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.JavaIoFileSystemAccess;
import org.eclipse.xtext.util.EmfFormatter;
import org.eclipse.xtext.validation.FeatureBasedDiagnostic;
import org.eclipse.xtext.xbase.lib.CollectionLiterals;
import org.eclipse.xtext.xbase.lib.Exceptions;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.eclipse.xtext.xbase.lib.Pure;
import org.eclipse.xtext.xbase.lib.StringExtensions;
import org.zikula.modulestudio.generator.application.ErrorState;
import org.zikula.modulestudio.generator.application.WorkflowPostProcess;
import org.zikula.modulestudio.generator.application.WorkflowPreProcess;
import org.zikula.modulestudio.generator.application.WorkflowSettings;
import org.zikula.modulestudio.generator.cartridges.MostGenerator;
import org.zikula.modulestudio.generator.cartridges.MostGeneratorSetup;
import org.zikula.modulestudio.generator.exceptions.ExceptionBase;
import org.zikula.modulestudio.generator.exceptions.M2TFailedGeneratorResourceNotFound;
import org.zikula.modulestudio.generator.exceptions.M2TUnknownException;
import org.zikula.modulestudio.generator.workflow.components.ModelReader;

/**
 * Main entry point for the workflow.
 */
@SuppressWarnings("all")
public class WorkflowStart {
  /**
   * Name of currently processed generator cartridge.
   */
  private String currentCartridge = "";
  
  public WorkflowSettings settings = new WorkflowSettings();
  
  public WorkflowPreProcess preProcess = new WorkflowPreProcess();
  
  /**
   * Reference to the model's {@link Resource} object.
   */
  private Resource model = null;
  
  /**
   * The Guice injector instance which may be provided
   * if the generator is executed inside MOST.
   */
  @Accessors
  private Injector injector = null;
  
  /**
   * Validates the model.
   */
  public ErrorState validate() {
    final IProgressMonitor progressMonitor = this.settings.getProgressMonitor();
    String _appName = this.settings.getAppName();
    String _plus = ("Validating \"" + _appName);
    String _plus_1 = (_plus + " ");
    String _appVersion = this.settings.getAppVersion();
    String _plus_2 = (_plus_1 + _appVersion);
    String _plus_3 = (_plus_2 + "\" ...");
    progressMonitor.beginTask(_plus_3, (-1));
    Diagnostic diag = Diagnostician.INSTANCE.validate(IterableExtensions.<EObject>head(this.getModel().getContents()));
    int _severity = diag.getSeverity();
    switch (_severity) {
      case Diagnostic.ERROR:
        CharSequence _validatorMessage = this.validatorMessage(diag);
        String _plus_4 = ("Errors: \n" + _validatorMessage);
        progressMonitor.subTask(_plus_4);
        progressMonitor.done();
        return ErrorState.ERROR;
      case Diagnostic.WARNING:
        CharSequence _validatorMessage_1 = this.validatorMessage(diag);
        String _plus_5 = ("Warnings: \n" + _validatorMessage_1);
        progressMonitor.subTask(_plus_5);
        progressMonitor.done();
        return ErrorState.WARN;
      default:
        {
          progressMonitor.subTask("Valid");
          progressMonitor.done();
          return ErrorState.OK;
        }
    }
  }
  
  public CharSequence validatorMessage(final Diagnostic diag) {
    StringConcatenation _builder = new StringConcatenation();
    {
      List<Diagnostic> _children = diag.getChildren();
      for(final Diagnostic c : _children) {
        _builder.append("- ");
        String _message = c.getMessage();
        _builder.append(_message);
        _builder.append(" at ");
        String _objPath = EmfFormatter.objPath(((FeatureBasedDiagnostic) c).getSourceEObject());
        _builder.append(_objPath);
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder;
  }
  
  /**
   * Executes the workflow, preProcess.run() has already been called.
   */
  public void run() throws ExceptionBase {
    this.performM2T();
    new WorkflowPostProcess(this.settings).run();
  }
  
  /**
   * Workflow facade executing the actual model-to-text workflows.
   */
  private boolean performM2T() throws ExceptionBase {
    boolean _xblockexpression = false;
    {
      boolean success = false;
      try {
        final IProgressMonitor progressMonitor = this.settings.getProgressMonitor();
        String _appVendor = this.settings.getAppVendor();
        String _plus = ("Generating \"" + _appVendor);
        String _plus_1 = (_plus + File.separator);
        String _appName = this.settings.getAppName();
        String _plus_2 = (_plus_1 + _appName);
        String _plus_3 = (_plus_2 + "Module ");
        String _appVersion = this.settings.getAppVersion();
        String _plus_4 = (_plus_3 + _appVersion);
        String _plus_5 = (_plus_4 + "\" ...");
        progressMonitor.beginTask(_plus_5, (-1));
        for (final String singleCartridge : Collections.<String>unmodifiableList(CollectionLiterals.<String>newArrayList("zclassic"))) {
          {
            this.currentCartridge = singleCartridge.toString();
            final MostGenerator generator = new MostGenerator();
            generator.setCartridge(this.currentCartridge);
            generator.setMonitor(this.settings.getProgressMonitor());
            final JavaIoFileSystemAccess fileSystemAccess = this.getConfiguredFileSystemAccess();
            generator.doGenerate(this.getModel(), fileSystemAccess);
          }
        }
        success = true;
      } catch (final Throwable _t) {
        if (_t instanceof IOException) {
          final IOException e = (IOException)_t;
          throw new M2TFailedGeneratorResourceNotFound(e);
        } else if (_t instanceof Exception) {
          final Exception e_1 = (Exception)_t;
          e_1.printStackTrace();
          throw new M2TUnknownException(e_1);
        } else {
          throw Exceptions.sneakyThrow(_t);
        }
      } finally {
      }
      _xblockexpression = success;
    }
    return _xblockexpression;
  }
  
  protected JavaIoFileSystemAccess getConfiguredFileSystemAccess() {
    JavaIoFileSystemAccess _xblockexpression = null;
    {
      final MostGeneratorSetup setup = new MostGeneratorSetup();
      final Injector injector = setup.createInjectorAndDoEMFRegistration();
      final JavaIoFileSystemAccess configuredFileSystemAccess = injector.<JavaIoFileSystemAccess>getInstance(JavaIoFileSystemAccess.class);
      configuredFileSystemAccess.setOutputPath("DEFAULT_OUTPUT", this.settings.getPathToModuleRoot());
      _xblockexpression = configuredFileSystemAccess;
    }
    return _xblockexpression;
  }
  
  private Resource getModel() {
    Resource _xblockexpression = null;
    {
      if ((null == this.model)) {
        final ModelReader reader = new ModelReader();
        reader.setUri(this.settings.getModelPath());
        if ((null != this.injector)) {
          reader.setInjector(this.injector);
        }
        this.model = reader.invoke();
      }
      _xblockexpression = this.model;
    }
    return _xblockexpression;
  }
  
  public void readSettingsFromModel() {
    final Resource model = this.getModel();
    EObject _head = IterableExtensions.<EObject>head(model.getContents());
    final Application app = ((Application) _head);
    String _elvis = null;
    String _name = app.getName();
    String _formatForCodeCapital = null;
    if (_name!=null) {
      _formatForCodeCapital=this.formatForCodeCapital(_name);
    }
    if (_formatForCodeCapital != null) {
      _elvis = _formatForCodeCapital;
    } else {
      _elvis = "Module";
    }
    this.settings.setAppName(_elvis);
    String _elvis_1 = null;
    String _vendor = app.getVendor();
    String _formatForCodeCapital_1 = null;
    if (_vendor!=null) {
      _formatForCodeCapital_1=this.formatForCodeCapital(_vendor);
    }
    if (_formatForCodeCapital_1 != null) {
      _elvis_1 = _formatForCodeCapital_1;
    } else {
      _elvis_1 = "Vendor";
    }
    this.settings.setAppVendor(_elvis_1);
    String _xifexpression = null;
    String _version = app.getVersion();
    boolean _tripleNotEquals = (null != _version);
    if (_tripleNotEquals) {
      _xifexpression = app.getVersion();
    } else {
      _xifexpression = "1.0.0";
    }
    this.settings.setAppVersion(_xifexpression);
    boolean _isEmpty = app.getGeneratorSettings().isEmpty();
    boolean _not = (!_isEmpty);
    if (_not) {
      final SettingsContainer genSettings = IterableExtensions.<SettingsContainer>head(app.getGeneratorSettings());
      boolean _isWriteModelToDocs = genSettings.isWriteModelToDocs();
      if (_isWriteModelToDocs) {
        String modelDestinationPath = this.settings.getPathToModuleRoot();
        String _modelDestinationPath = modelDestinationPath;
        modelDestinationPath = (_modelDestinationPath + ((((("Resources" + File.separator) + "docs") + File.separator) + "model") + File.separator));
        this.settings.setModelDestinationPath(modelDestinationPath);
      }
    }
    return;
  }
  
  /**
   * Formats a string for usage in generated source code starting with capital.
   * 
   * @param s given input string
   * @return String formatted for source code usage.
   */
  private String formatForCodeCapital(final String s) {
    return StringExtensions.toFirstUpper(s.replace("Ä", "Ae").replace("ä", "ae").replace("Ö", "Oe").replace("ö", "oe").replace("Ü", "Ue").replace("ü", "ue").replace("ß", "ss").replaceAll("[\\W]", ""));
  }
  
  @Pure
  public Injector getInjector() {
    return this.injector;
  }
  
  public void setInjector(final Injector injector) {
    this.injector = injector;
  }
}

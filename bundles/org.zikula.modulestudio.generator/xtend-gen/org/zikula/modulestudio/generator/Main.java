package org.zikula.modulestudio.generator;

import com.google.common.base.Objects;
import com.google.inject.Inject;
import com.google.inject.Injector;
import com.google.inject.Provider;
import de.guite.modulestudio.MostDslStandaloneSetup;
import java.io.File;
import java.lang.reflect.InvocationTargetException;
import java.util.List;
import java.util.function.Consumer;
import org.eclipse.core.runtime.NullProgressMonitor;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.ResourceSet;
import org.eclipse.xtext.diagnostics.Severity;
import org.eclipse.xtext.util.CancelIndicator;
import org.eclipse.xtext.validation.CheckMode;
import org.eclipse.xtext.validation.IResourceValidator;
import org.eclipse.xtext.validation.Issue;
import org.eclipse.xtext.xbase.lib.Conversions;
import org.eclipse.xtext.xbase.lib.Exceptions;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.InputOutput;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.zikula.modulestudio.generator.application.WorkflowStart;
import org.zikula.modulestudio.generator.exceptions.ExceptionBase;
import org.zikula.modulestudio.generator.exceptions.M2TFailedGeneratorResourceNotFound;
import org.zikula.modulestudio.generator.exceptions.M2TUnknownException;

/**
 * Entry point for stand-alone generator.
 */
@SuppressWarnings("all")
public class Main {
  public static void main(final String[] args) {
    boolean _isEmpty = ((List<String>)Conversions.doWrapArray(args)).isEmpty();
    if (_isEmpty) {
      System.err.println("Error: no model provided!");
      System.err.println();
      System.err.println("Call this like:");
      System.err.println("    java -jar ModuleStudio-generator.jar MyModel.mostapp");
      System.err.println();
      System.err.println("You can also define a custom output folder:");
      System.err.println("    java -jar ModuleStudio-generator.jar MyModel.mostapp MySubFolder");
      return;
    }
    final Injector injector = new MostDslStandaloneSetup().createInjectorAndDoEMFRegistration();
    final Main main = injector.<Main>getInstance(Main.class);
    final String modelUri = IterableExtensions.<String>head(((Iterable<String>)Conversions.doWrapArray(args)));
    String _property = System.getProperty("user.dir");
    String outputFolder = (_property + File.separator);
    String _outputFolder = outputFolder;
    String _xifexpression = null;
    int _length = args.length;
    boolean _greaterThan = (_length > 1);
    if (_greaterThan) {
      _xifexpression = args[1];
    } else {
      _xifexpression = "GeneratedModule";
    }
    String _plus = (_xifexpression + File.separator);
    outputFolder = (_outputFolder + _plus);
    final File outputDirectory = new File(outputFolder);
    boolean _exists = outputDirectory.exists();
    boolean _not = (!_exists);
    if (_not) {
      outputDirectory.mkdirs();
    }
    main.runGenerator(modelUri, outputFolder);
  }
  
  @Inject
  private Provider<ResourceSet> resourceSetProvider;
  
  @Inject
  private IResourceValidator validator;
  
  protected void runGenerator(final String modelUri, final String outputFolder) {
    final ResourceSet set = this.resourceSetProvider.get();
    final Resource resource = set.getResource(URI.createFileURI(modelUri), true);
    final List<Issue> issues = this.validator.validate(resource, CheckMode.ALL, CancelIndicator.NullImpl);
    boolean _isEmpty = issues.isEmpty();
    boolean _not = (!_isEmpty);
    if (_not) {
      final Consumer<Issue> _function = (Issue it) -> {
        System.err.println(it);
      };
      issues.forEach(_function);
    }
    final Function1<Issue, Boolean> _function_1 = (Issue it) -> {
      Severity _severity = it.getSeverity();
      return Boolean.valueOf(Objects.equal(_severity, Severity.ERROR));
    };
    boolean _isEmpty_1 = IterableExtensions.isEmpty(IterableExtensions.<Issue>filter(issues, _function_1));
    boolean _not_1 = (!_isEmpty_1);
    if (_not_1) {
      System.err.println();
      System.err.println("Aborting because the model has errors.");
      return;
    }
    final WorkflowStart workflow = new WorkflowStart();
    workflow.settings.setOutputPath(outputFolder);
    workflow.settings.setIsStandalone(Boolean.valueOf(true));
    workflow.settings.setModelPath(modelUri);
    workflow.readSettingsFromModel();
    NullProgressMonitor _nullProgressMonitor = new NullProgressMonitor();
    workflow.settings.setProgressMonitor(_nullProgressMonitor);
    try {
      workflow.run();
      InputOutput.<String>println((("Code generation finished. The output is located in the \"" + outputFolder) + "\" folder."));
    } catch (final Throwable _t) {
      if (_t instanceof M2TFailedGeneratorResourceNotFound) {
        final M2TFailedGeneratorResourceNotFound e = (M2TFailedGeneratorResourceNotFound)_t;
        System.err.println("Error: Generator resource could not be found.");
        e.printStackTrace();
      } else if (_t instanceof M2TUnknownException) {
        final M2TUnknownException e_1 = (M2TUnknownException)_t;
        System.err.println("Error: A M2T exception occurred during the workflow.");
        e_1.printStackTrace();
      } else if (_t instanceof ExceptionBase) {
        final ExceptionBase e_2 = (ExceptionBase)_t;
        System.err.println("Error: A general exception occurred during the workflow.");
        e_2.printStackTrace();
      } else if (_t instanceof InvocationTargetException) {
        final InvocationTargetException e_3 = (InvocationTargetException)_t;
        e_3.printStackTrace();
      } else if (_t instanceof InterruptedException) {
        final InterruptedException e_4 = (InterruptedException)_t;
        e_4.printStackTrace();
      } else {
        throw Exceptions.sneakyThrow(_t);
      }
    }
  }
}

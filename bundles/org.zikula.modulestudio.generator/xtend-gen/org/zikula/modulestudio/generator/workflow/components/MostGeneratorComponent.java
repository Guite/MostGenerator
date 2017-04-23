package org.zikula.modulestudio.generator.workflow.components;

import com.google.inject.Inject;
import com.google.inject.Injector;
import java.util.List;
import java.util.Map;
import java.util.Set;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.mwe2.runtime.workflow.IWorkflowComponent;
import org.eclipse.emf.mwe2.runtime.workflow.IWorkflowContext;
import org.eclipse.xtend.lib.annotations.Accessors;
import org.eclipse.xtext.ISetup;
import org.eclipse.xtext.generator.GeneratorComponent;
import org.eclipse.xtext.generator.GeneratorDelegate;
import org.eclipse.xtext.generator.IFileSystemAccess2;
import org.eclipse.xtext.generator.IGenerator;
import org.eclipse.xtext.generator.IGenerator2;
import org.eclipse.xtext.generator.JavaIoFileSystemAccess;
import org.eclipse.xtext.xbase.lib.CollectionLiterals;
import org.eclipse.xtext.xbase.lib.Pure;
import org.zikula.modulestudio.generator.cartridges.MostGenerator;

/**
 * Workflow component class for invoking the generator.
 */
@SuppressWarnings("all")
public class MostGeneratorComponent extends GeneratorComponent implements IWorkflowComponent {
  /**
   * The injector.
   */
  @Accessors
  private Injector injector;
  
  /**
   * List of slot names.
   */
  @Accessors
  private List<String> slotNames = CollectionLiterals.<String>newArrayList();
  
  /**
   * List of outlets.
   */
  @Accessors
  private Map<String, String> outlets = CollectionLiterals.<String, String>newHashMap();
  
  /**
   * Name of current cartridge.
   */
  @Accessors
  private String cartridge = "";
  
  /**
   * Registers an {@link ISetup}, which causes the execution of
   * {@link ISetup#createInjectorAndDoEMFRegistration()} the resulting
   * {@link Inject} is stored and used to obtain the used
   * {@link IGenerator}.
   */
  @Override
  public void setRegister(final ISetup setup) {
    this.setInjector(setup.createInjectorAndDoEMFRegistration());
  }
  
  /**
   * adds a slot name to look for {@link Resource}s (the slot's contents might
   * be a Resource or an Iterable of Resources).
   */
  @Override
  public void addSlot(final String slot) {
    this.slotNames.add(slot);
  }
  
  /**
   * Performs actions before the invocation.
   */
  @Override
  public void preInvoke() {
    boolean _isEmpty = this.slotNames.isEmpty();
    if (_isEmpty) {
      throw new IllegalStateException("no \'slot\' has been configured.");
    }
    if ((null == this.injector)) {
      throw new IllegalStateException(
        "no Injector has been configured. Use \'register\' with an ISetup or \'injector\' directly.");
    }
    boolean _isEmpty_1 = this.outlets.isEmpty();
    if (_isEmpty_1) {
      throw new IllegalStateException("no \'outlet\' has been configured.");
    }
    Set<Map.Entry<String, String>> _entrySet = this.outlets.entrySet();
    for (final Map.Entry<String, String> outlet : _entrySet) {
      {
        String _key = outlet.getKey();
        boolean _tripleEquals = (null == _key);
        if (_tripleEquals) {
          throw new IllegalStateException("One of the outlets was configured without a name");
        }
        String _value = outlet.getValue();
        boolean _tripleEquals_1 = (null == _value);
        if (_tripleEquals_1) {
          String _key_1 = outlet.getKey();
          String _plus = ("The path of outlet \'" + _key_1);
          String _plus_1 = (_plus + "\' was null.");
          throw new IllegalStateException(_plus_1);
        }
      }
    }
  }
  
  /**
   * An outlet is defined by a name and a path. The generator will internally
   * choose one of the configured outlets when generating a file. the given
   * path defines the root directory of the outlet.
   * 
   * @param out
   *            The given {@link org.zikula.modulestudio.generator.workflow.Outlet}.
   */
  public void addOutlet(final org.zikula.modulestudio.generator.workflow.Outlet out) {
    this.outlets.put(out.getOutletName(), out.getPath());
  }
  
  /**
   * Invokes the workflow component.
   * 
   * @param ctx
   *            The given {@link IWorkflowContext} instance.
   */
  @Override
  public void invoke(final IWorkflowContext ctx) {
    final GeneratorDelegate instance = this.getCompiler();
    final IFileSystemAccess2 fileSystemAccess = this.getConfiguredFileSystemAccess();
    for (final String slot : this.slotNames) {
      {
        final Object object = ctx.get(slot);
        if ((null == object)) {
          throw new IllegalStateException((("Slot \'" + slot) + "\' was empty!"));
        }
        if ((object instanceof Iterable<?>)) {
          for (final Object object2 : ((Iterable<?>)object)) {
            {
              if ((!(object2 instanceof Resource))) {
                String _simpleName = ((Iterable<?>)object).getClass().getSimpleName();
                String _plus = ("Slot contents was not a Resource but a \'" + _simpleName);
                String _plus_1 = (_plus + "\'!");
                throw new IllegalStateException(_plus_1);
              }
              instance.doGenerate(((Resource) object2), fileSystemAccess);
            }
          }
        } else {
          if ((object instanceof Resource)) {
            instance.doGenerate(((Resource)object), fileSystemAccess);
          } else {
            String _simpleName = object.getClass().getSimpleName();
            String _plus = ("Slot contents was not a Resource but a \'" + _simpleName);
            String _plus_1 = (_plus + "\'!");
            throw new IllegalStateException(_plus_1);
          }
        }
      }
    }
  }
  
  @Override
  protected GeneratorDelegate getCompiler() {
    MostGenerator _xblockexpression = null;
    {
      IGenerator2 _instance = this.injector.<IGenerator2>getInstance(IGenerator2.class);
      final MostGenerator generator = ((MostGenerator) _instance);
      generator.setCartridge(this.cartridge);
      _xblockexpression = generator;
    }
    return _xblockexpression;
  }
  
  @Override
  protected IFileSystemAccess2 getConfiguredFileSystemAccess() {
    JavaIoFileSystemAccess _xblockexpression = null;
    {
      final JavaIoFileSystemAccess configuredFileSystemAccess = this.injector.<JavaIoFileSystemAccess>getInstance(JavaIoFileSystemAccess.class);
      Set<Map.Entry<String, String>> _entrySet = this.outlets.entrySet();
      for (final Map.Entry<String, String> outlet : _entrySet) {
        configuredFileSystemAccess.setOutputPath(outlet.getKey(), outlet.getValue());
      }
      _xblockexpression = configuredFileSystemAccess;
    }
    return _xblockexpression;
  }
  
  /**
   * Performs actions after the invocation.
   */
  @Override
  public void postInvoke() {
  }
  
  @Pure
  public Injector getInjector() {
    return this.injector;
  }
  
  public void setInjector(final Injector injector) {
    this.injector = injector;
  }
  
  @Pure
  public List<String> getSlotNames() {
    return this.slotNames;
  }
  
  public void setSlotNames(final List<String> slotNames) {
    this.slotNames = slotNames;
  }
  
  @Pure
  public Map<String, String> getOutlets() {
    return this.outlets;
  }
  
  public void setOutlets(final Map<String, String> outlets) {
    this.outlets = outlets;
  }
  
  @Pure
  public String getCartridge() {
    return this.cartridge;
  }
  
  public void setCartridge(final String cartridge) {
    this.cartridge = cartridge;
  }
}

package org.zikula.modulestudio.generator.workflow.components;

import com.google.inject.Inject;
import com.google.inject.Injector;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Set;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.mwe2.runtime.workflow.IWorkflowComponent;
import org.eclipse.emf.mwe2.runtime.workflow.IWorkflowContext;
import org.eclipse.xtext.ISetup;
import org.eclipse.xtext.generator.GeneratorComponent;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.generator.IGenerator;
import org.eclipse.xtext.generator.JavaIoFileSystemAccess;
import org.eclipse.xtext.xbase.lib.CollectionLiterals;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.zikula.modulestudio.generator.cartridges.MostGenerator;
import org.zikula.modulestudio.generator.workflow.Outlet;

/**
 * Workflow component class for invoking the generator.
 */
@SuppressWarnings("all")
public class MostGeneratorComponent extends GeneratorComponent implements IWorkflowComponent {
  /**
   * The injector.
   */
  private Injector _injector;
  
  /**
   * The injector.
   */
  public Injector getInjector() {
    return this._injector;
  }
  
  /**
   * The injector.
   */
  public void setInjector(final Injector injector) {
    this._injector = injector;
  }
  
  /**
   * List of slot names.
   */
  private List<String> _slotNames = new Function0<List<String>>() {
    public List<String> apply() {
      ArrayList<String> _newArrayList = CollectionLiterals.<String>newArrayList();
      return _newArrayList;
    }
  }.apply();
  
  /**
   * List of slot names.
   */
  public List<String> getSlotNames() {
    return this._slotNames;
  }
  
  /**
   * List of slot names.
   */
  public void setSlotNames(final List<String> slotNames) {
    this._slotNames = slotNames;
  }
  
  /**
   * List of outlets.
   */
  private Map<String,String> _outlets = new Function0<Map<String,String>>() {
    public Map<String,String> apply() {
      HashMap<String,String> _newHashMap = CollectionLiterals.<String, String>newHashMap();
      return _newHashMap;
    }
  }.apply();
  
  /**
   * List of outlets.
   */
  public Map<String,String> getOutlets() {
    return this._outlets;
  }
  
  /**
   * List of outlets.
   */
  public void setOutlets(final Map<String,String> outlets) {
    this._outlets = outlets;
  }
  
  /**
   * Name of current cartridge.
   */
  private String _cartridge = "";
  
  /**
   * Name of current cartridge.
   */
  public String getCartridge() {
    return this._cartridge;
  }
  
  /**
   * Name of current cartridge.
   */
  public void setCartridge(final String cartridge) {
    this._cartridge = cartridge;
  }
  
  /**
   * Registers an {@link ISetup}, which causes the execution of
   * {@link ISetup#createInjectorAndDoEMFRegistration()} the resulting
   * {@link Inject} is stored and used to obtain the used
   * {@link IGenerator}.
   */
  public void setRegister(final ISetup setup) {
    Injector _createInjectorAndDoEMFRegistration = setup.createInjectorAndDoEMFRegistration();
    this.setInjector(_createInjectorAndDoEMFRegistration);
  }
  
  /**
   * adds a slot name to look for {@link Resource}s (the slot's contents might
   * be a Resource or an Iterable of Resources).
   */
  public void addSlot(final String slot) {
    List<String> _slotNames = this.getSlotNames();
    _slotNames.add(slot);
  }
  
  /**
   * Performs actions before the invocation.
   */
  public void preInvoke() {
    List<String> _slotNames = this.getSlotNames();
    boolean _isEmpty = _slotNames.isEmpty();
    if (_isEmpty) {
      IllegalStateException _illegalStateException = new IllegalStateException("no \'slot\' has been configured.");
      throw _illegalStateException;
    }
    Injector _injector = this.getInjector();
    boolean _tripleEquals = (_injector == null);
    if (_tripleEquals) {
      IllegalStateException _illegalStateException_1 = new IllegalStateException(
        "no Injector has been configured. Use \'register\' with an ISetup or \'injector\' directly.");
      throw _illegalStateException_1;
    }
    Map<String,String> _outlets = this.getOutlets();
    boolean _isEmpty_1 = _outlets.isEmpty();
    if (_isEmpty_1) {
      IllegalStateException _illegalStateException_2 = new IllegalStateException("no \'outlet\' has been configured.");
      throw _illegalStateException_2;
    }
    Map<String,String> _outlets_1 = this.getOutlets();
    Set<Entry<String,String>> _entrySet = _outlets_1.entrySet();
    for (final Entry<String,String> outlet : _entrySet) {
      {
        String _key = outlet.getKey();
        boolean _tripleEquals_1 = (_key == null);
        if (_tripleEquals_1) {
          IllegalStateException _illegalStateException_3 = new IllegalStateException("One of the outlets was configured without a name");
          throw _illegalStateException_3;
        }
        String _value = outlet.getValue();
        boolean _tripleEquals_2 = (_value == null);
        if (_tripleEquals_2) {
          String _key_1 = outlet.getKey();
          String _plus = ("The path of outlet \'" + _key_1);
          String _plus_1 = (_plus + "\' was null.");
          IllegalStateException _illegalStateException_4 = new IllegalStateException(_plus_1);
          throw _illegalStateException_4;
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
  public void addOutlet(final Outlet out) {
    Map<String,String> _outlets = this.getOutlets();
    String _outletName = out.getOutletName();
    String _path = out.getPath();
    _outlets.put(_outletName, _path);
  }
  
  /**
   * Invokes the workflow component.
   * 
   * @param ctx
   *            The given {@link IWorkflowContext} instance.
   */
  public void invoke(final IWorkflowContext ctx) {
    final IGenerator instance = this.getCompiler();
    final IFileSystemAccess fileSystemAccess = this.getConfiguredFileSystemAccess();
    List<String> _slotNames = this.getSlotNames();
    for (final String slot : _slotNames) {
      {
        final Object object = ctx.get(slot);
        boolean _tripleEquals = (object == null);
        if (_tripleEquals) {
          String _plus = ("Slot \'" + slot);
          String _plus_1 = (_plus + "\' was empty!");
          IllegalStateException _illegalStateException = new IllegalStateException(_plus_1);
          throw _illegalStateException;
        }
        if ((object instanceof Iterable)) {
          final Iterable<?> iterable = ((Iterable<?>) object);
          for (final Object object2 : iterable) {
            {
              boolean _not = (!(object2 instanceof Resource));
              if (_not) {
                Class<? extends Object> _class = object.getClass();
                String _simpleName = _class.getSimpleName();
                String _plus_2 = ("Slot contents was not a Resource but a \'" + _simpleName);
                String _plus_3 = (_plus_2 + "\'!");
                IllegalStateException _illegalStateException_1 = new IllegalStateException(_plus_3);
                throw _illegalStateException_1;
              }
              instance.doGenerate(((Resource) object2), fileSystemAccess);
            }
          }
        } else {
          if ((object instanceof Resource)) {
            instance.doGenerate(((Resource) object), fileSystemAccess);
          } else {
            Class<? extends Object> _class = object.getClass();
            String _simpleName = _class.getSimpleName();
            String _plus_2 = ("Slot contents was not a Resource but a \'" + _simpleName);
            String _plus_3 = (_plus_2 + "\'!");
            IllegalStateException _illegalStateException_1 = new IllegalStateException(_plus_3);
            throw _illegalStateException_1;
          }
        }
      }
    }
  }
  
  protected IGenerator getCompiler() {
    MostGenerator _xblockexpression = null;
    {
      Injector _injector = this.getInjector();
      IGenerator _instance = _injector.<IGenerator>getInstance(IGenerator.class);
      final MostGenerator generator = ((MostGenerator) _instance);
      String _cartridge = this.getCartridge();
      generator.setCartridge(_cartridge);
      _xblockexpression = (generator);
    }
    return _xblockexpression;
  }
  
  protected IFileSystemAccess getConfiguredFileSystemAccess() {
    JavaIoFileSystemAccess _xblockexpression = null;
    {
      Injector _injector = this.getInjector();
      final JavaIoFileSystemAccess configuredFileSystemAccess = _injector.<JavaIoFileSystemAccess>getInstance(JavaIoFileSystemAccess.class);
      Map<String,String> _outlets = this.getOutlets();
      Set<Entry<String,String>> _entrySet = _outlets.entrySet();
      for (final Entry<String,String> outlet : _entrySet) {
        String _key = outlet.getKey();
        String _value = outlet.getValue();
        configuredFileSystemAccess.setOutputPath(_key, _value);
      }
      _xblockexpression = (configuredFileSystemAccess);
    }
    return _xblockexpression;
  }
  
  /**
   * Performs actions after the invocation.
   */
  public void postInvoke() {
  }
}

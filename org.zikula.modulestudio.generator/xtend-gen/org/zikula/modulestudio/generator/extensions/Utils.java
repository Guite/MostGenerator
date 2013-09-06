package org.zikula.modulestudio.generator.extensions;

import com.google.common.base.Objects;
import com.google.common.collect.Iterables;
import com.google.inject.Inject;
import de.guite.modulestudio.metamodel.modulestudio.Application;
import de.guite.modulestudio.metamodel.modulestudio.CoreVersion;
import de.guite.modulestudio.metamodel.modulestudio.Models;
import de.guite.modulestudio.metamodel.modulestudio.Variable;
import de.guite.modulestudio.metamodel.modulestudio.Variables;
import java.util.Date;
import java.util.List;
import org.eclipse.emf.common.util.EList;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.eclipse.xtext.xbase.lib.ListExtensions;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;

/**
 * Miscellaneous utility methods.
 */
@SuppressWarnings("all")
public class Utils {
  /**
   * Extensions used for formatting element names.
   */
  @Inject
  @Extension
  private FormattingExtensions _formattingExtensions = new Function0<FormattingExtensions>() {
    public FormattingExtensions apply() {
      FormattingExtensions _formattingExtensions = new FormattingExtensions();
      return _formattingExtensions;
    }
  }.apply();
  
  /**
   * Returns the version number of ModuleStudio.
   * 
   * @return String The version number.
   */
  public String msVersion() {
    return "0.6.1";
  }
  
  /**
   * Returns the homepage url of ModuleStudio.
   * 
   * @return String The homepage url.
   */
  public String msUrl() {
    return "http://modulestudio.de";
  }
  
  /**
   * Returns the formatted name of the application.
   * 
   * @param it The {@link Application} instance
   * 
   * @return String The formatted name.
   */
  public String appName(final Application it) {
    String _xifexpression = null;
    boolean _targets = this.targets(it, "1.3.5");
    if (_targets) {
      String _name = it.getName();
      String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(_name);
      _xifexpression = _formatForCodeCapital;
    } else {
      String _vendor = it.getVendor();
      String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(_vendor);
      String _name_1 = it.getName();
      String _formatForCodeCapital_2 = this._formattingExtensions.formatForCodeCapital(_name_1);
      String _plus = (_formatForCodeCapital_1 + _formatForCodeCapital_2);
      String _plus_1 = (_plus + "Module");
      _xifexpression = _plus_1;
    }
    return _xifexpression;
  }
  
  /**
   * Returns the base namespace of the application.
   * 
   * @param it The {@link Application} instance
   * 
   * @return String The formatted namespace.
   */
  public String appNamespace(final Application it) {
    String _xifexpression = null;
    boolean _targets = this.targets(it, "1.3.5");
    if (_targets) {
      _xifexpression = "";
    } else {
      String _vendor = it.getVendor();
      String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(_vendor);
      String _plus = (_formatForCodeCapital + "\\");
      String _name = it.getName();
      String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(_name);
      String _plus_1 = (_plus + _formatForCodeCapital_1);
      String _plus_2 = (_plus_1 + "Module");
      _xifexpression = _plus_2;
    }
    return _xifexpression;
  }
  
  /**
   * Returns the lowercase application-specific prefix.
   * 
   * @param it The {@link Application} instance
   * 
   * @return String The prefix.
   */
  public String prefix(final Application it) {
    String _prefix = it.getPrefix();
    String _formatForDB = this._formattingExtensions.formatForDB(_prefix);
    return _formatForDB;
  }
  
  /**
   * Checks whether a given core version is targeted or not.
   * 
   * @param it The {@link Application} instance
   * @param version The version in question
   * 
   * @return Boolean The result.
   */
  public boolean targets(final Application it, final String version) {
    boolean _switchResult = false;
    CoreVersion _targetCoreVersion = it.getTargetCoreVersion();
    final CoreVersion getTargetCoreVersion = _targetCoreVersion;
    boolean _matched = false;
    if (!_matched) {
      if (Objects.equal(getTargetCoreVersion,CoreVersion.ZK135)) {
        _matched=true;
        boolean _equals = Objects.equal(version, "1.3.5");
        _switchResult = _equals;
      }
    }
    if (!_matched) {
      if (Objects.equal(getTargetCoreVersion,CoreVersion.ZK136)) {
        _matched=true;
        boolean _notEquals = (!Objects.equal(version, "1.3.5"));
        _switchResult = _notEquals;
      }
    }
    if (!_matched) {
      boolean _notEquals_1 = (!Objects.equal(version, "1.3.5"));
      _switchResult = _notEquals_1;
    }
    return _switchResult;
  }
  
  /**
   * Checks whether any variables are part of the model or not.
   * 
   * @param it The {@link Application} instance
   * 
   * @return Boolean The result.
   */
  public boolean needsConfig(final Application it) {
    List<Variable> _allVariables = this.getAllVariables(it);
    boolean _isEmpty = _allVariables.isEmpty();
    boolean _not = (!_isEmpty);
    return _not;
  }
  
  /**
   * Checks whether there exist multiple variables containers.
   * 
   * @param it The {@link Application} instance
   * 
   * @return Boolean The result.
   */
  public boolean hasMultipleConfigSections(final Application it) {
    List<Variables> _allVariableContainers = this.getAllVariableContainers(it);
    int _size = _allVariableContainers.size();
    boolean _greaterThan = (_size > 1);
    return _greaterThan;
  }
  
  /**
   * Returns the variables containers sorted by their sort order.
   * 
   * @param it The {@link Application} instance
   * 
   * @return List<Variables> The selected list.
   */
  public List<Variables> getSortedVariableContainers(final Application it) {
    List<Variables> _allVariableContainers = this.getAllVariableContainers(it);
    final Function1<Variables,Integer> _function = new Function1<Variables,Integer>() {
      public Integer apply(final Variables e) {
        int _sortOrder = e.getSortOrder();
        return Integer.valueOf(_sortOrder);
      }
    };
    List<Variables> _sortBy = IterableExtensions.<Variables, Integer>sortBy(_allVariableContainers, _function);
    return _sortBy;
  }
  
  /**
   * Returns all variables containers for a given application.
   * 
   * @param it The {@link Application} instance
   * 
   * @return List<Variables> The selected list.
   */
  public List<Variables> getAllVariableContainers(final Application it) {
    EList<Models> _models = it.getModels();
    final Function1<Models,EList<Variables>> _function = new Function1<Models,EList<Variables>>() {
      public EList<Variables> apply(final Models e) {
        EList<Variables> _variables = e.getVariables();
        return _variables;
      }
    };
    List<EList<Variables>> _map = ListExtensions.<Models, EList<Variables>>map(_models, _function);
    Iterable<Variables> _flatten = Iterables.<Variables>concat(_map);
    List<Variables> _list = IterableExtensions.<Variables>toList(_flatten);
    return _list;
  }
  
  /**
   * Returns all variables for a given application.
   * 
   * @param it The {@link Application} instance
   * 
   * @return List<Variable> The selected list.
   */
  public List<Variable> getAllVariables(final Application it) {
    List<Variables> _allVariableContainers = this.getAllVariableContainers(it);
    final Function1<Variables,EList<Variable>> _function = new Function1<Variables,EList<Variable>>() {
      public EList<Variable> apply(final Variables e) {
        EList<Variable> _vars = e.getVars();
        return _vars;
      }
    };
    List<EList<Variable>> _map = ListExtensions.<Variables, EList<Variable>>map(_allVariableContainers, _function);
    Iterable<Variable> _flatten = Iterables.<Variable>concat(_map);
    List<Variable> _list = IterableExtensions.<Variable>toList(_flatten);
    return _list;
  }
  
  /**
   * Helper function for building id attributes for input fields in edit templates.
   * 
   * @param name The given name
   * @param suffix The given suffix
   * 
   * @return String The concatenated identifier.
   */
  public String templateIdWithSuffix(final String name, final String suffix) {
    String _xifexpression = null;
    boolean _and = false;
    boolean _tripleNotEquals = (suffix != null);
    if (!_tripleNotEquals) {
      _and = false;
    } else {
      boolean _notEquals = (!Objects.equal(suffix, ""));
      _and = (_tripleNotEquals && _notEquals);
    }
    if (_and) {
      String _plus = ("\"" + name);
      String _plus_1 = (_plus + "`");
      String _plus_2 = (_plus_1 + suffix);
      String _plus_3 = (_plus_2 + "`\"");
      _xifexpression = _plus_3;
    } else {
      String _plus_4 = ("\'" + name);
      String _plus_5 = (_plus_4 + "\'");
      _xifexpression = _plus_5;
    }
    return _xifexpression;
  }
  
  /**
   * Returns the current timestamp to mark the generation time.
   * 
   * @return String The current timestamp.
   */
  public String timestamp() {
    String _xblockexpression = null;
    {
      final long currentTime = System.currentTimeMillis();
      Date _date = new Date(currentTime);
      final Date d = _date;
      String _string = d.toString();
      _xblockexpression = (_string);
    }
    return _xblockexpression;
  }
}

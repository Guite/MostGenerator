package org.zikula.modulestudio.generator.extensions;

import com.google.common.base.Objects;
import com.google.inject.Inject;
import de.guite.modulestudio.metamodel.modulestudio.DerivedField;
import de.guite.modulestudio.metamodel.modulestudio.Entity;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;

/**
 * This class contains extension methods for building urls, i.e. modurl calls.
 */
@SuppressWarnings("all")
public class UrlExtensions {
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
   * Extensions related to behavioural aspects of the model layer.
   */
  @Inject
  @Extension
  private ModelBehaviourExtensions _modelBehaviourExtensions = new Function0<ModelBehaviourExtensions>() {
    public ModelBehaviourExtensions apply() {
      ModelBehaviourExtensions _modelBehaviourExtensions = new ModelBehaviourExtensions();
      return _modelBehaviourExtensions;
    }
  }.apply();
  
  /**
   * Extensions related to the model layer.
   */
  @Inject
  @Extension
  private ModelExtensions _modelExtensions = new Function0<ModelExtensions>() {
    public ModelExtensions apply() {
      ModelExtensions _modelExtensions = new ModelExtensions();
      return _modelExtensions;
    }
  }.apply();
  
  /**
   * Creates the parameters for a modurl call relating a given entity,
   * either for a Zikula_View template or for php source code.
   * 
   * @param it The {@link Entity} to be linked to
   * @param func The function to be called by the url
   * @param ot The treated object type
   * @param objName The name of the object variable carrying the entity object in the output
   * @param template Whether to create the syntax for a template (true) or for source code (false)
   * @return String collected url parameter string.
   */
  public String modUrlGeneric(final Entity it, final String func, final String ot, final String objName, final Boolean template) {
    String _xifexpression = null;
    if ((template).booleanValue()) {
      String _plus = ("func=\'" + func);
      String _plus_1 = (_plus + "\' ot=\'");
      String _formatForCode = this._formattingExtensions.formatForCode(ot);
      String _plus_2 = (_plus_1 + _formatForCode);
      String _plus_3 = (_plus_2 + "\'");
      CharSequence _modUrlPrimaryKeyParams = this.modUrlPrimaryKeyParams(it, objName, template);
      String _plus_4 = (_plus_3 + _modUrlPrimaryKeyParams);
      String _xifexpression_1 = null;
      boolean _equals = Objects.equal(func, "display");
      if (_equals) {
        String _appendSlug = this.appendSlug(it, objName, template);
        _xifexpression_1 = _appendSlug;
      } else {
        _xifexpression_1 = "";
      }
      String _plus_5 = (_plus_4 + _xifexpression_1);
      _xifexpression = _plus_5;
    } else {
      String _plus_6 = ("\'" + func);
      String _plus_7 = (_plus_6 + "\', array(\'ot\' => \'");
      String _formatForCode_1 = this._formattingExtensions.formatForCode(ot);
      String _plus_8 = (_plus_7 + _formatForCode_1);
      String _plus_9 = (_plus_8 + "\'");
      CharSequence _modUrlPrimaryKeyParams_1 = this.modUrlPrimaryKeyParams(it, objName, template);
      String _plus_10 = (_plus_9 + _modUrlPrimaryKeyParams_1);
      String _xifexpression_2 = null;
      boolean _equals_1 = Objects.equal(func, "display");
      if (_equals_1) {
        String _appendSlug_1 = this.appendSlug(it, objName, template);
        _xifexpression_2 = _appendSlug_1;
      } else {
        _xifexpression_2 = "";
      }
      String _plus_11 = (_plus_10 + _xifexpression_2);
      String _plus_12 = (_plus_11 + ")");
      _xifexpression = _plus_12;
    }
    return _xifexpression;
  }
  
  /**
   * Creates the parameters for a modurl call relating a given entity,
   * either for a Zikula_View template or for php source code.
   * 
   * @param it The {@link Entity} to be linked to
   * @param func The function to be called by the url
   * @param ot The treated object type
   * @param objName The name of the object variable carrying the entity object in the output
   * @param template Whether to create the syntax for a template (true) or for source code (false)
   * @param customVarName Custom name for using another field name as url parameter
   * @return String collected url parameter string.
   */
  public String modUrlGeneric(final Entity it, final String func, final String ot, final String objName, final Boolean template, final String customVarName) {
    String _xifexpression = null;
    if ((template).booleanValue()) {
      String _plus = ("func=\'" + func);
      String _plus_1 = (_plus + "\' ot=\'");
      String _formatForCode = this._formattingExtensions.formatForCode(ot);
      String _plus_2 = (_plus_1 + _formatForCode);
      String _plus_3 = (_plus_2 + "\'");
      String _modUrlPrimaryKeyParams = this.modUrlPrimaryKeyParams(it, objName, template, customVarName);
      String _plus_4 = (_plus_3 + _modUrlPrimaryKeyParams);
      _xifexpression = _plus_4;
    } else {
      String _plus_5 = ("\'" + func);
      String _plus_6 = (_plus_5 + "\', array(\'ot\' => \'");
      String _formatForCode_1 = this._formattingExtensions.formatForCode(ot);
      String _plus_7 = (_plus_6 + _formatForCode_1);
      String _plus_8 = (_plus_7 + "\'");
      String _modUrlPrimaryKeyParams_1 = this.modUrlPrimaryKeyParams(it, objName, template, customVarName);
      String _plus_9 = (_plus_8 + _modUrlPrimaryKeyParams_1);
      String _plus_10 = (_plus_9 + ")");
      _xifexpression = _plus_10;
    }
    return _xifexpression;
  }
  
  /**
   * Creates the parameters for a modurl call to a display function relating a given entity,
   * either for a Zikula_View template or for php source code.
   * 
   * @param it The {@link Entity} to be linked to
   * @param objName The name of the object variable carrying the entity object in the output
   * @param template Whether to create the syntax for a template (true) or for source code (false)
   * @param otVar Custom name for the object type parameter
   * @return String collected url parameter string.
   */
  public String modUrlDisplayWithFreeOt(final Entity it, final String objName, final Boolean template, final String otVar) {
    String _xifexpression = null;
    if ((template).booleanValue()) {
      String _plus = ("func=\'display\' ot=" + otVar);
      CharSequence _modUrlPrimaryKeyParams = this.modUrlPrimaryKeyParams(it, objName, template);
      String _plus_1 = (_plus + _modUrlPrimaryKeyParams);
      String _appendSlug = this.appendSlug(it, objName, template);
      String _plus_2 = (_plus_1 + _appendSlug);
      _xifexpression = _plus_2;
    } else {
      String _plus_3 = ("\'display\', array(\'ot\' => " + otVar);
      CharSequence _modUrlPrimaryKeyParams_1 = this.modUrlPrimaryKeyParams(it, objName, template);
      String _plus_4 = (_plus_3 + _modUrlPrimaryKeyParams_1);
      String _appendSlug_1 = this.appendSlug(it, objName, template);
      String _plus_5 = (_plus_4 + _appendSlug_1);
      String _plus_6 = (_plus_5 + ")");
      _xifexpression = _plus_6;
    }
    return _xifexpression;
  }
  
  /**
   * Creates the parameters for a modurl call to a display function relating a given entity,
   * either for a Zikula_View template or for php source code.
   * 
   * @param it The {@link Entity} to be linked to
   * @param objName The name of the object variable carrying the entity object in the output
   * @param template Whether to create the syntax for a template (true) or for source code (false)
   * @return String collected url parameter string.
   */
  public String modUrlDisplay(final Entity it, final String objName, final Boolean template) {
    String _name = it.getName();
    String _modUrlGeneric = this.modUrlGeneric(it, "display", _name, objName, template);
    return _modUrlGeneric;
  }
  
  /**
   * Appends the slug parameter (if available) to display url arguments.
   * 
   * @param it The {@link Entity} to be linked to
   * @param objName The name of the object variable carrying the entity object in the output
   * @param template Whether to create the syntax for a template (true) or for source code (false)
   * @return String the slug parameter assignment.
   */
  private String appendSlug(final Entity it, final String objName, final Boolean template) {
    String _xifexpression = null;
    boolean _hasSluggableFields = this._modelBehaviourExtensions.hasSluggableFields(it);
    if (_hasSluggableFields) {
      String _xifexpression_1 = null;
      if ((template).booleanValue()) {
        String _plus = (" slug=$" + objName);
        String _plus_1 = (_plus + ".slug");
        _xifexpression_1 = _plus_1;
      } else {
        String _plus_2 = (", \'slug\' => $" + objName);
        String _plus_3 = (_plus_2 + "[\'slug\']");
        _xifexpression_1 = _plus_3;
      }
      _xifexpression = _xifexpression_1;
    } else {
      _xifexpression = "";
    }
    return _xifexpression;
  }
  
  /**
   * Creates the parameters for a modurl call to an edit function relating a given entity,
   * either for a Zikula_View template or for php source code.
   * 
   * @param it The {@link Entity} to be linked to
   * @param objName The name of the object variable carrying the entity object in the output
   * @param template Whether to create the syntax for a template (true) or for source code (false)
   * @return String collected url parameter string.
   */
  public String modUrlEdit(final Entity it, final String objName, final Boolean template) {
    String _name = it.getName();
    String _modUrlGeneric = this.modUrlGeneric(it, "edit", _name, objName, template);
    return _modUrlGeneric;
  }
  
  /**
   * Creates the parameters for a modurl call to an edit function relating a given entity,
   * either for a Zikula_View template or for php source code.
   * 
   * @param it The {@link Entity} to be linked to
   * @param objName The name of the object variable carrying the entity object in the output
   * @param template Whether to create the syntax for a template (true) or for source code (false)
   * @param customVarName Custom name for using another field name as url parameter
   * @return String collected url parameter string.
   */
  public String modUrlEdit(final Entity it, final String objName, final Boolean template, final String customVarName) {
    String _name = it.getName();
    String _modUrlGeneric = this.modUrlGeneric(it, "edit", _name, objName, template, customVarName);
    return _modUrlGeneric;
  }
  
  /**
   * Creates the parameters for a modurl call to a delete function relating a given entity,
   * either for a Zikula_View template or for php source code.
   * 
   * @param it The {@link Entity} to be linked to
   * @param objName The name of the object variable carrying the entity object in the output
   * @param template Whether to create the syntax for a template (true) or for source code (false)
   * @return String collected url parameter string.
   */
  public String modUrlDelete(final Entity it, final String objName, final Boolean template) {
    String _name = it.getName();
    String _modUrlGeneric = this.modUrlGeneric(it, "delete", _name, objName, template);
    return _modUrlGeneric;
  }
  
  /**
   * Collects primary key parameters for a modurl call relating a given entity,
   * either for a Zikula_View template or for php source code.
   * 
   * @param it The {@link Entity} to be linked to
   * @param objName The name of the object variable carrying the entity object in the output
   * @param template Whether to create the syntax for a template (true) or for source code (false)
   * @return String collected url parameter string.
   */
  public CharSequence modUrlPrimaryKeyParams(final Entity it, final String objName, final Boolean template) {
    CharSequence _xifexpression = null;
    if ((template).booleanValue()) {
      Iterable<DerivedField> _primaryKeyFields = this._modelExtensions.getPrimaryKeyFields(it);
      CharSequence _singleParamForTemplate = this.getSingleParamForTemplate(_primaryKeyFields, objName);
      _xifexpression = _singleParamForTemplate;
    } else {
      Iterable<DerivedField> _primaryKeyFields_1 = this._modelExtensions.getPrimaryKeyFields(it);
      CharSequence _singleParamForCode = this.getSingleParamForCode(_primaryKeyFields_1, objName);
      _xifexpression = _singleParamForCode;
    }
    return _xifexpression;
  }
  
  /**
   * Collects primary key parameters for a modurl call relating a given entity,
   * either for a Zikula_View template or for php source code.
   * 
   * @param it The {@link Entity} to be linked to
   * @param objName The name of the object variable carrying the entity object in the output
   * @param template Whether to create the syntax for a template (true) or for source code (false)
   * @param customVarName Custom name for using another field name as url parameter
   * @return String collected url parameter string.
   */
  public String modUrlPrimaryKeyParams(final Entity it, final String objName, final Boolean template, final String customVarName) {
    String _xifexpression = null;
    if ((template).booleanValue()) {
      Iterable<DerivedField> _primaryKeyFields = this._modelExtensions.getPrimaryKeyFields(it);
      String _singleParamForTemplate = this.getSingleParamForTemplate(_primaryKeyFields, objName, customVarName);
      _xifexpression = _singleParamForTemplate;
    } else {
      Iterable<DerivedField> _primaryKeyFields_1 = this._modelExtensions.getPrimaryKeyFields(it);
      String _singleParamForCode = this.getSingleParamForCode(_primaryKeyFields_1, objName, customVarName);
      _xifexpression = _singleParamForCode;
    }
    return _xifexpression;
  }
  
  /**
   * Returns a single parameter pair for a modurl call in a source code file.
   * 
   * @param it An {@link Iterable} of primary key fields to be linked to
   * @param objName The name of the object variable carrying the entity object in the output
   * @return String collected url parameter string.
   */
  public CharSequence getSingleParamForCode(final Iterable<DerivedField> it, final String objName) {
    String _xifexpression = null;
    int _size = IterableExtensions.size(it);
    boolean _equals = (_size == 0);
    if (_equals) {
      _xifexpression = "";
    } else {
      DerivedField _head = IterableExtensions.<DerivedField>head(it);
      String _name = _head.getName();
      String _formatForCode = this._formattingExtensions.formatForCode(_name);
      String _plus = (", \'" + _formatForCode);
      String _plus_1 = (_plus + "\' => $");
      String _plus_2 = (_plus_1 + objName);
      String _plus_3 = (_plus_2 + "[\'");
      DerivedField _head_1 = IterableExtensions.<DerivedField>head(it);
      String _name_1 = _head_1.getName();
      String _formatForCode_1 = this._formattingExtensions.formatForCode(_name_1);
      String _plus_4 = (_plus_3 + _formatForCode_1);
      String _plus_5 = (_plus_4 + "\']");
      Iterable<DerivedField> _tail = IterableExtensions.<DerivedField>tail(it);
      CharSequence _singleParamForCode = this.getSingleParamForCode(_tail, objName);
      String _plus_6 = (_plus_5 + _singleParamForCode);
      _xifexpression = _plus_6;
    }
    return _xifexpression;
  }
  
  /**
   * Returns a single parameter pair for a modurl call in a template file.
   * 
   * @param it An {@link Iterable} of primary key fields to be linked to
   * @param objName The name of the object variable carrying the entity object in the output
   * @return String collected url parameter string.
   */
  public CharSequence getSingleParamForTemplate(final Iterable<DerivedField> it, final String objName) {
    String _xifexpression = null;
    int _size = IterableExtensions.size(it);
    boolean _equals = (_size == 0);
    if (_equals) {
      _xifexpression = "";
    } else {
      DerivedField _head = IterableExtensions.<DerivedField>head(it);
      String _name = _head.getName();
      String _formatForCode = this._formattingExtensions.formatForCode(_name);
      String _plus = (" " + _formatForCode);
      String _plus_1 = (_plus + "=$");
      String _plus_2 = (_plus_1 + objName);
      String _plus_3 = (_plus_2 + ".");
      DerivedField _head_1 = IterableExtensions.<DerivedField>head(it);
      String _name_1 = _head_1.getName();
      String _formatForCode_1 = this._formattingExtensions.formatForCode(_name_1);
      String _plus_4 = (_plus_3 + _formatForCode_1);
      Iterable<DerivedField> _tail = IterableExtensions.<DerivedField>tail(it);
      CharSequence _singleParamForTemplate = this.getSingleParamForTemplate(_tail, objName);
      String _plus_5 = (_plus_4 + _singleParamForTemplate);
      _xifexpression = _plus_5;
    }
    return _xifexpression;
  }
  
  /**
   * Returns a single parameter pair for a modurl call in a source code file.
   * 
   * @param it An {@link Iterable} of primary key fields to be linked to
   * @param objName The name of the object variable carrying the entity object in the output
   * @param customVarName Custom name for using another field name as url parameter
   * @return String collected url parameter string.
   */
  public String getSingleParamForCode(final Iterable<DerivedField> it, final String objName, final String customVarName) {
    String _xifexpression = null;
    int _size = IterableExtensions.size(it);
    boolean _equals = (_size == 0);
    if (_equals) {
      _xifexpression = "";
    } else {
      String _plus = (", \'" + customVarName);
      String _plus_1 = (_plus + "\' => $");
      String _plus_2 = (_plus_1 + objName);
      String _plus_3 = (_plus_2 + "[\'");
      DerivedField _head = IterableExtensions.<DerivedField>head(it);
      String _name = _head.getName();
      String _formatForDB = this._formattingExtensions.formatForDB(_name);
      String _plus_4 = (_plus_3 + _formatForDB);
      String _plus_5 = (_plus_4 + "\']");
      Iterable<DerivedField> _tail = IterableExtensions.<DerivedField>tail(it);
      CharSequence _singleParamForCode = this.getSingleParamForCode(_tail, objName);
      String _plus_6 = (_plus_5 + _singleParamForCode);
      _xifexpression = _plus_6;
    }
    return _xifexpression;
  }
  
  /**
   * Returns a single parameter pair for a modurl call in a template file.
   * 
   * @param it An {@link Iterable} of primary key fields to be linked to
   * @param objName The name of the object variable carrying the entity object in the output
   * @param customVarName Custom name for using another field name as url parameter
   * @return String collected url parameter string.
   */
  public String getSingleParamForTemplate(final Iterable<DerivedField> it, final String objName, final String customVarName) {
    String _xifexpression = null;
    int _size = IterableExtensions.size(it);
    boolean _equals = (_size == 0);
    if (_equals) {
      _xifexpression = "";
    } else {
      String _plus = (" " + customVarName);
      String _plus_1 = (_plus + "=$");
      String _plus_2 = (_plus_1 + objName);
      String _plus_3 = (_plus_2 + ".");
      DerivedField _head = IterableExtensions.<DerivedField>head(it);
      String _name = _head.getName();
      String _formatForDB = this._formattingExtensions.formatForDB(_name);
      String _plus_4 = (_plus_3 + _formatForDB);
      Iterable<DerivedField> _tail = IterableExtensions.<DerivedField>tail(it);
      CharSequence _singleParamForTemplate = this.getSingleParamForTemplate(_tail, objName);
      String _plus_5 = (_plus_4 + _singleParamForTemplate);
      _xifexpression = _plus_5;
    }
    return _xifexpression;
  }
}

package org.zikula.modulestudio.generator.extensions;

import de.guite.modulestudio.metamodel.DerivedField;
import de.guite.modulestudio.metamodel.Entity;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;

/**
 * This class contains extension methods for building routes.
 */
@SuppressWarnings("all")
public class UrlExtensions {
  /**
   * Extensions used for formatting element names.
   */
  @Extension
  private FormattingExtensions _formattingExtensions = new FormattingExtensions();
  
  /**
   * Extensions related to behavioural aspects of the model layer.
   */
  @Extension
  private ModelBehaviourExtensions _modelBehaviourExtensions = new ModelBehaviourExtensions();
  
  /**
   * Extensions related to the model layer.
   */
  @Extension
  private ModelExtensions _modelExtensions = new ModelExtensions();
  
  /**
   * Collects parameters for a route relating a given entity,
   * either for a Twig template or for php source code.
   * 
   * @param it The {@link Entity} to be linked to
   * @param objName The name of the object variable carrying the entity object in the output
   * @param template Whether to create the syntax for a template (true) or for source code (false)
   * @return String collected url parameter string.
   */
  public CharSequence routeParams(final Entity it, final String objName, final Boolean template) {
    StringConcatenation _builder = new StringConcatenation();
    {
      if ((template).booleanValue()) {
        _builder.append(", { ");
      }
    }
    CharSequence _routePkParams = this.routePkParams(it, objName, template);
    _builder.append(_routePkParams);
    CharSequence _appendSlug = this.appendSlug(it, objName, template);
    _builder.append(_appendSlug);
    {
      if ((template).booleanValue()) {
        _builder.append(" }");
      }
    }
    return _builder;
  }
  
  /**
   * Collects parameters for a route relating a given entity,
   * either for a Twig template or for php source code.
   * 
   * @param it The {@link Entity} to be linked to
   * @param objName The name of the object variable carrying the entity object in the output
   * @param template Whether to create the syntax for a template (true) or for source code (false)
   * @param customVarName Custom name for using another field name as url parameter
   * @return String collected url parameter string.
   */
  public CharSequence routeParams(final Entity it, final String objName, final Boolean template, final String customVarName) {
    StringConcatenation _builder = new StringConcatenation();
    {
      if ((template).booleanValue()) {
        _builder.append(", { ");
      }
    }
    String _routePkParams = this.routePkParams(it, objName, template, customVarName);
    _builder.append(_routePkParams);
    CharSequence _appendSlug = this.appendSlug(it, objName, template);
    _builder.append(_appendSlug);
    {
      if ((template).booleanValue()) {
        _builder.append(" }");
      }
    }
    return _builder;
  }
  
  /**
   * Collects primary key parameters for a route relating a given entity,
   * either for a Twig template or for php source code.
   * 
   * @param it The {@link Entity} to be linked to
   * @param objName The name of the object variable carrying the entity object in the output
   * @param template Whether to create the syntax for a template (true) or for source code (false)
   * @return String collected url parameter string.
   */
  public CharSequence routePkParams(final Entity it, final String objName, final Boolean template) {
    CharSequence _xifexpression = null;
    if ((template).booleanValue()) {
      _xifexpression = this.routeParamsForTemplate(this._modelExtensions.getPrimaryKeyFields(it), objName);
    } else {
      _xifexpression = this.routeParamsForCode(this._modelExtensions.getPrimaryKeyFields(it), objName).toString().substring(2);
    }
    return _xifexpression;
  }
  
  /**
   * Collects primary key parameters for a route relating a given entity,
   * either for a Twig template or for php source code.
   * 
   * @param it The {@link Entity} to be linked to
   * @param objName The name of the object variable carrying the entity object in the output
   * @param template Whether to create the syntax for a template (true) or for source code (false)
   * @param customVarName Custom name for using another field name as url parameter
   * @return String collected url parameter string.
   */
  private String routePkParams(final Entity it, final String objName, final Boolean template, final String customVarName) {
    String _xifexpression = null;
    if ((template).booleanValue()) {
      _xifexpression = this.routeParamsForTemplate(this._modelExtensions.getPrimaryKeyFields(it), objName, customVarName);
    } else {
      _xifexpression = this.routeParamsForCode(this._modelExtensions.getPrimaryKeyFields(it), objName, customVarName).substring(2);
    }
    return _xifexpression;
  }
  
  /**
   * Appends the slug parameter (if available) to url arguments for display, edit and delete pages.
   * 
   * @param it The {@link Entity} to be linked to
   * @param objName The name of the object variable carrying the entity object in the output
   * @param template Whether to create the syntax for a template (true) or for source code (false)
   * @return String the slug parameter assignment.
   */
  public CharSequence appendSlug(final Entity it, final String objName, final Boolean template) {
    CharSequence _xifexpression = null;
    boolean _hasSluggableFields = this._modelBehaviourExtensions.hasSluggableFields(it);
    if (_hasSluggableFields) {
      CharSequence _xifexpression_1 = null;
      if ((template).booleanValue()) {
        StringConcatenation _builder = new StringConcatenation();
        _builder.append(", \'slug\': ");
        _builder.append(objName);
        _builder.append(".slug");
        _xifexpression_1 = _builder;
      } else {
        StringConcatenation _builder_1 = new StringConcatenation();
        _builder_1.append(", \'slug\' => $");
        _builder_1.append(objName);
        _builder_1.append("[\'slug\']");
        _xifexpression_1 = _builder_1;
      }
      _xifexpression = _xifexpression_1;
    } else {
      _xifexpression = "";
    }
    return _xifexpression;
  }
  
  /**
   * Returns a parameter pair for each given field for a route in a source code file.
   * 
   * @param it An {@link Iterable} of primary key fields to be linked to
   * @param objName The name of the object variable carrying the entity object in the output
   * @return String collected url parameter string.
   */
  private CharSequence routeParamsForCode(final Iterable<DerivedField> it, final String objName) {
    String _xifexpression = null;
    int _size = IterableExtensions.size(it);
    boolean _equals = (_size == 0);
    if (_equals) {
      _xifexpression = "";
    } else {
      String _formatForCode = this._formattingExtensions.formatForCode(IterableExtensions.<DerivedField>head(it).getName());
      String _plus = (", \'" + _formatForCode);
      String _plus_1 = (_plus + "\' => $");
      String _plus_2 = (_plus_1 + objName);
      String _plus_3 = (_plus_2 + "[\'");
      String _formatForCode_1 = this._formattingExtensions.formatForCode(IterableExtensions.<DerivedField>head(it).getName());
      String _plus_4 = (_plus_3 + _formatForCode_1);
      String _plus_5 = (_plus_4 + "\']");
      CharSequence _routeParamsForCode = this.routeParamsForCode(IterableExtensions.<DerivedField>tail(it), objName);
      _xifexpression = (_plus_5 + _routeParamsForCode);
    }
    return _xifexpression;
  }
  
  /**
   * Returns a parameter pair for each given field for a route in a template file.
   * 
   * @param it An {@link Iterable} of primary key fields to be linked to
   * @param objName The name of the object variable carrying the entity object in the output
   * @return String collected url parameter string.
   */
  private CharSequence routeParamsForTemplate(final Iterable<DerivedField> it, final String objName) {
    String _xifexpression = null;
    int _size = IterableExtensions.size(it);
    boolean _equals = (_size == 0);
    if (_equals) {
      _xifexpression = "";
    } else {
      String _formatForCode = this._formattingExtensions.formatForCode(IterableExtensions.<DerivedField>head(it).getName());
      String _plus = ("\'" + _formatForCode);
      String _plus_1 = (_plus + "\': ");
      String _plus_2 = (_plus_1 + objName);
      String _plus_3 = (_plus_2 + ".");
      String _formatForCode_1 = this._formattingExtensions.formatForCode(IterableExtensions.<DerivedField>head(it).getName());
      String _plus_4 = (_plus_3 + _formatForCode_1);
      String _xifexpression_1 = null;
      int _size_1 = IterableExtensions.size(it);
      boolean _greaterThan = (_size_1 > 1);
      if (_greaterThan) {
        _xifexpression_1 = ", ";
      } else {
        _xifexpression_1 = "";
      }
      String _plus_5 = (_plus_4 + _xifexpression_1);
      CharSequence _routeParamsForTemplate = this.routeParamsForTemplate(IterableExtensions.<DerivedField>tail(it), objName);
      _xifexpression = (_plus_5 + _routeParamsForTemplate);
    }
    return _xifexpression;
  }
  
  /**
   * Returns a single parameter pair for a route in a source code file.
   * 
   * @param it An {@link Iterable} of primary key fields to be linked to
   * @param objName The name of the object variable carrying the entity object in the output
   * @param customVarName Custom name for using another field name as url parameter
   * @return String collected url parameter string.
   */
  private String routeParamsForCode(final Iterable<DerivedField> it, final String objName, final String customVarName) {
    String _xifexpression = null;
    int _size = IterableExtensions.size(it);
    boolean _equals = (_size == 0);
    if (_equals) {
      _xifexpression = "";
    } else {
      String _formatForDB = this._formattingExtensions.formatForDB(IterableExtensions.<DerivedField>head(it).getName());
      String _plus = (((((", \'" + customVarName) + "\' => $") + objName) + "[\'") + _formatForDB);
      String _plus_1 = (_plus + "\']");
      CharSequence _routeParamsForCode = this.routeParamsForCode(IterableExtensions.<DerivedField>tail(it), objName);
      _xifexpression = (_plus_1 + _routeParamsForCode);
    }
    return _xifexpression;
  }
  
  /**
   * Returns a single parameter pair for a route in a template file.
   * 
   * @param it An {@link Iterable} of primary key fields to be linked to
   * @param objName The name of the object variable carrying the entity object in the output
   * @param customVarName Custom name for using another field name as url parameter
   * @return String collected url parameter string.
   */
  private String routeParamsForTemplate(final Iterable<DerivedField> it, final String objName, final String customVarName) {
    String _xifexpression = null;
    int _size = IterableExtensions.size(it);
    boolean _equals = (_size == 0);
    if (_equals) {
      _xifexpression = "";
    } else {
      String _formatForCode = this._formattingExtensions.formatForCode(IterableExtensions.<DerivedField>head(it).getName());
      String _plus = ((((("\'" + customVarName) + "\': ") + objName) + ".") + _formatForCode);
      String _xifexpression_1 = null;
      boolean _isEmpty = IterableExtensions.isEmpty(it);
      boolean _not = (!_isEmpty);
      if (_not) {
        _xifexpression_1 = ", ";
      } else {
        _xifexpression_1 = "";
      }
      String _plus_1 = (_plus + _xifexpression_1);
      CharSequence _routeParamsForTemplate = this.routeParamsForTemplate(IterableExtensions.<DerivedField>tail(it), objName);
      _xifexpression = (_plus_1 + _routeParamsForTemplate);
    }
    return _xifexpression;
  }
}

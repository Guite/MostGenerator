package org.zikula.modulestudio.generator.cartridges.zclassic.controller.action;

import com.google.common.base.Objects;
import de.guite.modulestudio.metamodel.Action;
import de.guite.modulestudio.metamodel.Application;
import de.guite.modulestudio.metamodel.CustomAction;
import de.guite.modulestudio.metamodel.DeleteAction;
import de.guite.modulestudio.metamodel.DerivedField;
import de.guite.modulestudio.metamodel.DisplayAction;
import de.guite.modulestudio.metamodel.EditAction;
import de.guite.modulestudio.metamodel.Entity;
import de.guite.modulestudio.metamodel.EntityTreeType;
import de.guite.modulestudio.metamodel.MainAction;
import de.guite.modulestudio.metamodel.ViewAction;
import java.util.ArrayList;
import java.util.Arrays;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;
import org.zikula.modulestudio.generator.extensions.ViewExtensions;

@SuppressWarnings("all")
public class Annotations {
  @Extension
  private FormattingExtensions _formattingExtensions = new FormattingExtensions();
  
  @Extension
  private ModelBehaviourExtensions _modelBehaviourExtensions = new ModelBehaviourExtensions();
  
  @Extension
  private ModelExtensions _modelExtensions = new ModelExtensions();
  
  @Extension
  private Utils _utils = new Utils();
  
  @Extension
  private ViewExtensions _viewExtensions = new ViewExtensions();
  
  private Application app;
  
  public Annotations(final Application app) {
    this.app = app;
  }
  
  public CharSequence generate(final Action it, final Entity entity, final Boolean isBase, final Boolean isAdmin) {
    StringConcatenation _builder = new StringConcatenation();
    {
      if ((!(isBase).booleanValue())) {
        CharSequence _actionRoute = this.actionRoute(it, entity, isAdmin);
        _builder.append(_actionRoute);
        _builder.newLineIfNotEmpty();
        {
          if ((isAdmin).booleanValue()) {
            _builder.append(" ");
            _builder.append("* @Theme(\"admin\")");
            _builder.newLineIfNotEmpty();
          }
        }
      } else {
        {
          if ((null != entity)) {
            {
              if (((it instanceof DisplayAction) || (it instanceof DeleteAction))) {
                CharSequence _paramConverter = this.paramConverter(entity);
                _builder.append(_paramConverter);
                _builder.newLineIfNotEmpty();
              }
            }
            {
              if ((it instanceof MainAction)) {
                _builder.append(" ");
                _builder.append("* @Cache(expires=\"+7 days\", public=true)");
                _builder.newLineIfNotEmpty();
              } else {
                if ((it instanceof ViewAction)) {
                  _builder.append(" ");
                  _builder.append("* @Cache(expires=\"+2 hours\", public=false)");
                  _builder.newLineIfNotEmpty();
                } else {
                  if ((!(it instanceof CustomAction))) {
                    {
                      boolean _isStandardFields = entity.isStandardFields();
                      if (_isStandardFields) {
                        _builder.append(" ");
                        _builder.append("* @Cache(lastModified=\"");
                        String _formatForCode = this._formattingExtensions.formatForCode(entity.getName());
                        _builder.append(_formatForCode);
                        _builder.append(".getUpdatedDate()\", ETag=\"\'");
                        String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(entity.getName());
                        _builder.append(_formatForCodeCapital);
                        _builder.append("\' ~ ");
                        final Function1<DerivedField, String> _function = (DerivedField it_1) -> {
                          String _formatForCode_1 = this._formattingExtensions.formatForCode(entity.getName());
                          String _plus = (_formatForCode_1 + ".get");
                          String _formatForCode_2 = this._formattingExtensions.formatForCode(it_1.getName());
                          String _plus_1 = (_plus + _formatForCode_2);
                          return (_plus_1 + "()");
                        };
                        String _join = IterableExtensions.join(IterableExtensions.<DerivedField, String>map(this._modelExtensions.getPrimaryKeyFields(entity), _function), " ~ ");
                        _builder.append(_join);
                        _builder.append(" ~ ");
                        String _formatForCode_1 = this._formattingExtensions.formatForCode(entity.getName());
                        _builder.append(_formatForCode_1);
                        _builder.append(".getUpdatedDate().format(\'U\')\")");
                        _builder.newLineIfNotEmpty();
                      } else {
                        {
                          if ((it instanceof EditAction)) {
                            _builder.append(" ");
                            _builder.append("* @Cache(expires=\"+30 minutes\", public=false)");
                            _builder.newLineIfNotEmpty();
                          } else {
                            _builder.append(" ");
                            _builder.append("* @Cache(expires=\"+12 hours\", public=false)");
                            _builder.newLineIfNotEmpty();
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
    return _builder;
  }
  
  private CharSequence _actionRoute(final Action it, final Entity entity, final Boolean isAdmin) {
    StringConcatenation _builder = new StringConcatenation();
    return _builder;
  }
  
  private CharSequence _actionRoute(final MainAction it, final Entity entity, final Boolean isAdmin) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("* @Route(\"/");
    {
      if ((isAdmin).booleanValue()) {
        _builder.append("admin/");
      }
    }
    String _formatForCode = this._formattingExtensions.formatForCode(entity.getNameMultiple());
    _builder.append(_formatForCode);
    _builder.append("\",");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*        methods = {\"GET\"}");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("* )");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence _actionRoute(final ViewAction it, final Entity entity, final Boolean isAdmin) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("* @Route(\"/");
    {
      if ((isAdmin).booleanValue()) {
        _builder.append("admin/");
      }
    }
    String _formatForCode = this._formattingExtensions.formatForCode(entity.getNameMultiple());
    _builder.append(_formatForCode);
    _builder.append("/view/{sort}/{sortdir}/{pos}/{num}.{_format}\",");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*        requirements = {\"sortdir\" = \"asc|desc|ASC|DESC\", \"pos\" = \"\\d+\", \"num\" = \"\\d+\", \"_format\" = \"html");
    {
      int _size = this._viewExtensions.getListOfViewFormats(this.app).size();
      boolean _greaterThan = (_size > 0);
      if (_greaterThan) {
        _builder.append("|");
        {
          ArrayList<String> _listOfViewFormats = this._viewExtensions.getListOfViewFormats(this.app);
          boolean _hasElements = false;
          for(final String format : _listOfViewFormats) {
            if (!_hasElements) {
              _hasElements = true;
            } else {
              _builder.appendImmediate("|", "");
            }
            _builder.append(format);
          }
        }
      }
    }
    _builder.append("\"},");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*        defaults = {\"sort\" = \"\", \"sortdir\" = \"asc\", \"pos\" = 1, \"num\" = 10, \"_format\" = \"html\"},");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*        methods = {\"GET\"}");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("* )");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence actionRouteForSingleEntity(final Entity it, final Action action, final Boolean isAdmin) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("* @Route(\"/");
    {
      if ((isAdmin).booleanValue()) {
        _builder.append("admin/");
      }
    }
    String _formatForCode = this._formattingExtensions.formatForCode(it.getName());
    _builder.append(_formatForCode);
    _builder.append("/");
    {
      if ((!(action instanceof DisplayAction))) {
        String _formatForCode_1 = this._formattingExtensions.formatForCode(action.getName());
        _builder.append(_formatForCode_1);
        _builder.append("/");
      }
    }
    String _actionRouteParamsForSingleEntity = this.actionRouteParamsForSingleEntity(it, action);
    _builder.append(_actionRouteParamsForSingleEntity);
    _builder.append(".{_format}\",");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*        requirements = {");
    String _actionRouteRequirementsForSingleEntity = this.actionRouteRequirementsForSingleEntity(it, action);
    _builder.append(_actionRouteRequirementsForSingleEntity);
    _builder.append(", \"_format\" = \"html");
    {
      if (((action instanceof DisplayAction) && (this._viewExtensions.getListOfDisplayFormats(this.app).size() > 0))) {
        _builder.append("|");
        {
          ArrayList<String> _listOfDisplayFormats = this._viewExtensions.getListOfDisplayFormats(this.app);
          boolean _hasElements = false;
          for(final String format : _listOfDisplayFormats) {
            if (!_hasElements) {
              _hasElements = true;
            } else {
              _builder.appendImmediate("|", "");
            }
            _builder.append(format);
          }
        }
      }
    }
    _builder.append("\"},");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*        defaults = {");
    {
      if ((action instanceof EditAction)) {
        String _actionRouteDefaultsForSingleEntity = this.actionRouteDefaultsForSingleEntity(it, action);
        _builder.append(_actionRouteDefaultsForSingleEntity);
        _builder.append(", ");
      }
    }
    _builder.append("\"_format\" = \"html\"},");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*        methods = {\"GET\"");
    {
      if (((action instanceof EditAction) || (action instanceof DeleteAction))) {
        _builder.append(", \"POST\"");
      }
    }
    _builder.append("}");
    {
      EntityTreeType _tree = it.getTree();
      boolean _notEquals = (!Objects.equal(_tree, EntityTreeType.NONE));
      if (_notEquals) {
        _builder.append(",");
        _builder.newLineIfNotEmpty();
        _builder.append(" ");
        _builder.append("*        options={\"expose\"=true}");
      }
    }
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("* )");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private String actionRouteParamsForSingleEntity(final Entity it, final Action action) {
    String _xblockexpression = null;
    {
      String output = "";
      if ((this._modelBehaviourExtensions.hasSluggableFields(it) && (!(action instanceof EditAction)))) {
        output = "{slug}";
        boolean _isSlugUnique = it.isSlugUnique();
        if (_isSlugUnique) {
          return output;
        }
        output = (output + ".");
      }
      final Function1<DerivedField, String> _function = (DerivedField it_1) -> {
        String _formatForCode = this._formattingExtensions.formatForCode(it_1.getName());
        String _plus = ("{" + _formatForCode);
        return (_plus + "}");
      };
      String _join = IterableExtensions.join(IterableExtensions.<DerivedField, String>map(this._modelExtensions.getPrimaryKeyFields(it), _function), "_");
      String _plus = (output + _join);
      output = _plus;
      _xblockexpression = output;
    }
    return _xblockexpression;
  }
  
  private String actionRouteRequirementsForSingleEntity(final Entity it, final Action action) {
    String _xblockexpression = null;
    {
      String output = "";
      if ((this._modelBehaviourExtensions.hasSluggableFields(it) && (!(action instanceof EditAction)))) {
        StringConcatenation _builder = new StringConcatenation();
        _builder.append("\"slug\" = \"[^/.]+\"");
        output = _builder.toString();
        boolean _isSlugUnique = it.isSlugUnique();
        if (_isSlugUnique) {
          return output;
        }
        output = (output + ", ");
      }
      final Function1<DerivedField, String> _function = (DerivedField it_1) -> {
        StringConcatenation _builder_1 = new StringConcatenation();
        _builder_1.append("\"");
        String _formatForCode = this._formattingExtensions.formatForCode(it_1.getName());
        _builder_1.append(_formatForCode);
        _builder_1.append("\" = \"\\d+\"");
        return _builder_1.toString();
      };
      String _join = IterableExtensions.join(IterableExtensions.<DerivedField, String>map(this._modelExtensions.getPrimaryKeyFields(it), _function), ", ");
      String _plus = (output + _join);
      output = _plus;
      _xblockexpression = output;
    }
    return _xblockexpression;
  }
  
  private String actionRouteDefaultsForSingleEntity(final Entity it, final Action action) {
    String _xblockexpression = null;
    {
      String output = "";
      if ((this._modelBehaviourExtensions.hasSluggableFields(it) && (action instanceof DisplayAction))) {
        StringConcatenation _builder = new StringConcatenation();
        _builder.append("\"slug\" = \"\"");
        output = _builder.toString();
        boolean _isSlugUnique = it.isSlugUnique();
        if (_isSlugUnique) {
          return output;
        }
        output = (output + ", ");
      }
      final Function1<DerivedField, String> _function = (DerivedField it_1) -> {
        StringConcatenation _builder_1 = new StringConcatenation();
        _builder_1.append("\"");
        String _formatForCode = this._formattingExtensions.formatForCode(it_1.getName());
        _builder_1.append(_formatForCode);
        _builder_1.append("\" = \"0\"");
        return _builder_1.toString();
      };
      String _join = IterableExtensions.join(IterableExtensions.<DerivedField, String>map(this._modelExtensions.getPrimaryKeyFields(it), _function), ", ");
      String _plus = (output + _join);
      output = _plus;
      _xblockexpression = output;
    }
    return _xblockexpression;
  }
  
  private CharSequence _actionRoute(final DisplayAction it, final Entity entity, final Boolean isAdmin) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _actionRouteForSingleEntity = this.actionRouteForSingleEntity(entity, it, isAdmin);
    _builder.append(_actionRouteForSingleEntity);
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence _actionRoute(final EditAction it, final Entity entity, final Boolean isAdmin) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _actionRouteForSingleEntity = this.actionRouteForSingleEntity(entity, it, isAdmin);
    _builder.append(_actionRouteForSingleEntity);
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence _actionRoute(final DeleteAction it, final Entity entity, final Boolean isAdmin) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _actionRouteForSingleEntity = this.actionRouteForSingleEntity(entity, it, isAdmin);
    _builder.append(_actionRouteForSingleEntity);
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence _actionRoute(final CustomAction it, final Entity entity, final Boolean isAdmin) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("* @Route(\"/");
    {
      if ((isAdmin).booleanValue()) {
        _builder.append("admin/");
      }
    }
    String _formatForCode = this._formattingExtensions.formatForCode(entity.getNameMultiple());
    _builder.append(_formatForCode);
    _builder.append("/");
    String _formatForCode_1 = this._formattingExtensions.formatForCode(it.getName());
    _builder.append(_formatForCode_1);
    _builder.append("\",");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*        methods = {\"GET\", \"POST\"}");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("* )");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence paramConverter(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append(" ");
    _builder.append("* @ParamConverter(\"");
    String _formatForCode = this._formattingExtensions.formatForCode(it.getName());
    _builder.append(_formatForCode);
    _builder.append("\", class=\"");
    String _appName = this._utils.appName(this.app);
    _builder.append(_appName);
    _builder.append(":");
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital);
    _builder.append("Entity\", options = {");
    String _paramConverterOptions = this.paramConverterOptions(it);
    _builder.append(_paramConverterOptions);
    _builder.append("})");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private String paramConverterOptions(final Entity it) {
    String _xblockexpression = null;
    {
      if ((this._modelBehaviourExtensions.hasSluggableFields(it) && it.isSlugUnique())) {
        return "\"id\" = \"slug\", \"repository_method\" = \"selectBySlug\"";
      }
      final boolean needsMapping = (this._modelBehaviourExtensions.hasSluggableFields(it) || this._modelExtensions.hasCompositeKeys(it));
      if ((!needsMapping)) {
        String _formatForCode = this._formattingExtensions.formatForCode(this._modelExtensions.getFirstPrimaryKey(it).getName());
        String _plus = ("\"id\" = \"" + _formatForCode);
        return (_plus + "\", \"repository_method\" = \"selectById\"");
      }
      String output = "\"mapping\": {";
      boolean _hasSluggableFields = this._modelBehaviourExtensions.hasSluggableFields(it);
      if (_hasSluggableFields) {
        output = (output + "\"slug\": \"slug\", ");
      }
      final Function1<DerivedField, String> _function = (DerivedField it_1) -> {
        String _formatForCode_1 = this._formattingExtensions.formatForCode(it_1.getName());
        String _plus_1 = ("\"" + _formatForCode_1);
        String _plus_2 = (_plus_1 + "\": \"");
        String _formatForCode_2 = this._formattingExtensions.formatForCode(it_1.getName());
        String _plus_3 = (_plus_2 + _formatForCode_2);
        return (_plus_3 + "\"");
      };
      String _join = IterableExtensions.join(IterableExtensions.<DerivedField, String>map(this._modelExtensions.getPrimaryKeyFields(it), _function), ", ");
      String _plus_1 = (output + _join);
      output = _plus_1;
      output = (output + "}, \"repository_method\" = \"selectByIdList\"");
      _xblockexpression = output;
    }
    return _xblockexpression;
  }
  
  private CharSequence actionRoute(final Action it, final Entity entity, final Boolean isAdmin) {
    if (it instanceof CustomAction) {
      return _actionRoute((CustomAction)it, entity, isAdmin);
    } else if (it instanceof DeleteAction) {
      return _actionRoute((DeleteAction)it, entity, isAdmin);
    } else if (it instanceof DisplayAction) {
      return _actionRoute((DisplayAction)it, entity, isAdmin);
    } else if (it instanceof EditAction) {
      return _actionRoute((EditAction)it, entity, isAdmin);
    } else if (it instanceof MainAction) {
      return _actionRoute((MainAction)it, entity, isAdmin);
    } else if (it instanceof ViewAction) {
      return _actionRoute((ViewAction)it, entity, isAdmin);
    } else if (it != null) {
      return _actionRoute(it, entity, isAdmin);
    } else {
      throw new IllegalArgumentException("Unhandled parameter types: " +
        Arrays.<Object>asList(it, entity, isAdmin).toString());
    }
  }
}

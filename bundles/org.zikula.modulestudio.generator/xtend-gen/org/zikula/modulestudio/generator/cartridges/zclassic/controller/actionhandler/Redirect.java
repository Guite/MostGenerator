package org.zikula.modulestudio.generator.cartridges.zclassic.controller.actionhandler;

import com.google.common.base.Objects;
import de.guite.modulestudio.metamodel.Application;
import de.guite.modulestudio.metamodel.DataObject;
import de.guite.modulestudio.metamodel.Entity;
import de.guite.modulestudio.metamodel.EntityTreeType;
import de.guite.modulestudio.metamodel.JoinRelationship;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.zikula.modulestudio.generator.extensions.ControllerExtensions;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions;
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.UrlExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

/**
 * Redirect processing functions for edit form handlers.
 */
@SuppressWarnings("all")
public class Redirect {
  @Extension
  private ControllerExtensions _controllerExtensions = new ControllerExtensions();
  
  @Extension
  private FormattingExtensions _formattingExtensions = new FormattingExtensions();
  
  @Extension
  private ModelBehaviourExtensions _modelBehaviourExtensions = new ModelBehaviourExtensions();
  
  @Extension
  private ModelJoinExtensions _modelJoinExtensions = new ModelJoinExtensions();
  
  @Extension
  private NamingExtensions _namingExtensions = new NamingExtensions();
  
  @Extension
  private UrlExtensions _urlExtensions = new UrlExtensions();
  
  @Extension
  private Utils _utils = new Utils();
  
  public CharSequence getRedirectCodes(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Get list of allowed redirect codes.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return array list of possible redirect codes");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected function getRedirectCodes()");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$codes = [];");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// to be filled by subclasses");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $codes;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  public CharSequence getRedirectCodes(final Entity it, final Application app) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Get list of allowed redirect codes.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return array list of possible redirect codes");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected function getRedirectCodes()");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$codes = parent::getRedirectCodes();");
    _builder.newLine();
    _builder.newLine();
    {
      boolean _hasIndexAction = this._controllerExtensions.hasIndexAction(it);
      if (_hasIndexAction) {
        _builder.append("    ");
        _builder.append("// user index page of ");
        String _formatForDisplay = this._formattingExtensions.formatForDisplay(it.getName());
        _builder.append(_formatForDisplay, "    ");
        _builder.append(" area");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("$codes[] = \'userIndex\';");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("// admin index page of ");
        String _formatForDisplay_1 = this._formattingExtensions.formatForDisplay(it.getName());
        _builder.append(_formatForDisplay_1, "    ");
        _builder.append(" area");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("$codes[] = \'adminIndex\';");
        _builder.newLine();
      }
    }
    {
      boolean _hasViewAction = this._controllerExtensions.hasViewAction(it);
      if (_hasViewAction) {
        _builder.append("    ");
        _builder.append("// user list of ");
        String _formatForDisplay_2 = this._formattingExtensions.formatForDisplay(it.getNameMultiple());
        _builder.append(_formatForDisplay_2, "    ");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("$codes[] = \'userView\';");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("// admin list of ");
        String _formatForDisplay_3 = this._formattingExtensions.formatForDisplay(it.getNameMultiple());
        _builder.append(_formatForDisplay_3, "    ");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("$codes[] = \'adminView\';");
        _builder.newLine();
        {
          boolean _isStandardFields = it.isStandardFields();
          if (_isStandardFields) {
            _builder.append("    ");
            _builder.append("// user list of own ");
            String _formatForDisplay_4 = this._formattingExtensions.formatForDisplay(it.getNameMultiple());
            _builder.append(_formatForDisplay_4, "    ");
            _builder.newLineIfNotEmpty();
            _builder.append("    ");
            _builder.append("$codes[] = \'userOwnView\';");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("// admin list of own ");
            String _formatForDisplay_5 = this._formattingExtensions.formatForDisplay(it.getNameMultiple());
            _builder.append(_formatForDisplay_5, "    ");
            _builder.newLineIfNotEmpty();
            _builder.append("    ");
            _builder.append("$codes[] = \'adminOwnView\';");
            _builder.newLine();
          }
        }
      }
    }
    {
      boolean _hasDisplayAction = this._controllerExtensions.hasDisplayAction(it);
      if (_hasDisplayAction) {
        _builder.append("    ");
        _builder.append("// user detail page of treated ");
        String _formatForDisplay_6 = this._formattingExtensions.formatForDisplay(it.getName());
        _builder.append(_formatForDisplay_6, "    ");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("$codes[] = \'userDisplay\';");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("// admin detail page of treated ");
        String _formatForDisplay_7 = this._formattingExtensions.formatForDisplay(it.getName());
        _builder.append(_formatForDisplay_7, "    ");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("$codes[] = \'adminDisplay\';");
        _builder.newLine();
      }
    }
    _builder.newLine();
    {
      final Function1<JoinRelationship, Boolean> _function = (JoinRelationship it_1) -> {
        return Boolean.valueOf((Objects.equal(it_1.getSource().getApplication(), app) && (it_1.getSource() instanceof Entity)));
      };
      Iterable<JoinRelationship> _filter = IterableExtensions.<JoinRelationship>filter(this._modelJoinExtensions.getIncomingJoinRelationsWithOneSource(it), _function);
      for(final JoinRelationship incomingRelation : _filter) {
        _builder.append("    ");
        DataObject _source = incomingRelation.getSource();
        final Entity sourceEntity = ((Entity) _source);
        _builder.newLineIfNotEmpty();
        {
          String _name = sourceEntity.getName();
          String _name_1 = it.getName();
          boolean _notEquals = (!Objects.equal(_name, _name_1));
          if (_notEquals) {
            {
              boolean _hasViewAction_1 = this._controllerExtensions.hasViewAction(sourceEntity);
              if (_hasViewAction_1) {
                _builder.append("    ");
                _builder.append("// user list of ");
                String _formatForDisplay_8 = this._formattingExtensions.formatForDisplay(sourceEntity.getNameMultiple());
                _builder.append(_formatForDisplay_8, "    ");
                _builder.newLineIfNotEmpty();
                _builder.append("    ");
                _builder.append("$codes[] = \'userView");
                String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(sourceEntity.getNameMultiple());
                _builder.append(_formatForCodeCapital, "    ");
                _builder.append("\';");
                _builder.newLineIfNotEmpty();
                _builder.append("    ");
                _builder.append("// admin list of ");
                String _formatForDisplay_9 = this._formattingExtensions.formatForDisplay(sourceEntity.getNameMultiple());
                _builder.append(_formatForDisplay_9, "    ");
                _builder.newLineIfNotEmpty();
                _builder.append("    ");
                _builder.append("$codes[] = \'adminView");
                String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(sourceEntity.getNameMultiple());
                _builder.append(_formatForCodeCapital_1, "    ");
                _builder.append("\';");
                _builder.newLineIfNotEmpty();
                {
                  boolean _isStandardFields_1 = sourceEntity.isStandardFields();
                  if (_isStandardFields_1) {
                    _builder.append("    ");
                    _builder.append("// user list of own ");
                    String _formatForDisplay_10 = this._formattingExtensions.formatForDisplay(sourceEntity.getNameMultiple());
                    _builder.append(_formatForDisplay_10, "    ");
                    _builder.newLineIfNotEmpty();
                    _builder.append("    ");
                    _builder.append("$codes[] = \'userOwnView");
                    String _formatForCodeCapital_2 = this._formattingExtensions.formatForCodeCapital(sourceEntity.getNameMultiple());
                    _builder.append(_formatForCodeCapital_2, "    ");
                    _builder.append("\';");
                    _builder.newLineIfNotEmpty();
                    _builder.append("    ");
                    _builder.append("// admin list of own ");
                    String _formatForDisplay_11 = this._formattingExtensions.formatForDisplay(sourceEntity.getNameMultiple());
                    _builder.append(_formatForDisplay_11, "    ");
                    _builder.newLineIfNotEmpty();
                    _builder.append("    ");
                    _builder.append("$codes[] = \'adminOwnView");
                    String _formatForCodeCapital_3 = this._formattingExtensions.formatForCodeCapital(sourceEntity.getNameMultiple());
                    _builder.append(_formatForCodeCapital_3, "    ");
                    _builder.append("\';");
                    _builder.newLineIfNotEmpty();
                  }
                }
              }
            }
            {
              boolean _hasDisplayAction_1 = this._controllerExtensions.hasDisplayAction(sourceEntity);
              if (_hasDisplayAction_1) {
                _builder.append("    ");
                _builder.append("// user detail page of related ");
                String _formatForDisplay_12 = this._formattingExtensions.formatForDisplay(sourceEntity.getName());
                _builder.append(_formatForDisplay_12, "    ");
                _builder.newLineIfNotEmpty();
                _builder.append("    ");
                _builder.append("$codes[] = \'userDisplay");
                String _formatForCodeCapital_4 = this._formattingExtensions.formatForCodeCapital(sourceEntity.getName());
                _builder.append(_formatForCodeCapital_4, "    ");
                _builder.append("\';");
                _builder.newLineIfNotEmpty();
                _builder.append("    ");
                _builder.append("// admin detail page of related ");
                String _formatForDisplay_13 = this._formattingExtensions.formatForDisplay(sourceEntity.getName());
                _builder.append(_formatForDisplay_13, "    ");
                _builder.newLineIfNotEmpty();
                _builder.append("    ");
                _builder.append("$codes[] = \'adminDisplay");
                String _formatForCodeCapital_5 = this._formattingExtensions.formatForCodeCapital(sourceEntity.getName());
                _builder.append(_formatForCodeCapital_5, "    ");
                _builder.append("\';");
                _builder.newLineIfNotEmpty();
              }
            }
          }
        }
      }
    }
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $codes;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  public CharSequence getDefaultReturnUrl(final Entity it, final Application app) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Get the default redirect url. Required if no returnTo parameter has been supplied.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* This method is called in handleCommand so we know which command has been performed.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param array $args List of arguments");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return string The default redirect url");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected function getDefaultReturnUrl($args)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$objectIsPersisted = $args[\'commandName\'] != \'delete\' && !($this->templateParameters[\'mode\'] == \'create\' && $args[\'commandName\'] == \'cancel\');");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (null !== $this->returnTo) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$isDisplayOrEditPage = substr($this->returnTo, -7) == \'display\' || substr($this->returnTo, -4) == \'edit\';");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if (!$isDisplayOrEditPage || $objectIsPersisted) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("// return to referer");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("return $this->returnTo;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    {
      if (((this._controllerExtensions.hasIndexAction(it) || this._controllerExtensions.hasViewAction(it)) || (this._controllerExtensions.hasDisplayAction(it) && (!Objects.equal(it.getTree(), EntityTreeType.NONE))))) {
        _builder.append("    ");
        _builder.append("$routeArea = array_key_exists(\'routeArea\', $this->templateParameters) ? $this->templateParameters[\'routeArea\'] : \'\';");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$routePrefix = \'");
        String _formatForDB = this._formattingExtensions.formatForDB(this._utils.appName(app));
        _builder.append(_formatForDB, "    ");
        _builder.append("_\' . $this->objectTypeLower . \'_\' . $routeArea;");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
      }
    }
    {
      boolean _hasViewAction = this._controllerExtensions.hasViewAction(it);
      if (_hasViewAction) {
        _builder.append("    ");
        _builder.append("// redirect to the list of ");
        String _formatForCode = this._formattingExtensions.formatForCode(it.getNameMultiple());
        _builder.append(_formatForCode, "    ");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("$url = $this->router->generate($routePrefix . \'view\'");
        {
          EntityTreeType _tree = it.getTree();
          boolean _notEquals = (!Objects.equal(_tree, EntityTreeType.NONE));
          if (_notEquals) {
            _builder.append(", [\'tpl\' => \'tree\']");
          }
        }
        _builder.append(");");
        _builder.newLineIfNotEmpty();
      } else {
        boolean _hasIndexAction = this._controllerExtensions.hasIndexAction(it);
        if (_hasIndexAction) {
          _builder.append("    ");
          _builder.append("// redirect to the index page");
          _builder.newLine();
          _builder.append("    ");
          _builder.append("$url = $this->router->generate($routePrefix . \'index\');");
          _builder.newLine();
        } else {
          _builder.append("    ");
          _builder.append("$url = $this->router->generate(\'home\');");
          _builder.newLine();
        }
      }
    }
    {
      if ((this._controllerExtensions.hasDisplayAction(it) && (!Objects.equal(it.getTree(), EntityTreeType.NONE)))) {
        _builder.newLine();
        _builder.append("    ");
        _builder.append("if ($objectIsPersisted) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("// redirect to the detail page of treated ");
        String _formatForCode_1 = this._formattingExtensions.formatForCode(it.getName());
        _builder.append(_formatForCode_1, "        ");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("$url = $this->router->generate($routePrefix . \'display\', [");
        CharSequence _routeParams = this._urlExtensions.routeParams(it, "this->idValues", Boolean.valueOf(false));
        _builder.append(_routeParams, "        ");
        _builder.append("]);");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
      }
    }
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $url;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  public CharSequence getRedirectUrl(final Entity it, final Application app) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Get url to redirect to.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param array $args List of arguments");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return string The redirect url");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected function getRedirectUrl($args)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    {
      if ((this._modelJoinExtensions.needsAutoCompletion(app) && ((!it.getIncoming().isEmpty()) || (!it.getOutgoing().isEmpty())))) {
        _builder.append("    ");
        _builder.append("if (true === $this->templateParameters[\'inlineUsage\']) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("$urlArgs = [");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("        ");
        _builder.append("\'idPrefix\' => $this->idPrefix,");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("        ");
        _builder.append("\'commandName\' => $args[\'commandName\']");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("];");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("foreach ($this->idFields as $idField) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("        ");
        _builder.append("$urlArgs[$idField] = $this->idValues[$idField];");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("// inline usage, return to special function for closing the modal window instance");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("return $this->router->generate(\'");
        String _formatForDB = this._formattingExtensions.formatForDB(this._utils.appName(app));
        _builder.append(_formatForDB, "        ");
        _builder.append("_\' . $this->objectTypeLower . \'_handleinlineredirect\', $urlArgs);");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
        _builder.newLine();
      }
    }
    _builder.append("    ");
    _builder.append("if ($this->repeatCreateAction) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return $this->repeatReturnUrl;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($this->request->getSession()->has(\'");
    String _formatForDB_1 = this._formattingExtensions.formatForDB(this._utils.appName(app));
    _builder.append(_formatForDB_1, "    ");
    _builder.append("\' . $this->objectTypeCapital . \'Referer\')) {");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("$this->request->getSession()->del(\'");
    String _formatForDB_2 = this._formattingExtensions.formatForDB(this._utils.appName(app));
    _builder.append(_formatForDB_2, "        ");
    _builder.append("\' . $this->objectTypeCapital . \'Referer\');");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// normal usage, compute return url from given redirect code");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!in_array($this->returnTo, $this->getRedirectCodes())) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// invalid return code, so return the default url");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return $this->getDefaultReturnUrl($args);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$routeArea = substr($this->returnTo, 0, 5) == \'admin\' ? \'admin\' : \'\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$routePrefix = \'");
    String _formatForDB_3 = this._formattingExtensions.formatForDB(this._utils.appName(app));
    _builder.append(_formatForDB_3, "    ");
    _builder.append("_\' . $this->objectTypeLower . \'_\' . $routeArea;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// parse given redirect code and return corresponding url");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("switch ($this->returnTo) {");
    _builder.newLine();
    {
      boolean _hasIndexAction = this._controllerExtensions.hasIndexAction(it);
      if (_hasIndexAction) {
        _builder.append("        ");
        _builder.append("case \'userIndex\':");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("case \'adminIndex\':");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("return $this->router->generate($routePrefix . \'index\');");
        _builder.newLine();
      }
    }
    {
      boolean _hasViewAction = this._controllerExtensions.hasViewAction(it);
      if (_hasViewAction) {
        _builder.append("        ");
        _builder.append("case \'userView\':");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("case \'adminView\':");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("return $this->router->generate($routePrefix . \'view\');");
        _builder.newLine();
        {
          boolean _isStandardFields = it.isStandardFields();
          if (_isStandardFields) {
            _builder.append("        ");
            _builder.append("case \'userOwnView\':");
            _builder.newLine();
            _builder.append("        ");
            _builder.append("case \'adminOwnView\':");
            _builder.newLine();
            _builder.append("        ");
            _builder.append("    ");
            _builder.append("return $this->router->generate($routePrefix . \'view\', [ \'own\' => 1 ]);");
            _builder.newLine();
          }
        }
      }
    }
    {
      boolean _hasDisplayAction = this._controllerExtensions.hasDisplayAction(it);
      if (_hasDisplayAction) {
        _builder.append("        ");
        _builder.append("case \'userDisplay\':");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("case \'adminDisplay\':");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("if ($args[\'commandName\'] != \'delete\' && !($this->templateParameters[\'mode\'] == \'create\' && $args[\'commandName\'] == \'cancel\')) {");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("        ");
        _builder.append("foreach ($this->idFields as $idField) {");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("            ");
        _builder.append("$urlArgs[$idField] = $this->idValues[$idField];");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("        ");
        _builder.append("}");
        _builder.newLine();
        _builder.newLine();
        _builder.append("        ");
        _builder.append("        ");
        _builder.append("return $this->router->generate($routePrefix . \'display\', $urlArgs);");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("return $this->getDefaultReturnUrl($args);");
        _builder.newLine();
      }
    }
    {
      final Function1<JoinRelationship, Boolean> _function = (JoinRelationship it_1) -> {
        return Boolean.valueOf((Objects.equal(it_1.getSource().getApplication(), app) && (it_1.getSource() instanceof Entity)));
      };
      Iterable<JoinRelationship> _filter = IterableExtensions.<JoinRelationship>filter(this._modelJoinExtensions.getIncomingJoinRelationsWithOneSource(it), _function);
      for(final JoinRelationship incomingRelation : _filter) {
        _builder.append("        ");
        DataObject _source = incomingRelation.getSource();
        final Entity sourceEntity = ((Entity) _source);
        _builder.newLineIfNotEmpty();
        {
          String _name = sourceEntity.getName();
          String _name_1 = it.getName();
          boolean _notEquals = (!Objects.equal(_name, _name_1));
          if (_notEquals) {
            {
              boolean _hasViewAction_1 = this._controllerExtensions.hasViewAction(sourceEntity);
              if (_hasViewAction_1) {
                _builder.append("        ");
                _builder.append("case \'userView");
                String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(sourceEntity.getNameMultiple());
                _builder.append(_formatForCodeCapital, "        ");
                _builder.append("\':");
                _builder.newLineIfNotEmpty();
                _builder.append("        ");
                _builder.append("case \'adminView");
                String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(sourceEntity.getNameMultiple());
                _builder.append(_formatForCodeCapital_1, "        ");
                _builder.append("\':");
                _builder.newLineIfNotEmpty();
                _builder.append("        ");
                _builder.append("    ");
                _builder.append("return $this->router->generate(\'");
                String _formatForDB_4 = this._formattingExtensions.formatForDB(this._utils.appName(app));
                _builder.append(_formatForDB_4, "            ");
                _builder.append("_");
                String _formatForDB_5 = this._formattingExtensions.formatForDB(sourceEntity.getName());
                _builder.append(_formatForDB_5, "            ");
                _builder.append("_\' . $routeArea . \'view\');");
                _builder.newLineIfNotEmpty();
                {
                  boolean _isStandardFields_1 = sourceEntity.isStandardFields();
                  if (_isStandardFields_1) {
                    _builder.append("        ");
                    _builder.append("case \'userOwnView");
                    String _formatForCodeCapital_2 = this._formattingExtensions.formatForCodeCapital(sourceEntity.getNameMultiple());
                    _builder.append(_formatForCodeCapital_2, "        ");
                    _builder.append("\':");
                    _builder.newLineIfNotEmpty();
                    _builder.append("        ");
                    _builder.append("case \'adminOwnView");
                    String _formatForCodeCapital_3 = this._formattingExtensions.formatForCodeCapital(sourceEntity.getNameMultiple());
                    _builder.append(_formatForCodeCapital_3, "        ");
                    _builder.append("\':");
                    _builder.newLineIfNotEmpty();
                    _builder.append("        ");
                    _builder.append("    ");
                    _builder.append("return $this->router->generate(\'");
                    String _formatForDB_6 = this._formattingExtensions.formatForDB(this._utils.appName(app));
                    _builder.append(_formatForDB_6, "            ");
                    _builder.append("_");
                    String _formatForDB_7 = this._formattingExtensions.formatForDB(sourceEntity.getName());
                    _builder.append(_formatForDB_7, "            ");
                    _builder.append("_\' . $routeArea . \'view\', [ \'own\' => 1 ]);");
                    _builder.newLineIfNotEmpty();
                  }
                }
              }
            }
            {
              boolean _hasDisplayAction_1 = this._controllerExtensions.hasDisplayAction(sourceEntity);
              if (_hasDisplayAction_1) {
                _builder.append("        ");
                _builder.append("case \'userDisplay");
                String _formatForCodeCapital_4 = this._formattingExtensions.formatForCodeCapital(sourceEntity.getName());
                _builder.append(_formatForCodeCapital_4, "        ");
                _builder.append("\':");
                _builder.newLineIfNotEmpty();
                _builder.append("        ");
                _builder.append("case \'adminDisplay");
                String _formatForCodeCapital_5 = this._formattingExtensions.formatForCodeCapital(sourceEntity.getName());
                _builder.append(_formatForCodeCapital_5, "        ");
                _builder.append("\':");
                _builder.newLineIfNotEmpty();
                _builder.append("        ");
                _builder.append("    ");
                _builder.append("if (!empty($this->relationPresets[\'");
                String _relationAliasName = this._namingExtensions.getRelationAliasName(incomingRelation, Boolean.valueOf(false));
                _builder.append(_relationAliasName, "            ");
                _builder.append("\'])) {");
                _builder.newLineIfNotEmpty();
                _builder.append("        ");
                _builder.append("        ");
                _builder.append("return $this->router->generate(\'");
                String _formatForDB_8 = this._formattingExtensions.formatForDB(this._utils.appName(app));
                _builder.append(_formatForDB_8, "                ");
                _builder.append("_");
                String _formatForDB_9 = this._formattingExtensions.formatForDB(sourceEntity.getName());
                _builder.append(_formatForDB_9, "                ");
                _builder.append("_\' . $routeArea . \'display\',  [\'id\' => $this->relationPresets[\'");
                String _relationAliasName_1 = this._namingExtensions.getRelationAliasName(incomingRelation, Boolean.valueOf(false));
                _builder.append(_relationAliasName_1, "                ");
                _builder.append("\']");
                {
                  boolean _hasSluggableFields = this._modelBehaviourExtensions.hasSluggableFields(sourceEntity);
                  if (_hasSluggableFields) {
                  }
                }
                _builder.append("]);");
                _builder.newLineIfNotEmpty();
                _builder.append("        ");
                _builder.append("    ");
                _builder.append("}");
                _builder.newLine();
                _builder.newLine();
                _builder.append("        ");
                _builder.append("    ");
                _builder.append("return $this->getDefaultReturnUrl($args);");
                _builder.newLine();
              }
            }
          }
        }
      }
    }
    _builder.append("        ");
    _builder.append("default:");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("return $this->getDefaultReturnUrl($args);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
}

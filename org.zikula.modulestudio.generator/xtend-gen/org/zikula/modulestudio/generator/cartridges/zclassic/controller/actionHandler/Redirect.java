package org.zikula.modulestudio.generator.cartridges.zclassic.controller.actionHandler;

import com.google.common.base.Objects;
import com.google.common.collect.Iterables;
import com.google.inject.Inject;
import de.guite.modulestudio.metamodel.modulestudio.AjaxController;
import de.guite.modulestudio.metamodel.modulestudio.Application;
import de.guite.modulestudio.metamodel.modulestudio.Controller;
import de.guite.modulestudio.metamodel.modulestudio.Entity;
import de.guite.modulestudio.metamodel.modulestudio.EntityTreeType;
import de.guite.modulestudio.metamodel.modulestudio.JoinRelationship;
import de.guite.modulestudio.metamodel.modulestudio.Models;
import org.eclipse.emf.common.util.EList;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
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
  @Inject
  @Extension
  private ControllerExtensions _controllerExtensions = new Function0<ControllerExtensions>() {
    public ControllerExtensions apply() {
      ControllerExtensions _controllerExtensions = new ControllerExtensions();
      return _controllerExtensions;
    }
  }.apply();
  
  @Inject
  @Extension
  private FormattingExtensions _formattingExtensions = new Function0<FormattingExtensions>() {
    public FormattingExtensions apply() {
      FormattingExtensions _formattingExtensions = new FormattingExtensions();
      return _formattingExtensions;
    }
  }.apply();
  
  @Inject
  @Extension
  private ModelBehaviourExtensions _modelBehaviourExtensions = new Function0<ModelBehaviourExtensions>() {
    public ModelBehaviourExtensions apply() {
      ModelBehaviourExtensions _modelBehaviourExtensions = new ModelBehaviourExtensions();
      return _modelBehaviourExtensions;
    }
  }.apply();
  
  @Inject
  @Extension
  private ModelJoinExtensions _modelJoinExtensions = new Function0<ModelJoinExtensions>() {
    public ModelJoinExtensions apply() {
      ModelJoinExtensions _modelJoinExtensions = new ModelJoinExtensions();
      return _modelJoinExtensions;
    }
  }.apply();
  
  @Inject
  @Extension
  private NamingExtensions _namingExtensions = new Function0<NamingExtensions>() {
    public NamingExtensions apply() {
      NamingExtensions _namingExtensions = new NamingExtensions();
      return _namingExtensions;
    }
  }.apply();
  
  @Inject
  @Extension
  private UrlExtensions _urlExtensions = new Function0<UrlExtensions>() {
    public UrlExtensions apply() {
      UrlExtensions _urlExtensions = new UrlExtensions();
      return _urlExtensions;
    }
  }.apply();
  
  @Inject
  @Extension
  private Utils _utils = new Function0<Utils>() {
    public Utils apply() {
      Utils _utils = new Utils();
      return _utils;
    }
  }.apply();
  
  public CharSequence getRedirectCodes(final Controller it, final Application app, final String actionName) {
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
    _builder.append("$codes = array();");
    _builder.newLine();
    {
      EList<Controller> _allControllers = this._controllerExtensions.getAllControllers(app);
      for(final Controller someController : _allControllers) {
        _builder.append("    ");
        final String controllerName = this._controllerExtensions.formattedName(someController);
        _builder.newLineIfNotEmpty();
        {
          boolean _hasActions = this._controllerExtensions.hasActions(someController, "index");
          if (_hasActions) {
            _builder.append("    ");
            _builder.append("// ");
            {
              boolean _targets = this._utils.targets(app, "1.3.5");
              if (_targets) {
                _builder.append("main");
              } else {
                _builder.append("index");
              }
            }
            _builder.append(" page of ");
            _builder.append(controllerName, "    ");
            _builder.append(" area");
            _builder.newLineIfNotEmpty();
            _builder.append("    ");
            _builder.append("$codes[] = \'");
            _builder.append(controllerName, "    ");
            _builder.append("\';");
            _builder.newLineIfNotEmpty();
          }
        }
        {
          boolean _hasActions_1 = this._controllerExtensions.hasActions(someController, "view");
          if (_hasActions_1) {
            _builder.append("    ");
            _builder.append("// ");
            _builder.append(controllerName, "    ");
            _builder.append(" list of entities");
            _builder.newLineIfNotEmpty();
            _builder.append("    ");
            _builder.append("$codes[] = \'");
            _builder.append(controllerName, "    ");
            _builder.append("View\';");
            _builder.newLineIfNotEmpty();
          }
        }
        {
          boolean _hasActions_2 = this._controllerExtensions.hasActions(someController, "display");
          if (_hasActions_2) {
            _builder.append("    ");
            _builder.append("// ");
            _builder.append(controllerName, "    ");
            _builder.append(" display page of treated entity");
            _builder.newLineIfNotEmpty();
            _builder.append("    ");
            _builder.append("$codes[] = \'");
            _builder.append(controllerName, "    ");
            _builder.append("Display\';");
            _builder.newLineIfNotEmpty();
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
  
  public CharSequence getRedirectCodes(final Entity it, final Application app, final Controller controller, final String actionName) {
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
    {
      Iterable<JoinRelationship> _incomingJoinRelationsWithOneSource = this._modelJoinExtensions.getIncomingJoinRelationsWithOneSource(it);
      final Function1<JoinRelationship,Boolean> _function = new Function1<JoinRelationship,Boolean>() {
        public Boolean apply(final JoinRelationship it) {
          Entity _source = it.getSource();
          Models _container = _source.getContainer();
          Application _application = _container.getApplication();
          boolean _equals = Objects.equal(_application, app);
          return Boolean.valueOf(_equals);
        }
      };
      Iterable<JoinRelationship> _filter = IterableExtensions.<JoinRelationship>filter(_incomingJoinRelationsWithOneSource, _function);
      for(final JoinRelationship incomingRelation : _filter) {
        _builder.append("    ");
        final Entity sourceEntity = incomingRelation.getSource();
        _builder.newLineIfNotEmpty();
        {
          String _name = sourceEntity.getName();
          String _name_1 = it.getName();
          boolean _notEquals = (!Objects.equal(_name, _name_1));
          if (_notEquals) {
            {
              EList<Controller> _allControllers = this._controllerExtensions.getAllControllers(app);
              for(final Controller someController : _allControllers) {
                _builder.append("    ");
                final String controllerName = this._controllerExtensions.formattedName(someController);
                _builder.newLineIfNotEmpty();
                {
                  boolean _hasActions = this._controllerExtensions.hasActions(someController, "view");
                  if (_hasActions) {
                    _builder.append("    ");
                    _builder.append("// ");
                    _builder.append(controllerName, "    ");
                    _builder.append(" list of ");
                    String _nameMultiple = sourceEntity.getNameMultiple();
                    String _formatForDisplay = this._formattingExtensions.formatForDisplay(_nameMultiple);
                    _builder.append(_formatForDisplay, "    ");
                    _builder.newLineIfNotEmpty();
                    _builder.append("    ");
                    _builder.append("$codes[] = \'");
                    _builder.append(controllerName, "    ");
                    _builder.append("View");
                    String _name_2 = sourceEntity.getName();
                    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(_name_2);
                    _builder.append(_formatForCodeCapital, "    ");
                    _builder.append("\';");
                    _builder.newLineIfNotEmpty();
                  }
                }
                {
                  boolean _hasActions_1 = this._controllerExtensions.hasActions(someController, "display");
                  if (_hasActions_1) {
                    _builder.append("    ");
                    _builder.append("// ");
                    _builder.append(controllerName, "    ");
                    _builder.append(" display page of treated ");
                    String _name_3 = sourceEntity.getName();
                    String _formatForDisplay_1 = this._formattingExtensions.formatForDisplay(_name_3);
                    _builder.append(_formatForDisplay_1, "    ");
                    _builder.newLineIfNotEmpty();
                    _builder.append("    ");
                    _builder.append("$codes[] = \'");
                    _builder.append(controllerName, "    ");
                    _builder.append("Display");
                    String _name_4 = sourceEntity.getName();
                    String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(_name_4);
                    _builder.append(_formatForCodeCapital_1, "    ");
                    _builder.append("\';");
                    _builder.newLineIfNotEmpty();
                  }
                }
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
  
  public CharSequence getDefaultReturnUrl(final Entity it, final Application app, final Controller controller, final String actionName) {
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
    _builder.append("* @param array  $args List of arguments.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return string The default redirect url.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected function getDefaultReturnUrl($args)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    {
      boolean _hasActions = this._controllerExtensions.hasActions(controller, "view");
      if (_hasActions) {
        _builder.append("    ");
        _builder.append("// redirect to the list of ");
        String _nameMultiple = it.getNameMultiple();
        String _formatForCode = this._formattingExtensions.formatForCode(_nameMultiple);
        _builder.append(_formatForCode, "    ");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("$viewArgs = array(\'ot\' => $this->objectType);");
        _builder.newLine();
        {
          EntityTreeType _tree = it.getTree();
          boolean _notEquals = (!Objects.equal(_tree, EntityTreeType.NONE));
          if (_notEquals) {
            _builder.append("    ");
            _builder.append("$viewArgs[\'tpl\'] = \'tree\';");
            _builder.newLine();
          }
        }
        _builder.append("    ");
        _builder.append("$url = ModUtil::url($this->name, \'");
        String _formattedName = this._controllerExtensions.formattedName(controller);
        _builder.append(_formattedName, "    ");
        _builder.append("\', \'view\', $viewArgs);");
        _builder.newLineIfNotEmpty();
      } else {
        boolean _hasActions_1 = this._controllerExtensions.hasActions(controller, "index");
        if (_hasActions_1) {
          _builder.append("    ");
          _builder.append("// redirect to the ");
          {
            boolean _targets = this._utils.targets(app, "1.3.5");
            if (_targets) {
              _builder.append("main");
            } else {
              _builder.append("index");
            }
          }
          _builder.append(" page");
          _builder.newLineIfNotEmpty();
          _builder.append("    ");
          _builder.append("$url = ModUtil::url($this->name, \'");
          String _formattedName_1 = this._controllerExtensions.formattedName(controller);
          _builder.append(_formattedName_1, "    ");
          _builder.append("\', \'");
          {
            boolean _targets_1 = this._utils.targets(app, "1.3.5");
            if (_targets_1) {
              _builder.append("main");
            } else {
              _builder.append("index");
            }
          }
          _builder.append("\');");
          _builder.newLineIfNotEmpty();
        } else {
          _builder.append("    ");
          _builder.append("$url = System::getHomepageUrl();");
          _builder.newLine();
        }
      }
    }
    _builder.newLine();
    {
      boolean _hasActions_2 = this._controllerExtensions.hasActions(controller, "display");
      if (_hasActions_2) {
        {
          EntityTreeType _tree_1 = it.getTree();
          boolean _notEquals_1 = (!Objects.equal(_tree_1, EntityTreeType.NONE));
          if (_notEquals_1) {
            _builder.append("    ");
            _builder.append("/*");
            _builder.newLine();
          }
        }
        _builder.append("    ");
        _builder.append("if ($args[\'commandName\'] != \'delete\' && !($this->mode == \'create\' && $args[\'commandName\'] == \'cancel\')) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("// redirect to the detail page of treated ");
        String _name = it.getName();
        String _formatForCode_1 = this._formattingExtensions.formatForCode(_name);
        _builder.append(_formatForCode_1, "        ");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("$url = ModUtil::url($this->name, \'");
        String _formattedName_2 = this._controllerExtensions.formattedName(controller);
        _builder.append(_formattedName_2, "        ");
        _builder.append("\', ");
        String _modUrlDisplay = this._urlExtensions.modUrlDisplay(it, "this->idValues", Boolean.valueOf(false));
        _builder.append(_modUrlDisplay, "        ");
        _builder.append(");");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
        {
          EntityTreeType _tree_2 = it.getTree();
          boolean _notEquals_2 = (!Objects.equal(_tree_2, EntityTreeType.NONE));
          if (_notEquals_2) {
            _builder.append("    ");
            _builder.append("*/");
            _builder.newLine();
          }
        }
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
  
  public CharSequence getRedirectUrl(final Entity it, final Application app, final Controller controller, final String actionName) {
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
    _builder.append("* @param array  $args List of arguments.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return string The redirect url.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected function getRedirectUrl($args)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($this->inlineUsage == true) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$urlArgs = array(\'idp\' => $this->idPrefix,");
    _builder.newLine();
    _builder.append("                         ");
    _builder.append("\'com\' => $args[\'commandName\']);");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$urlArgs = $this->addIdentifiersToUrlArgs($urlArgs);");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// inline usage, return to special function for closing the Zikula.UI.Window instance");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return ModUtil::url($this->name, \'");
    String _formattedName = this._controllerExtensions.formattedName(controller);
    _builder.append(_formattedName, "        ");
    _builder.append("\', \'handleInlineRedirect\', $urlArgs);");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
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
    _builder.append("// parse given redirect code and return corresponding url");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("switch ($this->returnTo) {");
    _builder.newLine();
    {
      EList<Controller> _allControllers = this._controllerExtensions.getAllControllers(app);
      Iterable<AjaxController> _filter = Iterables.<AjaxController>filter(_allControllers, AjaxController.class);
      for(final AjaxController someController : _filter) {
        _builder.append("        ");
        final String controllerName = this._controllerExtensions.formattedName(someController);
        _builder.newLineIfNotEmpty();
        {
          boolean _hasActions = this._controllerExtensions.hasActions(someController, "index");
          if (_hasActions) {
            _builder.append("        ");
            _builder.append("case \'");
            _builder.append(controllerName, "        ");
            _builder.append("\':");
            _builder.newLineIfNotEmpty();
            _builder.append("        ");
            _builder.append("            ");
            _builder.append("return ModUtil::url($this->name, \'");
            _builder.append(controllerName, "                    ");
            _builder.append("\', \'");
            {
              boolean _targets = this._utils.targets(app, "1.3.5");
              if (_targets) {
                _builder.append("main");
              } else {
                _builder.append("index");
              }
            }
            _builder.append("\');");
            _builder.newLineIfNotEmpty();
          }
        }
        {
          boolean _hasActions_1 = this._controllerExtensions.hasActions(someController, "view");
          if (_hasActions_1) {
            _builder.append("        ");
            _builder.append("case \'");
            _builder.append(controllerName, "        ");
            _builder.append("View\':");
            _builder.newLineIfNotEmpty();
            _builder.append("        ");
            _builder.append("            ");
            _builder.append("return ModUtil::url($this->name, \'");
            _builder.append(controllerName, "                    ");
            _builder.append("\', \'view\',");
            _builder.newLineIfNotEmpty();
            _builder.append("        ");
            _builder.append("                                     ");
            _builder.append("array(\'ot\' => $this->objectType));");
            _builder.newLine();
          }
        }
        {
          boolean _hasActions_2 = this._controllerExtensions.hasActions(someController, "display");
          if (_hasActions_2) {
            _builder.append("        ");
            _builder.append("case \'");
            _builder.append(controllerName, "        ");
            _builder.append("Display\':");
            _builder.newLineIfNotEmpty();
            _builder.append("        ");
            _builder.append("            ");
            _builder.append("if ($args[\'commandName\'] != \'delete\' && !($this->mode == \'create\' && $args[\'commandName\'] == \'cancel\')) {");
            _builder.newLine();
            _builder.append("        ");
            _builder.append("                ");
            _builder.append("$urlArgs = $this->addIdentifiersToUrlArgs();");
            _builder.newLine();
            _builder.append("        ");
            _builder.append("                ");
            _builder.append("$urlArgs[\'ot\'] = $this->objectType;");
            _builder.newLine();
            _builder.append("        ");
            _builder.append("                ");
            _builder.append("return ModUtil::url($this->name, \'");
            _builder.append(controllerName, "                        ");
            _builder.append("\', \'display\', $urlArgs);");
            _builder.newLineIfNotEmpty();
            _builder.append("        ");
            _builder.append("            ");
            _builder.append("}");
            _builder.newLine();
            _builder.append("        ");
            _builder.append("            ");
            _builder.append("return $this->getDefaultReturnUrl($args);");
            _builder.newLine();
          }
        }
      }
    }
    {
      Iterable<JoinRelationship> _incomingJoinRelationsWithOneSource = this._modelJoinExtensions.getIncomingJoinRelationsWithOneSource(it);
      final Function1<JoinRelationship,Boolean> _function = new Function1<JoinRelationship,Boolean>() {
        public Boolean apply(final JoinRelationship it) {
          Entity _source = it.getSource();
          Models _container = _source.getContainer();
          Application _application = _container.getApplication();
          boolean _equals = Objects.equal(_application, app);
          return Boolean.valueOf(_equals);
        }
      };
      Iterable<JoinRelationship> _filter_1 = IterableExtensions.<JoinRelationship>filter(_incomingJoinRelationsWithOneSource, _function);
      for(final JoinRelationship incomingRelation : _filter_1) {
        _builder.append("        ");
        final Entity sourceEntity = incomingRelation.getSource();
        _builder.newLineIfNotEmpty();
        {
          String _name = sourceEntity.getName();
          String _name_1 = it.getName();
          boolean _notEquals = (!Objects.equal(_name, _name_1));
          if (_notEquals) {
            {
              EList<Controller> _allControllers_1 = this._controllerExtensions.getAllControllers(app);
              Iterable<AjaxController> _filter_2 = Iterables.<AjaxController>filter(_allControllers_1, AjaxController.class);
              for(final AjaxController someController_1 : _filter_2) {
                _builder.append("        ");
                final String controllerName_1 = this._controllerExtensions.formattedName(someController_1);
                _builder.newLineIfNotEmpty();
                {
                  boolean _hasActions_3 = this._controllerExtensions.hasActions(someController_1, "view");
                  if (_hasActions_3) {
                    _builder.append("        ");
                    _builder.append("case \'");
                    _builder.append(controllerName_1, "        ");
                    _builder.append("View");
                    String _name_2 = sourceEntity.getName();
                    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(_name_2);
                    _builder.append(_formatForCodeCapital, "        ");
                    _builder.append("\':");
                    _builder.newLineIfNotEmpty();
                    _builder.append("        ");
                    _builder.append("    ");
                    _builder.append("return ModUtil::url($this->name, \'");
                    _builder.append(controllerName_1, "            ");
                    _builder.append("\', \'view\',");
                    _builder.newLineIfNotEmpty();
                    _builder.append("        ");
                    _builder.append("                             ");
                    _builder.append("array(\'ot\' => \'");
                    String _name_3 = sourceEntity.getName();
                    String _formatForCode = this._formattingExtensions.formatForCode(_name_3);
                    _builder.append(_formatForCode, "                                     ");
                    _builder.append("\'));");
                    _builder.newLineIfNotEmpty();
                  }
                }
                {
                  boolean _hasActions_4 = this._controllerExtensions.hasActions(someController_1, "display");
                  if (_hasActions_4) {
                    _builder.append("        ");
                    _builder.append("case \'");
                    _builder.append(controllerName_1, "        ");
                    _builder.append("Display");
                    String _name_4 = sourceEntity.getName();
                    String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(_name_4);
                    _builder.append(_formatForCodeCapital_1, "        ");
                    _builder.append("\':");
                    _builder.newLineIfNotEmpty();
                    _builder.append("        ");
                    _builder.append("    ");
                    _builder.append("if (!empty($this->");
                    String _relationAliasName = this._namingExtensions.getRelationAliasName(incomingRelation, Boolean.valueOf(false));
                    _builder.append(_relationAliasName, "            ");
                    _builder.append(")) {");
                    _builder.newLineIfNotEmpty();
                    _builder.append("        ");
                    _builder.append("        ");
                    _builder.append("return ModUtil::url($this->name, \'");
                    _builder.append(controllerName_1, "                ");
                    _builder.append("\', \'display\', array(\'ot\' => \'");
                    String _name_5 = sourceEntity.getName();
                    String _formatForCode_1 = this._formattingExtensions.formatForCode(_name_5);
                    _builder.append(_formatForCode_1, "                ");
                    _builder.append("\', \'id\' => $this->");
                    String _relationAliasName_1 = this._namingExtensions.getRelationAliasName(incomingRelation, Boolean.valueOf(false));
                    _builder.append(_relationAliasName_1, "                ");
                    {
                      boolean _hasSluggableFields = this._modelBehaviourExtensions.hasSluggableFields(sourceEntity);
                      if (_hasSluggableFields) {
                      }
                    }
                    _builder.append("));");
                    _builder.newLineIfNotEmpty();
                    _builder.append("        ");
                    _builder.append("    ");
                    _builder.append("}");
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
      }
    }
    _builder.append("                ");
    _builder.append("default:");
    _builder.newLine();
    _builder.append("                    ");
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

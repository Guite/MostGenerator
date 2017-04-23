package org.zikula.modulestudio.generator.cartridges.zclassic.controller;

import com.google.common.base.Objects;
import de.guite.modulestudio.metamodel.Action;
import de.guite.modulestudio.metamodel.Application;
import de.guite.modulestudio.metamodel.CustomAction;
import de.guite.modulestudio.metamodel.DeleteAction;
import de.guite.modulestudio.metamodel.DisplayAction;
import de.guite.modulestudio.metamodel.EditAction;
import de.guite.modulestudio.metamodel.Entity;
import de.guite.modulestudio.metamodel.MainAction;
import de.guite.modulestudio.metamodel.ViewAction;
import java.util.Arrays;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.StringExtensions;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.action.Actions;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.action.Annotations;
import org.zikula.modulestudio.generator.extensions.ControllerExtensions;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;

@SuppressWarnings("all")
public class ControllerAction {
  @Extension
  private ControllerExtensions _controllerExtensions = new ControllerExtensions();
  
  @Extension
  private FormattingExtensions _formattingExtensions = new FormattingExtensions();
  
  private Application app;
  
  private Actions actionsImpl;
  
  public ControllerAction(final Application app) {
    this.app = app;
    Actions _actions = new Actions(app);
    this.actionsImpl = _actions;
  }
  
  public CharSequence generate(final Entity it, final Action action, final Boolean isBase, final Boolean isAdmin) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _actionDoc = this.actionDoc(action, it, isBase, isAdmin);
    _builder.append(_actionDoc);
    _builder.newLineIfNotEmpty();
    _builder.append("public function ");
    CharSequence _methodName = this.methodName(action, isAdmin);
    _builder.append(_methodName);
    _builder.append("Action(");
    CharSequence _methodArgs = this.methodArgs(it, action);
    _builder.append(_methodArgs);
    _builder.append(")");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    {
      if ((isBase).booleanValue()) {
        _builder.append("    ");
        _builder.append("return $this->");
        CharSequence _methodName_1 = this.methodName(action, Boolean.valueOf(false));
        _builder.append(_methodName_1, "    ");
        _builder.append("Internal(");
        CharSequence _methodArgsCall = this.methodArgsCall(it, action);
        _builder.append(_methodArgsCall, "    ");
        _builder.append(", ");
        String _displayBool = this._formattingExtensions.displayBool(isAdmin);
        _builder.append(_displayBool, "    ");
        _builder.append(");");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("    ");
        _builder.append("return parent::");
        CharSequence _methodName_2 = this.methodName(action, isAdmin);
        _builder.append(_methodName_2, "    ");
        _builder.append("Action(");
        CharSequence _methodArgsCall_1 = this.methodArgsCall(it, action);
        _builder.append(_methodArgsCall_1, "    ");
        _builder.append(");");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("}");
    _builder.newLine();
    {
      if (((isBase).booleanValue() && (!(isAdmin).booleanValue()))) {
        _builder.newLine();
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* This method includes the common implementation code for ");
        CharSequence _methodName_3 = this.methodName(action, Boolean.valueOf(true));
        _builder.append(_methodName_3, " ");
        _builder.append("() and ");
        CharSequence _methodName_4 = this.methodName(action, Boolean.valueOf(false));
        _builder.append(_methodName_4, " ");
        _builder.append("().");
        _builder.newLineIfNotEmpty();
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("protected function ");
        CharSequence _methodName_5 = this.methodName(action, Boolean.valueOf(false));
        _builder.append(_methodName_5);
        _builder.append("Internal(");
        CharSequence _methodArgs_1 = this.methodArgs(it, action);
        _builder.append(_methodArgs_1);
        _builder.append(", $isAdmin = false)");
        _builder.newLineIfNotEmpty();
        _builder.append("{");
        _builder.newLine();
        _builder.append("    ");
        CharSequence _actionImpl = this.actionsImpl.actionImpl(it, action);
        _builder.append(_actionImpl, "    ");
        _builder.newLineIfNotEmpty();
        _builder.append("}");
        _builder.newLine();
      }
    }
    return _builder;
  }
  
  private CharSequence actionDoc(final Action it, final Entity entity, final Boolean isBase, final Boolean isAdmin) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    {
      if ((isBase).booleanValue()) {
        _builder.append(" ");
        _builder.append("* ");
        String _actionDocMethodDescription = this.actionDocMethodDescription(it, isAdmin);
        _builder.append(_actionDocMethodDescription, " ");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append(" ");
        _builder.append("* @inheritDoc");
        _builder.newLine();
      }
    }
    {
      if ((isBase).booleanValue()) {
        String _actionDocMethodDocumentation = this.actionDocMethodDocumentation(it);
        _builder.append(_actionDocMethodDocumentation);
      }
    }
    _builder.newLineIfNotEmpty();
    CharSequence _generate = new Annotations(this.app).generate(it, entity, isBase, isAdmin);
    _builder.append(_generate);
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param Request $request Current request instance");
    _builder.newLine();
    CharSequence _actionDocMethodParams = this.actionDocMethodParams(entity, it);
    _builder.append(_actionDocMethodParams);
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return Response Output");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @throws AccessDeniedException Thrown if the user doesn\'t have required permissions");
    _builder.newLine();
    {
      if ((it instanceof DisplayAction)) {
        _builder.append(" ");
        _builder.append("* @throws NotFoundHttpException Thrown by param converter if ");
        String _formatForDisplay = this._formattingExtensions.formatForDisplay(entity.getName());
        _builder.append(_formatForDisplay, " ");
        _builder.append(" to be displayed isn\'t found");
        _builder.newLineIfNotEmpty();
      } else {
        if ((it instanceof EditAction)) {
          _builder.append(" ");
          _builder.append("* @throws NotFoundHttpException Thrown by form handler if ");
          String _formatForDisplay_1 = this._formattingExtensions.formatForDisplay(entity.getName());
          _builder.append(_formatForDisplay_1, " ");
          _builder.append(" to be edited isn\'t found");
          _builder.newLineIfNotEmpty();
          _builder.append(" ");
          _builder.append("* @throws RuntimeException      Thrown if another critical error occurs (e.g. workflow actions not available)");
          _builder.newLine();
        } else {
          if ((it instanceof DeleteAction)) {
            _builder.append(" ");
            _builder.append("* @throws NotFoundHttpException Thrown by param converter if ");
            String _formatForDisplay_2 = this._formattingExtensions.formatForDisplay(entity.getName());
            _builder.append(_formatForDisplay_2, " ");
            _builder.append(" to be deleted isn\'t found");
            _builder.newLineIfNotEmpty();
            _builder.append(" ");
            _builder.append("* @throws RuntimeException      Thrown if another critical error occurs (e.g. workflow actions not available)");
            _builder.newLine();
          }
        }
      }
    }
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    return _builder;
  }
  
  private String actionDocMethodDescription(final Action it, final Boolean isAdmin) {
    String _switchResult = null;
    boolean _matched = false;
    if (it instanceof MainAction) {
      _matched=true;
      String _controllerName = this._controllerExtensions.controllerName(it);
      String _plus = ("This is the default action handling the " + _controllerName);
      String _xifexpression = null;
      if ((isAdmin).booleanValue()) {
        _xifexpression = " admin";
      } else {
        _xifexpression = "";
      }
      String _plus_1 = (_plus + _xifexpression);
      _switchResult = (_plus_1 + " area called without defining arguments.");
    }
    if (!_matched) {
      if (it instanceof ViewAction) {
        _matched=true;
        String _xifexpression = null;
        if ((isAdmin).booleanValue()) {
          _xifexpression = " in the admin area";
        } else {
          _xifexpression = "";
        }
        String _plus = ("This action provides an item list overview" + _xifexpression);
        _switchResult = (_plus + ".");
      }
    }
    if (!_matched) {
      if (it instanceof DisplayAction) {
        _matched=true;
        String _xifexpression = null;
        if ((isAdmin).booleanValue()) {
          _xifexpression = " in the admin area";
        } else {
          _xifexpression = "";
        }
        String _plus = ("This action provides a item detail view" + _xifexpression);
        _switchResult = (_plus + ".");
      }
    }
    if (!_matched) {
      if (it instanceof EditAction) {
        _matched=true;
        String _xifexpression = null;
        if ((isAdmin).booleanValue()) {
          _xifexpression = " in the admin area";
        } else {
          _xifexpression = "";
        }
        String _plus = ("This action provides a handling of edit requests" + _xifexpression);
        _switchResult = (_plus + ".");
      }
    }
    if (!_matched) {
      if (it instanceof DeleteAction) {
        _matched=true;
        String _xifexpression = null;
        if ((isAdmin).booleanValue()) {
          _xifexpression = " in the admin area";
        } else {
          _xifexpression = "";
        }
        String _plus = ("This action provides a handling of simple delete requests" + _xifexpression);
        _switchResult = (_plus + ".");
      }
    }
    if (!_matched) {
      if (it instanceof CustomAction) {
        _matched=true;
        String _xifexpression = null;
        if ((isAdmin).booleanValue()) {
          _xifexpression = " in the admin area";
        } else {
          _xifexpression = "";
        }
        String _plus = ("This is a custom action" + _xifexpression);
        _switchResult = (_plus + ".");
      }
    }
    if (!_matched) {
      _switchResult = "";
    }
    return _switchResult;
  }
  
  private String actionDocMethodDocumentation(final Action it) {
    String _xifexpression = null;
    if (((null != it.getDocumentation()) && (!Objects.equal(it.getDocumentation(), "")))) {
      String _replace = it.getDocumentation().replace("*/", "*");
      _xifexpression = (" * " + _replace);
    } else {
      _xifexpression = "";
    }
    return _xifexpression;
  }
  
  private CharSequence actionDocMethodParams(final Entity it, final Action action) {
    CharSequence _xifexpression = null;
    if ((!((action instanceof MainAction) || (action instanceof CustomAction)))) {
      StringConcatenation _builder = new StringConcatenation();
      String _actionDocAdditionalParams = this.actionDocAdditionalParams(action, it);
      _builder.append(_actionDocAdditionalParams);
      _xifexpression = _builder;
    }
    return _xifexpression;
  }
  
  private String actionDocAdditionalParams(final Action it, final Entity refEntity) {
    String _switchResult = null;
    boolean _matched = false;
    if (it instanceof ViewAction) {
      _matched=true;
      _switchResult = (((" * @param string $sort         Sorting field\n" + " * @param string $sortdir      Sorting direction\n") + " * @param int    $pos          Current pager position\n") + " * @param int    $num          Amount of entries to display\n");
    }
    if (!_matched) {
      if (it instanceof DisplayAction) {
        _matched=true;
        String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(refEntity.getName());
        String _plus = (" * @param " + _formatForCodeCapital);
        String _plus_1 = (_plus + "Entity $");
        String _formatForCode = this._formattingExtensions.formatForCode(refEntity.getName());
        String _plus_2 = (_plus_1 + _formatForCode);
        String _plus_3 = (_plus_2 + " Treated ");
        String _formatForDisplay = this._formattingExtensions.formatForDisplay(refEntity.getName());
        String _plus_4 = (_plus_3 + _formatForDisplay);
        _switchResult = (_plus_4 + " instance\n");
      }
    }
    if (!_matched) {
      if (it instanceof DeleteAction) {
        _matched=true;
        String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(refEntity.getName());
        String _plus = (" * @param " + _formatForCodeCapital);
        String _plus_1 = (_plus + "Entity $");
        String _formatForCode = this._formattingExtensions.formatForCode(refEntity.getName());
        String _plus_2 = (_plus_1 + _formatForCode);
        String _plus_3 = (_plus_2 + " Treated ");
        String _formatForDisplay = this._formattingExtensions.formatForDisplay(refEntity.getName());
        String _plus_4 = (_plus_3 + _formatForDisplay);
        _switchResult = (_plus_4 + " instance\n");
      }
    }
    if (!_matched) {
      _switchResult = "";
    }
    return _switchResult;
  }
  
  private CharSequence _methodName(final Action it, final Boolean isAdmin) {
    StringConcatenation _builder = new StringConcatenation();
    {
      if ((!(isAdmin).booleanValue())) {
        String _firstLower = StringExtensions.toFirstLower(this._formattingExtensions.formatForCode(it.getName()));
        _builder.append(_firstLower);
      } else {
        _builder.append("admin");
        String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(it.getName());
        _builder.append(_formatForCodeCapital);
      }
    }
    return _builder;
  }
  
  private CharSequence _methodName(final MainAction it, final Boolean isAdmin) {
    StringConcatenation _builder = new StringConcatenation();
    {
      if ((isAdmin).booleanValue()) {
        _builder.append("adminIndex");
      } else {
        _builder.append("index");
      }
    }
    return _builder;
  }
  
  private CharSequence _methodArgs(final Entity it, final Action action) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("Request $request");
    return _builder;
  }
  
  private CharSequence _methodArgsCall(final Entity it, final Action action) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("$request");
    return _builder;
  }
  
  private CharSequence _methodArgs(final Entity it, final ViewAction action) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("Request $request, $sort, $sortdir, $pos, $num");
    return _builder;
  }
  
  private CharSequence _methodArgsCall(final Entity it, final ViewAction action) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("$request, $sort, $sortdir, $pos, $num");
    return _builder;
  }
  
  private CharSequence _methodArgs(final Entity it, final DisplayAction action) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("Request $request, ");
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital);
    _builder.append("Entity $");
    String _formatForCode = this._formattingExtensions.formatForCode(it.getName());
    _builder.append(_formatForCode);
    return _builder;
  }
  
  private CharSequence _methodArgsCall(final Entity it, final DisplayAction action) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("$request, $");
    String _formatForCode = this._formattingExtensions.formatForCode(it.getName());
    _builder.append(_formatForCode);
    return _builder;
  }
  
  private CharSequence _methodArgs(final Entity it, final EditAction action) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("Request $request");
    return _builder;
  }
  
  private CharSequence _methodArgsCall(final Entity it, final EditAction action) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("$request");
    return _builder;
  }
  
  private CharSequence _methodArgs(final Entity it, final DeleteAction action) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("Request $request, ");
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital);
    _builder.append("Entity $");
    String _formatForCode = this._formattingExtensions.formatForCode(it.getName());
    _builder.append(_formatForCode);
    return _builder;
  }
  
  private CharSequence _methodArgsCall(final Entity it, final DeleteAction action) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("$request, $");
    String _formatForCode = this._formattingExtensions.formatForCode(it.getName());
    _builder.append(_formatForCode);
    return _builder;
  }
  
  private CharSequence methodName(final Action it, final Boolean isAdmin) {
    if (it instanceof MainAction) {
      return _methodName((MainAction)it, isAdmin);
    } else if (it != null) {
      return _methodName(it, isAdmin);
    } else {
      throw new IllegalArgumentException("Unhandled parameter types: " +
        Arrays.<Object>asList(it, isAdmin).toString());
    }
  }
  
  private CharSequence methodArgs(final Entity it, final Action action) {
    if (action instanceof DeleteAction) {
      return _methodArgs(it, (DeleteAction)action);
    } else if (action instanceof DisplayAction) {
      return _methodArgs(it, (DisplayAction)action);
    } else if (action instanceof EditAction) {
      return _methodArgs(it, (EditAction)action);
    } else if (action instanceof ViewAction) {
      return _methodArgs(it, (ViewAction)action);
    } else if (action != null) {
      return _methodArgs(it, action);
    } else {
      throw new IllegalArgumentException("Unhandled parameter types: " +
        Arrays.<Object>asList(it, action).toString());
    }
  }
  
  private CharSequence methodArgsCall(final Entity it, final Action action) {
    if (action instanceof DeleteAction) {
      return _methodArgsCall(it, (DeleteAction)action);
    } else if (action instanceof DisplayAction) {
      return _methodArgsCall(it, (DisplayAction)action);
    } else if (action instanceof EditAction) {
      return _methodArgsCall(it, (EditAction)action);
    } else if (action instanceof ViewAction) {
      return _methodArgsCall(it, (ViewAction)action);
    } else if (action != null) {
      return _methodArgsCall(it, action);
    } else {
      throw new IllegalArgumentException("Unhandled parameter types: " +
        Arrays.<Object>asList(it, action).toString());
    }
  }
}

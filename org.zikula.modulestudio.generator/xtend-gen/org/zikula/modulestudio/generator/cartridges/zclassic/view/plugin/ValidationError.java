package org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin;

import com.google.inject.Inject;
import de.guite.modulestudio.metamodel.modulestudio.Application;
import de.guite.modulestudio.metamodel.modulestudio.DerivedField;
import de.guite.modulestudio.metamodel.modulestudio.Entity;
import org.eclipse.emf.common.util.EList;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class ValidationError {
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
  private ModelExtensions _modelExtensions = new Function0<ModelExtensions>() {
    public ModelExtensions apply() {
      ModelExtensions _modelExtensions = new ModelExtensions();
      return _modelExtensions;
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
  private Utils _utils = new Function0<Utils>() {
    public Utils apply() {
      Utils _utils = new Utils();
      return _utils;
    }
  }.apply();
  
  public void generate(final Application it, final IFileSystemAccess fsa) {
    String _viewPluginFilePath = this._namingExtensions.viewPluginFilePath(it, "function", "ValidationError");
    CharSequence _validationErrorFile = this.validationErrorFile(it);
    fsa.generateFile(_viewPluginFilePath, _validationErrorFile);
  }
  
  private CharSequence validationErrorFile(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    FileHelper _fileHelper = new FileHelper();
    CharSequence _phpFileHeader = _fileHelper.phpFileHeader(it);
    _builder.append(_phpFileHeader, "");
    _builder.newLineIfNotEmpty();
    CharSequence _validationErrorImpl = this.validationErrorImpl(it);
    _builder.append(_validationErrorImpl, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence validationErrorImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* The ");
    String _appName = this._utils.appName(it);
    String _formatForDB = this._formattingExtensions.formatForDB(_appName);
    _builder.append(_formatForDB, " ");
    _builder.append("ValidationError plugin returns appropriate (and multilingual)");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("* error messages for different client-side validation error types.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Available parameters:");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*   - id:     Optional id of element as part of unique error message element.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*   - class:  Treated validation class.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*   - assign: If set, the results are assigned to the corresponding variable instead of printed out.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param  array            $params All attributes passed to this function from the template.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param  Zikula_Form_View $view   Reference to the view object.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return string The output of the plugin.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("function smarty_function_");
    String _appName_1 = this._utils.appName(it);
    String _formatForDB_1 = this._formattingExtensions.formatForDB(_appName_1);
    _builder.append(_formatForDB_1, "");
    _builder.append("ValidationError($params, $view)");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$id = $params[\'id\'];");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$class = $params[\'class\'];");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$message = \'\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("switch ($class) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// default rules");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("case \'required\':                    $message = $view->__(\'This is a required field.\'); break;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("case \'validate-number\':             $message = $view->__(\'Please enter a valid number in this field.\'); break;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("case \'validate-digits\':             $message = $view->__(\'Please use numbers only in this field. please avoid spaces or other characters such as dots or commas.\'); break;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("case \'validate-alpha\':              $message = $view->__(\'Please use letters only (a-z) in this field.\'); break;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("case \'validate-alphanum\':           $message = $view->__(\'Please use only letters (a-z) or numbers (0-9) only in this field. No spaces or other characters are allowed.\'); break;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("case \'validate-date\':               $message = $view->__(\'Please enter a valid date.\'); break;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("case \'validate-email\':              $message = $view->__(\'Please enter a valid email address. For example yourname@example.com .\'); break;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("case \'validate-url\':                $message = $view->__(\'Please enter a valid URL.\'); break;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("case \'validate-date-au\':            $message = $view->__(\'Please use this date format: dd/mm/yyyy. For example 17/03/2010 for the 17th of March, 2010.\'); break;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("case \'validate-currency-dollar\':    $message = $view->__(\'Please enter a valid $ amount. For example $100.00 .\'); break;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("case \'validate-selection\':          $message = $view->__(\'Please make a selection.\'); break;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("case \'validate-one-required\':       $message = $view->__(\'Please select one of the above options.\'); break;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// additional rules");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("case \'validate-nospace\':            $message = $view->__(\'This value must not contain spaces.\'); break;");
    _builder.newLine();
    {
      boolean _hasColourFields = this._modelExtensions.hasColourFields(it);
      if (_hasColourFields) {
        _builder.append("        ");
        _builder.append("case \'validate-htmlcolour\':         $message = $view->__(\'Please select a valid html colour code.\'); break;");
        _builder.newLine();
      }
    }
    {
      boolean _hasUploads = this._modelExtensions.hasUploads(it);
      if (_hasUploads) {
        _builder.append("        ");
        _builder.append("case \'validate-upload\':             $message = $view->__(\'Please select an allowed file type.\'); break;");
        _builder.newLine();
      }
    }
    _builder.append("        ");
    _builder.append("case \'validate-datetime-past\':      $message = $view->__(\'Please select a value in the past.\'); break;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("case \'validate-datetime-future\':    $message = $view->__(\'Please select a value in the future.\'); break;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("case \'validate-date-past\':          $message = $view->__(\'Please select a value in the past.\'); break;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("case \'validate-date-future\':        $message = $view->__(\'Please select a value in the future.\'); break;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("case \'validate-time-past\':          $message = $view->__(\'Please select a value in the past.\'); break;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("case \'validate-time-future\':        $message = $view->__(\'Please select a value in the future.\'); break;");
    _builder.newLine();
    {
      EList<Entity> _allEntities = this._modelExtensions.getAllEntities(it);
      final Function1<Entity,Boolean> _function = new Function1<Entity,Boolean>() {
          public Boolean apply(final Entity e) {
            Iterable<DerivedField> _uniqueDerivedFields = ValidationError.this._modelExtensions.getUniqueDerivedFields(e);
            final Function1<DerivedField,Boolean> _function = new Function1<DerivedField,Boolean>() {
                public Boolean apply(final DerivedField f) {
                  boolean _isPrimaryKey = f.isPrimaryKey();
                  boolean _not = (!_isPrimaryKey);
                  return Boolean.valueOf(_not);
                }
              };
            Iterable<DerivedField> _filter = IterableExtensions.<DerivedField>filter(_uniqueDerivedFields, _function);
            int _size = IterableExtensions.size(_filter);
            boolean _greaterThan = (_size > 0);
            return Boolean.valueOf(_greaterThan);
          }
        };
      boolean _exists = IterableExtensions.<Entity>exists(_allEntities, _function);
      if (_exists) {
        _builder.append("        ");
        _builder.append("case \'validate-unique\':             $message = $view->__(\'This value is already assigned, but must be unique. Please change it.\'); break;");
        _builder.newLine();
      }
    }
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$message = \'<div id=\"advice-\' . $class . \'-\' . $id . \'\" class=\"validation-advice z-formnote\" style=\"display: none\">\' . $message . \'</div>\';");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (array_key_exists(\'assign\', $params)) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$view->assign($params[\'assign\'], $message);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $message;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
}

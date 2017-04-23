package org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff;

import com.google.common.base.Objects;
import de.guite.modulestudio.metamodel.AbstractDateField;
import de.guite.modulestudio.metamodel.AbstractIntegerField;
import de.guite.modulestudio.metamodel.Application;
import de.guite.modulestudio.metamodel.BooleanField;
import de.guite.modulestudio.metamodel.DecimalField;
import de.guite.modulestudio.metamodel.DerivedField;
import de.guite.modulestudio.metamodel.Entity;
import de.guite.modulestudio.metamodel.FloatField;
import de.guite.modulestudio.metamodel.IntegerField;
import de.guite.modulestudio.metamodel.OneToManyRelationship;
import de.guite.modulestudio.metamodel.UserField;
import java.util.Arrays;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.GeneratorSettingsExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.ModelInheritanceExtensions;
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class FileHelper {
  @Extension
  private FormattingExtensions _formattingExtensions = new FormattingExtensions();
  
  @Extension
  private GeneratorSettingsExtensions _generatorSettingsExtensions = new GeneratorSettingsExtensions();
  
  @Extension
  private ModelExtensions _modelExtensions = new ModelExtensions();
  
  @Extension
  private ModelInheritanceExtensions _modelInheritanceExtensions = new ModelInheritanceExtensions();
  
  @Extension
  private ModelJoinExtensions _modelJoinExtensions = new ModelJoinExtensions();
  
  @Extension
  private Utils _utils = new Utils();
  
  public CharSequence phpFileHeader(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("<?php");
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    CharSequence _phpFileHeaderImpl = this.phpFileHeaderImpl(it);
    _builder.append(_phpFileHeaderImpl, " ");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("* @version ");
    CharSequence _generatedBy = this.generatedBy(it, Boolean.valueOf(this._generatorSettingsExtensions.timestampAllGeneratedFiles(it)), Boolean.valueOf(this._generatorSettingsExtensions.versionAllGeneratedFiles(it)));
    _builder.append(_generatedBy, " ");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.newLine();
    return _builder;
  }
  
  public CharSequence phpFileContent(final Application it, final CharSequence content) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _phpFileHeader = this.phpFileHeader(it);
    _builder.append(_phpFileHeader);
    _builder.newLineIfNotEmpty();
    _builder.append(content);
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  public CharSequence phpFileHeaderBootstrapFile(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("<?php");
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    CharSequence _phpFileHeaderImpl = this.phpFileHeaderImpl(it);
    _builder.append(_phpFileHeaderImpl, " ");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("* @version ");
    CharSequence _generatedBy = this.generatedBy(it, Boolean.valueOf(true), Boolean.valueOf(true));
    _builder.append(_generatedBy, " ");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence phpFileHeaderImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("* ");
    String _name = it.getName();
    _builder.append(_name);
    _builder.append(".");
    _builder.newLineIfNotEmpty();
    _builder.append("*");
    _builder.newLine();
    _builder.append("* @copyright ");
    String _author = it.getAuthor();
    _builder.append(_author);
    _builder.append(" (");
    String _vendor = it.getVendor();
    _builder.append(_vendor);
    _builder.append(")");
    _builder.newLineIfNotEmpty();
    _builder.append("* @license ");
    String _license = it.getLicense();
    _builder.append(_license);
    _builder.newLineIfNotEmpty();
    _builder.append("* @author ");
    String _author_1 = it.getAuthor();
    _builder.append(_author_1);
    {
      if (((null != it.getEmail()) && (!Objects.equal(it.getEmail(), "")))) {
        _builder.append(" <");
        String _email = it.getEmail();
        _builder.append(_email);
        _builder.append(">");
      }
    }
    _builder.append(".");
    _builder.newLineIfNotEmpty();
    _builder.append("* @link ");
    {
      String _url = it.getUrl();
      boolean _notEquals = (!Objects.equal(_url, ""));
      if (_notEquals) {
        String _url_1 = it.getUrl();
        _builder.append(_url_1);
      } else {
        String _msUrl = this._utils.msUrl();
        _builder.append(_msUrl);
      }
    }
    {
      String _url_2 = it.getUrl();
      boolean _notEquals_1 = (!Objects.equal(_url_2, "http://zikula.org"));
      if (_notEquals_1) {
        _builder.newLineIfNotEmpty();
        _builder.append("* @link http://zikula.org");
      }
    }
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  public CharSequence generatedBy(final Application it, final Boolean includeTimestamp, final Boolean includeVersion) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("Generated by ModuleStudio ");
    {
      if ((includeVersion).booleanValue()) {
        String _msVersion = this._utils.msVersion();
        _builder.append(_msVersion);
        _builder.append(" ");
      }
    }
    _builder.append("(");
    String _msUrl = this._utils.msUrl();
    _builder.append(_msUrl);
    _builder.append(")");
    {
      if ((includeTimestamp).booleanValue()) {
        _builder.append(" at ");
        String _timestamp = this._utils.timestamp();
        _builder.append(_timestamp);
      }
    }
    _builder.append(".");
    return _builder;
  }
  
  public CharSequence msWeblink(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("<p class=\"text-center\">");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("Powered by <a href=\"");
    String _msUrl = this._utils.msUrl();
    _builder.append(_msUrl, "    ");
    _builder.append("\" title=\"Get the MOST out of Zikula!\">ModuleStudio ");
    String _msVersion = this._utils.msVersion();
    _builder.append(_msVersion, "    ");
    _builder.append("</a>");
    _builder.newLineIfNotEmpty();
    _builder.append("</p>");
    _builder.newLine();
    return _builder;
  }
  
  public CharSequence getterAndSetterMethods(final Object it, final String name, final String type, final Boolean isMany, final Boolean nullable, final Boolean useHint, final String init, final CharSequence customImpl) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _terMethod = this.getterMethod(it, name, type, isMany);
    _builder.append(_terMethod);
    _builder.newLineIfNotEmpty();
    CharSequence _setterMethod = this.setterMethod(it, name, type, isMany, nullable, useHint, init, customImpl);
    _builder.append(_setterMethod);
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  public CharSequence getterMethod(final Object it, final String name, final String type, final Boolean isMany) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Returns the ");
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(name);
    _builder.append(_formatForDisplay, " ");
    _builder.append(".");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return ");
    {
      if ((Objects.equal(type, "smallint") || Objects.equal(type, "bigint"))) {
        _builder.append("integer");
      } else {
        boolean _equals = Objects.equal(type, "datetime");
        if (_equals) {
          _builder.append("\\DateTime");
        } else {
          _builder.append(type, " ");
        }
      }
    }
    {
      if (((!Objects.equal(type.toLowerCase(), "array")) && (isMany).booleanValue())) {
        _builder.append("[]");
      }
    }
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function get");
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(name);
    _builder.append(_formatForCodeCapital);
    _builder.append("()");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $this->");
    _builder.append(name, "    ");
    _builder.append(";");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    return _builder;
  }
  
  public CharSequence setterMethod(final Object it, final String name, final String type, final Boolean isMany, final Boolean nullable, final Boolean useHint, final String init, final CharSequence customImpl) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Sets the ");
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(name);
    _builder.append(_formatForDisplay, " ");
    _builder.append(".");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param ");
    {
      if ((Objects.equal(type, "smallint") || Objects.equal(type, "bigint"))) {
        _builder.append("integer");
      } else {
        boolean _equals = Objects.equal(type, "datetime");
        if (_equals) {
          _builder.append("\\DateTime");
        } else {
          _builder.append(type, " ");
        }
      }
    }
    {
      if (((!Objects.equal(type.toLowerCase(), "array")) && (isMany).booleanValue())) {
        _builder.append("[]");
      }
    }
    _builder.append(" $");
    _builder.append(name, " ");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return void");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function set");
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(name);
    _builder.append(_formatForCodeCapital);
    _builder.append("(");
    {
      if (((!(nullable).booleanValue()) && (useHint).booleanValue())) {
        _builder.append(type);
        _builder.append(" ");
      }
    }
    _builder.append("$");
    _builder.append(name);
    {
      boolean _notEquals = (!Objects.equal(init, ""));
      if (_notEquals) {
        _builder.append(" = ");
        _builder.append(init);
      }
    }
    _builder.append(")");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    {
      if (((null != customImpl) && (!Objects.equal(customImpl, "")))) {
        _builder.append("    ");
        _builder.append(customImpl, "    ");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("    ");
        CharSequence _setterMethodImpl = this.setterMethodImpl(it, name, type, nullable);
        _builder.append(_setterMethodImpl, "    ");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence _setterMethodImpl(final Object it, final String name, final String type, final Boolean nullable) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _equals = Objects.equal(type, "float");
      if (_equals) {
        _builder.append("if (floatval($this->");
        _builder.append(name);
        _builder.append(") !== floatval($");
        _builder.append(name);
        _builder.append(")) {");
        _builder.newLineIfNotEmpty();
        {
          if ((nullable).booleanValue()) {
            _builder.append("    ");
            _builder.append("$this->");
            _builder.append(name, "    ");
            _builder.append(" = floatval($");
            _builder.append(name, "    ");
            _builder.append(");");
            _builder.newLineIfNotEmpty();
          } else {
            _builder.append("    ");
            _builder.append("$this->");
            _builder.append(name, "    ");
            _builder.append(" = isset($");
            _builder.append(name, "    ");
            _builder.append(") ? floatval($");
            _builder.append(name, "    ");
            _builder.append(") : 0.00;");
            _builder.newLineIfNotEmpty();
          }
        }
        _builder.append("}");
        _builder.newLine();
      } else {
        _builder.append("if ($this->");
        _builder.append(name);
        _builder.append(" != $");
        _builder.append(name);
        _builder.append(") {");
        _builder.newLineIfNotEmpty();
        {
          if ((nullable).booleanValue()) {
            _builder.append("    ");
            _builder.append("$this->");
            _builder.append(name, "    ");
            _builder.append(" = $");
            _builder.append(name, "    ");
            _builder.append(";");
            _builder.newLineIfNotEmpty();
          } else {
            _builder.append("    ");
            _builder.append("$this->");
            _builder.append(name, "    ");
            _builder.append(" = isset($");
            _builder.append(name, "    ");
            _builder.append(") ? $");
            _builder.append(name, "    ");
            _builder.append(" : \'\';");
            _builder.newLineIfNotEmpty();
          }
        }
        _builder.append("}");
        _builder.newLine();
      }
    }
    return _builder;
  }
  
  public CharSequence triggerPropertyChangeListeners(final DerivedField it, final String name) {
    StringConcatenation _builder = new StringConcatenation();
    {
      if ((((it.getEntity() instanceof Entity) && this._modelExtensions.hasNotifyPolicy(((Entity) it.getEntity()))) || IterableExtensions.<Entity>exists(this._modelInheritanceExtensions.getInheritingEntities(it.getEntity()), ((Function1<Entity, Boolean>) (Entity it_1) -> {
        return Boolean.valueOf(this._modelExtensions.hasNotifyPolicy(it_1));
      })))) {
        _builder.append("$this->_onPropertyChanged(\'");
        String _formatForCode = this._formattingExtensions.formatForCode(name);
        _builder.append(_formatForCode);
        _builder.append("\', $this->");
        String _formatForCode_1 = this._formattingExtensions.formatForCode(name);
        _builder.append(_formatForCode_1);
        _builder.append(", $");
        _builder.append(name);
        _builder.append(");");
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder;
  }
  
  private CharSequence _setterMethodImpl(final DerivedField it, final String name, final String type, final Boolean nullable) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("if ($this->");
    String _formatForCode = this._formattingExtensions.formatForCode(name);
    _builder.append(_formatForCode);
    _builder.append(" !== $");
    _builder.append(name);
    _builder.append(") {");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    CharSequence _triggerPropertyChangeListeners = this.triggerPropertyChangeListeners(it, name);
    _builder.append(_triggerPropertyChangeListeners, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    CharSequence _setterAssignment = this.setterAssignment(it, name, type);
    _builder.append(_setterAssignment, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence _setterMethodImpl(final BooleanField it, final String name, final String type, final Boolean nullable) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("if (boolval($this->");
    String _formatForCode = this._formattingExtensions.formatForCode(name);
    _builder.append(_formatForCode);
    _builder.append(") !== boolval($");
    _builder.append(name);
    _builder.append(")) {");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    CharSequence _triggerPropertyChangeListeners = this.triggerPropertyChangeListeners(it, name);
    _builder.append(_triggerPropertyChangeListeners, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    CharSequence _setterAssignment = this.setterAssignment(it, name, type);
    _builder.append(_setterAssignment, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence _setterAssignment(final DerivedField it, final String name, final String type) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _isNullable = it.isNullable();
      if (_isNullable) {
        _builder.append("$this->");
        _builder.append(name);
        _builder.append(" = $");
        _builder.append(name);
        _builder.append(";");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("$this->");
        _builder.append(name);
        _builder.append(" = isset($");
        _builder.append(name);
        _builder.append(") ? $");
        _builder.append(name);
        _builder.append(" : \'\';");
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder;
  }
  
  private CharSequence _setterAssignment(final BooleanField it, final String name, final String type) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("$this->");
    _builder.append(name);
    _builder.append(" = boolval($");
    _builder.append(name);
    _builder.append(");");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence setterAssignmentNumeric(final DerivedField it, final String name, final String type) {
    StringConcatenation _builder = new StringConcatenation();
    final Iterable<OneToManyRelationship> aggregators = this._modelJoinExtensions.getAggregatingRelationships(it);
    _builder.newLineIfNotEmpty();
    {
      boolean _isEmpty = IterableExtensions.isEmpty(aggregators);
      boolean _not = (!_isEmpty);
      if (_not) {
        _builder.append("$diff = abs($this->");
        _builder.append(name);
        _builder.append(" - $");
        _builder.append(name);
        _builder.append(");");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("$this->");
    _builder.append(name);
    _builder.append(" = ");
    {
      if ((it instanceof UserField)) {
        _builder.append("$");
        _builder.append(name);
        _builder.append(";");
      } else {
        {
          if ((it instanceof AbstractIntegerField)) {
            _builder.append("intval");
          } else {
            _builder.append("floatval");
          }
        }
        _builder.append("($");
        _builder.append(name);
        _builder.append(");");
      }
    }
    _builder.newLineIfNotEmpty();
    {
      boolean _isEmpty_1 = IterableExtensions.isEmpty(aggregators);
      boolean _not_1 = (!_isEmpty_1);
      if (_not_1) {
        {
          for(final OneToManyRelationship aggregator : aggregators) {
            _builder.append("$this->");
            String _formatForCode = this._formattingExtensions.formatForCode(aggregator.getSourceAlias());
            _builder.append(_formatForCode);
            _builder.append("->add");
            String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(name);
            _builder.append(_formatForCodeCapital);
            _builder.append("Without");
            String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(it.getEntity().getName());
            _builder.append(_formatForCodeCapital_1);
            _builder.append("($diff);");
            _builder.newLineIfNotEmpty();
          }
        }
      }
    }
    return _builder;
  }
  
  private CharSequence _setterMethodImpl(final IntegerField it, final String name, final String type, final Boolean nullable) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("if (intval($this->");
    String _formatForCode = this._formattingExtensions.formatForCode(name);
    _builder.append(_formatForCode);
    _builder.append(") !== intval($");
    _builder.append(name);
    _builder.append(")) {");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    CharSequence _triggerPropertyChangeListeners = this.triggerPropertyChangeListeners(it, name);
    _builder.append(_triggerPropertyChangeListeners, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    CharSequence _setterAssignmentNumeric = this.setterAssignmentNumeric(it, name, type);
    _builder.append(_setterAssignmentNumeric, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence _setterMethodImpl(final DecimalField it, final String name, final String type, final Boolean nullable) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("if (floatval($this->");
    String _formatForCode = this._formattingExtensions.formatForCode(name);
    _builder.append(_formatForCode);
    _builder.append(") !== floatval($");
    _builder.append(name);
    _builder.append(")) {");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    CharSequence _triggerPropertyChangeListeners = this.triggerPropertyChangeListeners(it, name);
    _builder.append(_triggerPropertyChangeListeners, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    CharSequence _setterAssignmentNumeric = this.setterAssignmentNumeric(it, name, type);
    _builder.append(_setterAssignmentNumeric, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence _setterMethodImpl(final FloatField it, final String name, final String type, final Boolean nullable) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("if (floatval($this->");
    String _formatForCode = this._formattingExtensions.formatForCode(name);
    _builder.append(_formatForCode);
    _builder.append(") !== floatval($");
    _builder.append(name);
    _builder.append(")) {");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    CharSequence _triggerPropertyChangeListeners = this.triggerPropertyChangeListeners(it, name);
    _builder.append(_triggerPropertyChangeListeners, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    CharSequence _setterAssignmentNumeric = this.setterAssignmentNumeric(it, name, type);
    _builder.append(_setterAssignmentNumeric, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence _setterAssignment(final AbstractDateField it, final String name, final String type) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("if (is_object($");
    _builder.append(name);
    _builder.append(") && $");
    _builder.append(name);
    _builder.append(" instanceOf \\DateTime) {");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("$this->");
    _builder.append(name, "    ");
    _builder.append(" = $");
    _builder.append(name, "    ");
    _builder.append(";");
    _builder.newLineIfNotEmpty();
    {
      boolean _isNullable = it.isNullable();
      if (_isNullable) {
        _builder.append("} elseif (null === $");
        _builder.append(name);
        _builder.append(" || empty($");
        _builder.append(name);
        _builder.append(")) {");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("$this->");
        _builder.append(name, "    ");
        _builder.append(" = null;");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("} else {");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$this->");
    _builder.append(name, "    ");
    _builder.append(" = new \\DateTime($");
    _builder.append(name, "    ");
    _builder.append(");");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence setterMethodImpl(final Object it, final String name, final String type, final Boolean nullable) {
    if (it instanceof IntegerField) {
      return _setterMethodImpl((IntegerField)it, name, type, nullable);
    } else if (it instanceof DecimalField) {
      return _setterMethodImpl((DecimalField)it, name, type, nullable);
    } else if (it instanceof FloatField) {
      return _setterMethodImpl((FloatField)it, name, type, nullable);
    } else if (it instanceof BooleanField) {
      return _setterMethodImpl((BooleanField)it, name, type, nullable);
    } else if (it instanceof DerivedField) {
      return _setterMethodImpl((DerivedField)it, name, type, nullable);
    } else if (it != null) {
      return _setterMethodImpl(it, name, type, nullable);
    } else {
      throw new IllegalArgumentException("Unhandled parameter types: " +
        Arrays.<Object>asList(it, name, type, nullable).toString());
    }
  }
  
  private CharSequence setterAssignment(final DerivedField it, final String name, final String type) {
    if (it instanceof AbstractDateField) {
      return _setterAssignment((AbstractDateField)it, name, type);
    } else if (it instanceof BooleanField) {
      return _setterAssignment((BooleanField)it, name, type);
    } else if (it != null) {
      return _setterAssignment(it, name, type);
    } else {
      throw new IllegalArgumentException("Unhandled parameter types: " +
        Arrays.<Object>asList(it, name, type).toString());
    }
  }
}

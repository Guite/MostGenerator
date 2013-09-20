package org.zikula.modulestudio.generator.cartridges.zclassic.models.business;

import com.google.common.base.Objects;
import com.google.common.collect.Iterables;
import com.google.inject.Inject;
import de.guite.modulestudio.metamodel.modulestudio.AbstractDateField;
import de.guite.modulestudio.metamodel.modulestudio.AbstractIntegerField;
import de.guite.modulestudio.metamodel.modulestudio.AbstractStringField;
import de.guite.modulestudio.metamodel.modulestudio.Application;
import de.guite.modulestudio.metamodel.modulestudio.ArrayField;
import de.guite.modulestudio.metamodel.modulestudio.BooleanField;
import de.guite.modulestudio.metamodel.modulestudio.DateField;
import de.guite.modulestudio.metamodel.modulestudio.DatetimeField;
import de.guite.modulestudio.metamodel.modulestudio.DecimalField;
import de.guite.modulestudio.metamodel.modulestudio.DerivedField;
import de.guite.modulestudio.metamodel.modulestudio.EmailField;
import de.guite.modulestudio.metamodel.modulestudio.Entity;
import de.guite.modulestudio.metamodel.modulestudio.FloatField;
import de.guite.modulestudio.metamodel.modulestudio.IntegerField;
import de.guite.modulestudio.metamodel.modulestudio.JoinRelationship;
import de.guite.modulestudio.metamodel.modulestudio.ListField;
import de.guite.modulestudio.metamodel.modulestudio.ObjectField;
import de.guite.modulestudio.metamodel.modulestudio.Relationship;
import de.guite.modulestudio.metamodel.modulestudio.StringField;
import de.guite.modulestudio.metamodel.modulestudio.TextField;
import de.guite.modulestudio.metamodel.modulestudio.TimeField;
import de.guite.modulestudio.metamodel.modulestudio.UploadField;
import de.guite.modulestudio.metamodel.modulestudio.UrlField;
import de.guite.modulestudio.metamodel.modulestudio.UserField;
import java.math.BigInteger;
import java.util.Arrays;
import org.eclipse.emf.common.util.EList;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.InputOutput;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.ModelInheritanceExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class Validator {
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
  private ModelInheritanceExtensions _modelInheritanceExtensions = new Function0<ModelInheritanceExtensions>() {
    public ModelInheritanceExtensions apply() {
      ModelInheritanceExtensions _modelInheritanceExtensions = new ModelInheritanceExtensions();
      return _modelInheritanceExtensions;
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
  
  private FileHelper fh = new Function0<FileHelper>() {
    public FileHelper apply() {
      FileHelper _fileHelper = new FileHelper();
      return _fileHelper;
    }
  }.apply();
  
  /**
   * Creates a base validator class encapsulating common checks.
   */
  public void generateCommon(final Application it, final IFileSystemAccess fsa) {
    InputOutput.<String>println("Generating base validator class");
    String fileName = "Validator.php";
    boolean _targets = this._utils.targets(it, "1.3.5");
    boolean _not = (!_targets);
    if (_not) {
      String _plus = ("Abstract" + fileName);
      fileName = _plus;
    }
    String _appSourceLibPath = this._namingExtensions.getAppSourceLibPath(it);
    String _plus_1 = (_appSourceLibPath + "Base/");
    String _plus_2 = (_plus_1 + fileName);
    CharSequence _validatorCommonBaseFile = this.validatorCommonBaseFile(it);
    fsa.generateFile(_plus_2, _validatorCommonBaseFile);
    String _appSourceLibPath_1 = this._namingExtensions.getAppSourceLibPath(it);
    String _plus_3 = (_appSourceLibPath_1 + fileName);
    CharSequence _validatorCommonFile = this.validatorCommonFile(it);
    fsa.generateFile(_plus_3, _validatorCommonFile);
  }
  
  private CharSequence validatorCommonBaseFile(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _phpFileHeader = this.fh.phpFileHeader(it);
    _builder.append(_phpFileHeader, "");
    _builder.newLineIfNotEmpty();
    CharSequence _validatorCommonBaseImpl = this.validatorCommonBaseImpl(it);
    _builder.append(_validatorCommonBaseImpl, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence validatorCommonFile(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _phpFileHeader = this.fh.phpFileHeader(it);
    _builder.append(_phpFileHeader, "");
    _builder.newLineIfNotEmpty();
    CharSequence _validatorCommonImpl = this.validatorCommonImpl(it);
    _builder.append(_validatorCommonImpl, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence validatorCommonBaseImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _targets = this._utils.targets(it, "1.3.5");
      boolean _not = (!_targets);
      if (_not) {
        _builder.append("namespace ");
        String _appNamespace = this._utils.appNamespace(it);
        _builder.append(_appNamespace, "");
        _builder.append("\\Base;");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        _builder.append("use UserUtil;");
        _builder.newLine();
        _builder.append("use Zikula_AbstractBase;");
        _builder.newLine();
        _builder.append("use Zikula_EntityAccess;");
        _builder.newLine();
        _builder.append("use ZLanguage;");
        _builder.newLine();
        _builder.newLine();
      }
    }
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Validator class for encapsulating common entity validation methods.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* This is the base validation class with general checks.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("abstract class ");
    {
      boolean _targets_1 = this._utils.targets(it, "1.3.5");
      if (_targets_1) {
        String _appName = this._utils.appName(it);
        _builder.append(_appName, "");
        _builder.append("_Base_Validator");
      } else {
        _builder.append("AbstractValidator");
      }
    }
    _builder.append(" extends Zikula_AbstractBase");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @var Zikula_EntityAccess The entity instance which is treated by this validator.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("protected $entity = null;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* Constructor.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @param Zikula_EntityAccess $entity The entity to be validated.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("public function __construct(Zikula_EntityAccess $entity)");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$this->entity = $entity;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* Checks if field value is a valid boolean.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @param string $fieldName The name of the property to be checked");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @return boolean result of this check");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("public function isValidBoolean($fieldName)");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return (is_bool($this->entity[$fieldName]));");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* Checks if field value is a valid number.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @param string $fieldName The name of the property to be checked");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @return boolean result of this check");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("public function isValidNumber($fieldName)");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return (is_numeric($this->entity[$fieldName]));");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* Checks if field value is a valid integer.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @param string $fieldName The name of the property to be checked");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @return boolean result of this check");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("public function isValidInteger($fieldName)");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$val = $this->entity[$fieldName];");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return ($val == intval($val));");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* Checks if integer field value is not lower than a given value.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @param string $fieldName The name of the property to be checked");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @param int    $value     The maximum allowed value");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @return boolean result of this check");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("public function isIntegerNotLowerThan($fieldName, $value)");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return ($this->isValidInteger($fieldName) && $this->entity[$fieldName] >= $value);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* Checks if integer field value is not higher than a given value.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @param string $fieldName The name of the property to be checked");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @param int    $value     The maximum allowed value");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @return boolean result of this check");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("public function isIntegerNotHigherThan($fieldName, $value)");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return ($this->isValidInteger($fieldName) && $this->entity[$fieldName] <= $value);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* Checks if field value is a valid user id.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @param string $fieldName The name of the property to be checked");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @return boolean result of this check");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("public function isValidUser($fieldName)");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if (!$this->isValidInteger($fieldName)) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("return false;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$uname = UserUtil::getVar(\'uname\', $this->entity[$fieldName]);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return (!is_null($uname) && !empty($uname));");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* Checks if numeric field value has a value other than 0.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @param string $fieldName The name of the property to be checked");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @return boolean result of this check");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("public function isNumberNotEmpty($fieldName)");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return $this->entity[$fieldName] != 0;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* Checks if string field value has a value other than \'\'.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @param string $fieldName The name of the property to be checked");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @return boolean result of this check");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("public function isStringNotEmpty($fieldName)");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return $this->entity[$fieldName] != \'\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* Checks if numeric field value has a given minimum field length");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @param string $fieldName The name of the property to be checked");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @param int    $length    The minimum length");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @return boolean result of this check");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("public function isNumberNotShorterThan($fieldName, $length)");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$minValue = pow(10, $length-1);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return ($this->isValidNumber($fieldName) && $this->entity[$fieldName] > $minValue);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* Checks if numeric field value does fit into given field length.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @param string $fieldName The name of the property to be checked");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @param int    $length    The maximum allowed length");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @return boolean result of this check");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("public function isNumberNotLongerThan($fieldName, $length)");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$maxValue = pow(10, $length);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return ($this->isValidNumber($fieldName) && $this->entity[$fieldName] < $maxValue);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* Checks if string field value has a given minimum field length.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @param string $fieldName The name of the property to be checked");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @param int    $length    The minimum length");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @return boolean result of this check");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("public function isStringNotShorterThan($fieldName, $length)");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return (strlen($this->entity[$fieldName]) >= $length);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* Checks if string field value does fit into given field length.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @param string $fieldName The name of the property to be checked");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @param int    $length    The maximum allowed length");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @return boolean result of this check");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("public function isStringNotLongerThan($fieldName, $length)");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return (strlen($this->entity[$fieldName]) <= $length);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* Checks if string field value does conform to given fixed field length.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @param string $fieldName The name of the property to be checked");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @param int    $length    The fixed length");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @return boolean result of this check");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("public function isStringWithFixedLength($fieldName, $length)");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return (strlen($this->entity[$fieldName]) == $length);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* Checks if string field value does not contain a given string.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @param string  $fieldName The name of the property to be checked");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @param string  $keyword   The char or string to search for");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @param boolean $caseSensitive Whether the search should be case sensitive or not (default false)");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @return boolean result of this check");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("public function isStringNotContaining($fieldName, $keyword, $caseSensitive = false)");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if ($caseSensitive === true) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("return (strstr($this->entity[$fieldName], $keyword) === false);");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return (stristr($this->entity[$fieldName], $keyword) === false);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* Checks if string field value conforms to a given regular expression.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @param string  $fieldName  The name of the property to be checked");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @param string  $expression Regular expression string");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @return boolean result of this check");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("public function isValidRegExp($fieldName, $expression)");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return preg_match($expression, $this->entity[$fieldName]);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* Checks if string field value is a valid language code.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @param string  $fieldName     The name of the property to be checked");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @param boolean $onlyInstalled Whether to accept only installed languages (default false)");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @return boolean result of this check");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("public function isValidLanguage($fieldName, $onlyInstalled = false)");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$languageMap = ZLanguage::languagemap();");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$result = in_array($this->entity[$fieldName], array_keys($languageMap));        ");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if (!$result || !$onlyInstalled) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("return $result;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("} ");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$available = ZLanguage::getInstalledLanguages();");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return in_array($this->entity[$fieldName], $available);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* Checks if string field value is a valid country code.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @param string  $fieldName The name of the property to be checked");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @return boolean result of this check");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("public function isValidCountry($fieldName)");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$countryMap = ZLanguage::countrymap();");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return in_array($this->entity[$fieldName], array_keys($countryMap));");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* Checks if string field value is a valid html colour.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @param string  $fieldName The name of the property to be checked");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @return boolean result of this check");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("public function isValidHtmlColour($fieldName)");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$regex = \'/^#?(([a-fA-F0-9]{3}){1,2})$/\';");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return preg_match($regex, $this->entity[$fieldName]);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* Checks if field value is a valid email address.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @param string $fieldName The name of the property to be checked");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @return boolean result of this check");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("public function isValidEmail($fieldName)");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return filter_var($this->entity[$fieldName], FILTER_VALIDATE_EMAIL);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* Checks if field value is a valid url.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @param string $fieldName The name of the property to be checked");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @return boolean result of this check");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("public function isValidUrl($fieldName)");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return filter_var($this->entity[$fieldName], FILTER_VALIDATE_URL);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* Checks if field value is a valid DateTime instance.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @param string $fieldName The name of the property to be checked");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @return boolean result of this check");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("public function isValidDateTime($fieldName)");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return ($this->entity[$fieldName] instanceof \\DateTime);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* Checks if field value has a value in the past.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @param string  $fieldName The name of the property to be checked");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @param string  $format    The date format used for comparison");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @param boolean $mandatory Whether the property is mandatory or not.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @return boolean result of this check");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("protected function isDateTimeValueInPast($fieldName, $format, $mandatory = true)");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if ($mandatory === false) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("return true;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return ($this->isValidDateTime($fieldName) && $this->entity[$fieldName]->format($format) < date($format));");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* Checks if field value has a value in the future.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @param string  $fieldName The name of the property to be checked");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @param string  $format    The date format used for comparison");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @param boolean $mandatory Whether the property is mandatory or not.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @return boolean result of this check");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("protected function isDateTimeValueInFuture($fieldName, $format, $mandatory = true)");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if ($mandatory === false) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("return true;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return ($this->isValidDateTime($fieldName) && $this->entity[$fieldName]->format($format) > date($format));");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* Checks if field value is a datetime in the past.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @param string  $fieldName The name of the property to be checked");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @param boolean $mandatory Whether the property is mandatory or not.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @return boolean result of this check");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("public function isDateTimeInPast($fieldName, $mandatory = true)");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return $this->isDateTimeValueInPast($fieldName, \'U\', $mandatory);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* Checks if field value is a datetime in the future.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @param string  $fieldName The name of the property to be checked");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @param boolean $mandatory Whether the property is mandatory or not.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @return boolean result of this check");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("public function isDateTimeInFuture($fieldName, $mandatory = true)");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return $this->isDateTimeValueInFuture($fieldName, \'U\', $mandatory);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* Checks if field value is a date in the past.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @param string  $fieldName The name of the property to be checked");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @param boolean $mandatory Whether the property is mandatory or not.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @return boolean result of this check");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("public function isDateInPast($fieldName, $mandatory = true)");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return $this->isDateTimeValueInPast($fieldName, \'Ymd\', $mandatory);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* Checks if field value is a date in the future.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @param string  $fieldName The name of the property to be checked");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @param boolean $mandatory Whether the property is mandatory or not.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @return boolean result of this check");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("public function isDateInFuture($fieldName, $mandatory = true)");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return $this->isDateTimeValueInFuture($fieldName, \'Ymd\', $mandatory);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* Checks if field value is a time in the past.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @param string  $fieldName The name of the property to be checked");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @param boolean $mandatory Whether the property is mandatory or not.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @return boolean result of this check");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("public function isTimeInPast($fieldName, $mandatory = true)");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return $this->isDateTimeValueInPast($fieldName, \'His\', $mandatory);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* Checks if field value is a time in the future.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @param string  $fieldName The name of the property to be checked");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @param boolean $mandatory Whether the property is mandatory or not.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @return boolean result of this check");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("public function isTimeInFuture($fieldName, $mandatory = true)");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return $this->isDateTimeValueInFuture($fieldName, \'His\', $mandatory);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence validatorCommonImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _targets = this._utils.targets(it, "1.3.5");
      boolean _not = (!_targets);
      if (_not) {
        _builder.append("namespace ");
        String _appNamespace = this._utils.appNamespace(it);
        _builder.append(_appNamespace, "");
        _builder.append(";");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        _builder.append("use ");
        String _appNamespace_1 = this._utils.appNamespace(it);
        _builder.append(_appNamespace_1, "");
        _builder.append("\\Base\\AbstractValidator as BaseAbstractValidator;");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
      }
    }
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Validator class for encapsulating common entity validation methods.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* This is the concrete validation class with general checks.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    {
      boolean _targets_1 = this._utils.targets(it, "1.3.5");
      if (_targets_1) {
        _builder.append("class ");
        String _appName = this._utils.appName(it);
        _builder.append(_appName, "");
        _builder.append("_Validator extends ");
        String _appName_1 = this._utils.appName(it);
        _builder.append(_appName_1, "");
        _builder.append("_Base_Validator");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("class AbstractValidator extends BaseAbstractValidator");
        _builder.newLine();
      }
    }
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// here you can add custom validation methods or override existing checks");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  /**
   * Creates a validator class for every Entity instance.
   */
  public void generateWrapper(final Entity it, final Application app, final IFileSystemAccess fsa) {
    String _name = it.getName();
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(_name);
    String _plus = ("Generating validator classes for entity \"" + _formatForDisplay);
    String _plus_1 = (_plus + "\"");
    InputOutput.<String>println(_plus_1);
    String _appSourceLibPath = this._namingExtensions.getAppSourceLibPath(app);
    final String validatorPath = (_appSourceLibPath + "Entity/Validator/");
    String _xifexpression = null;
    boolean _targets = this._utils.targets(app, "1.3.5");
    if (_targets) {
      _xifexpression = "";
    } else {
      _xifexpression = "Validator";
    }
    final String validatorSuffix = _xifexpression;
    String _name_1 = it.getName();
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(_name_1);
    String _plus_2 = (_formatForCodeCapital + validatorSuffix);
    final String validatorFileName = (_plus_2 + ".php");
    boolean _isInheriting = this._modelInheritanceExtensions.isInheriting(it);
    boolean _not = (!_isInheriting);
    if (_not) {
      String _plus_3 = (validatorPath + "Base/");
      String _plus_4 = (_plus_3 + validatorFileName);
      CharSequence _validatorBaseFile = this.validatorBaseFile(it, app);
      fsa.generateFile(_plus_4, _validatorBaseFile);
    }
    String _plus_5 = (validatorPath + validatorFileName);
    CharSequence _validatorFile = this.validatorFile(it, app);
    fsa.generateFile(_plus_5, _validatorFile);
  }
  
  private CharSequence validatorBaseFile(final Entity it, final Application app) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _phpFileHeader = this.fh.phpFileHeader(app);
    _builder.append(_phpFileHeader, "");
    _builder.newLineIfNotEmpty();
    CharSequence _validatorBaseImpl = this.validatorBaseImpl(it, app);
    _builder.append(_validatorBaseImpl, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence validatorFile(final Entity it, final Application app) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _phpFileHeader = this.fh.phpFileHeader(app);
    _builder.append(_phpFileHeader, "");
    _builder.newLineIfNotEmpty();
    CharSequence _validatorImpl = this.validatorImpl(it, app);
    _builder.append(_validatorImpl, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence validatorBaseImpl(final Entity it, final Application app) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _targets = this._utils.targets(app, "1.3.5");
      boolean _not = (!_targets);
      if (_not) {
        _builder.append("namespace ");
        String _appNamespace = this._utils.appNamespace(app);
        _builder.append(_appNamespace, "");
        _builder.append("\\Entity\\Validator\\Base;");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        _builder.append("use ");
        String _appNamespace_1 = this._utils.appNamespace(app);
        _builder.append(_appNamespace_1, "");
        _builder.append("\\AbstractValidator as BaseAbstractValidator;");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        _builder.append("use ServiceUtil;");
        _builder.newLine();
        _builder.append("use ZLanguage;");
        _builder.newLine();
        _builder.newLine();
      }
    }
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Validator class for encapsulating entity validation methods.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* This is the base validation class for ");
    String _name = it.getName();
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(_name);
    _builder.append(_formatForDisplay, " ");
    _builder.append(" entities.");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    {
      boolean _targets_1 = this._utils.targets(app, "1.3.5");
      if (_targets_1) {
        _builder.append("class ");
        String _appName = this._utils.appName(app);
        _builder.append(_appName, "");
        _builder.append("_Entity_Validator_Base_");
        String _name_1 = it.getName();
        String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(_name_1);
        _builder.append(_formatForCodeCapital, "");
        _builder.append(" extends ");
        String _appName_1 = this._utils.appName(app);
        _builder.append(_appName_1, "");
        _builder.append("_Validator");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("class ");
        String _name_2 = it.getName();
        String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(_name_2);
        _builder.append(_formatForCodeCapital_1, "");
        _builder.append("Validator extends BaseAbstractValidator");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    CharSequence _validatorBaseImplBody = this.validatorBaseImplBody(it, app, Boolean.valueOf(false));
    _builder.append(_validatorBaseImplBody, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence validatorImpl(final Entity it, final Application app) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _targets = this._utils.targets(app, "1.3.5");
      boolean _not = (!_targets);
      if (_not) {
        _builder.append("namespace ");
        String _appNamespace = this._utils.appNamespace(app);
        _builder.append(_appNamespace, "");
        _builder.append("\\Entity\\Validator;");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        {
          boolean _isInheriting = this._modelInheritanceExtensions.isInheriting(it);
          if (_isInheriting) {
            _builder.append("use ");
            String _appNamespace_1 = this._utils.appNamespace(app);
            _builder.append(_appNamespace_1, "");
            _builder.append("\\Entity\\Validator\\");
            Entity _parentType = this._modelInheritanceExtensions.parentType(it);
            String _name = _parentType.getName();
            String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(_name);
            _builder.append(_formatForCodeCapital, "");
            _builder.append("Validator as Base");
            Entity _parentType_1 = this._modelInheritanceExtensions.parentType(it);
            String _name_1 = _parentType_1.getName();
            String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(_name_1);
            _builder.append(_formatForCodeCapital_1, "");
            _builder.append("Validator;");
            _builder.newLineIfNotEmpty();
          } else {
            _builder.append("use ");
            String _appNamespace_2 = this._utils.appNamespace(app);
            _builder.append(_appNamespace_2, "");
            _builder.append("\\Entity\\Validator\\Base\\");
            String _name_2 = it.getName();
            String _formatForCodeCapital_2 = this._formattingExtensions.formatForCodeCapital(_name_2);
            _builder.append(_formatForCodeCapital_2, "");
            _builder.append("Validator as Base");
            String _name_3 = it.getName();
            String _formatForCodeCapital_3 = this._formattingExtensions.formatForCodeCapital(_name_3);
            _builder.append(_formatForCodeCapital_3, "");
            _builder.append("Validator;");
            _builder.newLineIfNotEmpty();
          }
        }
        {
          boolean _isInheriting_1 = this._modelInheritanceExtensions.isInheriting(it);
          if (_isInheriting_1) {
            _builder.newLine();
            _builder.append("use ServiceUtil;");
            _builder.newLine();
            _builder.append("use ZLanguage;");
            _builder.newLine();
          }
        }
        _builder.newLine();
      }
    }
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Validator class for encapsulating entity validation methods.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* This is the concrete validation class for ");
    String _name_4 = it.getName();
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(_name_4);
    _builder.append(_formatForDisplay, " ");
    _builder.append(" entities.");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    {
      boolean _targets_1 = this._utils.targets(app, "1.3.5");
      if (_targets_1) {
        _builder.append("class ");
        String _appName = this._utils.appName(app);
        _builder.append(_appName, "");
        _builder.append("_Entity_Validator_");
        String _name_5 = it.getName();
        String _formatForCodeCapital_4 = this._formattingExtensions.formatForCodeCapital(_name_5);
        _builder.append(_formatForCodeCapital_4, "");
        _builder.append(" extends ");
        {
          boolean _isInheriting_2 = this._modelInheritanceExtensions.isInheriting(it);
          if (_isInheriting_2) {
            String _appName_1 = this._utils.appName(app);
            _builder.append(_appName_1, "");
            _builder.append("_Entity_Validator_");
            Entity _parentType_2 = this._modelInheritanceExtensions.parentType(it);
            String _name_6 = _parentType_2.getName();
            String _formatForCodeCapital_5 = this._formattingExtensions.formatForCodeCapital(_name_6);
            _builder.append(_formatForCodeCapital_5, "");
          } else {
            String _appName_2 = this._utils.appName(app);
            _builder.append(_appName_2, "");
            _builder.append("_Entity_Validator_Base_");
            String _name_7 = it.getName();
            String _formatForCodeCapital_6 = this._formattingExtensions.formatForCodeCapital(_name_7);
            _builder.append(_formatForCodeCapital_6, "");
          }
        }
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("class ");
        String _name_8 = it.getName();
        String _formatForCodeCapital_7 = this._formattingExtensions.formatForCodeCapital(_name_8);
        _builder.append(_formatForCodeCapital_7, "");
        _builder.append("Validator extends Base");
        {
          boolean _isInheriting_3 = this._modelInheritanceExtensions.isInheriting(it);
          if (_isInheriting_3) {
            Entity _parentType_3 = this._modelInheritanceExtensions.parentType(it);
            String _name_9 = _parentType_3.getName();
            String _formatForCodeCapital_8 = this._formattingExtensions.formatForCodeCapital(_name_9);
            _builder.append(_formatForCodeCapital_8, "");
          } else {
            String _name_10 = it.getName();
            String _formatForCodeCapital_9 = this._formattingExtensions.formatForCodeCapital(_name_10);
            _builder.append(_formatForCodeCapital_9, "");
          }
        }
        _builder.append("Validator");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// here you can add custom validation methods or override existing checks");
    _builder.newLine();
    {
      boolean _isInheriting_4 = this._modelInheritanceExtensions.isInheriting(it);
      if (_isInheriting_4) {
        CharSequence _validatorBaseImplBody = this.validatorBaseImplBody(it, app, Boolean.valueOf(true));
        _builder.append(_validatorBaseImplBody, "");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence validatorBaseImplBody(final Entity it, final Application app, final Boolean isInheriting) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Performs all validation rules.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return mixed either array with error information or true on success");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function validateAll()");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$errorInfo = array(\'message\' => \'\', \'code\' => 0, \'debugArray\' => array());");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$dom = ZLanguage::getModuleDomain(\'");
    String _appName = this._utils.appName(app);
    _builder.append(_appName, "    ");
    _builder.append("\');");
    _builder.newLineIfNotEmpty();
    {
      if ((isInheriting).booleanValue()) {
        _builder.append("    ");
        _builder.append("parent::validateAll();");
        _builder.newLine();
      }
    }
    {
      Iterable<DerivedField> _derivedFields = this._modelExtensions.getDerivedFields(it);
      for(final DerivedField df : _derivedFields) {
        _builder.append("    ");
        CharSequence _validationCalls = this.validationCalls(df);
        _builder.append(_validationCalls, "    ");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("    ");
    CharSequence _validationCallDateRange = this.validationCallDateRange(it);
    _builder.append(_validationCallDateRange, "    ");
    _builder.newLineIfNotEmpty();
    {
      Iterable<DerivedField> _uniqueDerivedFields = this._modelExtensions.getUniqueDerivedFields(it);
      final Function1<DerivedField,Boolean> _function = new Function1<DerivedField,Boolean>() {
        public Boolean apply(final DerivedField it) {
          boolean _isPrimaryKey = it.isPrimaryKey();
          boolean _not = (!_isPrimaryKey);
          return Boolean.valueOf(_not);
        }
      };
      Iterable<DerivedField> _filter = IterableExtensions.<DerivedField>filter(_uniqueDerivedFields, _function);
      for(final DerivedField udf : _filter) {
        _builder.append("    ");
        CharSequence _validationCallUnique = this.validationCallUnique(udf);
        _builder.append(_validationCallUnique, "    ");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return true;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    CharSequence _checkForUniqueValues = this.checkForUniqueValues(it, app);
    _builder.append(_checkForUniqueValues, "");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    CharSequence _terAndSetterMethods = this.fh.getterAndSetterMethods(app, "entity", "Zikula_EntityAccess", Boolean.valueOf(false), Boolean.valueOf(true), "null", "");
    _builder.append(_terAndSetterMethods, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence checkForUniqueValues(final Entity it, final Application app) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Check for unique values.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* This method determines if there already exist ");
    String _nameMultiple = it.getNameMultiple();
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(_nameMultiple);
    _builder.append(_formatForDisplay, " ");
    _builder.append(" with the same ");
    String _name = it.getName();
    String _formatForDisplay_1 = this._formattingExtensions.formatForDisplay(_name);
    _builder.append(_formatForDisplay_1, " ");
    _builder.append(".");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $fieldName The name of the property to be checked");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return boolean result of this check, true if the given ");
    String _name_1 = it.getName();
    String _formatForDisplay_2 = this._formattingExtensions.formatForDisplay(_name_1);
    _builder.append(_formatForDisplay_2, " ");
    _builder.append(" does not already exist");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function isUniqueValue($fieldName)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($this->entity[$fieldName] == \'\') {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return false;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    {
      boolean _targets = this._utils.targets(app, "1.3.5");
      if (_targets) {
        _builder.append("    ");
        _builder.append("$entityClass = \'");
        String _appName = this._utils.appName(app);
        _builder.append(_appName, "    ");
        _builder.append("_Entity_");
        String _name_2 = it.getName();
        String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(_name_2);
        _builder.append(_formatForCodeCapital, "    ");
        _builder.append("\';");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("    ");
        _builder.append("$entityClass = \'\\\\");
        String _vendor = app.getVendor();
        String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(_vendor);
        _builder.append(_formatForCodeCapital_1, "    ");
        _builder.append("\\\\");
        String _name_3 = app.getName();
        String _formatForCodeCapital_2 = this._formattingExtensions.formatForCodeCapital(_name_3);
        _builder.append(_formatForCodeCapital_2, "    ");
        _builder.append("Module\\\\Entity\\\\");
        String _name_4 = it.getName();
        String _formatForCodeCapital_3 = this._formattingExtensions.formatForCodeCapital(_name_4);
        _builder.append(_formatForCodeCapital_3, "    ");
        _builder.append("Entity\';");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("    ");
    _builder.append("$serviceManager = ServiceUtil::getManager();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$entityManager = $serviceManager->getService(\'doctrine.entitymanager\');");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$repository = $entityManager->getRepository($entityClass);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$excludeid = $this->entity[\'");
    DerivedField _firstPrimaryKey = this._modelExtensions.getFirstPrimaryKey(it);
    String _name_5 = _firstPrimaryKey.getName();
    String _formatForCode = this._formattingExtensions.formatForCode(_name_5);
    _builder.append(_formatForCode, "    ");
    _builder.append("\'];");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $repository->detectUniqueState($fieldName, $this->entity[$fieldName], $excludeid);");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence _validationCalls(final DerivedField it) {
    return null;
  }
  
  private CharSequence validationCallDateRange(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    final AbstractDateField startDateField = this._modelExtensions.getStartDateField(it);
    _builder.newLineIfNotEmpty();
    final AbstractDateField endDateField = this._modelExtensions.getEndDateField(it);
    _builder.newLineIfNotEmpty();
    {
      boolean _and = false;
      boolean _tripleNotEquals = (startDateField != null);
      if (!_tripleNotEquals) {
        _and = false;
      } else {
        boolean _tripleNotEquals_1 = (endDateField != null);
        _and = (_tripleNotEquals && _tripleNotEquals_1);
      }
      if (_and) {
        _builder.append("if ($this->entity[\'");
        String _name = startDateField.getName();
        String _formatForCode = this._formattingExtensions.formatForCode(_name);
        _builder.append(_formatForCode, "");
        _builder.append("\'] > $this->entity[\'");
        String _name_1 = endDateField.getName();
        String _formatForCode_1 = this._formattingExtensions.formatForCode(_name_1);
        _builder.append(_formatForCode_1, "");
        _builder.append("\']) {");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("$errorInfo[\'message\'] = __f(\'Error! The start date (%1$s) must be before the end date (%2$s).\', array(\'");
        String _name_2 = startDateField.getName();
        String _formatForDisplay = this._formattingExtensions.formatForDisplay(_name_2);
        _builder.append(_formatForDisplay, "    ");
        _builder.append("\', \'");
        String _name_3 = endDateField.getName();
        String _formatForDisplay_1 = this._formattingExtensions.formatForDisplay(_name_3);
        _builder.append(_formatForDisplay_1, "    ");
        _builder.append("\'), $dom);");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("return $errorInfo;");
        _builder.newLine();
        _builder.append("}");
        _builder.newLine();
      }
    }
    return _builder;
  }
  
  private CharSequence validationCallUnique(final DerivedField it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("if (!$this->isUniqueValue(\'");
    String _name = it.getName();
    String _formatForCode = this._formattingExtensions.formatForCode(_name);
    _builder.append(_formatForCode, "");
    _builder.append("\')) {");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("$errorInfo[\'message\'] = __f(\'The %1$s %2$s is already assigned. Please choose another %1$s.\', array(\'");
    String _name_1 = it.getName();
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(_name_1);
    _builder.append(_formatForDisplay, "    ");
    _builder.append("\', $this->entity[\'");
    String _name_2 = it.getName();
    String _formatForCode_1 = this._formattingExtensions.formatForCode(_name_2);
    _builder.append(_formatForCode_1, "    ");
    _builder.append("\']), $dom);");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("return $errorInfo;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence _validationCalls(final BooleanField it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("if (!$this->isValidBoolean(\'");
    String _name = it.getName();
    String _formatForCode = this._formattingExtensions.formatForCode(_name);
    _builder.append(_formatForCode, "");
    _builder.append("\')) {");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("$errorInfo[\'message\'] = __f(\'Error! Field value must be a valid boolean (%s).\', array(\'");
    String _name_1 = it.getName();
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(_name_1);
    _builder.append(_formatForDisplay, "    ");
    _builder.append("\'), $dom);");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("return $errorInfo;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  /**
   * replace by switch ?
   */
  private CharSequence validationCallsNumeric(final DerivedField it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("if (!$this->isValidNumber(\'");
    String _name = it.getName();
    String _formatForCode = this._formattingExtensions.formatForCode(_name);
    _builder.append(_formatForCode, "");
    _builder.append("\')) {");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("$errorInfo[\'message\'] = __f(\'Error! Field value must be numeric (%s).\', array(\'");
    String _name_1 = it.getName();
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(_name_1);
    _builder.append(_formatForDisplay, "    ");
    _builder.append("\'), $dom);");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("return $errorInfo;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    {
      boolean _isMandatory = it.isMandatory();
      if (_isMandatory) {
        _builder.append("if (!$this->isNumberNotEmpty(\'");
        String _name_2 = it.getName();
        String _formatForCode_1 = this._formattingExtensions.formatForCode(_name_2);
        _builder.append(_formatForCode_1, "");
        _builder.append("\')) {");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("$errorInfo[\'message\'] = __f(\'Error! Field value must not be 0 (%s).\', array(\'");
        String _name_3 = it.getName();
        String _formatForDisplay_1 = this._formattingExtensions.formatForDisplay(_name_3);
        _builder.append(_formatForDisplay_1, "    ");
        _builder.append("\'), $dom);");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("return $errorInfo;");
        _builder.newLine();
        _builder.append("}");
        _builder.newLine();
      }
    }
    return _builder;
  }
  
  private CharSequence validationCallsInteger(final AbstractIntegerField it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("if (!$this->isValidInteger(\'");
    String _name = it.getName();
    String _formatForCode = this._formattingExtensions.formatForCode(_name);
    _builder.append(_formatForCode, "");
    _builder.append("\')) {");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("$errorInfo[\'message\'] = __f(\'Error! Field value may only contain digits (%s).\', array(\'");
    String _name_1 = it.getName();
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(_name_1);
    _builder.append(_formatForDisplay, "    ");
    _builder.append("\'), $dom);");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("return $errorInfo;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    {
      boolean _and = false;
      boolean _isMandatory = it.isMandatory();
      if (!_isMandatory) {
        _and = false;
      } else {
        boolean _or = false;
        boolean _or_1 = false;
        boolean _isPrimaryKey = it.isPrimaryKey();
        boolean _not = (!_isPrimaryKey);
        if (_not) {
          _or_1 = true;
        } else {
          Entity _entity = it.getEntity();
          boolean _hasCompositeKeys = this._modelExtensions.hasCompositeKeys(_entity);
          _or_1 = (_not || _hasCompositeKeys);
        }
        if (_or_1) {
          _or = true;
        } else {
          Entity _entity_1 = it.getEntity();
          DerivedField _versionField = this._modelExtensions.getVersionField(_entity_1);
          boolean _equals = Objects.equal(_versionField, this);
          _or = (_or_1 || _equals);
        }
        _and = (_isMandatory && _or);
      }
      if (_and) {
        _builder.append("if (!$this->isNumberNotEmpty(\'");
        String _name_2 = it.getName();
        String _formatForCode_1 = this._formattingExtensions.formatForCode(_name_2);
        _builder.append(_formatForCode_1, "");
        _builder.append("\')) {");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("$errorInfo[\'message\'] = __f(\'Error! Field value must not be 0 (%s).\', array(\'");
        String _name_3 = it.getName();
        String _formatForDisplay_1 = this._formattingExtensions.formatForDisplay(_name_3);
        _builder.append(_formatForDisplay_1, "    ");
        _builder.append("\'), $dom);");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("return $errorInfo;");
        _builder.newLine();
        _builder.append("}");
        _builder.newLine();
      }
    }
    return _builder;
  }
  
  private CharSequence _validationCalls(final AbstractIntegerField it) {
    CharSequence _xifexpression = null;
    boolean _and = false;
    Entity _entity = it.getEntity();
    EList<Relationship> _incoming = _entity.getIncoming();
    Iterable<JoinRelationship> _filter = Iterables.<JoinRelationship>filter(_incoming, JoinRelationship.class);
    final Function1<JoinRelationship,Boolean> _function = new Function1<JoinRelationship,Boolean>() {
      public Boolean apply(final JoinRelationship e) {
        String _targetField = e.getTargetField();
        String _name = it.getName();
        boolean _equals = Objects.equal(_targetField, _name);
        return Boolean.valueOf(_equals);
      }
    };
    Iterable<JoinRelationship> _filter_1 = IterableExtensions.<JoinRelationship>filter(_filter, _function);
    boolean _isEmpty = IterableExtensions.isEmpty(_filter_1);
    if (!_isEmpty) {
      _and = false;
    } else {
      Entity _entity_1 = it.getEntity();
      EList<Relationship> _outgoing = _entity_1.getOutgoing();
      Iterable<JoinRelationship> _filter_2 = Iterables.<JoinRelationship>filter(_outgoing, JoinRelationship.class);
      final Function1<JoinRelationship,Boolean> _function_1 = new Function1<JoinRelationship,Boolean>() {
        public Boolean apply(final JoinRelationship e) {
          String _sourceField = e.getSourceField();
          String _name = it.getName();
          boolean _equals = Objects.equal(_sourceField, _name);
          return Boolean.valueOf(_equals);
        }
      };
      Iterable<JoinRelationship> _filter_3 = IterableExtensions.<JoinRelationship>filter(_filter_2, _function_1);
      boolean _isEmpty_1 = IterableExtensions.isEmpty(_filter_3);
      _and = (_isEmpty && _isEmpty_1);
    }
    if (_and) {
      CharSequence _validationCallsInteger = this.validationCallsInteger(it);
      _xifexpression = _validationCallsInteger;
    }
    return _xifexpression;
  }
  
  private CharSequence _validationCalls(final IntegerField it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _and = false;
      Entity _entity = it.getEntity();
      EList<Relationship> _incoming = _entity.getIncoming();
      Iterable<JoinRelationship> _filter = Iterables.<JoinRelationship>filter(_incoming, JoinRelationship.class);
      final Function1<JoinRelationship,Boolean> _function = new Function1<JoinRelationship,Boolean>() {
        public Boolean apply(final JoinRelationship e) {
          String _targetField = e.getTargetField();
          String _name = it.getName();
          boolean _equals = Objects.equal(_targetField, _name);
          return Boolean.valueOf(_equals);
        }
      };
      Iterable<JoinRelationship> _filter_1 = IterableExtensions.<JoinRelationship>filter(_filter, _function);
      boolean _isEmpty = IterableExtensions.isEmpty(_filter_1);
      if (!_isEmpty) {
        _and = false;
      } else {
        Entity _entity_1 = it.getEntity();
        EList<Relationship> _outgoing = _entity_1.getOutgoing();
        Iterable<JoinRelationship> _filter_2 = Iterables.<JoinRelationship>filter(_outgoing, JoinRelationship.class);
        final Function1<JoinRelationship,Boolean> _function_1 = new Function1<JoinRelationship,Boolean>() {
          public Boolean apply(final JoinRelationship e) {
            String _sourceField = e.getSourceField();
            String _name = it.getName();
            boolean _equals = Objects.equal(_sourceField, _name);
            return Boolean.valueOf(_equals);
          }
        };
        Iterable<JoinRelationship> _filter_3 = IterableExtensions.<JoinRelationship>filter(_filter_2, _function_1);
        boolean _isEmpty_1 = IterableExtensions.isEmpty(_filter_3);
        _and = (_isEmpty && _isEmpty_1);
      }
      if (_and) {
        CharSequence _validationCallsInteger = this.validationCallsInteger(it);
        _builder.append(_validationCallsInteger, "");
        _builder.newLineIfNotEmpty();
        {
          BigInteger _minValue = it.getMinValue();
          String _string = _minValue.toString();
          boolean _notEquals = (!Objects.equal(_string, "0"));
          if (_notEquals) {
            _builder.append("if (!$this->isIntegerNotLowerThan(\'");
            String _name = it.getName();
            String _formatForCode = this._formattingExtensions.formatForCode(_name);
            _builder.append(_formatForCode, "");
            _builder.append("\', ");
            BigInteger _minValue_1 = it.getMinValue();
            _builder.append(_minValue_1, "");
            _builder.append(")) {");
            _builder.newLineIfNotEmpty();
            _builder.append("    ");
            _builder.append("$errorInfo[\'message\'] = __f(\'Error! Field value must not be lower than %2$s (%1$s).\', array(\'");
            String _name_1 = it.getName();
            String _formatForDisplay = this._formattingExtensions.formatForDisplay(_name_1);
            _builder.append(_formatForDisplay, "    ");
            _builder.append("\', ");
            BigInteger _minValue_2 = it.getMinValue();
            _builder.append(_minValue_2, "    ");
            _builder.append("), $dom);");
            _builder.newLineIfNotEmpty();
            _builder.append("    ");
            _builder.append("return $errorInfo;");
            _builder.newLine();
            _builder.append("}");
            _builder.newLine();
          }
        }
        {
          BigInteger _maxValue = it.getMaxValue();
          String _string_1 = _maxValue.toString();
          boolean _notEquals_1 = (!Objects.equal(_string_1, "0"));
          if (_notEquals_1) {
            _builder.append("if (!$this->isIntegerNotHigherThan(\'");
            String _name_2 = it.getName();
            String _formatForCode_1 = this._formattingExtensions.formatForCode(_name_2);
            _builder.append(_formatForCode_1, "");
            _builder.append("\', ");
            BigInteger _maxValue_1 = it.getMaxValue();
            _builder.append(_maxValue_1, "");
            _builder.append(")) {");
            _builder.newLineIfNotEmpty();
            _builder.append("    ");
            _builder.append("$errorInfo[\'message\'] = __f(\'Error! Field value must not be higher than %2$s (%1$s).\', array(\'");
            String _name_3 = it.getName();
            String _formatForDisplay_1 = this._formattingExtensions.formatForDisplay(_name_3);
            _builder.append(_formatForDisplay_1, "    ");
            _builder.append("\', ");
            BigInteger _maxValue_2 = it.getMaxValue();
            _builder.append(_maxValue_2, "    ");
            _builder.append("), $dom);");
            _builder.newLineIfNotEmpty();
            _builder.append("    ");
            _builder.append("return $errorInfo;");
            _builder.newLine();
            _builder.append("}");
            _builder.newLine();
          }
        }
        _builder.append("if (!$this->isNumberNotLongerThan(\'");
        String _name_4 = it.getName();
        String _formatForCode_2 = this._formattingExtensions.formatForCode(_name_4);
        _builder.append(_formatForCode_2, "");
        _builder.append("\', ");
        int _length = it.getLength();
        _builder.append(_length, "");
        _builder.append(")) {");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("$errorInfo[\'message\'] = __f(\'Error! Length of field value must not be higher than %2$s (%1$s).\', array(\'");
        String _name_5 = it.getName();
        String _formatForDisplay_2 = this._formattingExtensions.formatForDisplay(_name_5);
        _builder.append(_formatForDisplay_2, "    ");
        _builder.append("\', ");
        int _length_1 = it.getLength();
        _builder.append(_length_1, "    ");
        _builder.append("), $dom);");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("return $errorInfo;");
        _builder.newLine();
        _builder.append("}");
        _builder.newLine();
      }
    }
    return _builder;
  }
  
  private CharSequence _validationCalls(final DecimalField it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _validationCallsNumeric = this.validationCallsNumeric(it);
    _builder.append(_validationCallsNumeric, "");
    _builder.newLineIfNotEmpty();
    _builder.append("if (!$this->isNumberNotLongerThan(\'");
    String _name = it.getName();
    String _formatForCode = this._formattingExtensions.formatForCode(_name);
    _builder.append(_formatForCode, "");
    _builder.append("\', ");
    int _length = it.getLength();
    int _scale = it.getScale();
    int _plus = (_length + _scale);
    _builder.append(_plus, "");
    _builder.append(")) {");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("$errorInfo[\'message\'] = __f(\'Error! Length of field value must not be higher than %2$s (%1$s).\', array(\'");
    String _name_1 = it.getName();
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(_name_1);
    _builder.append(_formatForDisplay, "    ");
    _builder.append("\', ");
    int _length_1 = it.getLength();
    int _scale_1 = it.getScale();
    int _plus_1 = (_length_1 + _scale_1);
    _builder.append(_plus_1, "    ");
    _builder.append("), $dom);");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("return $errorInfo;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence _validationCalls(final UserField it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _validationCallsInteger = this.validationCallsInteger(it);
    _builder.append(_validationCallsInteger, "");
    _builder.newLineIfNotEmpty();
    _builder.append("if (");
    {
      boolean _isMandatory = it.isMandatory();
      boolean _not = (!_isMandatory);
      if (_not) {
        _builder.append("$this->entity[\'");
        String _name = it.getName();
        String _formatForCode = this._formattingExtensions.formatForCode(_name);
        _builder.append(_formatForCode, "");
        _builder.append("\'] > 0 && ");
      }
    }
    _builder.append("!$this->isValidUser(\'");
    String _name_1 = it.getName();
    String _formatForCode_1 = this._formattingExtensions.formatForCode(_name_1);
    _builder.append(_formatForCode_1, "");
    _builder.append("\')) {");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("$errorInfo[\'message\'] = __f(\'Error! Field value must be a valid user id (%s).\', array(\'");
    String _name_2 = it.getName();
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(_name_2);
    _builder.append(_formatForDisplay, "    ");
    _builder.append("\'), $dom);");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("return $errorInfo;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence validationCallsString(final AbstractStringField it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _isMandatory = it.isMandatory();
      if (_isMandatory) {
        _builder.append("if (!$this->isStringNotEmpty(\'");
        String _name = it.getName();
        String _formatForCode = this._formattingExtensions.formatForCode(_name);
        _builder.append(_formatForCode, "");
        _builder.append("\')) {");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("$errorInfo[\'message\'] = __f(\'Error! Field value must not be empty (%s).\', array(\'");
        String _name_1 = it.getName();
        String _formatForDisplay = this._formattingExtensions.formatForDisplay(_name_1);
        _builder.append(_formatForDisplay, "    ");
        _builder.append("\'), $dom);");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("return $errorInfo;");
        _builder.newLine();
        _builder.append("}");
        _builder.newLine();
      }
    }
    {
      boolean _isNospace = it.isNospace();
      if (_isNospace) {
        _builder.append("if (!$this->isStringNotContaining(\'");
        String _name_2 = it.getName();
        String _formatForCode_1 = this._formattingExtensions.formatForCode(_name_2);
        _builder.append(_formatForCode_1, "");
        _builder.append("\', \' \')) {");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("$errorInfo[\'message\'] = __f(\'Error! Field value must not contain space chars (%s).\', array(\'");
        String _name_3 = it.getName();
        String _formatForDisplay_1 = this._formattingExtensions.formatForDisplay(_name_3);
        _builder.append(_formatForDisplay_1, "    ");
        _builder.append("\'), $dom);");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("return $errorInfo;");
        _builder.newLine();
        _builder.append("}");
        _builder.newLine();
      }
    }
    {
      int _minLength = it.getMinLength();
      boolean _greaterThan = (_minLength > 0);
      if (_greaterThan) {
        _builder.append("if (!$this->isStringNotShorterThan(\'");
        String _name_4 = it.getName();
        String _formatForCode_2 = this._formattingExtensions.formatForCode(_name_4);
        _builder.append(_formatForCode_2, "");
        _builder.append("\', ");
        int _minLength_1 = it.getMinLength();
        _builder.append(_minLength_1, "");
        _builder.append(")) {");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("$errorInfo[\'message\'] = __f(\'Error! Length of field value must not be smaller than %2$s (%1$s).\', array(\'");
        String _name_5 = it.getName();
        String _formatForDisplay_2 = this._formattingExtensions.formatForDisplay(_name_5);
        _builder.append(_formatForDisplay_2, "    ");
        _builder.append("\', ");
        int _minLength_2 = it.getMinLength();
        _builder.append(_minLength_2, "    ");
        _builder.append("), $dom);");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("return $errorInfo;");
        _builder.newLine();
        _builder.append("}");
        _builder.newLine();
      }
    }
    {
      boolean _and = false;
      String _regexp = it.getRegexp();
      boolean _tripleNotEquals = (_regexp != null);
      if (!_tripleNotEquals) {
        _and = false;
      } else {
        String _regexp_1 = it.getRegexp();
        boolean _notEquals = (!Objects.equal(_regexp_1, ""));
        _and = (_tripleNotEquals && _notEquals);
      }
      if (_and) {
        _builder.append("if (!$this->isValidRegExp(\'");
        String _name_6 = it.getName();
        String _formatForCode_3 = this._formattingExtensions.formatForCode(_name_6);
        _builder.append(_formatForCode_3, "");
        _builder.append("\', \'");
        String _regexp_2 = it.getRegexp();
        _builder.append(_regexp_2, "");
        _builder.append("\')) {");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("$errorInfo[\'message\'] = __f(\'Error! Field value must conform to regular expression [%2$s] (%1$s).\', array(\'");
        String _name_7 = it.getName();
        String _formatForDisplay_3 = this._formattingExtensions.formatForDisplay(_name_7);
        _builder.append(_formatForDisplay_3, "    ");
        _builder.append("\', \'");
        String _regexp_3 = it.getRegexp();
        _builder.append(_regexp_3, "    ");
        _builder.append("\'), $dom);");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("return $errorInfo;");
        _builder.newLine();
        _builder.append("}");
        _builder.newLine();
      }
    }
    return _builder;
  }
  
  private CharSequence _validationCalls(final AbstractStringField it) {
    StringConcatenation _builder = new StringConcatenation();
    return _builder;
  }
  
  private CharSequence _validationCalls(final StringField it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("if (!$this->isStringNotLongerThan(\'");
    String _name = it.getName();
    String _formatForCode = this._formattingExtensions.formatForCode(_name);
    _builder.append(_formatForCode, "");
    _builder.append("\', ");
    int _length = it.getLength();
    _builder.append(_length, "");
    _builder.append(")) {");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("$errorInfo[\'message\'] = __f(\'Error! Length of field value must not be higher than %2$s (%1$s).\', array(\'");
    String _name_1 = it.getName();
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(_name_1);
    _builder.append(_formatForDisplay, "    ");
    _builder.append("\', ");
    int _length_1 = it.getLength();
    _builder.append(_length_1, "    ");
    _builder.append("), $dom);");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("return $errorInfo;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    CharSequence _validationCallsString = this.validationCallsString(it);
    _builder.append(_validationCallsString, "");
    _builder.newLineIfNotEmpty();
    {
      boolean _isFixed = it.isFixed();
      if (_isFixed) {
        _builder.append("if (!$this->isStringWithFixedLength(\'");
        String _name_2 = it.getName();
        String _formatForCode_1 = this._formattingExtensions.formatForCode(_name_2);
        _builder.append(_formatForCode_1, "");
        _builder.append("\', ");
        int _length_2 = it.getLength();
        _builder.append(_length_2, "");
        _builder.append(")) {");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("$errorInfo[\'message\'] = __f(\'Error! Length of field value must be %2$s (%1$s).\', array(\'");
        String _name_3 = it.getName();
        String _formatForDisplay_1 = this._formattingExtensions.formatForDisplay(_name_3);
        _builder.append(_formatForDisplay_1, "    ");
        _builder.append("\', ");
        int _length_3 = it.getLength();
        _builder.append(_length_3, "    ");
        _builder.append("), $dom);");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("return $errorInfo;");
        _builder.newLine();
        _builder.append("}");
        _builder.newLine();
      }
    }
    {
      boolean _isLanguage = it.isLanguage();
      if (_isLanguage) {
        _builder.append("if (");
        {
          boolean _isMandatory = it.isMandatory();
          boolean _not = (!_isMandatory);
          if (_not) {
            _builder.append("$this->entity[\'");
            String _name_4 = it.getName();
            String _formatForCode_2 = this._formattingExtensions.formatForCode(_name_4);
            _builder.append(_formatForCode_2, "");
            _builder.append("\'] != \'\' && ");
          }
        }
        _builder.append("!$this->isValidLanguage(\'");
        String _name_5 = it.getName();
        String _formatForCode_3 = this._formattingExtensions.formatForCode(_name_5);
        _builder.append(_formatForCode_3, "");
        _builder.append("\', false)) {");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("$errorInfo[\'message\'] = __f(\'Error! Field value must be a valid language code (%s).\', array(\'");
        String _name_6 = it.getName();
        String _formatForDisplay_2 = this._formattingExtensions.formatForDisplay(_name_6);
        _builder.append(_formatForDisplay_2, "    ");
        _builder.append("\'), $dom);");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("return $errorInfo;");
        _builder.newLine();
        _builder.append("}");
        _builder.newLine();
      }
    }
    {
      boolean _isCountry = it.isCountry();
      if (_isCountry) {
        _builder.append("if (");
        {
          boolean _isMandatory_1 = it.isMandatory();
          boolean _not_1 = (!_isMandatory_1);
          if (_not_1) {
            _builder.append("$this->entity[\'");
            String _name_7 = it.getName();
            String _formatForCode_4 = this._formattingExtensions.formatForCode(_name_7);
            _builder.append(_formatForCode_4, "");
            _builder.append("\'] != \'\' && ");
          }
        }
        _builder.append("!$this->isValidCountry(\'");
        String _name_8 = it.getName();
        String _formatForCode_5 = this._formattingExtensions.formatForCode(_name_8);
        _builder.append(_formatForCode_5, "");
        _builder.append("\')) {");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("$errorInfo[\'message\'] = __f(\'Error! Field value must be a valid country code (%s).\', array(\'");
        String _name_9 = it.getName();
        String _formatForDisplay_3 = this._formattingExtensions.formatForDisplay(_name_9);
        _builder.append(_formatForDisplay_3, "    ");
        _builder.append("\'), $dom);");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("return $errorInfo;");
        _builder.newLine();
        _builder.append("}");
        _builder.newLine();
      }
    }
    {
      boolean _isHtmlcolour = it.isHtmlcolour();
      if (_isHtmlcolour) {
        _builder.append("if (");
        {
          boolean _isMandatory_2 = it.isMandatory();
          boolean _not_2 = (!_isMandatory_2);
          if (_not_2) {
            _builder.append("$this->entity[\'");
            String _name_10 = it.getName();
            String _formatForCode_6 = this._formattingExtensions.formatForCode(_name_10);
            _builder.append(_formatForCode_6, "");
            _builder.append("\'] != \'\' && ");
          }
        }
        _builder.append("!$this->isValidHtmlColour(\'");
        String _name_11 = it.getName();
        String _formatForCode_7 = this._formattingExtensions.formatForCode(_name_11);
        _builder.append(_formatForCode_7, "");
        _builder.append("\')) {");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("$errorInfo[\'message\'] = __f(\'Error! Field value must be a valid html colour code [#123 or #123456] (%s).\', array(\'");
        String _name_12 = it.getName();
        String _formatForDisplay_4 = this._formattingExtensions.formatForDisplay(_name_12);
        _builder.append(_formatForDisplay_4, "    ");
        _builder.append("\'), $dom);");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("return $errorInfo;");
        _builder.newLine();
        _builder.append("}");
        _builder.newLine();
      }
    }
    return _builder;
  }
  
  private CharSequence _validationCalls(final TextField it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("if (!$this->isStringNotLongerThan(\'");
    String _name = it.getName();
    String _formatForCode = this._formattingExtensions.formatForCode(_name);
    _builder.append(_formatForCode, "");
    _builder.append("\', ");
    int _length = it.getLength();
    _builder.append(_length, "");
    _builder.append(")) {");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("$errorInfo[\'message\'] = __f(\'Error! Length of field value must not be higher than %2$s (%1$s).\', array(\'");
    String _name_1 = it.getName();
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(_name_1);
    _builder.append(_formatForDisplay, "    ");
    _builder.append("\', ");
    int _length_1 = it.getLength();
    _builder.append(_length_1, "    ");
    _builder.append("), $dom);");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("return $errorInfo;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    CharSequence _validationCallsString = this.validationCallsString(it);
    _builder.append(_validationCallsString, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence _validationCalls(final EmailField it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("if (!$this->isStringNotLongerThan(\'");
    String _name = it.getName();
    String _formatForCode = this._formattingExtensions.formatForCode(_name);
    _builder.append(_formatForCode, "");
    _builder.append("\', ");
    int _length = it.getLength();
    _builder.append(_length, "");
    _builder.append(")) {");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("$errorInfo[\'message\'] = __f(\'Error! Length of field value must not be higher than %2$s (%1$s).\', array(\'");
    String _name_1 = it.getName();
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(_name_1);
    _builder.append(_formatForDisplay, "    ");
    _builder.append("\', ");
    int _length_1 = it.getLength();
    _builder.append(_length_1, "    ");
    _builder.append("), $dom);");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("return $errorInfo;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    CharSequence _validationCallsString = this.validationCallsString(it);
    _builder.append(_validationCallsString, "");
    _builder.newLineIfNotEmpty();
    _builder.append("if (");
    {
      boolean _isMandatory = it.isMandatory();
      boolean _not = (!_isMandatory);
      if (_not) {
        _builder.append("$this->entity[\'");
        String _name_2 = it.getName();
        String _formatForCode_1 = this._formattingExtensions.formatForCode(_name_2);
        _builder.append(_formatForCode_1, "");
        _builder.append("\'] != \'\' && ");
      }
    }
    _builder.append("!$this->isValidEmail(\'");
    String _name_3 = it.getName();
    String _formatForCode_2 = this._formattingExtensions.formatForCode(_name_3);
    _builder.append(_formatForCode_2, "");
    _builder.append("\')) {");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("$errorInfo[\'message\'] = __f(\'Error! Field value must be a valid email address (%s).\', array(\'");
    String _name_4 = it.getName();
    String _formatForDisplay_1 = this._formattingExtensions.formatForDisplay(_name_4);
    _builder.append(_formatForDisplay_1, "    ");
    _builder.append("\'), $dom);");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("return $errorInfo;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence _validationCalls(final UrlField it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("if (!$this->isStringNotLongerThan(\'");
    String _name = it.getName();
    String _formatForCode = this._formattingExtensions.formatForCode(_name);
    _builder.append(_formatForCode, "");
    _builder.append("\', ");
    int _length = it.getLength();
    _builder.append(_length, "");
    _builder.append(")) {");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("$errorInfo[\'message\'] = __f(\'Error! Length of field value must not be higher than %2$s (%1$s).\', array(\'");
    String _name_1 = it.getName();
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(_name_1);
    _builder.append(_formatForDisplay, "    ");
    _builder.append("\', ");
    int _length_1 = it.getLength();
    _builder.append(_length_1, "    ");
    _builder.append("), $dom);");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("return $errorInfo;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    CharSequence _validationCallsString = this.validationCallsString(it);
    _builder.append(_validationCallsString, "");
    _builder.newLineIfNotEmpty();
    _builder.append("if (");
    {
      boolean _isMandatory = it.isMandatory();
      boolean _not = (!_isMandatory);
      if (_not) {
        _builder.append("$this->entity[\'");
        String _name_2 = it.getName();
        String _formatForCode_1 = this._formattingExtensions.formatForCode(_name_2);
        _builder.append(_formatForCode_1, "");
        _builder.append("\'] != \'\' && ");
      }
    }
    _builder.append("!$this->isValidUrl(\'");
    String _name_3 = it.getName();
    String _formatForCode_2 = this._formattingExtensions.formatForCode(_name_3);
    _builder.append(_formatForCode_2, "");
    _builder.append("\')) {");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("$errorInfo[\'message\'] = __f(\'Error! Field value must be a valid url (%s).\', array(\'");
    String _name_4 = it.getName();
    String _formatForDisplay_1 = this._formattingExtensions.formatForDisplay(_name_4);
    _builder.append(_formatForDisplay_1, "    ");
    _builder.append("\'), $dom);");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("return $errorInfo;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence _validationCalls(final UploadField it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("if (!$this->isStringNotLongerThan(\'");
    String _name = it.getName();
    String _formatForCode = this._formattingExtensions.formatForCode(_name);
    _builder.append(_formatForCode, "");
    _builder.append("\', ");
    int _length = it.getLength();
    _builder.append(_length, "");
    _builder.append(")) {");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("$errorInfo[\'message\'] = __f(\'Error! Length of field value must not be higher than %2$s (%1$s).\', array(\'");
    String _name_1 = it.getName();
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(_name_1);
    _builder.append(_formatForDisplay, "    ");
    _builder.append("\', ");
    int _length_1 = it.getLength();
    _builder.append(_length_1, "    ");
    _builder.append("), $dom);");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("return $errorInfo;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    CharSequence _validationCallsString = this.validationCallsString(it);
    _builder.append(_validationCallsString, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence _validationCalls(final ListField it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _isMandatory = it.isMandatory();
      if (_isMandatory) {
        _builder.append("if (!$this->isStringNotEmpty(\'");
        String _name = it.getName();
        String _formatForCode = this._formattingExtensions.formatForCode(_name);
        _builder.append(_formatForCode, "");
        _builder.append("\')) {");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("$errorInfo[\'message\'] = __f(\'Error! Field value must not be empty (%s).\', array(\'");
        String _name_1 = it.getName();
        String _formatForDisplay = this._formattingExtensions.formatForDisplay(_name_1);
        _builder.append(_formatForDisplay, "    ");
        _builder.append("\'), $dom);");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("return $errorInfo;");
        _builder.newLine();
        _builder.append("}");
        _builder.newLine();
      }
    }
    return _builder;
  }
  
  private CharSequence _validationCalls(final ArrayField it) {
    return null;
  }
  
  private CharSequence _validationCalls(final ObjectField it) {
    return null;
  }
  
  private CharSequence validationCallsDateTime(final AbstractDateField it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _isMandatory = it.isMandatory();
      if (_isMandatory) {
        _builder.append("if (!$this->isValidDateTime(\'");
        String _name = it.getName();
        String _formatForCode = this._formattingExtensions.formatForCode(_name);
        _builder.append(_formatForCode, "");
        _builder.append("\')) {");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("$errorInfo[\'message\'] = __f(\'Error! Field value must be a valid datetime (%s).\', array(\'");
        String _name_1 = it.getName();
        String _formatForDisplay = this._formattingExtensions.formatForDisplay(_name_1);
        _builder.append(_formatForDisplay, "    ");
        _builder.append("\'), $dom);");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("return $errorInfo;");
        _builder.newLine();
        _builder.append("}");
        _builder.newLine();
      }
    }
    return _builder;
  }
  
  private CharSequence _validationCalls(final AbstractDateField it) {
    CharSequence _validationCallsDateTime = this.validationCallsDateTime(it);
    return _validationCallsDateTime;
  }
  
  private CharSequence _validationCalls(final DatetimeField it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _validationCallsDateTime = this.validationCallsDateTime(it);
    _builder.append(_validationCallsDateTime, "");
    _builder.newLineIfNotEmpty();
    {
      boolean _isPast = it.isPast();
      if (_isPast) {
        _builder.append("if (!$this->isDateTimeInPast(\'");
        String _name = it.getName();
        String _formatForCode = this._formattingExtensions.formatForCode(_name);
        _builder.append(_formatForCode, "");
        _builder.append("\', ");
        boolean _isMandatory = it.isMandatory();
        String _displayBool = this._formattingExtensions.displayBool(Boolean.valueOf(_isMandatory));
        _builder.append(_displayBool, "");
        _builder.append(")) {");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("$errorInfo[\'message\'] = __f(\'Error! Field value must be a date in the past (%s).\', array(\'");
        String _name_1 = it.getName();
        String _formatForDisplay = this._formattingExtensions.formatForDisplay(_name_1);
        _builder.append(_formatForDisplay, "    ");
        _builder.append("\'), $dom);");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("return $errorInfo;");
        _builder.newLine();
        _builder.append("}");
        _builder.newLine();
      } else {
        boolean _isFuture = it.isFuture();
        if (_isFuture) {
          _builder.append("if (!$this->isDateTimeInFuture(\'");
          String _name_2 = it.getName();
          String _formatForCode_1 = this._formattingExtensions.formatForCode(_name_2);
          _builder.append(_formatForCode_1, "");
          _builder.append("\', ");
          boolean _isMandatory_1 = it.isMandatory();
          String _displayBool_1 = this._formattingExtensions.displayBool(Boolean.valueOf(_isMandatory_1));
          _builder.append(_displayBool_1, "");
          _builder.append(")) {");
          _builder.newLineIfNotEmpty();
          _builder.append("    ");
          _builder.append("$errorInfo[\'message\'] = __f(\'Error! Field value must be a date in the future (%s).\', array(\'");
          String _name_3 = it.getName();
          String _formatForDisplay_1 = this._formattingExtensions.formatForDisplay(_name_3);
          _builder.append(_formatForDisplay_1, "    ");
          _builder.append("\'), $dom);");
          _builder.newLineIfNotEmpty();
          _builder.append("    ");
          _builder.append("return $errorInfo;");
          _builder.newLine();
          _builder.append("}");
          _builder.newLine();
        }
      }
    }
    return _builder;
  }
  
  private CharSequence _validationCalls(final DateField it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _validationCallsDateTime = this.validationCallsDateTime(it);
    _builder.append(_validationCallsDateTime, "");
    _builder.newLineIfNotEmpty();
    {
      boolean _isPast = it.isPast();
      if (_isPast) {
        _builder.append("if (!$this->isDateInPast(\'");
        String _name = it.getName();
        String _formatForCode = this._formattingExtensions.formatForCode(_name);
        _builder.append(_formatForCode, "");
        _builder.append("\', ");
        boolean _isMandatory = it.isMandatory();
        String _displayBool = this._formattingExtensions.displayBool(Boolean.valueOf(_isMandatory));
        _builder.append(_displayBool, "");
        _builder.append(")) {");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("$errorInfo[\'message\'] = __f(\'Error! Field value must be a date in the past (%s).\', array(\'");
        String _name_1 = it.getName();
        String _formatForDisplay = this._formattingExtensions.formatForDisplay(_name_1);
        _builder.append(_formatForDisplay, "    ");
        _builder.append("\'), $dom);");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("return $errorInfo;");
        _builder.newLine();
        _builder.append("}");
        _builder.newLine();
      } else {
        boolean _isFuture = it.isFuture();
        if (_isFuture) {
          _builder.append("if (!$this->isDateInFuture(\'");
          String _name_2 = it.getName();
          String _formatForCode_1 = this._formattingExtensions.formatForCode(_name_2);
          _builder.append(_formatForCode_1, "");
          _builder.append("\', ");
          boolean _isMandatory_1 = it.isMandatory();
          String _displayBool_1 = this._formattingExtensions.displayBool(Boolean.valueOf(_isMandatory_1));
          _builder.append(_displayBool_1, "");
          _builder.append(")) {");
          _builder.newLineIfNotEmpty();
          _builder.append("    ");
          _builder.append("$errorInfo[\'message\'] = __f(\'Error! Field value must be a date in the future (%s).\', array(\'");
          String _name_3 = it.getName();
          String _formatForDisplay_1 = this._formattingExtensions.formatForDisplay(_name_3);
          _builder.append(_formatForDisplay_1, "    ");
          _builder.append("\'), $dom);");
          _builder.newLineIfNotEmpty();
          _builder.append("    ");
          _builder.append("return $errorInfo;");
          _builder.newLine();
          _builder.append("}");
          _builder.newLine();
        }
      }
    }
    return _builder;
  }
  
  private CharSequence _validationCalls(final TimeField it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _validationCallsDateTime = this.validationCallsDateTime(it);
    _builder.append(_validationCallsDateTime, "");
    _builder.newLineIfNotEmpty();
    {
      boolean _isPast = it.isPast();
      if (_isPast) {
        _builder.append("if (!$this->isTimeInPast(\'");
        String _name = it.getName();
        String _formatForCode = this._formattingExtensions.formatForCode(_name);
        _builder.append(_formatForCode, "");
        _builder.append("\', ");
        boolean _isMandatory = it.isMandatory();
        String _displayBool = this._formattingExtensions.displayBool(Boolean.valueOf(_isMandatory));
        _builder.append(_displayBool, "");
        _builder.append(")) {");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("$errorInfo[\'message\'] = __f(\'Error! Field value must be a time in the past (%s).\', array(\'");
        String _name_1 = it.getName();
        String _formatForDisplay = this._formattingExtensions.formatForDisplay(_name_1);
        _builder.append(_formatForDisplay, "    ");
        _builder.append("\'), $dom);");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("return $errorInfo;");
        _builder.newLine();
        _builder.append("}");
        _builder.newLine();
      } else {
        boolean _isFuture = it.isFuture();
        if (_isFuture) {
          _builder.append("if (!$this->isTimeInFuture(\'");
          String _name_2 = it.getName();
          String _formatForCode_1 = this._formattingExtensions.formatForCode(_name_2);
          _builder.append(_formatForCode_1, "");
          _builder.append("\', ");
          boolean _isMandatory_1 = it.isMandatory();
          String _displayBool_1 = this._formattingExtensions.displayBool(Boolean.valueOf(_isMandatory_1));
          _builder.append(_displayBool_1, "");
          _builder.append(")) {");
          _builder.newLineIfNotEmpty();
          _builder.append("    ");
          _builder.append("$errorInfo[\'message\'] = __f(\'Error! Field value must be a time in the future (%s).\', array(\'");
          String _name_3 = it.getName();
          String _formatForDisplay_1 = this._formattingExtensions.formatForDisplay(_name_3);
          _builder.append(_formatForDisplay_1, "    ");
          _builder.append("\'), $dom);");
          _builder.newLineIfNotEmpty();
          _builder.append("    ");
          _builder.append("return $errorInfo;");
          _builder.newLine();
          _builder.append("}");
          _builder.newLine();
        }
      }
    }
    return _builder;
  }
  
  private CharSequence _validationCalls(final FloatField it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _validationCallsNumeric = this.validationCallsNumeric(it);
    _builder.append(_validationCallsNumeric, "");
    _builder.newLineIfNotEmpty();
    _builder.append("if (!$this->isNumberNotLongerThan(\'");
    String _name = it.getName();
    String _formatForCode = this._formattingExtensions.formatForCode(_name);
    _builder.append(_formatForCode, "");
    _builder.append("\', ");
    int _length = it.getLength();
    _builder.append(_length, "");
    _builder.append(")) {");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("$errorInfo[\'message\'] = __f(\'Error! Length of field value must not be higher than %2$s (%1$s).\', array(\'");
    String _name_1 = it.getName();
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(_name_1);
    _builder.append(_formatForDisplay, "    ");
    _builder.append("\', ");
    int _length_1 = it.getLength();
    _builder.append(_length_1, "    ");
    _builder.append("), $dom);");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("return $errorInfo;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence validationCalls(final DerivedField it) {
    if (it instanceof EmailField) {
      return _validationCalls((EmailField)it);
    } else if (it instanceof IntegerField) {
      return _validationCalls((IntegerField)it);
    } else if (it instanceof ListField) {
      return _validationCalls((ListField)it);
    } else if (it instanceof StringField) {
      return _validationCalls((StringField)it);
    } else if (it instanceof TextField) {
      return _validationCalls((TextField)it);
    } else if (it instanceof UploadField) {
      return _validationCalls((UploadField)it);
    } else if (it instanceof UrlField) {
      return _validationCalls((UrlField)it);
    } else if (it instanceof UserField) {
      return _validationCalls((UserField)it);
    } else if (it instanceof AbstractIntegerField) {
      return _validationCalls((AbstractIntegerField)it);
    } else if (it instanceof AbstractStringField) {
      return _validationCalls((AbstractStringField)it);
    } else if (it instanceof ArrayField) {
      return _validationCalls((ArrayField)it);
    } else if (it instanceof DateField) {
      return _validationCalls((DateField)it);
    } else if (it instanceof DatetimeField) {
      return _validationCalls((DatetimeField)it);
    } else if (it instanceof DecimalField) {
      return _validationCalls((DecimalField)it);
    } else if (it instanceof FloatField) {
      return _validationCalls((FloatField)it);
    } else if (it instanceof TimeField) {
      return _validationCalls((TimeField)it);
    } else if (it instanceof AbstractDateField) {
      return _validationCalls((AbstractDateField)it);
    } else if (it instanceof BooleanField) {
      return _validationCalls((BooleanField)it);
    } else if (it instanceof ObjectField) {
      return _validationCalls((ObjectField)it);
    } else if (it != null) {
      return _validationCalls(it);
    } else {
      throw new IllegalArgumentException("Unhandled parameter types: " +
        Arrays.<Object>asList(it).toString());
    }
  }
}

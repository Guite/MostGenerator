package org.zikula.modulestudio.generator.cartridges.zclassic.controller.util;

import com.google.inject.Inject;
import de.guite.modulestudio.metamodel.modulestudio.Application;
import de.guite.modulestudio.metamodel.modulestudio.Entity;
import de.guite.modulestudio.metamodel.modulestudio.UploadField;
import org.eclipse.emf.common.util.EList;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.eclipse.xtext.xbase.lib.InputOutput;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class ControllerUtil {
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
  private ModelBehaviourExtensions _modelBehaviourExtensions = new Function0<ModelBehaviourExtensions>() {
    public ModelBehaviourExtensions apply() {
      ModelBehaviourExtensions _modelBehaviourExtensions = new ModelBehaviourExtensions();
      return _modelBehaviourExtensions;
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
   * Entry point for the utility class creation.
   */
  public void generate(final Application it, final IFileSystemAccess fsa) {
    InputOutput.<String>println("Generating utility class for controller layer");
    String _appSourceLibPath = this._namingExtensions.getAppSourceLibPath(it);
    final String utilPath = (_appSourceLibPath + "Util/");
    String _xifexpression = null;
    boolean _targets = this._utils.targets(it, "1.3.5");
    if (_targets) {
      _xifexpression = "";
    } else {
      _xifexpression = "Util";
    }
    final String utilSuffix = _xifexpression;
    String _plus = (utilPath + "Base/Controller");
    String _plus_1 = (_plus + utilSuffix);
    String _plus_2 = (_plus_1 + ".php");
    CharSequence _controllerFunctionsBaseFile = this.controllerFunctionsBaseFile(it);
    fsa.generateFile(_plus_2, _controllerFunctionsBaseFile);
    String _plus_3 = (utilPath + "Controller");
    String _plus_4 = (_plus_3 + utilSuffix);
    String _plus_5 = (_plus_4 + ".php");
    CharSequence _controllerFunctionsFile = this.controllerFunctionsFile(it);
    fsa.generateFile(_plus_5, _controllerFunctionsFile);
  }
  
  private CharSequence controllerFunctionsBaseFile(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _phpFileHeader = this.fh.phpFileHeader(it);
    _builder.append(_phpFileHeader, "");
    _builder.newLineIfNotEmpty();
    CharSequence _controllerFunctionsBaseImpl = this.controllerFunctionsBaseImpl(it);
    _builder.append(_controllerFunctionsBaseImpl, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence controllerFunctionsFile(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _phpFileHeader = this.fh.phpFileHeader(it);
    _builder.append(_phpFileHeader, "");
    _builder.newLineIfNotEmpty();
    CharSequence _controllerFunctionsImpl = this.controllerFunctionsImpl(it);
    _builder.append(_controllerFunctionsImpl, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence controllerFunctionsBaseImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _targets = this._utils.targets(it, "1.3.5");
      boolean _not = (!_targets);
      if (_not) {
        _builder.append("namespace ");
        String _appName = this._utils.appName(it);
        _builder.append(_appName, "");
        _builder.append("\\Util\\Base;");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        _builder.append("use DataUtil;");
        _builder.newLine();
        {
          boolean _hasUploads = this._modelExtensions.hasUploads(it);
          if (_hasUploads) {
            _builder.append("use FileUtil;");
            _builder.newLine();
            _builder.append("use LogUtil;");
            _builder.newLine();
          }
        }
        _builder.append("use Zikula_AbstractBase;");
        _builder.newLine();
        {
          boolean _hasGeographical = this._modelBehaviourExtensions.hasGeographical(it);
          if (_hasGeographical) {
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
    _builder.append("* Utility base class for controller helper methods.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("class ");
    {
      boolean _targets_1 = this._utils.targets(it, "1.3.5");
      if (_targets_1) {
        String _appName_1 = this._utils.appName(it);
        _builder.append(_appName_1, "");
        _builder.append("_Util_Base_Controller");
      } else {
        _builder.append("ControllerUtil");
      }
    }
    _builder.append(" extends Zikula_AbstractBase");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    CharSequence _objectTypes = this.getObjectTypes(it);
    _builder.append(_objectTypes, "    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    CharSequence _defaultObjectType = this.getDefaultObjectType(it);
    _builder.append(_defaultObjectType, "    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    CharSequence _retrieveIdentifier = this.retrieveIdentifier(it);
    _builder.append(_retrieveIdentifier, "    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    CharSequence _isValidIdentifier = this.isValidIdentifier(it);
    _builder.append(_isValidIdentifier, "    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    CharSequence _formatPermalink = this.formatPermalink(it);
    _builder.append(_formatPermalink, "    ");
    _builder.newLineIfNotEmpty();
    {
      boolean _hasUploads_1 = this._modelExtensions.hasUploads(it);
      if (_hasUploads_1) {
        _builder.newLine();
        _builder.append("    ");
        CharSequence _fileBaseFolder = this.getFileBaseFolder(it);
        _builder.append(_fileBaseFolder, "    ");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        _builder.append("    ");
        CharSequence _checkAndCreateAllUploadFolders = this.checkAndCreateAllUploadFolders(it);
        _builder.append(_checkAndCreateAllUploadFolders, "    ");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        _builder.append("    ");
        CharSequence _checkAndCreateUploadFolder = this.checkAndCreateUploadFolder(it);
        _builder.append(_checkAndCreateUploadFolder, "    ");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      boolean _hasGeographical_1 = this._modelBehaviourExtensions.hasGeographical(it);
      if (_hasGeographical_1) {
        _builder.newLine();
        _builder.append("    ");
        CharSequence _performGeoCoding = this.performGeoCoding(it);
        _builder.append(_performGeoCoding, "    ");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence getObjectTypes(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Returns an array of all allowed object types in ");
    String _appName = this._utils.appName(it);
    _builder.append(_appName, " ");
    _builder.append(".");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $context Usage context (allowed values: controllerAction, api, actionHandler, block, contentType).");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param array  $args    Additional arguments.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return array List of allowed object types.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function getObjectTypes($context = \'\', $args = array())");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!in_array($context, array(\'controllerAction\', \'api\', \'actionHandler\', \'block\', \'contentType\'))) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$context = \'controllerAction\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$allowedObjectTypes = array();");
    _builder.newLine();
    {
      EList<Entity> _allEntities = this._modelExtensions.getAllEntities(it);
      for(final Entity entity : _allEntities) {
        _builder.append("    ");
        _builder.append("$allowedObjectTypes[] = \'");
        String _name = entity.getName();
        String _formatForCode = this._formattingExtensions.formatForCode(_name);
        _builder.append(_formatForCode, "    ");
        _builder.append("\';");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $allowedObjectTypes;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence getDefaultObjectType(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Returns the default object type in ");
    String _appName = this._utils.appName(it);
    _builder.append(_appName, " ");
    _builder.append(".");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $context Usage context (allowed values: controllerAction, api, actionHandler, block, contentType).");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param array  $args    Additional arguments.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return string The name of the default object type.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function getDefaultObjectType($context = \'\', $args = array())");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!in_array($context, array(\'controllerAction\', \'api\', \'actionHandler\', \'block\', \'contentType\'))) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$context = \'controllerAction\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$defaultObjectType = \'");
    Entity _leadingEntity = this._modelExtensions.getLeadingEntity(it);
    String _name = _leadingEntity.getName();
    String _formatForCode = this._formattingExtensions.formatForCode(_name);
    _builder.append(_formatForCode, "    ");
    _builder.append("\';");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $defaultObjectType;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence retrieveIdentifier(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Retrieve identifier parameters for a given object type.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param Zikula_Request_Http $request    Instance of Zikula_Request_Http.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param array               $args       List of arguments used as fallback if request does not contain a field.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string              $objectType Name of treated entity type.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param array               $idFields   List of identifier field names.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return array List of fetched identifiers.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function retrieveIdentifier(Zikula_Request_Http $request, array $args, $objectType = \'\', array $idFields)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$idValues = array();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("foreach ($idFields as $idField) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$defaultValue = isset($args[$idField]) && is_numeric($args[$idField]) ? $args[$idField] : 0;");
    _builder.newLine();
    _builder.append("        ");
    _builder.newLine();
    _builder.append("        ");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$id = $request->query->filter($idField, $defaultValue);");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if (!$id && $idField != \'id\' && count($idFields) == 1) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$defaultValue = isset($args[\'id\']) && is_numeric($args[\'id\']) ? $args[\'id\'] : 0;");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$id = (int) $request->query->filter(\'id\', $defaultValue, FILTER_VALIDATE_INT);");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$idValues[$idField] = $id;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $idValues;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence isValidIdentifier(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Checks if all identifiers are set properly.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param array  $idValues List of identifier field values.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return boolean Whether all identifiers are set or not.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function isValidIdentifier(array $idValues)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!count($idValues)) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return false;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("foreach ($idValues as $idField => $idValue) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if (!$idValue) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("return false;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return true;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence formatPermalink(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Create nice permalinks.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $name The given object title.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return string processed permalink.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @deprecated made obsolete by Doctrine extensions.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function formatPermalink($name)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$name = str_replace(array(\'\u00E4\', \'\u00F6\', \'\u00FC\', \'\u00C4\', \'\u00D6\', \'\u00DC\', \'\u00DF\', \'.\', \'?\', \'\"\', \'/\', \':\', \'\u00E9\', \'\u00E8\', \'\u00E2\'),");
    _builder.newLine();
    _builder.append("                        ");
    _builder.append("array(\'ae\', \'oe\', \'ue\', \'Ae\', \'Oe\', \'Ue\', \'ss\', \'\', \'\', \'\', \'-\', \'-\', \'e\', \'e\', \'a\'),");
    _builder.newLine();
    _builder.append("                        ");
    _builder.append("$name);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$name = DataUtil::formatPermalink($name);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return strtolower($name);");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence getFileBaseFolder(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Retrieve the base path for given object type and upload field combination.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string  $objectType   Name of treated entity type.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string  $fieldName    Name of upload field.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param boolean $ignoreCreate Whether to ignore the creation of upload folders on demand or not.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return mixed Output.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @throws Exception if invalid object type is given.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function getFileBaseFolder($objectType, $fieldName, $ignoreCreate = false)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!in_array($objectType, $this->getObjectTypes())) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("throw new Exception(\'Error! Invalid object type received.\');");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$basePath = FileUtil::getDataDirectory() . \'/");
    String _appName = this._utils.appName(it);
    _builder.append(_appName, "    ");
    _builder.append("/\';");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("switch ($objectType) {");
    _builder.newLine();
    {
      Iterable<Entity> _uploadEntities = this._modelExtensions.getUploadEntities(it);
      for(final Entity entity : _uploadEntities) {
        _builder.append("        ");
        final Iterable<UploadField> uploadFields = this._modelExtensions.getUploadFieldsEntity(entity);
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("case \'");
        String _name = entity.getName();
        String _formatForCode = this._formattingExtensions.formatForCode(_name);
        _builder.append(_formatForCode, "        ");
        _builder.append("\':");
        _builder.newLineIfNotEmpty();
        {
          int _size = IterableExtensions.size(uploadFields);
          boolean _greaterThan = (_size > 1);
          if (_greaterThan) {
            _builder.append("        ");
            _builder.append("    ");
            _builder.append("$basePath .= \'");
            String _nameMultiple = entity.getNameMultiple();
            String _formatForDB = this._formattingExtensions.formatForDB(_nameMultiple);
            _builder.append(_formatForDB, "            ");
            _builder.append("/\';");
            _builder.newLineIfNotEmpty();
            _builder.append("        ");
            _builder.append("    ");
            _builder.append("switch ($fieldName) {");
            _builder.newLine();
            {
              for(final UploadField uploadField : uploadFields) {
                _builder.append("        ");
                _builder.append("    ");
                _builder.append("    ");
                _builder.append("case \'");
                String _name_1 = uploadField.getName();
                String _formatForCode_1 = this._formattingExtensions.formatForCode(_name_1);
                _builder.append(_formatForCode_1, "                ");
                _builder.append("\':");
                _builder.newLineIfNotEmpty();
                _builder.append("        ");
                _builder.append("    ");
                _builder.append("    ");
                _builder.append("    ");
                _builder.append("$basePath .= \'");
                String _subFolderPathSegment = this._modelExtensions.subFolderPathSegment(uploadField);
                _builder.append(_subFolderPathSegment, "                    ");
                _builder.append("/\';");
                _builder.newLineIfNotEmpty();
                _builder.append("        ");
                _builder.append("    ");
                _builder.append("    ");
                _builder.append("    ");
                _builder.append("break;");
                _builder.newLine();
              }
            }
            _builder.append("        ");
            _builder.append("    ");
            _builder.append("}");
            _builder.newLine();
          } else {
            _builder.append("        ");
            _builder.append("    ");
            _builder.append("$basePath .= \'");
            String _nameMultiple_1 = entity.getNameMultiple();
            String _formatForDB_1 = this._formattingExtensions.formatForDB(_nameMultiple_1);
            _builder.append(_formatForDB_1, "            ");
            _builder.append("/");
            UploadField _head = IterableExtensions.<UploadField>head(uploadFields);
            String _subFolderPathSegment_1 = this._modelExtensions.subFolderPathSegment(_head);
            _builder.append(_subFolderPathSegment_1, "            ");
            _builder.append("/\';");
            _builder.newLineIfNotEmpty();
          }
        }
        _builder.append("        ");
        _builder.append("break;");
        _builder.newLine();
      }
    }
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$result = DataUtil::formatForOS($basePath);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (substr($result, -1, 1) != \'/\') {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// reappend the removed slash");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$result .= \'/\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!is_dir($result) && !$ignoreCreate) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$this->checkAndCreateAllUploadFolders();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $result;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence checkAndCreateAllUploadFolders(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Creates all required upload folders for this application.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return Boolean whether everything went okay or not.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function checkAndCreateAllUploadFolders()");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$result = true;");
    _builder.newLine();
    {
      Iterable<Entity> _uploadEntities = this._modelExtensions.getUploadEntities(it);
      for(final Entity uploadEntity : _uploadEntities) {
        _builder.newLine();
        {
          Iterable<UploadField> _uploadFieldsEntity = this._modelExtensions.getUploadFieldsEntity(uploadEntity);
          for(final UploadField uploadField : _uploadFieldsEntity) {
            _builder.append("    ");
            _builder.append("$result &= $this->checkAndCreateUploadFolder(\'");
            Entity _entity = uploadField.getEntity();
            String _name = _entity.getName();
            String _formatForCode = this._formattingExtensions.formatForCode(_name);
            _builder.append(_formatForCode, "    ");
            _builder.append("\', \'");
            String _name_1 = uploadField.getName();
            String _formatForCode_1 = this._formattingExtensions.formatForCode(_name_1);
            _builder.append(_formatForCode_1, "    ");
            _builder.append("\', \'");
            String _allowedExtensions = uploadField.getAllowedExtensions();
            _builder.append(_allowedExtensions, "    ");
            _builder.append("\');");
            _builder.newLineIfNotEmpty();
          }
        }
      }
    }
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $result;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence checkAndCreateUploadFolder(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Creates upload folder including a subfolder for thumbnail and an .htaccess file within it.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $objectType        Name of treated entity type.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $fieldName         Name of upload field.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $allowedExtensions String with list of allowed file extensions (separated by \", \").");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return Boolean whether everything went okay or not.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected function checkAndCreateUploadFolder($objectType, $fieldName, $allowedExtensions = \'\')");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$uploadPath = $this->getFileBaseFolder($objectType, $fieldName, true);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// Check if directory exist and try to create it if needed");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!is_dir($uploadPath) && !FileUtil::mkdirs($uploadPath, 0777)) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("LogUtil::registerStatus($this->__f(\'The upload directory \"%s\" does not exist and could not be created. Try to create it yourself and make sure that this folder is accessible via the web and writable by the webserver.\', array($uploadPath)));");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return false;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// Check if directory is writable and change permissions if needed");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!is_writable($uploadPath) && !chmod($uploadPath, 0777)) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("LogUtil::registerStatus($this->__f(\'Warning! The upload directory at \"%s\" exists but is not writable by the webserver.\', array($uploadPath)));");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return false;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// Write a htaccess file into the upload directory");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$htaccessFilePath = $uploadPath . \'/.htaccess\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$htaccessFileTemplate = \'modules/");
    String _appName = this._utils.appName(it);
    _builder.append(_appName, "    ");
    _builder.append("/");
    {
      boolean _targets = this._utils.targets(it, "1.3.5");
      if (_targets) {
        _builder.append("docs/");
      } else {
        String _appDocPath = this._namingExtensions.getAppDocPath(it);
        _builder.append(_appDocPath, "    ");
      }
    }
    _builder.append("htaccessTemplate\';");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("if (!file_exists($htaccessFilePath) && file_exists($htaccessFileTemplate)) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$extensions = str_replace(\',\', \'|\', str_replace(\' \', \'\', $allowedExtensions));");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$htaccessContent = str_replace(\'__EXTENSIONS__\', $extensions, FileUtil::readFile($htaccessFileTemplate));");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if (!FileUtil::writeFile($htaccessFilePath, $htaccessContent)) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("LogUtil::registerStatus($this->__f(\'Warning! Could not write the .htaccess file at \"%s\".\', array($htaccessFilePath)));");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("return false;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return true;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence performGeoCoding(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Example method for performing geo coding in PHP.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* To use this please customise it to your needs in the concrete subclass.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Also you have to call this method in a PrePersist-Handler of the");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* corresponding entity class.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* There is also a method on JS level available in ");
    String _appJsPath = this._namingExtensions.getAppJsPath(it);
    _builder.append(_appJsPath, " ");
    String _appName = this._utils.appName(it);
    _builder.append(_appName, " ");
    _builder.append("_editFunctions.js.");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $address The address input string.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return Array The determined coordinates.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function performGeoCoding($address)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$lang = ZLanguage::getLanguageCode();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$url = \'http://maps.google.com/maps/api/geocode/xml?address=\' . urlencode($address);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$url .= \'&region=\' . $lang . \'&language=\' . $lang . \'&sensor=false\';");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// we can either use Snoopy if available");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("//require_once(\'modules/");
    String _appName_1 = this._utils.appName(it);
    _builder.append(_appName_1, "    ");
    _builder.append("/");
    {
      boolean _targets = this._utils.targets(it, "1.3.5");
      if (_targets) {
        _builder.append("lib/");
      }
    }
    _builder.append("vendor/Snoopy/Snoopy.class.php\');");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("//$snoopy = new Snoopy();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("//$snoopy->fetch($url);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("//$xmlContent = $snoopy->results;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// we can also use curl");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// example do be done");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// or we can use the plain file_get_contents method");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// requires allow_url_fopen = true in php.ini which is NOT good for security");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$xmlContent = file_get_contents($url);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// parse the markup");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$xml = new SimpleXMLElement($xmlContent);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("//$xml = simplexml_load_string($xmlContent, \'SimpleXMLElement\', LIBXML_NOCDATA);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// create the result array");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$result = array(\'latitude\' => 0, \'longitude\' => 0);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$lat = $xml->xpath(\'result/geometry/location/lat\');");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$result[\'latitude\'] = (float)$lat[0];");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$lng = $xml->xpath(\'result/geometry/location/lng\');");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$result[\'longitude\'] = (float)$lng[0];");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $result;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence controllerFunctionsImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _targets = this._utils.targets(it, "1.3.5");
      boolean _not = (!_targets);
      if (_not) {
        _builder.append("namespace ");
        String _appName = this._utils.appName(it);
        _builder.append(_appName, "");
        _builder.append("\\Util;");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
      }
    }
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Utility implementation class for controller helper methods.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    {
      boolean _targets_1 = this._utils.targets(it, "1.3.5");
      if (_targets_1) {
        _builder.append("class ");
        String _appName_1 = this._utils.appName(it);
        _builder.append(_appName_1, "");
        _builder.append("_Util_Controller extends ");
        String _appName_2 = this._utils.appName(it);
        _builder.append(_appName_2, "");
        _builder.append("_Util_Base_Controller");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("class ControllerUtil extends Base\\ControllerUtil");
        _builder.newLine();
      }
    }
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// feel free to add your own convenience methods here");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
}

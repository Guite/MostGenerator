package org.zikula.modulestudio.generator.cartridges.zclassic.controller;

import com.google.inject.Inject;
import de.guite.modulestudio.metamodel.modulestudio.Application;
import de.guite.modulestudio.metamodel.modulestudio.Entity;
import de.guite.modulestudio.metamodel.modulestudio.Models;
import de.guite.modulestudio.metamodel.modulestudio.UploadField;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class Uploads {
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
  
  private FileHelper fh = new Function0<FileHelper>() {
    public FileHelper apply() {
      FileHelper _fileHelper = new FileHelper();
      return _fileHelper;
    }
  }.apply();
  
  private IFileSystemAccess fsa;
  
  /**
   * Entry point for the upload handler.
   */
  public void generate(final Application it, final IFileSystemAccess fsa) {
    this.fsa = fsa;
    this.createUploadFolders(it);
    String _appSourceLibPath = this._namingExtensions.getAppSourceLibPath(it);
    String _plus = (_appSourceLibPath + "Base/UploadHandler.php");
    CharSequence _uploadHandlerBaseFile = this.uploadHandlerBaseFile(it);
    fsa.generateFile(_plus, _uploadHandlerBaseFile);
    String _appSourceLibPath_1 = this._namingExtensions.getAppSourceLibPath(it);
    String _plus_1 = (_appSourceLibPath_1 + "UploadHandler.php");
    CharSequence _uploadHandlerFile = this.uploadHandlerFile(it);
    fsa.generateFile(_plus_1, _uploadHandlerFile);
  }
  
  private CharSequence uploadHandlerBaseFile(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _phpFileHeader = this.fh.phpFileHeader(it);
    _builder.append(_phpFileHeader, "");
    _builder.newLineIfNotEmpty();
    CharSequence _uploadHandlerBaseImpl = this.uploadHandlerBaseImpl(it);
    _builder.append(_uploadHandlerBaseImpl, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence uploadHandlerFile(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _phpFileHeader = this.fh.phpFileHeader(it);
    _builder.append(_phpFileHeader, "");
    _builder.newLineIfNotEmpty();
    CharSequence _uploadHandlerImpl = this.uploadHandlerImpl(it);
    _builder.append(_uploadHandlerImpl, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private void createUploadFolders(final Application it) {
    String _appUploadPath = this._namingExtensions.getAppUploadPath(it);
    String _plus = (_appUploadPath + "index.html");
    String _msUrl = this._utils.msUrl();
    this.fsa.generateFile(_plus, _msUrl);
    Iterable<Entity> _uploadEntities = this._modelExtensions.getUploadEntities(it);
    for (final Entity entity : _uploadEntities) {
      {
        String _nameMultiple = entity.getNameMultiple();
        String _formatForDB = this._formattingExtensions.formatForDB(_nameMultiple);
        final String subFolderName = (_formatForDB + "/");
        String _appUploadPath_1 = this._namingExtensions.getAppUploadPath(it);
        String _plus_1 = (_appUploadPath_1 + subFolderName);
        String _plus_2 = (_plus_1 + "/index.html");
        String _msUrl_1 = this._utils.msUrl();
        this.fsa.generateFile(_plus_2, _msUrl_1);
        final Iterable<UploadField> uploadFields = this._modelExtensions.getUploadFieldsEntity(entity);
        int _size = IterableExtensions.size(uploadFields);
        boolean _greaterThan = (_size > 1);
        if (_greaterThan) {
          for (final UploadField uploadField : uploadFields) {
            String _subFolderPathSegment = this._modelExtensions.subFolderPathSegment(uploadField);
            String _plus_3 = (subFolderName + _subFolderPathSegment);
            this.uploadFolder(uploadField, _plus_3);
          }
        } else {
          int _size_1 = IterableExtensions.size(uploadFields);
          boolean _greaterThan_1 = (_size_1 > 0);
          if (_greaterThan_1) {
            UploadField _head = IterableExtensions.<UploadField>head(uploadFields);
            UploadField _head_1 = IterableExtensions.<UploadField>head(uploadFields);
            String _subFolderPathSegment_1 = this._modelExtensions.subFolderPathSegment(_head_1);
            String _plus_4 = (subFolderName + _subFolderPathSegment_1);
            this.uploadFolder(_head, _plus_4);
          }
        }
      }
    }
    String _xifexpression = null;
    boolean _targets = this._utils.targets(it, "1.3.5");
    if (_targets) {
      String _appSourcePath = this._namingExtensions.getAppSourcePath(it);
      String _plus_1 = (_appSourcePath + "docs/");
      _xifexpression = _plus_1;
    } else {
      String _appDocPath = this._namingExtensions.getAppDocPath(it);
      _xifexpression = _appDocPath;
    }
    final String docPath = _xifexpression;
    String _plus_2 = (docPath + "htaccessTemplate");
    CharSequence _htAccessTemplate = this.htAccessTemplate(it);
    this.fsa.generateFile(_plus_2, _htAccessTemplate);
  }
  
  private void uploadFolder(final UploadField it, final String folder) {
    Entity _entity = it.getEntity();
    Models _container = _entity.getContainer();
    Application _application = _container.getApplication();
    String _appUploadPath = this._namingExtensions.getAppUploadPath(_application);
    String _plus = (_appUploadPath + folder);
    String _plus_1 = (_plus + "/index.html");
    String _msUrl = this._utils.msUrl();
    this.fsa.generateFile(_plus_1, _msUrl);
    Entity _entity_1 = it.getEntity();
    Models _container_1 = _entity_1.getContainer();
    Application _application_1 = _container_1.getApplication();
    String _appUploadPath_1 = this._namingExtensions.getAppUploadPath(_application_1);
    String _plus_2 = (_appUploadPath_1 + folder);
    String _plus_3 = (_plus_2 + "/.htaccess");
    CharSequence _htAccess = this.htAccess(it);
    this.fsa.generateFile(_plus_3, _htAccess);
  }
  
  private CharSequence htAccess(final UploadField it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("# generated at ");
    String _timestamp = this._utils.timestamp();
    _builder.append(_timestamp, "");
    _builder.append(" by ModuleStudio ");
    String _msVersion = this._utils.msVersion();
    _builder.append(_msVersion, "");
    _builder.append(" (");
    String _msUrl = this._utils.msUrl();
    _builder.append(_msUrl, "");
    _builder.append(")");
    _builder.newLineIfNotEmpty();
    _builder.append("# ----------------------------------------------------------------------");
    _builder.newLine();
    _builder.append("# Purpose of file: give access to upload files treated in this directory");
    _builder.newLine();
    _builder.append("# ----------------------------------------------------------------------");
    _builder.newLine();
    _builder.append("deny from all");
    _builder.newLine();
    _builder.append("<FilesMatch \"\\.(");
    String _allowedExtensions = it.getAllowedExtensions();
    String _replaceAll = _allowedExtensions.replaceAll(", ", "|");
    _builder.append(_replaceAll, "");
    _builder.append(")$\">");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("order allow,deny");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("allow from all");
    _builder.newLine();
    _builder.append("</filesmatch>");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence htAccessTemplate(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("# generated at ");
    String _timestamp = this._utils.timestamp();
    _builder.append(_timestamp, "");
    _builder.append(" by ModuleStudio ");
    String _msVersion = this._utils.msVersion();
    _builder.append(_msVersion, "");
    _builder.append(" (");
    String _msUrl = this._utils.msUrl();
    _builder.append(_msUrl, "");
    _builder.append(")");
    _builder.newLineIfNotEmpty();
    _builder.append("# ----------------------------------------------------------------------");
    _builder.newLine();
    _builder.append("# Purpose of file: give access to upload files treated in this directory");
    _builder.newLine();
    _builder.append("# ----------------------------------------------------------------------");
    _builder.newLine();
    _builder.append("deny from all");
    _builder.newLine();
    _builder.append("<FilesMatch \"\\.(__EXTENSIONS__)$\">");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("order allow,deny");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("allow from all");
    _builder.newLine();
    _builder.append("</filesmatch>");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence uploadHandlerBaseImpl(final Application it) {
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
        _builder.append("use ");
        String _appNamespace_1 = this._utils.appNamespace(it);
        _builder.append(_appNamespace_1, "");
        _builder.append("\\Util\\ControllerUtil;");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        _builder.append("use DataUtil;");
        _builder.newLine();
        _builder.append("use FileUtil;");
        _builder.newLine();
        _builder.append("use LogUtil;");
        _builder.newLine();
        _builder.append("use ModUtil;");
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
    _builder.append("* Upload handler base class.");
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
        _builder.append("_Base_UploadHandler");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("class UploadHandler");
        _builder.newLine();
      }
    }
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @var array List of object types with upload fields.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("protected $allowedObjectTypes;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @var array List of file types to be considered as images.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("protected $imageFileTypes;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @var array List of dangerous file types to be rejected.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("protected $forbiddenFileTypes;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @var array List of allowed file sizes per field.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("protected $allowedFileSizes;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* Constructor initialising the supported object types.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("public function __construct()");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$this->allowedObjectTypes = array(");
    {
      Iterable<Entity> _uploadEntities = this._modelExtensions.getUploadEntities(it);
      boolean _hasElements = false;
      for(final Entity entity : _uploadEntities) {
        if (!_hasElements) {
          _hasElements = true;
        } else {
          _builder.appendImmediate(", ", "        ");
        }
        _builder.append("\'");
        String _name = entity.getName();
        String _formatForCode = this._formattingExtensions.formatForCode(_name);
        _builder.append(_formatForCode, "        ");
        _builder.append("\'");
      }
    }
    _builder.append(");");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("$this->imageFileTypes = array(\'gif\', \'jpeg\', \'jpg\', \'png\', \'swf\');");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$this->forbiddenFileTypes = array(\'cgi\', \'pl\', \'asp\', \'phtml\', \'php\', \'php3\', \'php4\', \'php5\', \'exe\', \'com\', \'bat\', \'jsp\', \'cfm\', \'shtml\');");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$this->allowedFileSizes = array(");
    {
      Iterable<Entity> _uploadEntities_1 = this._modelExtensions.getUploadEntities(it);
      boolean _hasElements_1 = false;
      for(final Entity entity_1 : _uploadEntities_1) {
        if (!_hasElements_1) {
          _hasElements_1 = true;
        } else {
          _builder.appendImmediate(", ", "        ");
        }
        _builder.append("\'");
        String _name_1 = entity_1.getName();
        String _formatForCode_1 = this._formattingExtensions.formatForCode(_name_1);
        _builder.append(_formatForCode_1, "        ");
        _builder.append("\' => array(");
        {
          Iterable<UploadField> _uploadFieldsEntity = this._modelExtensions.getUploadFieldsEntity(entity_1);
          boolean _hasElements_2 = false;
          for(final UploadField field : _uploadFieldsEntity) {
            if (!_hasElements_2) {
              _hasElements_2 = true;
            } else {
              _builder.appendImmediate(", ", "        ");
            }
            _builder.append("\'");
            String _name_2 = field.getName();
            String _formatForCode_2 = this._formattingExtensions.formatForCode(_name_2);
            _builder.append(_formatForCode_2, "        ");
            _builder.append("\' => ");
            int _allowedFileSize = field.getAllowedFileSize();
            _builder.append(_allowedFileSize, "        ");
          }
        }
        _builder.append(")");
      }
    }
    _builder.append(");");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    CharSequence _performFileUpload = this.performFileUpload(it);
    _builder.append(_performFileUpload, "    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    CharSequence _validateFileUpload = this.validateFileUpload(it);
    _builder.append(_validateFileUpload, "    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    CharSequence _readMetaDataForFile = this.readMetaDataForFile(it);
    _builder.append(_readMetaDataForFile, "    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    CharSequence _isAllowedFileExtension = this.isAllowedFileExtension(it);
    _builder.append(_isAllowedFileExtension, "    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    CharSequence _determineFileName = this.determineFileName(it);
    _builder.append(_determineFileName, "    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    CharSequence _handleError = this.handleError(it);
    _builder.append(_handleError, "    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    CharSequence _deleteUploadFile = this.deleteUploadFile(it);
    _builder.append(_deleteUploadFile, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence performFileUpload(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Process a file upload.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $objectType Currently treated entity type.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $fileData   Form data array.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $fieldName  Name of upload field.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return array Resulting file name and collected meta data.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function performFileUpload($objectType, $fileData, $fieldName)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$dom = ZLanguage::getModuleDomain(\'");
    String _appName = this._utils.appName(it);
    _builder.append(_appName, "    ");
    _builder.append("\');");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$result = array(\'fileName\' => \'\',");
    _builder.newLine();
    _builder.append("                    ");
    _builder.append("\'metaData\' => array());");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// check whether uploads are allowed for the given object type");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!in_array($objectType, $this->allowedObjectTypes)) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return $result;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// perform validation");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!$this->validateFileUpload($objectType, $fileData[$fieldName], $fieldName)) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// skip this upload field");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return $result;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// retrieve the final file name");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$fileName = $fileData[$fieldName][\'name\'];");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$fileNameParts = explode(\'.\', $fileName);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$extension = strtolower($fileNameParts[count($fileNameParts) - 1]);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$extension = str_replace(\'jpeg\', \'jpg\', $extension);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$fileNameParts[count($fileNameParts) - 1] = $extension;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$fileName = implode(\'.\', $fileNameParts);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$serviceManager = ServiceUtil::getManager();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$controllerHelper = new ");
    {
      boolean _targets = this._utils.targets(it, "1.3.5");
      if (_targets) {
        String _appName_1 = this._utils.appName(it);
        _builder.append(_appName_1, "    ");
        _builder.append("_Util_Controller");
      } else {
        _builder.append("ControllerUtil");
      }
    }
    _builder.append("($serviceManager");
    {
      boolean _targets_1 = this._utils.targets(it, "1.3.5");
      boolean _not = (!_targets_1);
      if (_not) {
        _builder.append(", ModUtil::getModule(\'");
        String _appName_2 = this._utils.appName(it);
        _builder.append(_appName_2, "    ");
        _builder.append("\')");
      }
    }
    _builder.append(");");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// retrieve the final file name");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("try {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$basePath = $controllerHelper->getFileBaseFolder($objectType, $fieldName);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("} catch (\\Exception $e) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return LogUtil::registerError($e->getMessage());");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$fileName = $this->determineFileName($objectType, $fieldName, $basePath, $fileName, $extension);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!move_uploaded_file($fileData[$fieldName][\'tmp_name\'], $basePath . $fileName)) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return LogUtil::registerError(__(\'Error! Could not move your file to the destination folder.\', $dom));");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// collect data to return");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$result[\'fileName\'] = $fileName;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$result[\'metaData\'] = $this->readMetaDataForFile($fileName, $basePath . $fileName);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $result;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence validateFileUpload(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Check if an upload file meets all validation criteria.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $objectType Currently treated entity type.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param array $file Reference to data of uploaded file.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $fieldName  Name of upload field.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return boolean true if file is valid else false");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected function validateFileUpload($objectType, $file, $fieldName)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$dom = ZLanguage::getModuleDomain(\'");
    String _appName = this._utils.appName(it);
    _builder.append(_appName, "    ");
    _builder.append("\');");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// check if a file has been uploaded properly without errors");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ((!is_array($file)) || (is_array($file) && ($file[\'error\'] != \'0\'))) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if (is_array($file)) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("return $this->handleError($file);");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return LogUtil::registerError(__(\'Error! No file found.\', $dom));");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// extract file extension");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$fileName = $file[\'name\'];");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$fileNameParts = explode(\'.\', $fileName);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$extension = strtolower($fileNameParts[count($fileNameParts) - 1]);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$extension = str_replace(\'jpeg\', \'jpg\', $extension);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// validate extension");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$isValidExtension = $this->isAllowedFileExtension($objectType, $fieldName, $extension);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($isValidExtension === false) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return LogUtil::registerError(__(\'Error! This file type is not allowed. Please choose another file format.\', $dom));");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$maxSize = $this->allowedFileSizes[$objectType][$fieldName];");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($maxSize > 0) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$fileSize = filesize($file[\'tmp_name\']);");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if ($fileSize > $maxSize) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$maxSizeKB = $maxSize / 1024;");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("if ($maxSizeKB < 1024) {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("$maxSizeKB = DataUtil::formatNumber($maxSizeKB); ");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("return LogUtil::registerError(__f(\'Error! Your file is too big. Please keep it smaller than %s kilobytes.\', array($maxSizeKB), $dom));");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$maxSizeMB = $maxSizeKB / 1024;");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$maxSizeMB = DataUtil::formatNumber($maxSizeMB); ");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("return LogUtil::registerError(__f(\'Error! Your file is too big. Please keep it smaller than %s megabytes.\', array($maxSizeMB), $dom));");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// validate image file");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$isImage = in_array($extension, $this->imageFileTypes);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($isImage) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$imgInfo = getimagesize($file[\'tmp_name\']);");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if (!is_array($imgInfo) || !$imgInfo[0] || !$imgInfo[1]) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("return LogUtil::registerError(__(\'Error! This file type seems not to be a valid image.\', $dom));");
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
  
  private CharSequence readMetaDataForFile(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Read meta data from a certain file.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $fileName  Name of file to be processed.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $filePath  Path to file to be processed.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return array collected meta data");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function readMetaDataForFile($fileName, $filePath)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$meta = array();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (empty($fileName)) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return $meta;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$extensionarr = explode(\'.\', $fileName);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$meta = array();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$meta[\'extension\'] = strtolower($extensionarr[count($extensionarr) - 1]);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$meta[\'size\'] = filesize($filePath);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$meta[\'isImage\'] = (in_array($meta[\'extension\'], $this->imageFileTypes) ? true : false);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!$meta[\'isImage\']) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return $meta;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($meta[\'extension\'] == \'swf\') {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$meta[\'isImage\'] = false;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$imgInfo = getimagesize($filePath);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!is_array($imgInfo)) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return $meta;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$meta[\'width\'] = $imgInfo[0];");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$meta[\'height\'] = $imgInfo[1];");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($imgInfo[1] < $imgInfo[0]) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$meta[\'format\'] = \'landscape\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("} elseif ($imgInfo[1] > $imgInfo[0]) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$meta[\'format\'] = \'portrait\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("} else {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$meta[\'format\'] = \'square\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $meta;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence isAllowedFileExtension(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Determines the allowed file extensions for a given object type.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $objectType Currently treated entity type.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $fieldName  Name of upload field.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $extension  Input file extension.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return array the list of allowed file extensions");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected function isAllowedFileExtension($objectType, $fieldName, $extension)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// determine the allowed extensions");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$allowedExtensions = array();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("switch ($objectType) {");
    _builder.newLine();
    _builder.append("        ");
    {
      Iterable<Entity> _uploadEntities = this._modelExtensions.getUploadEntities(it);
      for(final Entity entity : _uploadEntities) {
        CharSequence _isAllowedFileExtensionEntityCase = this.isAllowedFileExtensionEntityCase(entity);
        _builder.append(_isAllowedFileExtensionEntityCase, "        ");
      }
    }
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (count($allowedExtensions) > 0) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if (!in_array($extension, $allowedExtensions)) {");
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
    _builder.append("if (in_array($extension, $this->forbiddenFileTypes)) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return false;");
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
  
  private CharSequence isAllowedFileExtensionEntityCase(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    final Iterable<UploadField> uploadFields = this._modelExtensions.getUploadFieldsEntity(it);
    _builder.newLineIfNotEmpty();
    _builder.append("case \'");
    String _name = it.getName();
    String _formatForCode = this._formattingExtensions.formatForCode(_name);
    _builder.append(_formatForCode, "");
    _builder.append("\':");
    _builder.newLineIfNotEmpty();
    {
      int _size = IterableExtensions.size(uploadFields);
      boolean _greaterThan = (_size > 1);
      if (_greaterThan) {
        _builder.append("    ");
        _builder.append("switch ($fieldName) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        {
          for(final UploadField uploadField : uploadFields) {
            CharSequence _isAllowedFileExtensionFieldCase = this.isAllowedFileExtensionFieldCase(uploadField);
            _builder.append(_isAllowedFileExtensionFieldCase, "        ");
          }
        }
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
      } else {
        _builder.append("    ");
        _builder.append("$allowedExtensions = array(\'");
        UploadField _head = IterableExtensions.<UploadField>head(uploadFields);
        String _allowedExtensions = _head.getAllowedExtensions();
        String _replaceAll = _allowedExtensions.replaceAll(", ", "\', \'");
        _builder.append(_replaceAll, "    ");
        _builder.append("\');");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("        ");
    _builder.append("break;");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence isAllowedFileExtensionFieldCase(final UploadField it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("case \'");
    String _name = it.getName();
    String _formatForCode = this._formattingExtensions.formatForCode(_name);
    _builder.append(_formatForCode, "");
    _builder.append("\':");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("$allowedExtensions = array(\'");
    String _allowedExtensions = it.getAllowedExtensions();
    String _replaceAll = _allowedExtensions.replaceAll(", ", "\', \'");
    _builder.append(_replaceAll, "    ");
    _builder.append("\');");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("break;");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence determineFileName(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Determines the final filename for a given input filename.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* It considers different strategies for computing the result.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $objectType Currently treated entity type.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $fieldName  Name of upload field.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $basePath   Base path for file storage.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $fileName   Input file name.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $extension  Input file extension.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return string the resulting file name");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected function determineFileName($objectType, $fieldName, $basePath, $fileName, $extension)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$backupFileName = $fileName;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$namingScheme = 0;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("switch ($objectType) {");
    _builder.newLine();
    _builder.append("        ");
    {
      Iterable<Entity> _uploadEntities = this._modelExtensions.getUploadEntities(it);
      for(final Entity entity : _uploadEntities) {
        CharSequence _determineFileNameEntityCase = this.determineFileNameEntityCase(entity);
        _builder.append(_determineFileNameEntityCase, "        ");
      }
    }
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$iterIndex = -1;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("do {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if ($namingScheme == 0) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("// original file name");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$fileNameCharCount = strlen($fileName);");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("for ($y = 0; $y < $fileNameCharCount; $y++) {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("if (preg_match(\'/[^0-9A-Za-z_\\.]/\', $fileName[$y])) {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("$fileName[$y] = \'_\';");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("// append incremented number");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("if ($iterIndex > 0) {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("// strip off extension");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("$fileName = str_replace(\'.\' . $extension, \'\', $backupFileName);");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("// add iterated number");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("$fileName .= (string) ++$iterIndex;");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("// readd extension");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("$fileName .= \'.\' . $extension;");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("} else {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("$iterIndex++;");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("} else if ($namingScheme == 1) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("// md5 name");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$fileName = md5(uniqid(mt_rand(), TRUE)) . \'.\' . $extension;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("} else if ($namingScheme == 2) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("// prefix with random number");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$fileName = $fieldName . mt_rand(1, 999999) . \'.\' . $extension;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("while (file_exists($basePath . $fileName)); // repeat until we have a new name");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// return the new file name");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $fileName;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence determineFileNameEntityCase(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    final Iterable<UploadField> uploadFields = this._modelExtensions.getUploadFieldsEntity(it);
    _builder.newLineIfNotEmpty();
    _builder.append("case \'");
    String _name = it.getName();
    String _formatForCode = this._formattingExtensions.formatForCode(_name);
    _builder.append(_formatForCode, "");
    _builder.append("\':");
    _builder.newLineIfNotEmpty();
    {
      int _size = IterableExtensions.size(uploadFields);
      boolean _greaterThan = (_size > 1);
      if (_greaterThan) {
        _builder.append("    ");
        _builder.append("switch ($fieldName) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        {
          for(final UploadField uploadField : uploadFields) {
            CharSequence _determineFileNameFieldCase = this.determineFileNameFieldCase(uploadField);
            _builder.append(_determineFileNameFieldCase, "        ");
          }
        }
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
      } else {
        _builder.append("    ");
        _builder.append("$namingScheme = ");
        UploadField _head = IterableExtensions.<UploadField>head(uploadFields);
        String _namingSchemeAsInt = this._modelExtensions.namingSchemeAsInt(_head);
        _builder.append(_namingSchemeAsInt, "    ");
        _builder.append(";");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("        ");
    _builder.append("break;");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence determineFileNameFieldCase(final UploadField it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("case \'");
    String _name = it.getName();
    String _formatForCode = this._formattingExtensions.formatForCode(_name);
    _builder.append(_formatForCode, "");
    _builder.append("\':");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("$namingScheme = ");
    String _namingSchemeAsInt = this._modelExtensions.namingSchemeAsInt(it);
    _builder.append(_namingSchemeAsInt, "    ");
    _builder.append(";");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("break;");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence handleError(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Error handling helper method.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param array $file File array from $_FILES.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return boolean false");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("private function handleError($file)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$errmsg = \'\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("switch ($file[\'error\']) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("case UPLOAD_ERR_OK: //no error; possible file attack!");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$errmsg = \'Unknown error\';");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("break;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("case UPLOAD_ERR_INI_SIZE: //uploaded file exceeds the upload_max_filesize directive in php.ini");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$errmsg = \'File too big\';");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("break;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("case UPLOAD_ERR_FORM_SIZE: //uploaded file exceeds the MAX_FILE_SIZE directive that was specified in the html form");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$errmsg = \'File too big\';");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("break;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("case UPLOAD_ERR_PARTIAL: //uploaded file was only partially uploaded");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$errmsg = \'File uploaded partially\';");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("break;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("case UPLOAD_ERR_NO_FILE: //no file was uploaded");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$errmsg = \'No file uploaded\';");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("break;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("case UPLOAD_ERR_NO_TMP_DIR: //missing a temporary folder");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$errmsg = \'No tmp folder\';");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("break;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("default: //a default (error, just in case!  :)");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$errmsg = \'Unknown error\';");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("break;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return LogUtil::registerError(\'Error with upload: \' . $errmsg);");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence deleteUploadFile(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Deletes an existing upload file.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* For images the thumbnails are removed, too.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string  $objectType Currently treated entity type.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string  $objectData Object data array.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string  $fieldName  Name of upload field.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param integer $objectId   Primary identifier of the given object.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return mixed Array with updated object data on success, else false.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function deleteUploadFile($objectType, $objectData, $fieldName, $objectId)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!in_array($objectType, $this->allowedObjectTypes)) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return false;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (empty($objectData[$fieldName])) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return $objectData;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$serviceManager = ServiceUtil::getManager();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$controllerHelper = new ");
    {
      boolean _targets = this._utils.targets(it, "1.3.5");
      if (_targets) {
        String _appName = this._utils.appName(it);
        _builder.append(_appName, "    ");
        _builder.append("_Util_Controller");
      } else {
        _builder.append("ControllerUtil");
      }
    }
    _builder.append("($serviceManager");
    {
      boolean _targets_1 = this._utils.targets(it, "1.3.5");
      boolean _not = (!_targets_1);
      if (_not) {
        _builder.append(", ModUtil::getModule(\'");
        String _appName_1 = this._utils.appName(it);
        _builder.append(_appName_1, "    ");
        _builder.append("\')");
      }
    }
    _builder.append(");");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// determine file system information");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("try {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$basePath = $controllerHelper->getFileBaseFolder($objectType, $fieldName);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("} catch (\\Exception $e) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("LogUtil::registerError($e->getMessage());");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return $objectData;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$fileName = $objectData[$fieldName];");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// path to original file");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$filePath = $basePath . $fileName;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// check whether we have to consider thumbnails, too");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$fileExtension = FileUtil::getExtension($fileName, false);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (in_array($fileExtension, $this->imageFileTypes) && $fileExtension != \'swf\') {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// remove thumbnail images as well");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$manager = ServiceUtil::getManager()->getService(\'systemplugin.imagine.manager\');");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$manager->setModule(\'");
    String _appName_2 = this._utils.appName(it);
    _builder.append(_appName_2, "        ");
    _builder.append("\');");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("$fullObjectId = $objectType . \'-\' . $objectId;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$manager->removeImageThumbs($filePath, $fullObjectId);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// remove original file");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!unlink($filePath)) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return false;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$objectData[$fieldName] = \'\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$objectData[$fieldName . \'Meta\'] = array();");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $objectData;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence uploadHandlerImpl(final Application it) {
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
        _builder.append("\\Base\\UploadHandler as BaseUploadHandler;");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
      }
    }
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Upload handler implementation class.");
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
        _builder.append("_UploadHandler extends ");
        String _appName_1 = this._utils.appName(it);
        _builder.append(_appName_1, "");
        _builder.append("_Base_UploadHandler");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("class UploadHandler extends BaseUploadHandler");
        _builder.newLine();
      }
    }
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// feel free to add your upload handler enhancements here");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
}

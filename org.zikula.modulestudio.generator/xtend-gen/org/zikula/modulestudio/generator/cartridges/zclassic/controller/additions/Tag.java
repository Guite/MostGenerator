package org.zikula.modulestudio.generator.cartridges.zclassic.controller.additions;

import com.google.inject.Inject;
import de.guite.modulestudio.metamodel.modulestudio.Application;
import de.guite.modulestudio.metamodel.modulestudio.Entity;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class Tag {
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
  
  public void generate(final Application it, final IFileSystemAccess fsa) {
    String _appSourceLibPath = this._namingExtensions.getAppSourceLibPath(it);
    final String tagPath = (_appSourceLibPath + "TaggedObjectMeta/");
    String _plus = (tagPath + "Base/");
    String _appName = this._utils.appName(it);
    String _plus_1 = (_plus + _appName);
    String _plus_2 = (_plus_1 + ".php");
    CharSequence _tagBaseFile = this.tagBaseFile(it);
    fsa.generateFile(_plus_2, _tagBaseFile);
    String _appName_1 = this._utils.appName(it);
    String _plus_3 = (tagPath + _appName_1);
    String _plus_4 = (_plus_3 + ".php");
    CharSequence _tagFile = this.tagFile(it);
    fsa.generateFile(_plus_4, _tagFile);
  }
  
  private CharSequence tagBaseFile(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _phpFileHeader = this.fh.phpFileHeader(it);
    _builder.append(_phpFileHeader, "");
    _builder.newLineIfNotEmpty();
    CharSequence _tagBaseClass = this.tagBaseClass(it);
    _builder.append(_tagBaseClass, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence tagFile(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _phpFileHeader = this.fh.phpFileHeader(it);
    _builder.append(_phpFileHeader, "");
    _builder.newLineIfNotEmpty();
    CharSequence _tagImpl = this.tagImpl(it);
    _builder.append(_tagImpl, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence tagBaseClass(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _targets = this._utils.targets(it, "1.3.5");
      boolean _not = (!_targets);
      if (_not) {
        _builder.append("namespace ");
        String _appNamespace = this._utils.appNamespace(it);
        _builder.append(_appNamespace, "");
        _builder.append("\\TaggedObjectMeta\\Base;");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        _builder.append("use DateUtil;");
        _builder.newLine();
        _builder.append("use SecurityUtil;");
        _builder.newLine();
        _builder.append("use ServiceUtil;");
        _builder.newLine();
        _builder.append("use UserUtil;");
        _builder.newLine();
        _builder.append("use Zikula\\Core\\ModUrl;");
        _builder.newLine();
        _builder.newLine();
      }
    }
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* This class provides object meta data for the Tag module.");
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
        _builder.append("_TaggedObjectMeta_Base_");
        String _appName_1 = this._utils.appName(it);
        _builder.append(_appName_1, "");
        _builder.append(" extends Tag_AbstractTaggedObjectMeta");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("class ");
        String _appName_2 = this._utils.appName(it);
        _builder.append(_appName_2, "");
        _builder.append(" extends \\Tag\\AbstractTaggedObjectMeta");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    CharSequence _tagBaseImpl = this.tagBaseImpl(it);
    _builder.append(_tagBaseImpl, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence tagBaseImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Constructor.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param integer             $objectId  Identifier of treated object.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param integer             $areaId    Name of hook area.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string              $module    Name of the owning module.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string              $urlString **deprecated**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param ");
    {
      boolean _targets = this._utils.targets(it, "1.3.5");
      if (_targets) {
        _builder.append("Zikula_");
      }
    }
    _builder.append("ModUrl $urlObject Object carrying url arguments.");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("function __construct($objectId, $areaId, $module, $urlString = null, ");
    {
      boolean _targets_1 = this._utils.targets(it, "1.3.5");
      if (_targets_1) {
        _builder.append("Zikula_");
      }
    }
    _builder.append("ModUrl $urlObject = null)");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// call base constructor to store arguments in member vars");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("parent::__construct($objectId, $areaId, $module, $urlString, $urlObject);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// derive object type from url object");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$urlArgs = $urlObject->getArgs();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$objectType = isset($urlArgs[\'ot\']) ? $urlArgs[\'ot\'] : \'");
    Entity _leadingEntity = this._modelExtensions.getLeadingEntity(it);
    String _name = _leadingEntity.getName();
    String _formatForCode = this._formattingExtensions.formatForCode(_name);
    _builder.append(_formatForCode, "    ");
    _builder.append("\';");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$component = $module . \':\' . ucwords($objectType) . \':\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$perm = SecurityUtil::checkPermission($component, $objectId . \'::\', ACCESS_READ);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!$perm) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    {
      boolean _targets_2 = this._utils.targets(it, "1.3.5");
      if (_targets_2) {
        _builder.append("    ");
        _builder.append("$entityClass = $module . \'_Entity_\' . ucwords($objectType);");
        _builder.newLine();
      } else {
        _builder.append("    ");
        _builder.append("$entityClass = \'\\\\\' . $module . \'\\\\Entity\\\\\' . ucwords($objectType) . \'Entity\';");
        _builder.newLine();
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
    _builder.append("    ");
    _builder.append("$useJoins = false;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/** TODO support composite identifiers properly at this point */");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$entity = $repository->selectById($objectId, $useJoins);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($entity === false || (!is_array($entity) && !is_object($entity))) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$this->setObjectTitle($entity[$repository->getTitleFieldName()]);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$dateFieldName = $repository->getStartDateFieldName();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($dateFieldName != \'\') {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$this->setObjectDate($entity[$dateFieldName]);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("} else {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$this->setObjectDate(\'\');");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (method_exists[$entity, \'getCreatedUserId\')) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$this->setObjectAuthor(UserUtil::getVar(\'uname\', $entity[\'createdUserId\']));");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("} else {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$this->setObjectAuthor(\'\');");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Sets the object title.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $title");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function setObjectTitle($title)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$this->title = $title;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Sets the object date.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $date");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function setObjectDate($date)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$this->date = DateUtil::formatDatetime($date, \'datetimebrief\');");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Sets the object author.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $author");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function setObjectAuthor($author)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$this->author = $author;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence tagImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _targets = this._utils.targets(it, "1.3.5");
      boolean _not = (!_targets);
      if (_not) {
        _builder.append("namespace ");
        String _appNamespace = this._utils.appNamespace(it);
        _builder.append(_appNamespace, "");
        _builder.append("\\TaggedObjectMeta;");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        _builder.append("use ");
        String _appNamespace_1 = this._utils.appNamespace(it);
        _builder.append(_appNamespace_1, "");
        _builder.append("\\TaggedObjectMeta\\Base\\");
        String _appName = this._utils.appName(it);
        _builder.append(_appName, "");
        _builder.append(" as Base");
        String _appName_1 = this._utils.appName(it);
        _builder.append(_appName_1, "");
        _builder.append(";");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
      }
    }
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* This class provides object meta data for the Tag module.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    {
      boolean _targets_1 = this._utils.targets(it, "1.3.5");
      if (_targets_1) {
        _builder.append("class ");
        String _appName_2 = this._utils.appName(it);
        _builder.append(_appName_2, "");
        _builder.append("_TaggedObjectMeta_");
        String _appName_3 = this._utils.appName(it);
        _builder.append(_appName_3, "");
        _builder.append(" extends ");
        String _appName_4 = this._utils.appName(it);
        _builder.append(_appName_4, "");
        _builder.append("_TaggedObjectMeta_Base_");
        String _appName_5 = this._utils.appName(it);
        _builder.append(_appName_5, "");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("class ");
        String _appName_6 = this._utils.appName(it);
        _builder.append(_appName_6, "");
        _builder.append(" extends Base");
        String _appName_7 = this._utils.appName(it);
        _builder.append(_appName_7, "");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// feel free to extend the tag support here");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
}

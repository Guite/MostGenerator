package org.zikula.modulestudio.generator.cartridges.zclassic.controller.apis;

import com.google.inject.Inject;
import de.guite.modulestudio.metamodel.modulestudio.Application;
import de.guite.modulestudio.metamodel.modulestudio.Entity;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper;
import org.zikula.modulestudio.generator.cartridges.zclassic.view.additions.MailzView;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class Mailz {
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
    final String apiPath = (_appSourceLibPath + "Api/");
    String _xifexpression = null;
    boolean _targets = this._utils.targets(it, "1.3.5");
    boolean _not = (!_targets);
    if (_not) {
      _xifexpression = "Api";
    } else {
      _xifexpression = "";
    }
    final String apiClassSuffix = _xifexpression;
    String _plus = ("Mailz" + apiClassSuffix);
    final String apiFileName = (_plus + ".php");
    String _plus_1 = (apiPath + "Base/");
    String _plus_2 = (_plus_1 + apiFileName);
    CharSequence _mailzBaseFile = this.mailzBaseFile(it);
    fsa.generateFile(_plus_2, _mailzBaseFile);
    String _plus_3 = (apiPath + apiFileName);
    CharSequence _mailzFile = this.mailzFile(it);
    fsa.generateFile(_plus_3, _mailzFile);
    MailzView _mailzView = new MailzView();
    _mailzView.generate(it, fsa);
  }
  
  private CharSequence mailzBaseFile(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _phpFileHeader = this.fh.phpFileHeader(it);
    _builder.append(_phpFileHeader, "");
    _builder.newLineIfNotEmpty();
    CharSequence _mailzBaseClass = this.mailzBaseClass(it);
    _builder.append(_mailzBaseClass, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence mailzFile(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _phpFileHeader = this.fh.phpFileHeader(it);
    _builder.append(_phpFileHeader, "");
    _builder.newLineIfNotEmpty();
    CharSequence _mailzImpl = this.mailzImpl(it);
    _builder.append(_mailzImpl, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence mailzBaseClass(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _targets = this._utils.targets(it, "1.3.5");
      boolean _not = (!_targets);
      if (_not) {
        _builder.append("namespace ");
        String _appNamespace = this._utils.appNamespace(it);
        _builder.append(_appNamespace, "");
        _builder.append("\\Api\\Base;");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        _builder.append("use ModUtil;");
        _builder.newLine();
        _builder.append("use ServiceUtil;");
        _builder.newLine();
        _builder.append("use Zikula_AbstractApi;");
        _builder.newLine();
        _builder.append("use Zikula_View;");
        _builder.newLine();
        _builder.newLine();
      }
    }
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Mailz api base class.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("class ");
    {
      boolean _targets_1 = this._utils.targets(it, "1.3.5");
      if (_targets_1) {
        String _appName = this._utils.appName(it);
        _builder.append(_appName, "");
        _builder.append("_Api_Base_Mailz");
      } else {
        _builder.append("MailzApi");
      }
    }
    _builder.append(" extends Zikula_AbstractApi");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    CharSequence _mailzBaseImpl = this.mailzBaseImpl(it);
    _builder.append(_mailzBaseImpl, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence mailzBaseImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Returns existing Mailz plugins with type / title.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param array $args List of arguments.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return array List of provided plugin functions.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function getPlugins(array $args = array())");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    Entity _leadingEntity = this._modelExtensions.getLeadingEntity(it);
    String _nameMultiple = _leadingEntity.getNameMultiple();
    final String itemDesc = this._formattingExtensions.formatForDisplay(_nameMultiple);
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("$plugins = array();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$plugins[] = array(");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'pluginid\'      => 1,");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'module\'        => \'");
    String _appName = this._utils.appName(it);
    _builder.append(_appName, "        ");
    _builder.append("\',");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("\'title\'         => $this->__(\'3 newest ");
    _builder.append(itemDesc, "        ");
    _builder.append("\'),");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("\'description\'   => $this->__(\'A list of the three newest ");
    _builder.append(itemDesc, "        ");
    _builder.append(".\')");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append(");");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$plugins[] = array(");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'pluginid\'      => 2,");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'module\'        => \'");
    String _appName_1 = this._utils.appName(it);
    _builder.append(_appName_1, "        ");
    _builder.append("\',");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("\'title\'         => $this->__(\'3 random ");
    _builder.append(itemDesc, "        ");
    _builder.append("\'),");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("\'description\'   => $this->__(\'A list of three random ");
    _builder.append(itemDesc, "        ");
    _builder.append(".\')");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append(");");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $plugins;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Returns the content for a given Mailz plugin.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param array    $args                List of arguments.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param int      $args[\'pluginid\']    id number of plugin (internal id for this module, see getPlugins method).");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string   $args[\'params\']      optional, show specific one or all otherwise.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param int      $args[\'uid\']         optional, user id for user specific content.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string   $args[\'contenttype\'] h or t for html or text.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param datetime $args[\'last\']        timestamp of last newsletter.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return string output of plugin template.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function getContent(array $args = array())");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("ModUtil::initOOModule(\'");
    String _appName_2 = this._utils.appName(it);
    _builder.append(_appName_2, "    ");
    _builder.append("\');");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("// $args is something like:");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// Array ( [uid] => 5 [contenttype] => h [pluginid] => 1 [nid] => 1 [last] => 0000-00-00 00:00:00 [params] => Array ( [] => ) ) 1");
    _builder.newLine();
    _builder.append("    ");
    final Entity leadingEntity = this._modelExtensions.getLeadingEntity(it);
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("$objectType = \'");
    String _name = leadingEntity.getName();
    String _formatForCode = this._formattingExtensions.formatForCode(_name);
    _builder.append(_formatForCode, "    ");
    _builder.append("\';");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    {
      boolean _targets = this._utils.targets(it, "1.3.5");
      if (_targets) {
        _builder.append("    ");
        _builder.append("$entityClass = \'");
        String _appName_3 = this._utils.appName(it);
        _builder.append(_appName_3, "    ");
        _builder.append("_Entity_\' . ucwords($objectType);");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("    ");
        _builder.append("$entityClass = \'\\\\");
        String _appName_4 = this._utils.appName(it);
        _builder.append(_appName_4, "    ");
        _builder.append("\\\\Entity\\\\\' . ucwords($objectType) . \'Entity\';");
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
    _builder.append("$idFields = ModUtil::apiFunc(\'");
    String _appName_5 = this._utils.appName(it);
    _builder.append(_appName_5, "    ");
    _builder.append("\', \'selection\', \'getIdFields\', array(\'ot\' => $objectType));");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$sortParam = \'\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($args[\'pluginid\'] == 2) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$sortParam = \'RAND()\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("} elseif ($args[\'pluginid\'] == 1) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if (count($idFields) == 1) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$sortParam = $idFields[0] . \' DESC\';");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("} else {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("foreach ($idFields as $idField) {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("if (!empty($sortParam)) {");
    _builder.newLine();
    _builder.append("                    ");
    _builder.append("$sortParam .= \', \';");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("$sortParam .= $idField . \' ASC\';");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$where = \'\'/*$this->filter*/;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$resultsPerPage = 3;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// get objects from database");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$selectionArgs = array(");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'ot\' => $objectType,");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'where\' => $where,");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'orderBy\' => $sortParam,");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'currentPage\' => 1,");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'resultsPerPage\' => $resultsPerPage");
    _builder.newLine();
    _builder.append("    ");
    _builder.append(");");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("list($entities, $objectCount) = ModUtil::apiFunc(\'");
    String _appName_6 = this._utils.appName(it);
    _builder.append(_appName_6, "    ");
    _builder.append("\', \'selection\', \'getEntitiesPaginated\', $selectionArgs);");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$view = Zikula_View::getInstance(\'");
    String _appName_7 = this._utils.appName(it);
    _builder.append(_appName_7, "    ");
    _builder.append("\', true);");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("//$data = array(\'sorting\' => $this->sorting, \'amount\' => $this->amount, \'filter\' => $this->filter, \'template\' => $this->template);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("//$view->assign(\'vars\', $data);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$view->assign(\'objectType\', $objectType)");
    _builder.newLine();
    _builder.append("         ");
    _builder.append("->assign(\'items\', $entities)");
    _builder.newLine();
    _builder.append("         ");
    _builder.append("->assign($repository->getAdditionalTemplateParameters(\'api\', array(\'name\' => \'mailz\')));");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($args[\'contenttype\'] == \'t\') { /* text */");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return $view->fetch(\'");
    {
      boolean _targets_1 = this._utils.targets(it, "1.3.5");
      if (_targets_1) {
        _builder.append("mailz");
      } else {
        _builder.append("Mailz");
      }
    }
    _builder.append("/itemlist_");
    String _name_1 = leadingEntity.getName();
    String _formatForCode_1 = this._formattingExtensions.formatForCode(_name_1);
    _builder.append(_formatForCode_1, "        ");
    _builder.append("_text.tpl\');");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("} else {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("//return $view->fetch(\'");
    {
      boolean _targets_2 = this._utils.targets(it, "1.3.5");
      if (_targets_2) {
        _builder.append("contenttype");
      } else {
        _builder.append("ContentType");
      }
    }
    _builder.append("/itemlist_display.html\');");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("return $view->fetch(\'");
    {
      boolean _targets_3 = this._utils.targets(it, "1.3.5");
      if (_targets_3) {
        _builder.append("mailz");
      } else {
        _builder.append("Mailz");
      }
    }
    _builder.append("/itemlist_");
    String _name_2 = leadingEntity.getName();
    String _formatForCode_2 = this._formattingExtensions.formatForCode(_name_2);
    _builder.append(_formatForCode_2, "        ");
    _builder.append("_html.tpl\');");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence mailzImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _targets = this._utils.targets(it, "1.3.5");
      boolean _not = (!_targets);
      if (_not) {
        _builder.append("namespace ");
        String _appNamespace = this._utils.appNamespace(it);
        _builder.append(_appNamespace, "");
        _builder.append("\\Api;");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
      }
    }
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Mailz api implementation class.");
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
        _builder.append("_Api_Mailz extends ");
        String _appName_1 = this._utils.appName(it);
        _builder.append(_appName_1, "");
        _builder.append("_Api_Base_Mailz");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("class MailzApi extends Base\\MailzApi");
        _builder.newLine();
      }
    }
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// feel free to extend the mailz api here");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
}

package org.zikula.modulestudio.generator.cartridges.zclassic.controller.apis;

import com.google.inject.Inject;
import de.guite.modulestudio.metamodel.modulestudio.Application;
import de.guite.modulestudio.metamodel.modulestudio.Entity;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.eclipse.xtext.xbase.lib.InputOutput;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class Category {
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
    InputOutput.<String>println("Generating category api");
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
    String _plus = ("Category" + apiClassSuffix);
    final String apiFileName = (_plus + ".php");
    String _plus_1 = (apiPath + "Base/");
    String _plus_2 = (_plus_1 + apiFileName);
    CharSequence _categoryBaseFile = this.categoryBaseFile(it);
    fsa.generateFile(_plus_2, _categoryBaseFile);
    String _plus_3 = (apiPath + apiFileName);
    CharSequence _categoryFile = this.categoryFile(it);
    fsa.generateFile(_plus_3, _categoryFile);
  }
  
  private CharSequence categoryBaseFile(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _phpFileHeader = this.fh.phpFileHeader(it);
    _builder.append(_phpFileHeader, "");
    _builder.newLineIfNotEmpty();
    CharSequence _categoryBaseClass = this.categoryBaseClass(it);
    _builder.append(_categoryBaseClass, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence categoryFile(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _phpFileHeader = this.fh.phpFileHeader(it);
    _builder.append(_phpFileHeader, "");
    _builder.newLineIfNotEmpty();
    CharSequence _categoryImpl = this.categoryImpl(it);
    _builder.append(_categoryImpl, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence categoryBaseClass(final Application it) {
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
        _builder.append("use ");
        String _appNamespace_1 = this._utils.appNamespace(it);
        _builder.append(_appNamespace_1, "");
        _builder.append("\\Util\\ControllerUtil;");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        _builder.append("use CategoryRegistryUtil;");
        _builder.newLine();
        _builder.append("use DataUtil;");
        _builder.newLine();
        _builder.append("use ModUtil;");
        _builder.newLine();
        _builder.append("use Zikula_AbstractApi;");
        _builder.newLine();
      }
    }
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Category api base class.");
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
        _builder.append("_Api_Base_Category");
      } else {
        _builder.append("CategoryApi");
      }
    }
    _builder.append(" extends Zikula_AbstractApi");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    CharSequence _categoryBaseImpl = this.categoryBaseImpl(it);
    _builder.append(_categoryBaseImpl, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence categoryBaseImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Retrieves the main/default category of ");
    String _appName = this._utils.appName(it);
    _builder.append(_appName, " ");
    _builder.append(".");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $args[\'ot\']       The object type to be treated (optional)");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $args[\'registry\'] Name of category registry to be used (optional)");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @deprecated Use the methods getAllProperties, getAllPropertiesWithMainCat, getMainCatForProperty and getPrimaryProperty instead.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return mixed Category array on success, false on failure");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function getMainCat(array $args = array())");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (isset($args[\'registry\'])) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$args[\'registry\'] = $this->getPrimaryProperty($args);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$objectType = $this->determineObjectType($args, \'getMainCat\');");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return CategoryRegistryUtil::getRegisteredModuleCategory($this->name, ucwords($objectType), $args[\'registry\'], 32); // 32 == /__System/Modules/Global");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Defines whether multiple selection is enabled for a given object type");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* or not. Subclass can override this method to apply a custom behaviour");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* to certain category registries for example.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $args[\'ot\']       The object type to be treated (optional)");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $args[\'registry\'] Name of category registry to be used (optional)");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return boolean true if multiple selection is allowed, else false");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function hasMultipleSelection(array $args = array())");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (isset($args[\'registry\'])) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// default to the primary registry");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$args[\'registry\'] = $this->getPrimaryProperty($args);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$objectType = $this->determineObjectType($args, \'hasMultipleSelection\');");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// we make no difference between different category registries here");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// if you need a custom behaviour you should override this method");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$result = false;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("switch ($objectType) {");
    _builder.newLine();
    {
      Iterable<Entity> _categorisableEntities = this._modelBehaviourExtensions.getCategorisableEntities(it);
      for(final Entity entity : _categorisableEntities) {
        _builder.append("        ");
        _builder.append("case \'");
        String _name = entity.getName();
        String _formatForCode = this._formattingExtensions.formatForCode(_name);
        _builder.append(_formatForCode, "        ");
        _builder.append("\':");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("$result = ");
        boolean _isCategorisableMultiSelection = entity.isCategorisableMultiSelection();
        String _displayBool = this._formattingExtensions.displayBool(Boolean.valueOf(_isCategorisableMultiSelection));
        _builder.append(_displayBool, "            ");
        _builder.append(";");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("break;");
        _builder.newLine();
      }
    }
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $result;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Retrieves input data from POST for all registries.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $args[\'ot\']     The object type to be treated (optional)");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $args[\'source\'] Where to retrieve the data from (defaults to POST)");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return array The fetched data indexed by the registry id.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function retrieveCategoriesFromRequest(array $args = array())");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$dataSource = $this->request->request;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (isset($args[\'source\']) && $args[\'source\'] == \'GET\') {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$dataSource = $this->request->query;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$controllerArgs = isset($args[\'controllerArgs\']) && is_array($args[\'controllerArgs\']) ? $args[\'controllerArgs\'] : array();");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$catIdsPerRegistry = array();");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$objectType = $this->determineObjectType($args, \'retrieveCategoriesFromRequest\');");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$properties = $this->getAllProperties($args);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("foreach ($properties as $propertyName => $propertyId) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$hasMultiSelection = $this->hasMultipleSelection(array(\'ot\' => $objectType, \'registry\' => $propertyName));");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if ($hasMultiSelection === true) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$argName = \'catids\' . $propertyName;");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$inputValue = isset($controllerArgs[$argName]) ? $controllerArgs[$argName] : $dataSource->get($argName, array());");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("if (!is_array($inputValue)) {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("$inputValue = explode(\',\', $inputValue);");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("} else {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$argName = \'catid\' . $propertyName;");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$inputVal = isset($controllerArgs[$argName]) ? $controllerArgs[$argName] : (int) $dataSource->filter($argName, 0, FILTER_VALIDATE_INT);");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$inputValue = array();");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("if ($inputVal > 0) {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("$inputValue[] = $inputVal;");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$catIdsPerRegistry[$propertyName] = $inputValue;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $catIdsPerRegistry;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Adds a list of where clauses for a certain list of categories to a given query builder.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param Doctrine\\ORM\\QueryBuilder $args[\'qb\']     Query builder instance to be enhanced.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string                    $args[\'ot\']     The object type to be treated (optional)");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string                    $args[\'catids\'] Category ids grouped by property name");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return Doctrine\\ORM\\QueryBuilder The enriched query builder instance.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function buildFilterClauses(array $args = array())");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$qb = $args[\'qb\'];");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$properties = $this->getAllProperties($args);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$catIds = $args[\'catids\'];");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$filtersPerRegistry = array();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$filterParameters = array(\'values\' => array(), \'registries\' => array());");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("foreach ($properties as $propertyName => $propertyId) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if (!isset($catIds[$propertyName]) || !is_array($catIds[$propertyName]) || !count($catIds[$propertyName])) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("continue;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$filterParameters[\'values\'][$propertyName] = $catIds[$propertyName];");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$filterParameters[\'registries\'][$propertyName] = $propertyId;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$filtersPerRegistry[] = \'(tblCategories.category IN (:propName\' . $propertyName . \') AND tblCategories.categoryRegistryId = :propId\' . $propertyName . \')\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (count($filtersPerRegistry) > 0) {");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$qb->andWhere($qb->expr()->orX()->addMultiple($filtersPerRegistry));");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("foreach ($filterParameters as $propertyName => $filterValue) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$qb->setParameter(\'propName\' . $propertyName, $filterValue)");
    _builder.newLine();
    _builder.append("               ");
    _builder.append("->setParameter(\'propId\' . $propertyName, $filterParameters[\'registries\'][$propertyName]);");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $qb;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Returns a list of all registries / properties for a given object type.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $args[\'ot\'] The object type to retrieve (optional)");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return array list of the registries (property name as key, id as value).");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function getAllProperties(array $args = array())");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$objectType = $this->determineObjectType($args, \'getAllProperties\');");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$propertyIdsPerName = CategoryRegistryUtil::getRegisteredModuleCategoriesIds($this->name, ucwords($objectType));");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $propertyIdsPerName;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Returns a list of all registries with main category for a given object type.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $args[\'ot\']       The object type to retrieve (optional)");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $args[\'arraykey\'] Key for the result array (optional)");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return array list of the registries (registry id as key, main category id as value).");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function getAllPropertiesWithMainCat(array $args = array())");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$objectType = $this->determineObjectType($args, \'getAllPropertiesWithMainCat\');");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!isset($args[\'arraykey\'])) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$args[\'arraykey\'] = \'\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$registryInfo = CategoryRegistryUtil::getRegisteredModuleCategories($this->name, ucwords($objectType), $args[\'arraykey\']);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $registryInfo;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Returns the main category id for a given object type and a certain property name.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $args[\'ot\']       The object type to retrieve (optional)");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $args[\'property\'] The property name (optional)");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return integer The main category id of desired tree.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function getMainCatForProperty(array $args = array())");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$objectType = $this->determineObjectType($args, \'getMainCatForProperty\');");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$catId = CategoryRegistryUtil::getRegisteredModuleCategory($this->name, ucwords($objectType), $args[\'property\']);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $catId;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Returns the name of the primary registry.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $args[\'ot\'] The object type to retrieve (optional)");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return string name of the main registry.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function getPrimaryProperty(array $args = array())");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$objectType = $this->determineObjectType($args, \'getPrimaryProperty\');");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$registry = \'Main\';");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $registry;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Determine object type using controller util methods.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $args[\'ot\'] The object type to retrieve (optional)");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $methodName Name of calling method");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return string name of the determined object type");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected function determineObjectType(array $args = array(), $methodName = \'\')");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$objectType = isset($args[\'ot\']) ? $args[\'ot\'] : \'\';");
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
    _builder.append("($this->serviceManager");
    {
      boolean _targets_1 = this._utils.targets(it, "1.3.5");
      boolean _not = (!_targets_1);
      if (_not) {
        _builder.append(", ModUtil::getModule($this->name)");
      }
    }
    _builder.append(");");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("$utilArgs = array(\'api\' => \'category\', \'action\' => $methodName);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!in_array($objectType, $controllerHelper->getObjectTypes(\'api\', $utilArgs))) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$objectType = $controllerHelper->getDefaultObjectType(\'api\', $utilArgs);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $objectType;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence categoryImpl(final Application it) {
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
        _builder.append("use ");
        String _appNamespace_1 = this._utils.appNamespace(it);
        _builder.append(_appNamespace_1, "");
        _builder.append("\\Api\\Base\\CategoryApi as BaseCategoryApi;");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
      }
    }
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Category api implementation class.");
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
        _builder.append("_Api_Category extends ");
        String _appName_1 = this._utils.appName(it);
        _builder.append(_appName_1, "");
        _builder.append("_Api_Base_Category");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("class CategoryApi extends BaseCategoryApi");
        _builder.newLine();
      }
    }
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// feel free to extend the category api at this place");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
}

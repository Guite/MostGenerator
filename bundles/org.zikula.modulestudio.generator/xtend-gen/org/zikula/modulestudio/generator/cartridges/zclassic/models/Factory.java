package org.zikula.modulestudio.generator.cartridges.zclassic.models;

import com.google.common.base.Objects;
import com.google.common.collect.Iterables;
import de.guite.modulestudio.metamodel.AbstractDateField;
import de.guite.modulestudio.metamodel.Application;
import de.guite.modulestudio.metamodel.DataObject;
import de.guite.modulestudio.metamodel.DateField;
import de.guite.modulestudio.metamodel.DatetimeField;
import de.guite.modulestudio.metamodel.Entity;
import de.guite.modulestudio.metamodel.ListField;
import de.guite.modulestudio.metamodel.TimeField;
import java.util.Arrays;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.InputOutput;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class Factory {
  @Extension
  private FormattingExtensions _formattingExtensions = new FormattingExtensions();
  
  @Extension
  private ModelExtensions _modelExtensions = new ModelExtensions();
  
  @Extension
  private NamingExtensions _namingExtensions = new NamingExtensions();
  
  @Extension
  private Utils _utils = new Utils();
  
  private FileHelper fh = new FileHelper();
  
  /**
   * Creates a factory class file for easy entity creation.
   */
  public void generate(final Application it, final IFileSystemAccess fsa) {
    InputOutput.<String>println("Generating entity factory class");
    String _appSourceLibPath = this._namingExtensions.getAppSourceLibPath(it);
    String _plus = (_appSourceLibPath + "Entity/Factory/");
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(it.getName());
    String _plus_1 = (_plus + _formatForCodeCapital);
    String _plus_2 = (_plus_1 + "Factory.php");
    this._namingExtensions.generateClassPair(it, fsa, _plus_2, 
      this.fh.phpFileContent(it, this.modelFactoryBaseImpl(it)), this.fh.phpFileContent(it, this.modelFactoryImpl(it)));
    InputOutput.<String>println("Generating entity initialiser class");
    String _appSourceLibPath_1 = this._namingExtensions.getAppSourceLibPath(it);
    String _plus_3 = (_appSourceLibPath_1 + "Entity/Factory/EntityInitialiser.php");
    this._namingExtensions.generateClassPair(it, fsa, _plus_3, 
      this.fh.phpFileContent(it, this.initialiserBaseImpl(it)), this.fh.phpFileContent(it, this.initialiserImpl(it)));
  }
  
  private CharSequence modelFactoryBaseImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("namespace ");
    String _appNamespace = this._utils.appNamespace(it);
    _builder.append(_appNamespace);
    _builder.append("\\Entity\\Factory\\Base;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("use Doctrine\\Common\\Persistence\\ObjectManager;");
    _builder.newLine();
    _builder.append("use Doctrine\\ORM\\EntityRepository;");
    _builder.newLine();
    _builder.append("use InvalidArgumentException;");
    _builder.newLine();
    _builder.append("use ");
    String _appNamespace_1 = this._utils.appNamespace(it);
    _builder.append(_appNamespace_1);
    _builder.append("\\Entity\\Factory\\EntityInitialiser;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Factory class used to create entities and receive entity repositories.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("abstract class Abstract");
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital);
    _builder.append("Factory");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @var ObjectManager The object manager to be used for determining the repository");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("protected $objectManager;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @var EntityInitialiser The entity initialiser for dynamical application of default values");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("protected $entityInitialiser;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* ");
    String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital_1, "     ");
    _builder.append("Factory constructor.");
    _builder.newLineIfNotEmpty();
    _builder.append("     ");
    _builder.append("*");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @param ObjectManager     $objectManager     The object manager to be used for determining the repositories");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @param EntityInitialiser $entityInitialiser The entity initialiser for dynamical application of default values");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("public function __construct(ObjectManager $objectManager, EntityInitialiser $entityInitialiser)");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$this->objectManager = $objectManager;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$this->entityInitialiser = $entityInitialiser;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* Returns a repository for a given object type.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @param string $objectType Name of desired entity type");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @return EntityRepository The repository responsible for the given object type");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("public function getRepository($objectType)");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$entityClass = \'");
    String _formatForCodeCapital_2 = this._formattingExtensions.formatForCodeCapital(it.getVendor());
    _builder.append(_formatForCodeCapital_2, "        ");
    _builder.append("\\\\");
    String _formatForCodeCapital_3 = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital_3, "        ");
    _builder.append("Module\\\\Entity\\\\\' . ucfirst($objectType) . \'Entity\';");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return $this->objectManager->getRepository($entityClass);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    {
      Iterable<Entity> _allEntities = this._modelExtensions.getAllEntities(it);
      for(final Entity entity : _allEntities) {
        _builder.newLine();
        _builder.append("    ");
        _builder.append("/**");
        _builder.newLine();
        _builder.append("    ");
        _builder.append(" ");
        _builder.append("* Creates a new ");
        String _formatForCode = this._formattingExtensions.formatForCode(entity.getName());
        _builder.append(_formatForCode, "     ");
        _builder.append(" instance.");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append("    ");
        _builder.append(" ");
        _builder.append("* @return ");
        String _appNamespace_2 = this._utils.appNamespace(it);
        _builder.append(_appNamespace_2, "     ");
        _builder.append("\\Entity\\");
        String _formatForCode_1 = this._formattingExtensions.formatForCode(entity.getName());
        _builder.append(_formatForCode_1, "     ");
        _builder.append("Entity The newly created entity instance");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("public function create");
        String _formatForCodeCapital_4 = this._formattingExtensions.formatForCodeCapital(entity.getName());
        _builder.append(_formatForCodeCapital_4, "    ");
        _builder.append("()");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("{");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("$entityClass = \'");
        String _formatForCodeCapital_5 = this._formattingExtensions.formatForCodeCapital(it.getVendor());
        _builder.append(_formatForCodeCapital_5, "        ");
        _builder.append("\\\\");
        String _formatForCodeCapital_6 = this._formattingExtensions.formatForCodeCapital(it.getName());
        _builder.append(_formatForCodeCapital_6, "        ");
        _builder.append("Module\\\\Entity\\\\");
        String _formatForCodeCapital_7 = this._formattingExtensions.formatForCodeCapital(entity.getName());
        _builder.append(_formatForCodeCapital_7, "        ");
        _builder.append("Entity\';");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("$entity = new $entityClass(");
        _builder.append(");");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("$this->entityInitialiser->init");
        String _formatForCodeCapital_8 = this._formattingExtensions.formatForCodeCapital(entity.getName());
        _builder.append(_formatForCodeCapital_8, "        ");
        _builder.append("($entity);");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("return $entity;");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
      }
    }
    _builder.newLine();
    _builder.append("    ");
    CharSequence _idFields = this.getIdFields(it);
    _builder.append(_idFields, "    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    CharSequence _hasCompositeKeys = this.hasCompositeKeys(it);
    _builder.append(_hasCompositeKeys, "    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    CharSequence _terAndSetterMethods = this.fh.getterAndSetterMethods(it, "objectManager", "ObjectManager", Boolean.valueOf(false), Boolean.valueOf(true), Boolean.valueOf(false), "", "");
    _builder.append(_terAndSetterMethods, "    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    CharSequence _terAndSetterMethods_1 = this.fh.getterAndSetterMethods(it, "entityInitialiser", "EntityInitialiser", Boolean.valueOf(false), Boolean.valueOf(true), Boolean.valueOf(false), "", "");
    _builder.append(_terAndSetterMethods_1, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence getIdFields(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Gets the list of identifier fields for a given object type.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $objectType The object type to be treated");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return array List of identifier field names");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function getIdFields($objectType = \'\')");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (empty($objectType)) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("throw new InvalidArgumentException(\'Invalid object type received.\');");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$entityClass = \'");
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(it.getVendor());
    _builder.append(_formatForCodeCapital, "    ");
    String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital_1, "    ");
    _builder.append("Module:\' . ucfirst($objectType) . \'Entity\';");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$meta = $this->getObjectManager()->getClassMetadata($entityClass);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($this->hasCompositeKeys($objectType)) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$idFields = $meta->getIdentifierFieldNames();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("} else {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$idFields = [$meta->getSingleIdentifierFieldName()];");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $idFields;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence hasCompositeKeys(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Checks whether a certain entity type uses composite keys or not.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $objectType The object type to retrieve");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return Boolean Whether composite keys are used or not");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function hasCompositeKeys($objectType)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    {
      final Function1<DataObject, Boolean> _function = (DataObject it_1) -> {
        return Boolean.valueOf(this._modelExtensions.hasCompositeKeys(it_1));
      };
      boolean _isEmpty = IterableExtensions.isEmpty(IterableExtensions.<DataObject>filter(it.getEntities(), _function));
      if (_isEmpty) {
        _builder.append("    ");
        _builder.append("return false;");
        _builder.newLine();
      } else {
        _builder.append("    ");
        _builder.append("return in_array($objectType, [\'");
        final Function1<DataObject, Boolean> _function_1 = (DataObject it_1) -> {
          return Boolean.valueOf(this._modelExtensions.hasCompositeKeys(it_1));
        };
        final Function1<DataObject, String> _function_2 = (DataObject it_1) -> {
          return this._formattingExtensions.formatForCode(it_1.getName());
        };
        String _join = IterableExtensions.join(IterableExtensions.<DataObject, String>map(IterableExtensions.<DataObject>filter(it.getEntities(), _function_1), _function_2), "\', \'");
        _builder.append(_join, "    ");
        _builder.append("\']);");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence modelFactoryImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("namespace ");
    String _appNamespace = this._utils.appNamespace(it);
    _builder.append(_appNamespace);
    _builder.append("\\Entity\\Factory;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("use ");
    String _appNamespace_1 = this._utils.appNamespace(it);
    _builder.append(_appNamespace_1);
    _builder.append("\\Entity\\Factory\\Base\\Abstract");
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital);
    _builder.append("Factory;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Factory class used to create entities and receive entity repositories.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("class ");
    String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital_1);
    _builder.append("Factory extends Abstract");
    String _formatForCodeCapital_2 = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital_2);
    _builder.append("Factory");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// feel free to customise the factory");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence initialiserBaseImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("namespace ");
    String _appNamespace = this._utils.appNamespace(it);
    _builder.append(_appNamespace);
    _builder.append("\\Entity\\Factory\\Base;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    {
      Iterable<Entity> _allEntities = this._modelExtensions.getAllEntities(it);
      for(final Entity entity : _allEntities) {
        _builder.append("use ");
        String _appNamespace_1 = this._utils.appNamespace(it);
        _builder.append(_appNamespace_1);
        _builder.append("\\Entity\\");
        String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(entity.getName());
        _builder.append(_formatForCodeCapital);
        _builder.append("Entity;");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      final Function1<ListField, Boolean> _function = (ListField it_1) -> {
        String _name = it_1.getName();
        return Boolean.valueOf((!Objects.equal(_name, "workflowState")));
      };
      boolean _isEmpty = IterableExtensions.isEmpty(IterableExtensions.<ListField>filter(this._modelExtensions.getAllListFields(it), _function));
      boolean _not = (!_isEmpty);
      if (_not) {
        _builder.append("use ");
        String _appNamespace_2 = this._utils.appNamespace(it);
        _builder.append(_appNamespace_2);
        _builder.append("\\Helper\\ListEntriesHelper;");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Entity initialiser class used to dynamically apply default values to newly created entities.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("abstract class AbstractEntityInitialiser");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    {
      final Function1<ListField, Boolean> _function_1 = (ListField it_1) -> {
        String _name = it_1.getName();
        return Boolean.valueOf((!Objects.equal(_name, "workflowState")));
      };
      boolean _isEmpty_1 = IterableExtensions.isEmpty(IterableExtensions.<ListField>filter(this._modelExtensions.getAllListFields(it), _function_1));
      boolean _not_1 = (!_isEmpty_1);
      if (_not_1) {
        _builder.append("    ");
        _builder.append("/**");
        _builder.newLine();
        _builder.append("    ");
        _builder.append(" ");
        _builder.append("* @var ListEntriesHelper Helper service for managing list entries");
        _builder.newLine();
        _builder.append("    ");
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("protected $listEntriesHelper;");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("/**");
        _builder.newLine();
        _builder.append("    ");
        _builder.append(" ");
        _builder.append("* EntityInitialiser constructor.");
        _builder.newLine();
        _builder.append("    ");
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append("    ");
        _builder.append(" ");
        _builder.append("* @param ListEntriesHelper $listEntriesHelper Helper service for managing list entries");
        _builder.newLine();
        _builder.append("    ");
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("public function __construct(ListEntriesHelper $listEntriesHelper)");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("{");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("$this->listEntriesHelper = $listEntriesHelper;");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
        _builder.newLine();
      }
    }
    {
      Iterable<Entity> _allEntities_1 = this._modelExtensions.getAllEntities(it);
      for(final Entity entity_1 : _allEntities_1) {
        _builder.append("    ");
        _builder.append("/**");
        _builder.newLine();
        _builder.append("    ");
        _builder.append(" ");
        _builder.append("* Initialises a given ");
        String _formatForCode = this._formattingExtensions.formatForCode(entity_1.getName());
        _builder.append(_formatForCode, "     ");
        _builder.append(" instance.");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append("    ");
        _builder.append(" ");
        _builder.append("* @param ");
        String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(entity_1.getName());
        _builder.append(_formatForCodeCapital_1, "     ");
        _builder.append("Entity $entity The newly created entity instance");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append("    ");
        _builder.append(" ");
        _builder.append("* @return ");
        String _formatForCodeCapital_2 = this._formattingExtensions.formatForCodeCapital(entity_1.getName());
        _builder.append(_formatForCodeCapital_2, "     ");
        _builder.append("Entity The updated entity instance");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("public function init");
        String _formatForCodeCapital_3 = this._formattingExtensions.formatForCodeCapital(entity_1.getName());
        _builder.append(_formatForCodeCapital_3, "    ");
        _builder.append("(");
        String _formatForCodeCapital_4 = this._formattingExtensions.formatForCodeCapital(entity_1.getName());
        _builder.append(_formatForCodeCapital_4, "    ");
        _builder.append("Entity $entity)");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("{");
        _builder.newLine();
        {
          Iterable<AbstractDateField> _filter = Iterables.<AbstractDateField>filter(this._modelExtensions.getDerivedFields(entity_1), AbstractDateField.class);
          for(final AbstractDateField field : _filter) {
            _builder.append("    ");
            _builder.append("    ");
            CharSequence _setDefaultValue = this.setDefaultValue(field);
            _builder.append(_setDefaultValue, "        ");
            _builder.newLineIfNotEmpty();
          }
        }
        {
          final Function1<ListField, Boolean> _function_2 = (ListField it_1) -> {
            String _name = it_1.getName();
            return Boolean.valueOf((!Objects.equal(_name, "workflowState")));
          };
          boolean _isEmpty_2 = IterableExtensions.isEmpty(IterableExtensions.<ListField>filter(this._modelExtensions.getListFieldsEntity(entity_1), _function_2));
          boolean _not_2 = (!_isEmpty_2);
          if (_not_2) {
            {
              final Function1<ListField, Boolean> _function_3 = (ListField it_1) -> {
                String _name = it_1.getName();
                return Boolean.valueOf((!Objects.equal(_name, "workflowState")));
              };
              Iterable<ListField> _filter_1 = IterableExtensions.<ListField>filter(this._modelExtensions.getListFieldsEntity(entity_1), _function_3);
              for(final ListField listField : _filter_1) {
                _builder.append("    ");
                _builder.append("    ");
                _builder.append("$listEntries = $this->listEntriesHelper->get");
                String _formatForCodeCapital_5 = this._formattingExtensions.formatForCodeCapital(listField.getName());
                _builder.append(_formatForCodeCapital_5, "        ");
                _builder.append("EntriesFor");
                String _formatForCodeCapital_6 = this._formattingExtensions.formatForCodeCapital(entity_1.getName());
                _builder.append(_formatForCodeCapital_6, "        ");
                _builder.append("();");
                _builder.newLineIfNotEmpty();
                {
                  boolean _isMultiple = listField.isMultiple();
                  if (_isMultiple) {
                    _builder.append("    ");
                    _builder.append("    ");
                    _builder.append("foreach ($listEntries as $listEntry) {");
                    _builder.newLine();
                    _builder.append("    ");
                    _builder.append("    ");
                    _builder.append("    ");
                    _builder.append("if (true === $listEntry[\'default\']) {");
                    _builder.newLine();
                    _builder.append("    ");
                    _builder.append("    ");
                    _builder.append("        ");
                    _builder.append("$entity->set");
                    String _formatForCodeCapital_7 = this._formattingExtensions.formatForCodeCapital(listField.getName());
                    _builder.append(_formatForCodeCapital_7, "                ");
                    _builder.append("($listEntry[\'value\']);");
                    _builder.newLineIfNotEmpty();
                    _builder.append("    ");
                    _builder.append("    ");
                    _builder.append("        ");
                    _builder.append("break;");
                    _builder.newLine();
                    _builder.append("    ");
                    _builder.append("    ");
                    _builder.append("    ");
                    _builder.append("}");
                    _builder.newLine();
                    _builder.append("    ");
                    _builder.append("    ");
                    _builder.append("}");
                    _builder.newLine();
                  } else {
                    _builder.append("    ");
                    _builder.append("    ");
                    _builder.append("$items = [];");
                    _builder.newLine();
                    _builder.append("    ");
                    _builder.append("    ");
                    _builder.append("foreach ($listEntries as $listEntry) {");
                    _builder.newLine();
                    _builder.append("    ");
                    _builder.append("    ");
                    _builder.append("    ");
                    _builder.append("if (true === $listEntry[\'default\']) {");
                    _builder.newLine();
                    _builder.append("    ");
                    _builder.append("    ");
                    _builder.append("        ");
                    _builder.append("$items[] = $listEntry[\'value\'];");
                    _builder.newLine();
                    _builder.append("    ");
                    _builder.append("    ");
                    _builder.append("    ");
                    _builder.append("}");
                    _builder.newLine();
                    _builder.append("    ");
                    _builder.append("    ");
                    _builder.append("}");
                    _builder.newLine();
                    _builder.append("    ");
                    _builder.append("    ");
                    _builder.append("$entity->set");
                    String _formatForCodeCapital_8 = this._formattingExtensions.formatForCodeCapital(listField.getName());
                    _builder.append(_formatForCodeCapital_8, "        ");
                    _builder.append("(implode(\'###\', $items));");
                    _builder.newLineIfNotEmpty();
                  }
                }
                _builder.newLine();
              }
            }
            _builder.newLine();
          }
        }
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("return $entity;");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
        _builder.newLine();
      }
    }
    {
      final Function1<ListField, Boolean> _function_4 = (ListField it_1) -> {
        String _name = it_1.getName();
        return Boolean.valueOf((!Objects.equal(_name, "workflowState")));
      };
      boolean _isEmpty_3 = IterableExtensions.isEmpty(IterableExtensions.<ListField>filter(this._modelExtensions.getAllListFields(it), _function_4));
      boolean _not_3 = (!_isEmpty_3);
      if (_not_3) {
        _builder.append("    ");
        CharSequence _terAndSetterMethods = this.fh.getterAndSetterMethods(it, "listEntriesHelper", "ListEntriesHelper", Boolean.valueOf(false), Boolean.valueOf(true), Boolean.valueOf(false), "", "");
        _builder.append(_terAndSetterMethods, "    ");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence setDefaultValue(final AbstractDateField it) {
    CharSequence _xifexpression = null;
    if ((((it.getDefaultValue() != null) && (!Objects.equal(it.getDefaultValue(), ""))) && (it.getDefaultValue().length() > 0))) {
      CharSequence _xifexpression_1 = null;
      String _defaultValue = it.getDefaultValue();
      boolean _notEquals = (!Objects.equal(_defaultValue, "now"));
      if (_notEquals) {
        StringConcatenation _builder = new StringConcatenation();
        _builder.append("$entity->set");
        String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(it.getName());
        _builder.append(_formatForCodeCapital);
        _builder.append("(new \\DateTime(\'");
        String _defaultValue_1 = it.getDefaultValue();
        _builder.append(_defaultValue_1);
        _builder.append("\'));");
        _xifexpression_1 = _builder;
      } else {
        StringConcatenation _builder_1 = new StringConcatenation();
        _builder_1.append("$entity->set");
        String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(it.getName());
        _builder_1.append(_formatForCodeCapital_1);
        _builder_1.append("(\\DateTime::createFromFormat(\'");
        CharSequence _defaultFormat = this.defaultFormat(it);
        _builder_1.append(_defaultFormat);
        _builder_1.append("\'));");
        _xifexpression_1 = _builder_1;
      }
      _xifexpression = _xifexpression_1;
    }
    return _xifexpression;
  }
  
  private CharSequence _defaultFormat(final DatetimeField it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("Y-m-d H:i:s");
    return _builder;
  }
  
  private CharSequence _defaultFormat(final DateField it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("Y-m-d");
    return _builder;
  }
  
  private CharSequence _defaultFormat(final TimeField it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("H:i:s");
    return _builder;
  }
  
  private CharSequence initialiserImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("namespace ");
    String _appNamespace = this._utils.appNamespace(it);
    _builder.append(_appNamespace);
    _builder.append("\\Entity\\Factory;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("use ");
    String _appNamespace_1 = this._utils.appNamespace(it);
    _builder.append(_appNamespace_1);
    _builder.append("\\Entity\\Factory\\Base\\AbstractEntityInitialiser;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Entity initialiser class used to dynamically apply default values to newly created entities.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("class EntityInitialiser extends AbstractEntityInitialiser");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// feel free to customise the initialiser");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence defaultFormat(final AbstractDateField it) {
    if (it instanceof DateField) {
      return _defaultFormat((DateField)it);
    } else if (it instanceof DatetimeField) {
      return _defaultFormat((DatetimeField)it);
    } else if (it instanceof TimeField) {
      return _defaultFormat((TimeField)it);
    } else {
      throw new IllegalArgumentException("Unhandled parameter types: " +
        Arrays.<Object>asList(it).toString());
    }
  }
}

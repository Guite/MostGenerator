package org.zikula.modulestudio.generator.cartridges.zclassic.controller.installer;

import com.google.common.base.Objects;
import com.google.common.collect.Iterables;
import de.guite.modulestudio.metamodel.AbstractDateField;
import de.guite.modulestudio.metamodel.AbstractStringField;
import de.guite.modulestudio.metamodel.Application;
import de.guite.modulestudio.metamodel.ArrayField;
import de.guite.modulestudio.metamodel.BooleanField;
import de.guite.modulestudio.metamodel.DateField;
import de.guite.modulestudio.metamodel.DatetimeField;
import de.guite.modulestudio.metamodel.DecimalField;
import de.guite.modulestudio.metamodel.DerivedField;
import de.guite.modulestudio.metamodel.EmailField;
import de.guite.modulestudio.metamodel.Entity;
import de.guite.modulestudio.metamodel.EntityTreeType;
import de.guite.modulestudio.metamodel.FloatField;
import de.guite.modulestudio.metamodel.IntegerField;
import de.guite.modulestudio.metamodel.JoinRelationship;
import de.guite.modulestudio.metamodel.ListField;
import de.guite.modulestudio.metamodel.ListFieldItem;
import de.guite.modulestudio.metamodel.ManyToManyRelationship;
import de.guite.modulestudio.metamodel.ManyToOneRelationship;
import de.guite.modulestudio.metamodel.ObjectField;
import de.guite.modulestudio.metamodel.OneToManyRelationship;
import de.guite.modulestudio.metamodel.OneToOneRelationship;
import de.guite.modulestudio.metamodel.StringField;
import de.guite.modulestudio.metamodel.TextField;
import de.guite.modulestudio.metamodel.TimeField;
import de.guite.modulestudio.metamodel.UploadField;
import de.guite.modulestudio.metamodel.UrlField;
import de.guite.modulestudio.metamodel.UserField;
import java.util.Arrays;
import java.util.List;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.IntegerRange;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.GeneratorSettingsExtensions;
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.ModelInheritanceExtensions;
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class ExampleData {
  @Extension
  private FormattingExtensions _formattingExtensions = new FormattingExtensions();
  
  @Extension
  private GeneratorSettingsExtensions _generatorSettingsExtensions = new GeneratorSettingsExtensions();
  
  @Extension
  private ModelExtensions _modelExtensions = new ModelExtensions();
  
  @Extension
  private ModelBehaviourExtensions _modelBehaviourExtensions = new ModelBehaviourExtensions();
  
  @Extension
  private ModelJoinExtensions _modelJoinExtensions = new ModelJoinExtensions();
  
  @Extension
  private ModelInheritanceExtensions _modelInheritanceExtensions = new ModelInheritanceExtensions();
  
  @Extension
  private NamingExtensions _namingExtensions = new NamingExtensions();
  
  @Extension
  private Utils _utils = new Utils();
  
  /**
   * Entry point for example data used by the installer.
   */
  public CharSequence generate(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Create the default data for ");
    String _appName = this._utils.appName(it);
    _builder.append(_appName, " ");
    _builder.append(".");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    {
      boolean _hasCategorisableEntities = this._modelBehaviourExtensions.hasCategorisableEntities(it);
      if (_hasCategorisableEntities) {
        _builder.append(" ");
        _builder.append("* @param array $categoryRegistryIdsPerEntity List of category registry ids");
        _builder.newLineIfNotEmpty();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append(" ");
    _builder.append("* @return void");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected function createDefaultData(");
    {
      boolean _hasCategorisableEntities_1 = this._modelBehaviourExtensions.hasCategorisableEntities(it);
      if (_hasCategorisableEntities_1) {
        _builder.append("$categoryRegistryIdsPerEntity");
      }
    }
    _builder.append(")");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    CharSequence _exampleRows = this.exampleRows(it);
    _builder.append(_exampleRows, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence exampleRows(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("$entityManager = $this->container->get(\'");
    String _entityManagerService = this._namingExtensions.entityManagerService(it);
    _builder.append(_entityManagerService);
    _builder.append("\');");
    _builder.newLineIfNotEmpty();
    _builder.append("$logger = $this->container->get(\'logger\');");
    _builder.newLine();
    _builder.append("$request = $this->container->get(\'request_stack\')->getCurrentRequest();");
    _builder.newLine();
    {
      if ((this._modelExtensions.hasUserFields(it) || this._modelBehaviourExtensions.hasStandardFieldEntities(it))) {
        _builder.append("$adminUser = $this->container->get(\'zikula_users_module.user_repository\')->find(");
        {
          Boolean _targets = this._utils.targets(it, "1.5");
          if ((_targets).booleanValue()) {
            _builder.append("UsersConstant::USER_ID_ADMIN");
          } else {
            _builder.append("2");
          }
        }
        _builder.append(");");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.newLine();
    {
      final Function1<Entity, Boolean> _function = (Entity it_1) -> {
        EntityTreeType _tree = it_1.getTree();
        return Boolean.valueOf(Objects.equal(_tree, EntityTreeType.NONE));
      };
      Iterable<Entity> _filter = IterableExtensions.<Entity>filter(this._modelExtensions.getAllEntities(it), _function);
      for(final Entity entity : _filter) {
        CharSequence _truncateTable = this.truncateTable(entity);
        _builder.append(_truncateTable);
      }
    }
    _builder.newLineIfNotEmpty();
    {
      int _amountOfExampleRows = this._generatorSettingsExtensions.amountOfExampleRows(it);
      boolean _greaterThan = (_amountOfExampleRows > 0);
      if (_greaterThan) {
        {
          final Function1<Entity, Boolean> _function_1 = (Entity it_1) -> {
            EntityTreeType _tree = it_1.getTree();
            return Boolean.valueOf((!Objects.equal(_tree, EntityTreeType.NONE)));
          };
          boolean _isEmpty = IterableExtensions.isEmpty(IterableExtensions.<Entity>filter(this._modelExtensions.getAllEntities(it), _function_1));
          boolean _not = (!_isEmpty);
          if (_not) {
            _builder.append("$treeCounterRoot = 1;");
            _builder.newLine();
          }
        }
        CharSequence _createExampleRows = this.createExampleRows(it);
        _builder.append(_createExampleRows);
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder;
  }
  
  private CharSequence truncateTable(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    final Application app = it.getApplication();
    _builder.newLineIfNotEmpty();
    _builder.append("$entityClass = \'");
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(app.getVendor());
    _builder.append(_formatForCodeCapital);
    _builder.append("\\");
    String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(app.getName());
    _builder.append(_formatForCodeCapital_1);
    _builder.append("Module\\Entity\\");
    String _formatForCodeCapital_2 = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital_2);
    _builder.append("Entity\';");
    _builder.newLineIfNotEmpty();
    _builder.append("$entityManager->getRepository($entityClass)->truncateTable($logger);");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence createExampleRows(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _initDateValues = this.initDateValues(it);
    _builder.append(_initDateValues);
    _builder.newLineIfNotEmpty();
    {
      Iterable<Entity> _allEntities = this._modelExtensions.getAllEntities(it);
      for(final Entity entity : _allEntities) {
        CharSequence _initExampleObjects = this.initExampleObjects(entity, it);
        _builder.append(_initExampleObjects);
      }
    }
    _builder.newLineIfNotEmpty();
    {
      Iterable<Entity> _allEntities_1 = this._modelExtensions.getAllEntities(it);
      for(final Entity entity_1 : _allEntities_1) {
        CharSequence _createExampleRows = this.createExampleRows(entity_1, it);
        _builder.append(_createExampleRows);
      }
    }
    _builder.newLineIfNotEmpty();
    CharSequence _persistExampleObjects = this.persistExampleObjects(it);
    _builder.append(_persistExampleObjects);
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence initDateValues(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    final Iterable<AbstractDateField> fields = Iterables.<AbstractDateField>filter(this._modelExtensions.getAllEntityFields(it), AbstractDateField.class);
    _builder.newLineIfNotEmpty();
    {
      final Function1<AbstractDateField, Boolean> _function = (AbstractDateField it_1) -> {
        return Boolean.valueOf(it_1.isPast());
      };
      boolean _isEmpty = IterableExtensions.isEmpty(IterableExtensions.<AbstractDateField>filter(fields, _function));
      boolean _not = (!_isEmpty);
      if (_not) {
        _builder.append("$lastMonth = mktime(date(\'s\'), date(\'H\'), date(\'i\'), date(\'m\')-1, date(\'d\'), date(\'Y\'));");
        _builder.newLine();
        _builder.append("$lastHour = mktime(date(\'s\'), date(\'H\')-1, date(\'i\'), date(\'m\'), date(\'d\'), date(\'Y\'));");
        _builder.newLine();
      }
    }
    {
      final Function1<AbstractDateField, Boolean> _function_1 = (AbstractDateField it_1) -> {
        return Boolean.valueOf(it_1.isFuture());
      };
      boolean _isEmpty_1 = IterableExtensions.isEmpty(IterableExtensions.<AbstractDateField>filter(fields, _function_1));
      boolean _not_1 = (!_isEmpty_1);
      if (_not_1) {
        _builder.append("$nextMonth = mktime(date(\'s\'), date(\'H\'), date(\'i\'), date(\'m\')+1, date(\'d\'), date(\'Y\'));");
        _builder.newLine();
        _builder.append("$nextHour = mktime(date(\'s\'), date(\'H\')+1, date(\'i\'), date(\'m\'), date(\'d\'), date(\'Y\'));");
        _builder.newLine();
      }
    }
    {
      boolean _isEmpty_2 = IterableExtensions.isEmpty(Iterables.<DatetimeField>filter(fields, DatetimeField.class));
      boolean _not_2 = (!_isEmpty_2);
      if (_not_2) {
        _builder.append("$dtNow = date(\'Y-m-d H:i:s\');");
        _builder.newLine();
        {
          final Function1<DatetimeField, Boolean> _function_2 = (DatetimeField it_1) -> {
            return Boolean.valueOf(it_1.isPast());
          };
          boolean _isEmpty_3 = IterableExtensions.isEmpty(IterableExtensions.<DatetimeField>filter(Iterables.<DatetimeField>filter(fields, DatetimeField.class), _function_2));
          boolean _not_3 = (!_isEmpty_3);
          if (_not_3) {
            _builder.append("$dtPast = date(\'Y-m-d H:i:s\', $lastMonth);");
            _builder.newLine();
          }
        }
        {
          final Function1<DatetimeField, Boolean> _function_3 = (DatetimeField it_1) -> {
            return Boolean.valueOf(it_1.isFuture());
          };
          boolean _isEmpty_4 = IterableExtensions.isEmpty(IterableExtensions.<DatetimeField>filter(Iterables.<DatetimeField>filter(fields, DatetimeField.class), _function_3));
          boolean _not_4 = (!_isEmpty_4);
          if (_not_4) {
            _builder.append("$dtFuture = date(\'Y-m-d H:i:s\', $nextMonth);");
            _builder.newLine();
          }
        }
      }
    }
    {
      boolean _isEmpty_5 = IterableExtensions.isEmpty(Iterables.<DateField>filter(fields, DateField.class));
      boolean _not_5 = (!_isEmpty_5);
      if (_not_5) {
        _builder.append("$dNow = date(\'Y-m-d\');");
        _builder.newLine();
        {
          final Function1<DateField, Boolean> _function_4 = (DateField it_1) -> {
            return Boolean.valueOf(it_1.isPast());
          };
          boolean _isEmpty_6 = IterableExtensions.isEmpty(IterableExtensions.<DateField>filter(Iterables.<DateField>filter(fields, DateField.class), _function_4));
          boolean _not_6 = (!_isEmpty_6);
          if (_not_6) {
            _builder.append("$dPast = date(\'Y-m-d\', $lastMonth);");
            _builder.newLine();
          }
        }
        {
          final Function1<DateField, Boolean> _function_5 = (DateField it_1) -> {
            return Boolean.valueOf(it_1.isFuture());
          };
          boolean _isEmpty_7 = IterableExtensions.isEmpty(IterableExtensions.<DateField>filter(Iterables.<DateField>filter(fields, DateField.class), _function_5));
          boolean _not_7 = (!_isEmpty_7);
          if (_not_7) {
            _builder.append("$dFuture = date(\'Y-m-d\', $nextMonth);");
            _builder.newLine();
          }
        }
      }
    }
    {
      boolean _isEmpty_8 = IterableExtensions.isEmpty(Iterables.<TimeField>filter(fields, TimeField.class));
      boolean _not_8 = (!_isEmpty_8);
      if (_not_8) {
        _builder.append("$tNow = date(\'H:i:s\');");
        _builder.newLine();
        {
          final Function1<TimeField, Boolean> _function_6 = (TimeField it_1) -> {
            return Boolean.valueOf(it_1.isPast());
          };
          boolean _isEmpty_9 = IterableExtensions.isEmpty(IterableExtensions.<TimeField>filter(Iterables.<TimeField>filter(fields, TimeField.class), _function_6));
          boolean _not_9 = (!_isEmpty_9);
          if (_not_9) {
            _builder.append("$tPast = date(\'H:i:s\', $lastHour);");
            _builder.newLine();
          }
        }
        {
          final Function1<TimeField, Boolean> _function_7 = (TimeField it_1) -> {
            return Boolean.valueOf(it_1.isFuture());
          };
          boolean _isEmpty_10 = IterableExtensions.isEmpty(IterableExtensions.<TimeField>filter(Iterables.<TimeField>filter(fields, TimeField.class), _function_7));
          boolean _not_10 = (!_isEmpty_10);
          if (_not_10) {
            _builder.append("$tFuture = date(\'H:i:s\', $nextHour);");
            _builder.newLine();
          }
        }
      }
    }
    return _builder;
  }
  
  private CharSequence initExampleObjects(final Entity it, final Application app) {
    StringConcatenation _builder = new StringConcatenation();
    {
      int _amountOfExampleRows = this._generatorSettingsExtensions.amountOfExampleRows(app);
      IntegerRange _upTo = new IntegerRange(1, _amountOfExampleRows);
      for(final Integer number : _upTo) {
        _builder.append("$");
        String _formatForCode = this._formattingExtensions.formatForCode(it.getName());
        _builder.append(_formatForCode);
        _builder.append(number);
        _builder.append(" = new \\");
        String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(app.getVendor());
        _builder.append(_formatForCodeCapital);
        _builder.append("\\");
        String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(app.getName());
        _builder.append(_formatForCodeCapital_1);
        _builder.append("Module\\Entity\\");
        String _formatForCodeCapital_2 = this._formattingExtensions.formatForCodeCapital(it.getName());
        _builder.append(_formatForCodeCapital_2);
        _builder.append("Entity(");
        CharSequence _exampleRowsConstructorArguments = this.exampleRowsConstructorArguments(it, number);
        _builder.append(_exampleRowsConstructorArguments);
        _builder.append(");");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence createExampleRows(final Entity it, final Application app) {
    StringConcatenation _builder = new StringConcatenation();
    final String entityName = this._formattingExtensions.formatForCode(it.getName());
    _builder.newLineIfNotEmpty();
    {
      boolean _isCategorisable = it.isCategorisable();
      if (_isCategorisable) {
        _builder.append("$categoryId = 41; // Business and work");
        _builder.newLine();
        _builder.append("$category = $entityManager->find(\'ZikulaCategoriesModule:CategoryEntity\', $categoryId);");
        _builder.newLine();
      }
    }
    {
      int _amountOfExampleRows = this._generatorSettingsExtensions.amountOfExampleRows(app);
      IntegerRange _upTo = new IntegerRange(1, _amountOfExampleRows);
      for(final Integer number : _upTo) {
        {
          boolean _isInheriting = this._modelInheritanceExtensions.isInheriting(it);
          if (_isInheriting) {
            {
              List<DerivedField> _fieldsForExampleData = this._modelExtensions.getFieldsForExampleData(this._modelInheritanceExtensions.parentType(it));
              for(final DerivedField field : _fieldsForExampleData) {
                CharSequence _exampleRowAssignment = this.exampleRowAssignment(field, it, entityName, number);
                _builder.append(_exampleRowAssignment);
              }
            }
            _builder.newLineIfNotEmpty();
          }
        }
        {
          List<DerivedField> _fieldsForExampleData_1 = this._modelExtensions.getFieldsForExampleData(it);
          for(final DerivedField field_1 : _fieldsForExampleData_1) {
            CharSequence _exampleRowAssignment_1 = this.exampleRowAssignment(field_1, it, entityName, number);
            _builder.append(_exampleRowAssignment_1);
          }
        }
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        {
          EntityTreeType _tree = it.getTree();
          boolean _notEquals = (!Objects.equal(_tree, EntityTreeType.NONE));
          if (_notEquals) {
            _builder.append("$");
            _builder.append(entityName);
            _builder.append(number);
            _builder.append("->setParent(");
            {
              if (((number).intValue() == 1)) {
                _builder.append("null");
              } else {
                _builder.append("$");
                _builder.append(entityName);
                _builder.append("1");
              }
            }
            _builder.append(");");
            _builder.newLineIfNotEmpty();
            _builder.append("$");
            _builder.append(entityName);
            _builder.append(number);
            _builder.append("->setLvl(");
            {
              if (((number).intValue() == 1)) {
                _builder.append("1");
              } else {
                _builder.append("2");
              }
            }
            _builder.append(");");
            _builder.newLineIfNotEmpty();
            _builder.append("$");
            _builder.append(entityName);
            _builder.append(number);
            _builder.append("->setLft(");
            {
              if (((number).intValue() == 1)) {
                _builder.append("1");
              } else {
                _builder.append((((number).intValue() - 1) * 2));
              }
            }
            _builder.append(");");
            _builder.newLineIfNotEmpty();
            _builder.append("$");
            _builder.append(entityName);
            _builder.append(number);
            _builder.append("->setRgt(");
            {
              if (((number).intValue() == 1)) {
                int _amountOfExampleRows_1 = this._generatorSettingsExtensions.amountOfExampleRows(app);
                int _multiply = (_amountOfExampleRows_1 * 2);
                _builder.append(_multiply);
              } else {
                _builder.append(((((number).intValue() - 1) * 2) + 1));
              }
            }
            _builder.append(");");
            _builder.newLineIfNotEmpty();
            _builder.append("$");
            _builder.append(entityName);
            _builder.append(number);
            _builder.append("->setRoot($treeCounterRoot);");
            _builder.newLineIfNotEmpty();
          }
        }
        {
          final Function1<OneToOneRelationship, Boolean> _function = (OneToOneRelationship it_1) -> {
            Application _application = it_1.getTarget().getApplication();
            return Boolean.valueOf(Objects.equal(_application, app));
          };
          Iterable<OneToOneRelationship> _filter = IterableExtensions.<OneToOneRelationship>filter(Iterables.<OneToOneRelationship>filter(it.getOutgoing(), OneToOneRelationship.class), _function);
          for(final OneToOneRelationship relation : _filter) {
            CharSequence _exampleRowAssignmentOutgoing = this.exampleRowAssignmentOutgoing(relation, entityName, number);
            _builder.append(_exampleRowAssignmentOutgoing);
          }
        }
        _builder.append(" ");
        _builder.newLineIfNotEmpty();
        {
          final Function1<ManyToOneRelationship, Boolean> _function_1 = (ManyToOneRelationship it_1) -> {
            Application _application = it_1.getTarget().getApplication();
            return Boolean.valueOf(Objects.equal(_application, app));
          };
          Iterable<ManyToOneRelationship> _filter_1 = IterableExtensions.<ManyToOneRelationship>filter(Iterables.<ManyToOneRelationship>filter(it.getOutgoing(), ManyToOneRelationship.class), _function_1);
          for(final ManyToOneRelationship relation_1 : _filter_1) {
            CharSequence _exampleRowAssignmentOutgoing_1 = this.exampleRowAssignmentOutgoing(relation_1, entityName, number);
            _builder.append(_exampleRowAssignmentOutgoing_1);
          }
        }
        _builder.newLineIfNotEmpty();
        {
          final Function1<ManyToManyRelationship, Boolean> _function_2 = (ManyToManyRelationship it_1) -> {
            Application _application = it_1.getTarget().getApplication();
            return Boolean.valueOf(Objects.equal(_application, app));
          };
          Iterable<ManyToManyRelationship> _filter_2 = IterableExtensions.<ManyToManyRelationship>filter(Iterables.<ManyToManyRelationship>filter(it.getOutgoing(), ManyToManyRelationship.class), _function_2);
          for(final ManyToManyRelationship relation_2 : _filter_2) {
            CharSequence _exampleRowAssignmentOutgoing_2 = this.exampleRowAssignmentOutgoing(relation_2, entityName, number);
            _builder.append(_exampleRowAssignmentOutgoing_2);
          }
        }
        _builder.newLineIfNotEmpty();
        {
          final Function1<OneToManyRelationship, Boolean> _function_3 = (OneToManyRelationship it_1) -> {
            return Boolean.valueOf(it_1.isBidirectional());
          };
          final Function1<OneToManyRelationship, Boolean> _function_4 = (OneToManyRelationship it_1) -> {
            Application _application = it_1.getSource().getApplication();
            return Boolean.valueOf(Objects.equal(_application, app));
          };
          Iterable<OneToManyRelationship> _filter_3 = IterableExtensions.<OneToManyRelationship>filter(IterableExtensions.<OneToManyRelationship>filter(Iterables.<OneToManyRelationship>filter(it.getIncoming(), OneToManyRelationship.class), _function_3), _function_4);
          for(final OneToManyRelationship relation_3 : _filter_3) {
            CharSequence _exampleRowAssignmentIncoming = this.exampleRowAssignmentIncoming(relation_3, entityName, number);
            _builder.append(_exampleRowAssignmentIncoming);
          }
        }
        _builder.newLineIfNotEmpty();
        {
          boolean _isCategorisable_1 = it.isCategorisable();
          if (_isCategorisable_1) {
            _builder.append("// create category assignment");
            _builder.newLine();
            _builder.append("$");
            _builder.append(entityName);
            _builder.append(number);
            _builder.append("->getCategories()->add(new \\");
            String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(app.getVendor());
            _builder.append(_formatForCodeCapital);
            _builder.append("\\");
            String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(app.getName());
            _builder.append(_formatForCodeCapital_1);
            _builder.append("Module\\Entity\\");
            String _formatForCodeCapital_2 = this._formattingExtensions.formatForCodeCapital(it.getName());
            _builder.append(_formatForCodeCapital_2);
            _builder.append("CategoryEntity($categoryRegistryIdsPerEntity[\'");
            String _formatForCode = this._formattingExtensions.formatForCode(it.getName());
            _builder.append(_formatForCode);
            _builder.append("\'], $category, $");
            _builder.append(entityName);
            _builder.append(number);
            _builder.append("));");
            _builder.newLineIfNotEmpty();
          }
        }
        {
          boolean _isAttributable = it.isAttributable();
          if (_isAttributable) {
            _builder.append("// create example attributes");
            _builder.newLine();
            _builder.append("$");
            _builder.append(entityName);
            _builder.append(number);
            _builder.append("->setAttribute(\'field1\', \'first value\');");
            _builder.newLineIfNotEmpty();
            _builder.append("$");
            _builder.append(entityName);
            _builder.append(number);
            _builder.append("->setAttribute(\'field2\', \'second value\');");
            _builder.newLineIfNotEmpty();
            _builder.append("$");
            _builder.append(entityName);
            _builder.append(number);
            _builder.append("->setAttribute(\'field3\', \'third value\');");
            _builder.newLineIfNotEmpty();
          }
        }
      }
    }
    {
      EntityTreeType _tree_1 = it.getTree();
      boolean _notEquals_1 = (!Objects.equal(_tree_1, EntityTreeType.NONE));
      if (_notEquals_1) {
        _builder.append("$treeCounterRoot++;");
        _builder.newLine();
      }
    }
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence persistExampleObjects(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("// execute the workflow action for each entity");
    _builder.newLine();
    _builder.append("$action = \'submit\';");
    _builder.newLine();
    _builder.append("$workflowHelper = new \\");
    String _appNamespace = this._utils.appNamespace(it);
    _builder.append(_appNamespace);
    _builder.append("\\Helper\\WorkflowHelper($this->container, $this->container->get(\'translator.default\'));");
    _builder.newLineIfNotEmpty();
    _builder.append("try {");
    _builder.newLine();
    _builder.append("    ");
    {
      Iterable<Entity> _allEntities = this._modelExtensions.getAllEntities(it);
      for(final Entity entity : _allEntities) {
        CharSequence _persistEntities = this.persistEntities(entity, it);
        _builder.append(_persistEntities, "    ");
      }
    }
    _builder.newLineIfNotEmpty();
    _builder.append("} catch(\\Exception $e) {");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$this->addFlash(\'error\', $this->__(\'Exception during example data creation\') . \': \' . $e->getMessage());");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$logger->error(\'{app}: Could not completely create example data during installation. Error details: {errorMessage}.\', [\'app\' => \'");
    String _appName = this._utils.appName(it);
    _builder.append(_appName, "    ");
    _builder.append("\', \'errorMessage\' => $e->getMessage()]);");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return false;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence persistEntities(final Entity it, final Application app) {
    StringConcatenation _builder = new StringConcatenation();
    {
      int _amountOfExampleRows = this._generatorSettingsExtensions.amountOfExampleRows(app);
      IntegerRange _upTo = new IntegerRange(1, _amountOfExampleRows);
      for(final Integer number : _upTo) {
        _builder.append("$success = $workflowHelper->executeAction($");
        String _formatForCode = this._formattingExtensions.formatForCode(it.getName());
        _builder.append(_formatForCode);
        _builder.append(number);
        _builder.append(", $action);");
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder;
  }
  
  private CharSequence exampleRowsConstructorArgumentsDefault(final Entity it, final Boolean hasPreviousArgs, final Integer number) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _hasCompositeKeys = this._modelExtensions.hasCompositeKeys(it);
      if (_hasCompositeKeys) {
        {
          if ((hasPreviousArgs).booleanValue()) {
            _builder.append(", ");
          }
        }
        {
          Iterable<DerivedField> _primaryKeyFields = this._modelExtensions.getPrimaryKeyFields(it);
          boolean _hasElements = false;
          for(final DerivedField pkField : _primaryKeyFields) {
            if (!_hasElements) {
              _hasElements = true;
            } else {
              _builder.appendImmediate(", ", "");
            }
            _builder.append("$");
            String _formatForCode = this._formattingExtensions.formatForCode(pkField.getName());
            _builder.append(_formatForCode);
          }
        }
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder;
  }
  
  private CharSequence exampleRowsConstructorArguments(final Entity it, final Integer number) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _isIndexByTarget = this._modelJoinExtensions.isIndexByTarget(it);
      if (_isIndexByTarget) {
        final Function1<JoinRelationship, Boolean> _function = (JoinRelationship it_1) -> {
          return Boolean.valueOf(this._modelJoinExtensions.isIndexed(it_1));
        };
        final JoinRelationship indexRelation = IterableExtensions.<JoinRelationship>head(IterableExtensions.<JoinRelationship>filter(Iterables.<JoinRelationship>filter(it.getIncoming(), JoinRelationship.class), _function));
        _builder.newLineIfNotEmpty();
        final String sourceAlias = this._namingExtensions.getRelationAliasName(indexRelation, Boolean.valueOf(false));
        _builder.newLineIfNotEmpty();
        final String indexBy = this._modelJoinExtensions.getIndexByField(indexRelation);
        _builder.newLineIfNotEmpty();
        final Function1<DerivedField, Boolean> _function_1 = (DerivedField it_1) -> {
          String _name = it_1.getName();
          return Boolean.valueOf(Objects.equal(_name, indexBy));
        };
        final DerivedField indexByField = IterableExtensions.<DerivedField>findFirst(this._modelExtensions.getDerivedFields(it), _function_1);
        _builder.newLineIfNotEmpty();
        Object _exampleRowsConstructorArgument = this.exampleRowsConstructorArgument(indexByField, number);
        _builder.append(_exampleRowsConstructorArgument);
        _builder.append(", $");
        String _formatForCode = this._formattingExtensions.formatForCode(sourceAlias);
        _builder.append(_formatForCode);
        _builder.append(number);
        CharSequence _exampleRowsConstructorArgumentsDefault = this.exampleRowsConstructorArgumentsDefault(it, Boolean.valueOf(true), number);
        _builder.append(_exampleRowsConstructorArgumentsDefault);
        _builder.newLineIfNotEmpty();
      } else {
        boolean _isAggregated = this._modelJoinExtensions.isAggregated(it);
        if (_isAggregated) {
          {
            Iterable<DerivedField> _aggregators = this._modelJoinExtensions.getAggregators(it);
            boolean _hasElements = false;
            for(final DerivedField aggregator : _aggregators) {
              if (!_hasElements) {
                _hasElements = true;
              } else {
                _builder.appendImmediate(", ", "");
              }
              {
                Iterable<OneToManyRelationship> _aggregatingRelationships = this._modelJoinExtensions.getAggregatingRelationships(aggregator);
                boolean _hasElements_1 = false;
                for(final OneToManyRelationship relation : _aggregatingRelationships) {
                  if (!_hasElements_1) {
                    _hasElements_1 = true;
                  } else {
                    _builder.appendImmediate(", ", "");
                  }
                  CharSequence _exampleRowsConstructorArgumentsAggregate = this.exampleRowsConstructorArgumentsAggregate(relation, number);
                  _builder.append(_exampleRowsConstructorArgumentsAggregate);
                }
              }
              CharSequence _exampleRowsConstructorArgumentsDefault_1 = this.exampleRowsConstructorArgumentsDefault(it, Boolean.valueOf(true), number);
              _builder.append(_exampleRowsConstructorArgumentsDefault_1);
              _builder.newLineIfNotEmpty();
            }
          }
        } else {
          CharSequence _exampleRowsConstructorArgumentsDefault_2 = this.exampleRowsConstructorArgumentsDefault(it, Boolean.valueOf(false), number);
          _builder.append(_exampleRowsConstructorArgumentsDefault_2);
          _builder.newLineIfNotEmpty();
        }
      }
    }
    return _builder;
  }
  
  private Object exampleRowsConstructorArgument(final DerivedField it, final Integer number) {
    Object _switchResult = null;
    boolean _matched = false;
    if (it instanceof IntegerField) {
      _matched=true;
      Object _xifexpression = null;
      int _length = ((IntegerField)it).getDefaultValue().length();
      boolean _greaterThan = (_length > 0);
      if (_greaterThan) {
        _xifexpression = ((IntegerField)it).getDefaultValue();
      } else {
        _xifexpression = number;
      }
      _switchResult = ((Object)_xifexpression);
    }
    if (!_matched) {
      String _xifexpression = null;
      int _length = it.getDefaultValue().length();
      boolean _greaterThan = (_length > 0);
      if (_greaterThan) {
        _xifexpression = it.getDefaultValue();
      } else {
        String _formatForDisplayCapital = this._formattingExtensions.formatForDisplayCapital(it.getName());
        String _plus = (_formatForDisplayCapital + " ");
        _xifexpression = (_plus + number);
      }
      String _plus_1 = ("\'" + _xifexpression);
      _switchResult = (_plus_1 + "\'");
    }
    return _switchResult;
  }
  
  private CharSequence exampleRowsConstructorArgumentsAggregate(final OneToManyRelationship it, final Integer number) {
    StringConcatenation _builder = new StringConcatenation();
    final DerivedField targetField = this._modelJoinExtensions.getAggregateTargetField(IterableExtensions.<IntegerField>head(this._modelExtensions.getAggregateFields(it.getSource())));
    _builder.newLineIfNotEmpty();
    _builder.append("$");
    String _relationAliasName = this._namingExtensions.getRelationAliasName(it, Boolean.valueOf(false));
    _builder.append(_relationAliasName);
    _builder.append(number);
    _builder.append(", ");
    {
      if (((!Objects.equal(targetField.getDefaultValue(), "")) && (!Objects.equal(targetField.getDefaultValue(), "0")))) {
        String _defaultValue = targetField.getDefaultValue();
        _builder.append(_defaultValue);
      } else {
        _builder.append(number);
      }
    }
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence exampleRowAssignment(final DerivedField it, final Entity dataEntity, final String entityName, final Integer number) {
    CharSequence _switchResult = null;
    boolean _matched = false;
    if (it instanceof IntegerField) {
      _matched=true;
      StringConcatenation _builder = new StringConcatenation();
      {
        int _length = ((IntegerField)it).getAggregateFor().length();
        boolean _equals = (_length == 0);
        if (_equals) {
          _builder.append("$");
          _builder.append(entityName);
          _builder.append(number);
          _builder.append("->set");
          String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(((IntegerField)it).getName());
          _builder.append(_formatForCodeCapital);
          _builder.append("(");
          CharSequence _exampleRowValue = this.exampleRowValue(it, dataEntity, number);
          _builder.append(_exampleRowValue);
          _builder.append(");");
          _builder.newLineIfNotEmpty();
        }
      }
      _switchResult = _builder;
    }
    if (!_matched) {
      if (it instanceof UploadField) {
        _matched=true;
        _switchResult = "";
      }
    }
    if (!_matched) {
      StringConcatenation _builder = new StringConcatenation();
      _builder.append("$");
      _builder.append(entityName);
      _builder.append(number);
      _builder.append("->set");
      String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(it.getName());
      _builder.append(_formatForCodeCapital);
      _builder.append("(");
      CharSequence _exampleRowValue = this.exampleRowValue(it, dataEntity, number);
      _builder.append(_exampleRowValue);
      _builder.append(");");
      _builder.newLineIfNotEmpty();
      _switchResult = _builder;
    }
    return _switchResult;
  }
  
  private CharSequence _exampleRowAssignmentOutgoing(final JoinRelationship it, final String entityName, final Integer number) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("$");
    _builder.append(entityName);
    _builder.append(number);
    _builder.append("->set");
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(this._namingExtensions.getRelationAliasName(it, Boolean.valueOf(true)));
    _builder.append(_formatForCodeCapital);
    _builder.append("($");
    String _formatForCode = this._formattingExtensions.formatForCode(it.getTarget().getName());
    _builder.append(_formatForCode);
    _builder.append(number);
    _builder.append(");");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence _exampleRowAssignmentOutgoing(final ManyToManyRelationship it, final String entityName, final Integer number) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("$");
    _builder.append(entityName);
    _builder.append(number);
    _builder.append("->add");
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(this._namingExtensions.getRelationAliasName(it, Boolean.valueOf(true)));
    _builder.append(_formatForCodeCapital);
    _builder.append("($");
    String _formatForCode = this._formattingExtensions.formatForCode(it.getTarget().getName());
    _builder.append(_formatForCode);
    _builder.append(number);
    _builder.append(");");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence exampleRowAssignmentIncoming(final JoinRelationship it, final String entityName, final Integer number) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("$");
    _builder.append(entityName);
    _builder.append(number);
    _builder.append("->set");
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(this._namingExtensions.getRelationAliasName(it, Boolean.valueOf(false)));
    _builder.append(_formatForCodeCapital);
    _builder.append("($");
    String _formatForCode = this._formattingExtensions.formatForCode(it.getSource().getName());
    _builder.append(_formatForCode);
    _builder.append(number);
    _builder.append(");");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence exampleRowValueNumber(final DerivedField it, final Entity dataEntity, final Integer number) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append(number);
    return _builder;
  }
  
  private CharSequence exampleRowValueTextLength(final DerivedField it, final Entity dataEntity, final Integer number, final Integer maxLength) {
    StringConcatenation _builder = new StringConcatenation();
    {
      int _length = this._formattingExtensions.formatForDisplayCapital(it.getEntity().getName()).length();
      int _plus = (_length + 4);
      int _length_1 = this._formattingExtensions.formatForDisplay(it.getName()).length();
      int _plus_1 = (_plus + _length_1);
      boolean _greaterEqualsThan = ((maxLength).intValue() >= _plus_1);
      if (_greaterEqualsThan) {
        _builder.append("\'");
        String _formatForDisplayCapital = this._formattingExtensions.formatForDisplayCapital(dataEntity.getName());
        _builder.append(_formatForDisplayCapital);
        _builder.append(" ");
        String _formatForDisplay = this._formattingExtensions.formatForDisplay(it.getName());
        _builder.append(_formatForDisplay);
        _builder.append(" ");
        _builder.append(number);
        _builder.append("\'");
      } else {
        if (((!it.isUnique()) && ((maxLength).intValue() >= (4 + this._formattingExtensions.formatForDisplay(it.getName()).length())))) {
          _builder.newLineIfNotEmpty();
          _builder.append("\'");
          String _formatForDisplay_1 = this._formattingExtensions.formatForDisplay(it.getName());
          _builder.append(_formatForDisplay_1);
          _builder.append(" ");
          _builder.append(number);
          _builder.append("\'");
        } else {
          if ((((maxLength).intValue() < 4) && ((maxLength).intValue() > 1))) {
            _builder.newLineIfNotEmpty();
            _builder.append("\'");
            int _length_2 = dataEntity.getName().length();
            int _plus_2 = ((number).intValue() + _length_2);
            int _size = dataEntity.getFields().size();
            int _plus_3 = (_plus_2 + _size);
            _builder.append(_plus_3);
            _builder.append("\'");
          } else {
            if (((maxLength).intValue() == 1)) {
              _builder.newLineIfNotEmpty();
              _builder.append("\'");
              Integer _xifexpression = null;
              if (((number).intValue() > 9)) {
                _xifexpression = Integer.valueOf(1);
              } else {
                _xifexpression = number;
              }
              _builder.append(_xifexpression);
              _builder.append("\'");
            } else {
              _builder.newLineIfNotEmpty();
              _builder.append("substr(\'");
              String _formatForDisplayCapital_1 = this._formattingExtensions.formatForDisplayCapital(dataEntity.getName());
              _builder.append(_formatForDisplayCapital_1);
              _builder.append(" ");
              String _formatForDisplay_2 = this._formattingExtensions.formatForDisplay(it.getName());
              _builder.append(_formatForDisplay_2);
              _builder.append("\', 0, ");
              _builder.append(((maxLength).intValue() - 2));
              _builder.append(") . \' ");
              _builder.append(number);
              _builder.append("\'");
              _builder.newLineIfNotEmpty();
              _builder.append("        ");
            }
          }
        }
      }
    }
    return _builder;
  }
  
  private CharSequence exampleRowValueText(final DerivedField it, final Entity dataEntity, final Integer number) {
    CharSequence _xifexpression = null;
    if (((it instanceof AbstractStringField) && ((AbstractStringField) it).isNospace())) {
      _xifexpression = this.exampleRowValueTextInternal(it, dataEntity, number).toString().replace(" ", "");
    } else {
      _xifexpression = this.exampleRowValueTextInternal(it, dataEntity, number);
    }
    return _xifexpression;
  }
  
  private CharSequence exampleRowValueTextInternal(final DerivedField it, final Entity dataEntity, final Integer number) {
    CharSequence _switchResult = null;
    boolean _matched = false;
    if (it instanceof StringField) {
      _matched=true;
      _switchResult = this.exampleRowValueTextLength(it, dataEntity, number, Integer.valueOf(((StringField)it).getLength()));
    }
    if (!_matched) {
      if (it instanceof TextField) {
        _matched=true;
        _switchResult = this.exampleRowValueTextLength(it, dataEntity, number, Integer.valueOf(((TextField)it).getLength()));
      }
    }
    if (!_matched) {
      if (it instanceof EmailField) {
        _matched=true;
        _switchResult = this.exampleRowValueTextLength(it, dataEntity, number, Integer.valueOf(((EmailField)it).getLength()));
      }
    }
    if (!_matched) {
      if (it instanceof UrlField) {
        _matched=true;
        _switchResult = this.exampleRowValueTextLength(it, dataEntity, number, Integer.valueOf(((UrlField)it).getLength()));
      }
    }
    if (!_matched) {
      String _formatForDisplayCapital = this._formattingExtensions.formatForDisplayCapital(it.getEntity().getName());
      String _plus = ("\'" + _formatForDisplayCapital);
      String _plus_1 = (_plus + " ");
      String _formatForDisplay = this._formattingExtensions.formatForDisplay(it.getName());
      String _plus_2 = (_plus_1 + _formatForDisplay);
      String _plus_3 = (_plus_2 + " ");
      String _plus_4 = (_plus_3 + number);
      _switchResult = (_plus_4 + "\'");
    }
    return _switchResult;
  }
  
  private CharSequence exampleRowValue(final DerivedField it, final Entity dataEntity, final Integer number) {
    CharSequence _switchResult = null;
    boolean _matched = false;
    if (it instanceof BooleanField) {
      _matched=true;
      String _xifexpression = null;
      String _defaultValue = ((BooleanField)it).getDefaultValue();
      boolean _equals = Objects.equal(_defaultValue, "true");
      if (_equals) {
        _xifexpression = "true";
      } else {
        _xifexpression = "false";
      }
      _switchResult = _xifexpression;
    }
    if (!_matched) {
      if (it instanceof IntegerField) {
        _matched=true;
        _switchResult = this.exampleRowValueNumber(it, dataEntity, number);
      }
    }
    if (!_matched) {
      if (it instanceof DecimalField) {
        _matched=true;
        _switchResult = this.exampleRowValueNumber(it, dataEntity, number);
      }
    }
    if (!_matched) {
      if (it instanceof StringField) {
        _matched=true;
        CharSequence _xifexpression = null;
        if (((((StringField)it).isCountry() || ((StringField)it).isLanguage()) || ((StringField)it).isLocale())) {
          StringConcatenation _builder = new StringConcatenation();
          _builder.append("$request->getLocale()");
          _xifexpression = _builder;
        } else {
          CharSequence _xifexpression_1 = null;
          boolean _isCurrency = ((StringField)it).isCurrency();
          if (_isCurrency) {
            _xifexpression_1 = "EUR";
          } else {
            CharSequence _xifexpression_2 = null;
            boolean _isHtmlcolour = ((StringField)it).isHtmlcolour();
            if (_isHtmlcolour) {
              _xifexpression_2 = "\'#ff6600\'";
            } else {
              _xifexpression_2 = this.exampleRowValueText(it, dataEntity, number);
            }
            _xifexpression_1 = _xifexpression_2;
          }
          _xifexpression = _xifexpression_1;
        }
        _switchResult = _xifexpression;
      }
    }
    if (!_matched) {
      if (it instanceof TextField) {
        _matched=true;
        _switchResult = this.exampleRowValueText(it, dataEntity, number);
      }
    }
    if (!_matched) {
      if (it instanceof EmailField) {
        _matched=true;
        String _email = ((EmailField)it).getEntity().getApplication().getEmail();
        String _plus = ("\'" + _email);
        _switchResult = (_plus + "\'");
      }
    }
    if (!_matched) {
      if (it instanceof UrlField) {
        _matched=true;
        String _url = ((UrlField)it).getEntity().getApplication().getUrl();
        String _plus = ("\'" + _url);
        _switchResult = (_plus + "\'");
      }
    }
    if (!_matched) {
      if (it instanceof UploadField) {
        _matched=true;
        _switchResult = this.exampleRowValueText(it, dataEntity, number);
      }
    }
    if (!_matched) {
      if (it instanceof UserField) {
        _matched=true;
        _switchResult = "$adminUser";
      }
    }
    if (!_matched) {
      if (it instanceof ArrayField) {
        _matched=true;
        _switchResult = this.exampleRowValueNumber(it, dataEntity, number);
      }
    }
    if (!_matched) {
      if (it instanceof ObjectField) {
        _matched=true;
        _switchResult = this.exampleRowValueText(it, dataEntity, number);
      }
    }
    if (!_matched) {
      if (it instanceof DatetimeField) {
        _matched=true;
        StringConcatenation _builder = new StringConcatenation();
        {
          boolean _isPast = ((DatetimeField)it).isPast();
          if (_isPast) {
            _builder.append("$dtPast");
          } else {
            boolean _isFuture = ((DatetimeField)it).isFuture();
            if (_isFuture) {
              _builder.append("$dtFuture");
            } else {
              _builder.append("$dtNow");
            }
          }
        }
        _switchResult = _builder;
      }
    }
    if (!_matched) {
      if (it instanceof DateField) {
        _matched=true;
        StringConcatenation _builder = new StringConcatenation();
        {
          boolean _isPast = ((DateField)it).isPast();
          if (_isPast) {
            _builder.append("$dPast");
          } else {
            boolean _isFuture = ((DateField)it).isFuture();
            if (_isFuture) {
              _builder.append("$dFuture");
            } else {
              _builder.append("$dNow");
            }
          }
        }
        _switchResult = _builder;
      }
    }
    if (!_matched) {
      if (it instanceof TimeField) {
        _matched=true;
        StringConcatenation _builder = new StringConcatenation();
        {
          boolean _isPast = ((TimeField)it).isPast();
          if (_isPast) {
            _builder.append("$tPast");
          } else {
            boolean _isFuture = ((TimeField)it).isFuture();
            if (_isFuture) {
              _builder.append("$tFuture");
            } else {
              _builder.append("$tNow");
            }
          }
        }
        _switchResult = _builder;
      }
    }
    if (!_matched) {
      if (it instanceof FloatField) {
        _matched=true;
        _switchResult = this.exampleRowValueNumber(it, dataEntity, number);
      }
    }
    if (!_matched) {
      if (it instanceof ListField) {
        _matched=true;
        StringConcatenation _builder = new StringConcatenation();
        _builder.append("\'");
        {
          boolean _isMultiple = ((ListField)it).isMultiple();
          if (_isMultiple) {
            _builder.append("###");
            {
              Iterable<ListFieldItem> _defaultItems = this._modelExtensions.getDefaultItems(((ListField)it));
              boolean _hasElements = false;
              for(final ListFieldItem item : _defaultItems) {
                if (!_hasElements) {
                  _hasElements = true;
                } else {
                  _builder.appendImmediate("###", "");
                }
                String _exampleRowValue = this.exampleRowValue(item);
                _builder.append(_exampleRowValue);
              }
            }
            _builder.append("###");
          } else {
            {
              Iterable<ListFieldItem> _defaultItems_1 = this._modelExtensions.getDefaultItems(((ListField)it));
              for(final ListFieldItem item_1 : _defaultItems_1) {
                String _exampleRowValue_1 = this.exampleRowValue(item_1);
                _builder.append(_exampleRowValue_1);
              }
            }
          }
        }
        _builder.append("\'");
        _switchResult = _builder;
      }
    }
    if (!_matched) {
      _switchResult = "";
    }
    return _switchResult;
  }
  
  private String exampleRowValue(final ListFieldItem it) {
    String _xifexpression = null;
    boolean _isDefault = it.isDefault();
    if (_isDefault) {
      _xifexpression = it.getValue();
    } else {
      _xifexpression = "";
    }
    return _xifexpression;
  }
  
  private CharSequence exampleRowAssignmentOutgoing(final JoinRelationship it, final String entityName, final Integer number) {
    if (it instanceof ManyToManyRelationship) {
      return _exampleRowAssignmentOutgoing((ManyToManyRelationship)it, entityName, number);
    } else if (it != null) {
      return _exampleRowAssignmentOutgoing(it, entityName, number);
    } else {
      throw new IllegalArgumentException("Unhandled parameter types: " +
        Arrays.<Object>asList(it, entityName, number).toString());
    }
  }
}

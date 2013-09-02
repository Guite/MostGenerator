package org.zikula.modulestudio.generator.cartridges.zclassic.controller.installer;

import com.google.common.base.Objects;
import com.google.common.collect.Iterables;
import com.google.inject.Inject;
import de.guite.modulestudio.metamodel.modulestudio.AbstractDateField;
import de.guite.modulestudio.metamodel.modulestudio.Application;
import de.guite.modulestudio.metamodel.modulestudio.ArrayField;
import de.guite.modulestudio.metamodel.modulestudio.BooleanField;
import de.guite.modulestudio.metamodel.modulestudio.DateField;
import de.guite.modulestudio.metamodel.modulestudio.DatetimeField;
import de.guite.modulestudio.metamodel.modulestudio.DecimalField;
import de.guite.modulestudio.metamodel.modulestudio.DerivedField;
import de.guite.modulestudio.metamodel.modulestudio.EmailField;
import de.guite.modulestudio.metamodel.modulestudio.Entity;
import de.guite.modulestudio.metamodel.modulestudio.EntityField;
import de.guite.modulestudio.metamodel.modulestudio.EntityTreeType;
import de.guite.modulestudio.metamodel.modulestudio.FloatField;
import de.guite.modulestudio.metamodel.modulestudio.IntegerField;
import de.guite.modulestudio.metamodel.modulestudio.JoinRelationship;
import de.guite.modulestudio.metamodel.modulestudio.ListField;
import de.guite.modulestudio.metamodel.modulestudio.ListFieldItem;
import de.guite.modulestudio.metamodel.modulestudio.ManyToOneRelationship;
import de.guite.modulestudio.metamodel.modulestudio.Models;
import de.guite.modulestudio.metamodel.modulestudio.ObjectField;
import de.guite.modulestudio.metamodel.modulestudio.OneToManyRelationship;
import de.guite.modulestudio.metamodel.modulestudio.OneToOneRelationship;
import de.guite.modulestudio.metamodel.modulestudio.Relationship;
import de.guite.modulestudio.metamodel.modulestudio.StringField;
import de.guite.modulestudio.metamodel.modulestudio.TextField;
import de.guite.modulestudio.metamodel.modulestudio.TimeField;
import de.guite.modulestudio.metamodel.modulestudio.UploadField;
import de.guite.modulestudio.metamodel.modulestudio.UrlField;
import de.guite.modulestudio.metamodel.modulestudio.UserField;
import java.util.ArrayList;
import java.util.List;
import org.eclipse.emf.common.util.EList;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.zikula.modulestudio.generator.extensions.ControllerExtensions;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.ModelInheritanceExtensions;
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class ExampleData {
  @Inject
  @Extension
  private ControllerExtensions _controllerExtensions = new Function0<ControllerExtensions>() {
    public ControllerExtensions apply() {
      ControllerExtensions _controllerExtensions = new ControllerExtensions();
      return _controllerExtensions;
    }
  }.apply();
  
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
  private ModelJoinExtensions _modelJoinExtensions = new Function0<ModelJoinExtensions>() {
    public ModelJoinExtensions apply() {
      ModelJoinExtensions _modelJoinExtensions = new ModelJoinExtensions();
      return _modelJoinExtensions;
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
    _builder.append(" ");
    _builder.append("* @param array $categoryRegistryIdsPerEntity List of category registry ids.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return void");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected function createDefaultData($categoryRegistryIdsPerEntity)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    Models _defaultDataSource = this._modelExtensions.getDefaultDataSource(it);
    CharSequence _exampleRowImpl = this.exampleRowImpl(_defaultDataSource);
    _builder.append(_exampleRowImpl, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence exampleRowImpl(final Models it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      EList<Entity> _entities = it.getEntities();
      for(final Entity entity : _entities) {
        CharSequence _truncateTable = this.truncateTable(entity);
        _builder.append(_truncateTable, "");
      }
    }
    _builder.newLineIfNotEmpty();
    {
      int _numExampleRows = it.getNumExampleRows();
      boolean _greaterThan = (_numExampleRows > 0);
      if (_greaterThan) {
        {
          EList<Entity> _entities_1 = it.getEntities();
          final Function1<Entity,Boolean> _function = new Function1<Entity,Boolean>() {
              public Boolean apply(final Entity e) {
                EntityTreeType _tree = e.getTree();
                boolean _notEquals = (!Objects.equal(_tree, EntityTreeType.NONE));
                return Boolean.valueOf(_notEquals);
              }
            };
          Iterable<Entity> _filter = IterableExtensions.<Entity>filter(_entities_1, _function);
          boolean _isEmpty = IterableExtensions.isEmpty(_filter);
          boolean _not = (!_isEmpty);
          if (_not) {
            _builder.append("$treeCounterRoot = 1;");
            _builder.newLine();
          }
        }
        CharSequence _createExampleRows = this.createExampleRows(it);
        _builder.append(_createExampleRows, "");
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder;
  }
  
  private CharSequence truncateTable(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    Models _container = it.getContainer();
    final Application app = _container.getApplication();
    _builder.newLineIfNotEmpty();
    {
      boolean _targets = this._utils.targets(app, "1.3.5");
      if (_targets) {
        _builder.append("$entityClass = \'");
        String _appName = this._utils.appName(app);
        _builder.append(_appName, "");
        _builder.append("_Entity_");
        String _name = it.getName();
        String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(_name);
        _builder.append(_formatForCodeCapital, "");
        _builder.append("\';");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("$entityClass = \'\\\\");
        String _vendor = app.getVendor();
        String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(_vendor);
        _builder.append(_formatForCodeCapital_1, "");
        _builder.append("\\\\");
        String _name_1 = app.getName();
        String _formatForCodeCapital_2 = this._formattingExtensions.formatForCodeCapital(_name_1);
        _builder.append(_formatForCodeCapital_2, "");
        _builder.append("Module\\\\Entity\\\\");
        String _name_2 = it.getName();
        String _formatForCodeCapital_3 = this._formattingExtensions.formatForCodeCapital(_name_2);
        _builder.append(_formatForCodeCapital_3, "");
        _builder.append("Entity\';");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("$this->entityManager->getRepository($entityClass)->truncateTable();");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence createExampleRows(final Models it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _initDateValues = this.initDateValues(it);
    _builder.append(_initDateValues, "");
    _builder.newLineIfNotEmpty();
    {
      EList<Entity> _entities = it.getEntities();
      for(final Entity entity : _entities) {
        Application _application = it.getApplication();
        CharSequence _initExampleObjects = this.initExampleObjects(entity, _application);
        _builder.append(_initExampleObjects, "");
      }
    }
    _builder.newLineIfNotEmpty();
    {
      EList<Entity> _entities_1 = it.getEntities();
      for(final Entity entity_1 : _entities_1) {
        Application _application_1 = it.getApplication();
        CharSequence _createExampleRows = this.createExampleRows(entity_1, _application_1);
        _builder.append(_createExampleRows, "");
      }
    }
    _builder.newLineIfNotEmpty();
    CharSequence _persistExampleObjects = this.persistExampleObjects(it);
    _builder.append(_persistExampleObjects, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence initDateValues(final Models it) {
    StringConcatenation _builder = new StringConcatenation();
    List<EntityField> _modelEntityFields = this._modelExtensions.getModelEntityFields(it);
    final Iterable<AbstractDateField> fields = Iterables.<AbstractDateField>filter(_modelEntityFields, AbstractDateField.class);
    _builder.newLineIfNotEmpty();
    {
      final Function1<AbstractDateField,Boolean> _function = new Function1<AbstractDateField,Boolean>() {
          public Boolean apply(final AbstractDateField e) {
            boolean _isPast = e.isPast();
            return Boolean.valueOf(_isPast);
          }
        };
      Iterable<AbstractDateField> _filter = IterableExtensions.<AbstractDateField>filter(fields, _function);
      boolean _isEmpty = IterableExtensions.isEmpty(_filter);
      boolean _not = (!_isEmpty);
      if (_not) {
        _builder.append("$lastMonth = mktime(date(\'s\'), date(\'H\'), date(\'i\'), date(\'m\')-1, date(\'d\'), date(\'Y\'));");
        _builder.newLine();
        _builder.append("$lastHour = mktime(date(\'s\'), date(\'H\')-1, date(\'i\'), date(\'m\'), date(\'d\'), date(\'Y\'));");
        _builder.newLine();
      }
    }
    {
      final Function1<AbstractDateField,Boolean> _function_1 = new Function1<AbstractDateField,Boolean>() {
          public Boolean apply(final AbstractDateField e) {
            boolean _isFuture = e.isFuture();
            return Boolean.valueOf(_isFuture);
          }
        };
      Iterable<AbstractDateField> _filter_1 = IterableExtensions.<AbstractDateField>filter(fields, _function_1);
      boolean _isEmpty_1 = IterableExtensions.isEmpty(_filter_1);
      boolean _not_1 = (!_isEmpty_1);
      if (_not_1) {
        _builder.append("$nextMonth = mktime(date(\'s\'), date(\'H\'), date(\'i\'), date(\'m\')+1, date(\'d\'), date(\'Y\'));");
        _builder.newLine();
        _builder.append("$nextHour = mktime(date(\'s\'), date(\'H\')+1, date(\'i\'), date(\'m\'), date(\'d\'), date(\'Y\'));");
        _builder.newLine();
      }
    }
    {
      Iterable<DatetimeField> _filter_2 = Iterables.<DatetimeField>filter(fields, DatetimeField.class);
      boolean _isEmpty_2 = IterableExtensions.isEmpty(_filter_2);
      boolean _not_2 = (!_isEmpty_2);
      if (_not_2) {
        _builder.append("$dtNow = date(\'Y-m-d H:i:s\');");
        _builder.newLine();
        {
          Iterable<DatetimeField> _filter_3 = Iterables.<DatetimeField>filter(fields, DatetimeField.class);
          final Function1<DatetimeField,Boolean> _function_2 = new Function1<DatetimeField,Boolean>() {
              public Boolean apply(final DatetimeField e) {
                boolean _isPast = e.isPast();
                return Boolean.valueOf(_isPast);
              }
            };
          Iterable<DatetimeField> _filter_4 = IterableExtensions.<DatetimeField>filter(_filter_3, _function_2);
          boolean _isEmpty_3 = IterableExtensions.isEmpty(_filter_4);
          boolean _not_3 = (!_isEmpty_3);
          if (_not_3) {
            _builder.append("$dtPast = date(\'Y-m-d H:i:s\', $lastMonth);");
            _builder.newLine();
          }
        }
        {
          Iterable<DatetimeField> _filter_5 = Iterables.<DatetimeField>filter(fields, DatetimeField.class);
          final Function1<DatetimeField,Boolean> _function_3 = new Function1<DatetimeField,Boolean>() {
              public Boolean apply(final DatetimeField e) {
                boolean _isFuture = e.isFuture();
                return Boolean.valueOf(_isFuture);
              }
            };
          Iterable<DatetimeField> _filter_6 = IterableExtensions.<DatetimeField>filter(_filter_5, _function_3);
          boolean _isEmpty_4 = IterableExtensions.isEmpty(_filter_6);
          boolean _not_4 = (!_isEmpty_4);
          if (_not_4) {
            _builder.append("$dtFuture = date(\'Y-m-d H:i:s\', $nextMonth);");
            _builder.newLine();
          }
        }
      }
    }
    {
      Iterable<DateField> _filter_7 = Iterables.<DateField>filter(fields, DateField.class);
      boolean _isEmpty_5 = IterableExtensions.isEmpty(_filter_7);
      boolean _not_5 = (!_isEmpty_5);
      if (_not_5) {
        _builder.append("$dNow = date(\'Y-m-d\');");
        _builder.newLine();
        {
          Iterable<DateField> _filter_8 = Iterables.<DateField>filter(fields, DateField.class);
          final Function1<DateField,Boolean> _function_4 = new Function1<DateField,Boolean>() {
              public Boolean apply(final DateField e) {
                boolean _isPast = e.isPast();
                return Boolean.valueOf(_isPast);
              }
            };
          Iterable<DateField> _filter_9 = IterableExtensions.<DateField>filter(_filter_8, _function_4);
          boolean _isEmpty_6 = IterableExtensions.isEmpty(_filter_9);
          boolean _not_6 = (!_isEmpty_6);
          if (_not_6) {
            _builder.append("$dPast = date(\'Y-m-d\', $lastMonth);");
            _builder.newLine();
          }
        }
        {
          Iterable<DateField> _filter_10 = Iterables.<DateField>filter(fields, DateField.class);
          final Function1<DateField,Boolean> _function_5 = new Function1<DateField,Boolean>() {
              public Boolean apply(final DateField e) {
                boolean _isFuture = e.isFuture();
                return Boolean.valueOf(_isFuture);
              }
            };
          Iterable<DateField> _filter_11 = IterableExtensions.<DateField>filter(_filter_10, _function_5);
          boolean _isEmpty_7 = IterableExtensions.isEmpty(_filter_11);
          boolean _not_7 = (!_isEmpty_7);
          if (_not_7) {
            _builder.append("$dFuture = date(\'Y-m-d\', $nextMonth);");
            _builder.newLine();
          }
        }
      }
    }
    {
      Iterable<TimeField> _filter_12 = Iterables.<TimeField>filter(fields, TimeField.class);
      boolean _isEmpty_8 = IterableExtensions.isEmpty(_filter_12);
      boolean _not_8 = (!_isEmpty_8);
      if (_not_8) {
        _builder.append("$tNow = date(\'H:i:s\');");
        _builder.newLine();
        {
          Iterable<TimeField> _filter_13 = Iterables.<TimeField>filter(fields, TimeField.class);
          final Function1<TimeField,Boolean> _function_6 = new Function1<TimeField,Boolean>() {
              public Boolean apply(final TimeField e) {
                boolean _isPast = e.isPast();
                return Boolean.valueOf(_isPast);
              }
            };
          Iterable<TimeField> _filter_14 = IterableExtensions.<TimeField>filter(_filter_13, _function_6);
          boolean _isEmpty_9 = IterableExtensions.isEmpty(_filter_14);
          boolean _not_9 = (!_isEmpty_9);
          if (_not_9) {
            _builder.append("$tPast = date(\'H:i:s\', $lastHour);");
            _builder.newLine();
          }
        }
        {
          Iterable<TimeField> _filter_15 = Iterables.<TimeField>filter(fields, TimeField.class);
          final Function1<TimeField,Boolean> _function_7 = new Function1<TimeField,Boolean>() {
              public Boolean apply(final TimeField e) {
                boolean _isFuture = e.isFuture();
                return Boolean.valueOf(_isFuture);
              }
            };
          Iterable<TimeField> _filter_16 = IterableExtensions.<TimeField>filter(_filter_15, _function_7);
          boolean _isEmpty_10 = IterableExtensions.isEmpty(_filter_16);
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
    Models _container = it.getContainer();
    int _numExampleRows = _container.getNumExampleRows();
    ArrayList<Integer> exampleNumbers = this._controllerExtensions.getListForCounter(Integer.valueOf(_numExampleRows));
    _builder.newLineIfNotEmpty();
    {
      for(final Integer number : exampleNumbers) {
        _builder.append("$");
        String _name = it.getName();
        String _formatForCode = this._formattingExtensions.formatForCode(_name);
        _builder.append(_formatForCode, "");
        _builder.append(number, "");
        _builder.append(" = new \\");
        String _appName = this._utils.appName(app);
        _builder.append(_appName, "");
        {
          boolean _targets = this._utils.targets(app, "1.3.5");
          if (_targets) {
            _builder.append("_Entity_");
            String _name_1 = it.getName();
            String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(_name_1);
            _builder.append(_formatForCodeCapital, "");
          } else {
            _builder.append("\\Entity\\");
            String _name_2 = it.getName();
            String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(_name_2);
            _builder.append(_formatForCodeCapital_1, "");
            _builder.append("Entity");
          }
        }
        _builder.append("(");
        CharSequence _exampleRowsConstructorArguments = this.exampleRowsConstructorArguments(it, number);
        _builder.append(_exampleRowsConstructorArguments, "");
        _builder.append(");");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence createExampleRows(final Entity it, final Application app) {
    StringConcatenation _builder = new StringConcatenation();
    String _name = it.getName();
    final String entityName = this._formattingExtensions.formatForCode(_name);
    _builder.newLineIfNotEmpty();
    Models _container = it.getContainer();
    int _numExampleRows = _container.getNumExampleRows();
    ArrayList<Integer> exampleNumbers = this._controllerExtensions.getListForCounter(Integer.valueOf(_numExampleRows));
    _builder.newLineIfNotEmpty();
    {
      boolean _isCategorisable = it.isCategorisable();
      if (_isCategorisable) {
        _builder.append("$categoryId = 41; // Business and work");
        _builder.newLine();
        _builder.append("$category = $this->entityManager->find(\'Zikula");
        {
          boolean _targets = this._utils.targets(app, "1.3.5");
          if (_targets) {
            _builder.append("_Doctrine2_Entity_Category");
          } else {
            _builder.append("\\Core\\Doctrine\\Entity\\CategoryEntity");
          }
        }
        _builder.append("\', $categoryId);");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      for(final Integer number : exampleNumbers) {
        {
          boolean _isInheriting = this._modelInheritanceExtensions.isInheriting(it);
          if (_isInheriting) {
            {
              Entity _parentType = this._modelInheritanceExtensions.parentType(it);
              List<DerivedField> _fieldsForExampleData = this._modelExtensions.getFieldsForExampleData(_parentType);
              for(final DerivedField field : _fieldsForExampleData) {
                CharSequence _exampleRowAssignment = this.exampleRowAssignment(field, it, entityName, number);
                _builder.append(_exampleRowAssignment, "");
              }
            }
            _builder.newLineIfNotEmpty();
          }
        }
        {
          List<DerivedField> _fieldsForExampleData_1 = this._modelExtensions.getFieldsForExampleData(it);
          for(final DerivedField field_1 : _fieldsForExampleData_1) {
            CharSequence _exampleRowAssignment_1 = this.exampleRowAssignment(field_1, it, entityName, number);
            _builder.append(_exampleRowAssignment_1, "");
          }
        }
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        {
          EntityTreeType _tree = it.getTree();
          boolean _notEquals = (!Objects.equal(_tree, EntityTreeType.NONE));
          if (_notEquals) {
            _builder.append("$");
            _builder.append(entityName, "");
            _builder.append(number, "");
            _builder.append("->setParent(");
            {
              boolean _equals = ((number).intValue() == 1);
              if (_equals) {
                _builder.append("null");
              } else {
                _builder.append("$");
                _builder.append(entityName, "");
                _builder.append("1");
              }
            }
            _builder.append(");");
            _builder.newLineIfNotEmpty();
            _builder.append("$");
            _builder.append(entityName, "");
            _builder.append(number, "");
            _builder.append("->setLvl(");
            {
              boolean _equals_1 = ((number).intValue() == 1);
              if (_equals_1) {
                _builder.append("1");
              } else {
                _builder.append("2");
              }
            }
            _builder.append(");");
            _builder.newLineIfNotEmpty();
            _builder.append("$");
            _builder.append(entityName, "");
            _builder.append(number, "");
            _builder.append("->setLft(");
            {
              boolean _equals_2 = ((number).intValue() == 1);
              if (_equals_2) {
                _builder.append("1");
              } else {
                int _minus = ((number).intValue() - 1);
                int _multiply = (_minus * 2);
                _builder.append(_multiply, "");
              }
            }
            _builder.append(");");
            _builder.newLineIfNotEmpty();
            _builder.append("$");
            _builder.append(entityName, "");
            _builder.append(number, "");
            _builder.append("->setRgt(");
            {
              boolean _equals_3 = ((number).intValue() == 1);
              if (_equals_3) {
                Models _container_1 = it.getContainer();
                int _numExampleRows_1 = _container_1.getNumExampleRows();
                int _multiply_1 = (_numExampleRows_1 * 2);
                _builder.append(_multiply_1, "");
              } else {
                int _minus_1 = ((number).intValue() - 1);
                int _multiply_2 = (_minus_1 * 2);
                int _plus = (_multiply_2 + 1);
                _builder.append(_plus, "");
              }
            }
            _builder.append(");");
            _builder.newLineIfNotEmpty();
            _builder.append("$");
            _builder.append(entityName, "");
            _builder.append(number, "");
            _builder.append("->setRoot($treeCounterRoot);");
            _builder.newLineIfNotEmpty();
          }
        }
        {
          EList<Relationship> _outgoing = it.getOutgoing();
          Iterable<OneToOneRelationship> _filter = Iterables.<OneToOneRelationship>filter(_outgoing, OneToOneRelationship.class);
          final Function1<OneToOneRelationship,Boolean> _function = new Function1<OneToOneRelationship,Boolean>() {
              public Boolean apply(final OneToOneRelationship e) {
                Entity _target = e.getTarget();
                Models _container = _target.getContainer();
                Application _application = _container.getApplication();
                boolean _equals = Objects.equal(_application, app);
                return Boolean.valueOf(_equals);
              }
            };
          Iterable<OneToOneRelationship> _filter_1 = IterableExtensions.<OneToOneRelationship>filter(_filter, _function);
          for(final OneToOneRelationship relation : _filter_1) {
            CharSequence _exampleRowAssignmentOutgoing = this.exampleRowAssignmentOutgoing(relation, entityName, number);
            _builder.append(_exampleRowAssignmentOutgoing, "");
          }
        }
        _builder.append(" ");
        _builder.newLineIfNotEmpty();
        {
          EList<Relationship> _outgoing_1 = it.getOutgoing();
          Iterable<ManyToOneRelationship> _filter_2 = Iterables.<ManyToOneRelationship>filter(_outgoing_1, ManyToOneRelationship.class);
          final Function1<ManyToOneRelationship,Boolean> _function_1 = new Function1<ManyToOneRelationship,Boolean>() {
              public Boolean apply(final ManyToOneRelationship e) {
                Entity _target = e.getTarget();
                Models _container = _target.getContainer();
                Application _application = _container.getApplication();
                boolean _equals = Objects.equal(_application, app);
                return Boolean.valueOf(_equals);
              }
            };
          Iterable<ManyToOneRelationship> _filter_3 = IterableExtensions.<ManyToOneRelationship>filter(_filter_2, _function_1);
          for(final ManyToOneRelationship relation_1 : _filter_3) {
            CharSequence _exampleRowAssignmentOutgoing_1 = this.exampleRowAssignmentOutgoing(relation_1, entityName, number);
            _builder.append(_exampleRowAssignmentOutgoing_1, "");
          }
        }
        _builder.newLineIfNotEmpty();
        {
          EList<Relationship> _incoming = it.getIncoming();
          Iterable<OneToManyRelationship> _filter_4 = Iterables.<OneToManyRelationship>filter(_incoming, OneToManyRelationship.class);
          final Function1<OneToManyRelationship,Boolean> _function_2 = new Function1<OneToManyRelationship,Boolean>() {
              public Boolean apply(final OneToManyRelationship e) {
                boolean _isBidirectional = e.isBidirectional();
                return Boolean.valueOf(_isBidirectional);
              }
            };
          Iterable<OneToManyRelationship> _filter_5 = IterableExtensions.<OneToManyRelationship>filter(_filter_4, _function_2);
          final Function1<OneToManyRelationship,Boolean> _function_3 = new Function1<OneToManyRelationship,Boolean>() {
              public Boolean apply(final OneToManyRelationship e) {
                Entity _source = e.getSource();
                Models _container = _source.getContainer();
                Application _application = _container.getApplication();
                boolean _equals = Objects.equal(_application, app);
                return Boolean.valueOf(_equals);
              }
            };
          Iterable<OneToManyRelationship> _filter_6 = IterableExtensions.<OneToManyRelationship>filter(_filter_5, _function_3);
          for(final OneToManyRelationship relation_2 : _filter_6) {
            CharSequence _exampleRowAssignmentIncoming = this.exampleRowAssignmentIncoming(relation_2, entityName, number);
            _builder.append(_exampleRowAssignmentIncoming, "");
          }
        }
        _builder.newLineIfNotEmpty();
        {
          boolean _isCategorisable_1 = it.isCategorisable();
          if (_isCategorisable_1) {
            _builder.append("// create category assignment");
            _builder.newLine();
            _builder.append("$");
            _builder.append(entityName, "");
            _builder.append(number, "");
            _builder.append("->getCategories()->add(new \\");
            String _appName = this._utils.appName(app);
            _builder.append(_appName, "");
            {
              boolean _targets_1 = this._utils.targets(app, "1.3.5");
              if (_targets_1) {
                _builder.append("_Entity_");
                String _name_1 = it.getName();
                String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(_name_1);
                _builder.append(_formatForCodeCapital, "");
                _builder.append("Category");
              } else {
                _builder.append("\\Entity\\");
                String _name_2 = it.getName();
                String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(_name_2);
                _builder.append(_formatForCodeCapital_1, "");
                _builder.append("CategoryEntity");
              }
            }
            _builder.append("($categoryRegistryIdsPerEntity[\'");
            String _name_3 = it.getName();
            String _formatForCode = this._formattingExtensions.formatForCode(_name_3);
            _builder.append(_formatForCode, "");
            _builder.append("\'], $category, $");
            _builder.append(entityName, "");
            _builder.append(number, "");
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
            _builder.append(entityName, "");
            _builder.append(number, "");
            _builder.append("->setAttribute(\'field1\', \'first value\');");
            _builder.newLineIfNotEmpty();
            _builder.append("$");
            _builder.append(entityName, "");
            _builder.append(number, "");
            _builder.append("->setAttribute(\'field2\', \'second value\');");
            _builder.newLineIfNotEmpty();
            _builder.append("$");
            _builder.append(entityName, "");
            _builder.append(number, "");
            _builder.append("->setAttribute(\'field3\', \'third value\');");
            _builder.newLineIfNotEmpty();
          }
        }
        {
          boolean _isMetaData = it.isMetaData();
          if (_isMetaData) {
            _builder.append("// create meta data assignment");
            _builder.newLine();
            {
              boolean _targets_2 = this._utils.targets(app, "1.3.5");
              if (_targets_2) {
                _builder.append("$metaDataEntityClass = $this->name . \'_Entity_");
                String _name_4 = it.getName();
                String _formatForCodeCapital_2 = this._formattingExtensions.formatForCodeCapital(_name_4);
                _builder.append(_formatForCodeCapital_2, "");
                _builder.append("MetaData\';");
                _builder.newLineIfNotEmpty();
              } else {
                _builder.append("$metaDataEntityClass = \'\\\\\' . $this->name . \'\\\\Entity\\\\");
                String _name_5 = it.getName();
                String _formatForCodeCapital_3 = this._formattingExtensions.formatForCodeCapital(_name_5);
                _builder.append(_formatForCodeCapital_3, "");
                _builder.append("MetaDataEntity\';");
                _builder.newLineIfNotEmpty();
              }
            }
            _builder.append("$metaData = new $metaDataEntityClass($entity);");
            _builder.newLine();
            _builder.newLine();
            _builder.append("$metaData->setTitle($this->__(\'Example title\'));");
            _builder.newLine();
            _builder.append("$metaData->setAuthor($this->__(\'Example author\'));");
            _builder.newLine();
            _builder.append("$metaData->setSubject($this->__(\'Example subject\'));");
            _builder.newLine();
            _builder.append("$metaData->setKeywords($this->__(\'Example keywords, one, two, three\'));");
            _builder.newLine();
            _builder.append("$metaData->setDescription($this->__(\'Example description\'));");
            _builder.newLine();
            _builder.append("$metaData->setPublisher($this->__(\'Example publisher\'));");
            _builder.newLine();
            _builder.append("$metaData->setContributor($this->__(\'Example contributor\'));");
            _builder.newLine();
            _builder.append("$metaData->setPublisher($this->__(\'Example publisher\'));");
            _builder.newLine();
            _builder.append("$metaData->setPublisher($this->__(\'Example publisher\'));");
            _builder.newLine();
            _builder.append("$metaData->setPublisher($this->__(\'Example publisher\'));");
            _builder.newLine();
            _builder.append("$metaData->setPublisher($this->__(\'Example publisher\'));");
            _builder.newLine();
            _builder.newLine();
            _builder.append("$");
            _builder.append(entityName, "");
            _builder.append(number, "");
            _builder.append("->setMetadata($metaData);");
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
  
  private CharSequence persistExampleObjects(final Models it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("// execute the workflow action for each entity");
    _builder.newLine();
    _builder.append("$action = \'submit\';");
    _builder.newLine();
    _builder.append("$workflowHelper = new ");
    {
      Application _application = it.getApplication();
      boolean _targets = this._utils.targets(_application, "1.3.5");
      if (_targets) {
        Application _application_1 = it.getApplication();
        String _appName = this._utils.appName(_application_1);
        _builder.append(_appName, "");
        _builder.append("_Util_Workflow");
      } else {
        _builder.append("\\");
        Application _application_2 = it.getApplication();
        String _appName_1 = this._utils.appName(_application_2);
        _builder.append(_appName_1, "");
        _builder.append("\\Util\\WorkflowUtil");
      }
    }
    _builder.append("($this->serviceManager");
    {
      Application _application_3 = it.getApplication();
      boolean _targets_1 = this._utils.targets(_application_3, "1.3.5");
      boolean _not = (!_targets_1);
      if (_not) {
        _builder.append(", ModUtil::getModule($this->name)");
      }
    }
    _builder.append(");");
    _builder.newLineIfNotEmpty();
    _builder.append("try {");
    _builder.newLine();
    _builder.append("    ");
    {
      EList<Entity> _entities = it.getEntities();
      for(final Entity entity : _entities) {
        Application _application_4 = it.getApplication();
        CharSequence _persistEntities = this.persistEntities(entity, _application_4);
        _builder.append(_persistEntities, "    ");
      }
    }
    _builder.newLineIfNotEmpty();
    _builder.append("} catch(\\Exception $e) {");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("LogUtil::registerError($this->__(\'Sorry, but an unknown error occured during example data creation. Possibly not all data could be created properly!\'));");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence persistEntities(final Entity it, final Application app) {
    StringConcatenation _builder = new StringConcatenation();
    Models _container = it.getContainer();
    int _numExampleRows = _container.getNumExampleRows();
    ArrayList<Integer> exampleNumbers = this._controllerExtensions.getListForCounter(Integer.valueOf(_numExampleRows));
    _builder.newLineIfNotEmpty();
    {
      for(final Integer number : exampleNumbers) {
        _builder.append("$success = $workflowHelper->executeAction($");
        String _name = it.getName();
        String _formatForCode = this._formattingExtensions.formatForCode(_name);
        _builder.append(_formatForCode, "");
        _builder.append(number, "");
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
            String _name = pkField.getName();
            String _formatForCode = this._formattingExtensions.formatForCode(_name);
            _builder.append(_formatForCode, "");
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
        EList<Relationship> _incoming = it.getIncoming();
        Iterable<JoinRelationship> _filter = Iterables.<JoinRelationship>filter(_incoming, JoinRelationship.class);
        final Function1<JoinRelationship,Boolean> _function = new Function1<JoinRelationship,Boolean>() {
            public Boolean apply(final JoinRelationship e) {
              boolean _isIndexed = ExampleData.this._modelJoinExtensions.isIndexed(e);
              return Boolean.valueOf(_isIndexed);
            }
          };
        Iterable<JoinRelationship> _filter_1 = IterableExtensions.<JoinRelationship>filter(_filter, _function);
        final JoinRelationship indexRelation = IterableExtensions.<JoinRelationship>head(_filter_1);
        _builder.newLineIfNotEmpty();
        final String sourceAlias = this._namingExtensions.getRelationAliasName(indexRelation, Boolean.valueOf(false));
        _builder.newLineIfNotEmpty();
        final String indexBy = this._modelJoinExtensions.getIndexByField(indexRelation);
        _builder.newLineIfNotEmpty();
        Iterable<DerivedField> _derivedFields = this._modelExtensions.getDerivedFields(it);
        final Function1<DerivedField,Boolean> _function_1 = new Function1<DerivedField,Boolean>() {
            public Boolean apply(final DerivedField e) {
              String _name = e.getName();
              boolean _equals = Objects.equal(_name, indexBy);
              return Boolean.valueOf(_equals);
            }
          };
        final DerivedField indexByField = IterableExtensions.<DerivedField>findFirst(_derivedFields, _function_1);
        _builder.newLineIfNotEmpty();
        Object _exampleRowsConstructorArgument = this.exampleRowsConstructorArgument(indexByField, number);
        _builder.append(_exampleRowsConstructorArgument, "");
        _builder.append(", $");
        String _formatForCode = this._formattingExtensions.formatForCode(sourceAlias);
        _builder.append(_formatForCode, "");
        _builder.append(number, "");
        CharSequence _exampleRowsConstructorArgumentsDefault = this.exampleRowsConstructorArgumentsDefault(it, Boolean.valueOf(true), number);
        _builder.append(_exampleRowsConstructorArgumentsDefault, "");
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
                  _builder.append(_exampleRowsConstructorArgumentsAggregate, "");
                }
              }
              CharSequence _exampleRowsConstructorArgumentsDefault_1 = this.exampleRowsConstructorArgumentsDefault(it, Boolean.valueOf(true), number);
              _builder.append(_exampleRowsConstructorArgumentsDefault_1, "");
              _builder.newLineIfNotEmpty();
            }
          }
        } else {
          CharSequence _exampleRowsConstructorArgumentsDefault_2 = this.exampleRowsConstructorArgumentsDefault(it, Boolean.valueOf(false), number);
          _builder.append(_exampleRowsConstructorArgumentsDefault_2, "");
          _builder.newLineIfNotEmpty();
        }
      }
    }
    return _builder;
  }
  
  private Object exampleRowsConstructorArgument(final DerivedField it, final Integer number) {
    Object _switchResult = null;
    boolean _matched = false;
    if (!_matched) {
      if (it instanceof IntegerField) {
        final IntegerField _integerField = (IntegerField)it;
        _matched=true;
        Object _xifexpression = null;
        String _defaultValue = _integerField.getDefaultValue();
        int _length = _defaultValue.length();
        boolean _greaterThan = (_length > 0);
        if (_greaterThan) {
          String _defaultValue_1 = _integerField.getDefaultValue();
          _xifexpression = _defaultValue_1;
        } else {
          _xifexpression = number;
        }
        _switchResult = _xifexpression;
      }
    }
    if (!_matched) {
      String _xifexpression = null;
      String _defaultValue = it.getDefaultValue();
      int _length = _defaultValue.length();
      boolean _greaterThan = (_length > 0);
      if (_greaterThan) {
        String _defaultValue_1 = it.getDefaultValue();
        _xifexpression = _defaultValue_1;
      } else {
        String _name = it.getName();
        String _formatForDisplayCapital = this._formattingExtensions.formatForDisplayCapital(_name);
        String _plus = (_formatForDisplayCapital + " ");
        String _plus_1 = (_plus + number);
        _xifexpression = _plus_1;
      }
      String _plus_2 = ("\'" + _xifexpression);
      String _plus_3 = (_plus_2 + "\'");
      _switchResult = _plus_3;
    }
    return _switchResult;
  }
  
  private CharSequence exampleRowsConstructorArgumentsAggregate(final OneToManyRelationship it, final Integer number) {
    StringConcatenation _builder = new StringConcatenation();
    Entity _source = it.getSource();
    Iterable<IntegerField> _aggregateFields = this._modelExtensions.getAggregateFields(_source);
    IntegerField _head = IterableExtensions.<IntegerField>head(_aggregateFields);
    final DerivedField targetField = this._modelJoinExtensions.getAggregateTargetField(_head);
    _builder.newLineIfNotEmpty();
    _builder.append("$");
    String _relationAliasName = this._namingExtensions.getRelationAliasName(it, Boolean.valueOf(false));
    _builder.append(_relationAliasName, "");
    _builder.append(number, "");
    _builder.append(", ");
    {
      boolean _and = false;
      String _defaultValue = targetField.getDefaultValue();
      boolean _notEquals = (!Objects.equal(_defaultValue, ""));
      if (!_notEquals) {
        _and = false;
      } else {
        String _defaultValue_1 = targetField.getDefaultValue();
        boolean _notEquals_1 = (!Objects.equal(_defaultValue_1, "0"));
        _and = (_notEquals && _notEquals_1);
      }
      if (_and) {
        String _defaultValue_2 = targetField.getDefaultValue();
        _builder.append(_defaultValue_2, "");
      } else {
        _builder.append(number, "");
      }
    }
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence exampleRowAssignment(final DerivedField it, final Entity dataEntity, final String entityName, final Integer number) {
    CharSequence _switchResult = null;
    boolean _matched = false;
    if (!_matched) {
      if (it instanceof IntegerField) {
        final IntegerField _integerField = (IntegerField)it;
        _matched=true;
        StringConcatenation _builder = new StringConcatenation();
        {
          String _aggregateFor = _integerField.getAggregateFor();
          int _length = _aggregateFor.length();
          boolean _equals = (_length == 0);
          if (_equals) {
            _builder.append("$");
            _builder.append(entityName, "");
            _builder.append(number, "");
            _builder.append("->set");
            String _name = _integerField.getName();
            String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(_name);
            _builder.append(_formatForCodeCapital, "");
            _builder.append("(");
            Object _exampleRowValue = this.exampleRowValue(_integerField, dataEntity, number);
            _builder.append(_exampleRowValue, "");
            _builder.append(");");
            _builder.newLineIfNotEmpty();
          }
        }
        _switchResult = _builder;
      }
    }
    if (!_matched) {
      if (it instanceof UploadField) {
        final UploadField _uploadField = (UploadField)it;
        _matched=true;
        _switchResult = "";
      }
    }
    if (!_matched) {
      StringConcatenation _builder = new StringConcatenation();
      _builder.append("$");
      _builder.append(entityName, "");
      _builder.append(number, "");
      _builder.append("->set");
      String _name = it.getName();
      String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(_name);
      _builder.append(_formatForCodeCapital, "");
      _builder.append("(");
      Object _exampleRowValue = this.exampleRowValue(it, dataEntity, number);
      _builder.append(_exampleRowValue, "");
      _builder.append(");");
      _builder.newLineIfNotEmpty();
      _switchResult = _builder;
    }
    return _switchResult;
  }
  
  private CharSequence exampleRowAssignmentOutgoing(final JoinRelationship it, final String entityName, final Integer number) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("$");
    _builder.append(entityName, "");
    _builder.append(number, "");
    _builder.append("->set");
    String _relationAliasName = this._namingExtensions.getRelationAliasName(it, Boolean.valueOf(true));
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(_relationAliasName);
    _builder.append(_formatForCodeCapital, "");
    _builder.append("($");
    Entity _target = it.getTarget();
    String _name = _target.getName();
    String _formatForCode = this._formattingExtensions.formatForCode(_name);
    _builder.append(_formatForCode, "");
    _builder.append(number, "");
    _builder.append(");");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence exampleRowAssignmentIncoming(final JoinRelationship it, final String entityName, final Integer number) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("$");
    _builder.append(entityName, "");
    _builder.append(number, "");
    _builder.append("->set");
    String _relationAliasName = this._namingExtensions.getRelationAliasName(it, Boolean.valueOf(false));
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(_relationAliasName);
    _builder.append(_formatForCodeCapital, "");
    _builder.append("($");
    Entity _source = it.getSource();
    String _name = _source.getName();
    String _formatForCode = this._formattingExtensions.formatForCode(_name);
    _builder.append(_formatForCode, "");
    _builder.append(number, "");
    _builder.append(");");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence exampleRowValueNumber(final DerivedField it, final Entity dataEntity, final Integer number) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append(number, "");
    return _builder;
  }
  
  private CharSequence exampleRowValueTextLength(final DerivedField it, final Entity dataEntity, final Integer number, final Integer maxLength) {
    StringConcatenation _builder = new StringConcatenation();
    {
      Entity _entity = it.getEntity();
      String _name = _entity.getName();
      String _formatForDisplayCapital = this._formattingExtensions.formatForDisplayCapital(_name);
      int _length = _formatForDisplayCapital.length();
      int _plus = (_length + 4);
      String _name_1 = it.getName();
      String _formatForDisplay = this._formattingExtensions.formatForDisplay(_name_1);
      int _length_1 = _formatForDisplay.length();
      int _plus_1 = (_plus + _length_1);
      boolean _greaterEqualsThan = ((maxLength).intValue() >= _plus_1);
      if (_greaterEqualsThan) {
        _builder.append("\'");
        String _name_2 = dataEntity.getName();
        String _formatForDisplayCapital_1 = this._formattingExtensions.formatForDisplayCapital(_name_2);
        _builder.append(_formatForDisplayCapital_1, "");
        _builder.append(" ");
        String _name_3 = it.getName();
        String _formatForDisplay_1 = this._formattingExtensions.formatForDisplay(_name_3);
        _builder.append(_formatForDisplay_1, "");
        _builder.append(" ");
        _builder.append(number, "");
        _builder.append("\'");
      } else {
        boolean _and = false;
        boolean _isUnique = it.isUnique();
        boolean _not = (!_isUnique);
        if (!_not) {
          _and = false;
        } else {
          String _name_4 = it.getName();
          String _formatForDisplay_2 = this._formattingExtensions.formatForDisplay(_name_4);
          int _length_2 = _formatForDisplay_2.length();
          int _plus_2 = (4 + _length_2);
          boolean _greaterEqualsThan_1 = ((maxLength).intValue() >= _plus_2);
          _and = (_not && _greaterEqualsThan_1);
        }
        if (_and) {
          _builder.newLineIfNotEmpty();
          _builder.append("\'");
          String _name_5 = it.getName();
          String _formatForDisplay_3 = this._formattingExtensions.formatForDisplay(_name_5);
          _builder.append(_formatForDisplay_3, "");
          _builder.append(" ");
          _builder.append(number, "");
          _builder.append("\'");
        } else {
          boolean _and_1 = false;
          boolean _lessThan = ((maxLength).intValue() < 4);
          if (!_lessThan) {
            _and_1 = false;
          } else {
            boolean _greaterThan = ((maxLength).intValue() > 1);
            _and_1 = (_lessThan && _greaterThan);
          }
          if (_and_1) {
            _builder.newLineIfNotEmpty();
            _builder.append("\'");
            String _name_6 = dataEntity.getName();
            int _length_3 = _name_6.length();
            int _plus_3 = ((number).intValue() + _length_3);
            EList<EntityField> _fields = dataEntity.getFields();
            int _size = _fields.size();
            int _plus_4 = (_plus_3 + _size);
            _builder.append(_plus_4, "");
            _builder.append("\'");
          } else {
            boolean _equals = ((maxLength).intValue() == 1);
            if (_equals) {
              _builder.newLineIfNotEmpty();
              _builder.append("\'");
              int _xifexpression = (int) 0;
              boolean _greaterThan_1 = ((number).intValue() > 9);
              if (_greaterThan_1) {
                _xifexpression = 1;
              } else {
                _xifexpression = (number).intValue();
              }
              _builder.append(_xifexpression, "");
              _builder.append("\'");
            } else {
              _builder.newLineIfNotEmpty();
              _builder.append("substr(\'");
              String _name_7 = dataEntity.getName();
              String _formatForDisplayCapital_2 = this._formattingExtensions.formatForDisplayCapital(_name_7);
              _builder.append(_formatForDisplayCapital_2, "");
              _builder.append(" ");
              String _name_8 = it.getName();
              String _formatForDisplay_4 = this._formattingExtensions.formatForDisplay(_name_8);
              _builder.append(_formatForDisplay_4, "");
              _builder.append("\', 0, ");
              int _minus = ((maxLength).intValue() - 2);
              _builder.append(_minus, "");
              _builder.append(") . \' ");
              _builder.append(number, "");
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
    CharSequence _switchResult = null;
    boolean _matched = false;
    if (!_matched) {
      if (it instanceof StringField) {
        final StringField _stringField = (StringField)it;
        _matched=true;
        int _length = _stringField.getLength();
        CharSequence _exampleRowValueTextLength = this.exampleRowValueTextLength(_stringField, dataEntity, number, Integer.valueOf(_length));
        _switchResult = _exampleRowValueTextLength;
      }
    }
    if (!_matched) {
      if (it instanceof TextField) {
        final TextField _textField = (TextField)it;
        _matched=true;
        int _length = _textField.getLength();
        CharSequence _exampleRowValueTextLength = this.exampleRowValueTextLength(_textField, dataEntity, number, Integer.valueOf(_length));
        _switchResult = _exampleRowValueTextLength;
      }
    }
    if (!_matched) {
      if (it instanceof EmailField) {
        final EmailField _emailField = (EmailField)it;
        _matched=true;
        int _length = _emailField.getLength();
        CharSequence _exampleRowValueTextLength = this.exampleRowValueTextLength(_emailField, dataEntity, number, Integer.valueOf(_length));
        _switchResult = _exampleRowValueTextLength;
      }
    }
    if (!_matched) {
      if (it instanceof UrlField) {
        final UrlField _urlField = (UrlField)it;
        _matched=true;
        int _length = _urlField.getLength();
        CharSequence _exampleRowValueTextLength = this.exampleRowValueTextLength(_urlField, dataEntity, number, Integer.valueOf(_length));
        _switchResult = _exampleRowValueTextLength;
      }
    }
    if (!_matched) {
      Entity _entity = it.getEntity();
      String _name = _entity.getName();
      String _formatForDisplayCapital = this._formattingExtensions.formatForDisplayCapital(_name);
      String _plus = ("\'" + _formatForDisplayCapital);
      String _plus_1 = (_plus + " ");
      String _name_1 = it.getName();
      String _formatForDisplay = this._formattingExtensions.formatForDisplay(_name_1);
      String _plus_2 = (_plus_1 + _formatForDisplay);
      String _plus_3 = (_plus_2 + " ");
      String _plus_4 = (_plus_3 + number);
      String _plus_5 = (_plus_4 + "\'");
      _switchResult = _plus_5;
    }
    return _switchResult;
  }
  
  private Object exampleRowValue(final DerivedField it, final Entity dataEntity, final Integer number) {
    Object _switchResult = null;
    boolean _matched = false;
    if (!_matched) {
      if (it instanceof BooleanField) {
        final BooleanField _booleanField = (BooleanField)it;
        _matched=true;
        String _xifexpression = null;
        boolean _or = false;
        String _defaultValue = _booleanField.getDefaultValue();
        boolean _equals = Objects.equal(_defaultValue, Boolean.valueOf(true));
        if (_equals) {
          _or = true;
        } else {
          String _defaultValue_1 = _booleanField.getDefaultValue();
          boolean _equals_1 = Objects.equal(_defaultValue_1, "true");
          _or = (_equals || _equals_1);
        }
        if (_or) {
          _xifexpression = "true";
        } else {
          _xifexpression = "false";
        }
        _switchResult = _xifexpression;
      }
    }
    if (!_matched) {
      if (it instanceof IntegerField) {
        final IntegerField _integerField = (IntegerField)it;
        _matched=true;
        CharSequence _exampleRowValueNumber = this.exampleRowValueNumber(_integerField, dataEntity, number);
        _switchResult = _exampleRowValueNumber;
      }
    }
    if (!_matched) {
      if (it instanceof DecimalField) {
        final DecimalField _decimalField = (DecimalField)it;
        _matched=true;
        CharSequence _exampleRowValueNumber = this.exampleRowValueNumber(_decimalField, dataEntity, number);
        _switchResult = _exampleRowValueNumber;
      }
    }
    if (!_matched) {
      if (it instanceof StringField) {
        final StringField _stringField = (StringField)it;
        _matched=true;
        CharSequence _xifexpression = null;
        boolean _or = false;
        boolean _isCountry = _stringField.isCountry();
        if (_isCountry) {
          _or = true;
        } else {
          boolean _isLanguage = _stringField.isLanguage();
          _or = (_isCountry || _isLanguage);
        }
        if (_or) {
          _xifexpression = "ZLanguage::getLanguageCode()";
        } else {
          CharSequence _xifexpression_1 = null;
          boolean _isHtmlcolour = _stringField.isHtmlcolour();
          if (_isHtmlcolour) {
            _xifexpression_1 = "\'#ff6600\'";
          } else {
            CharSequence _exampleRowValueText = this.exampleRowValueText(_stringField, dataEntity, number);
            _xifexpression_1 = _exampleRowValueText;
          }
          _xifexpression = _xifexpression_1;
        }
        _switchResult = _xifexpression;
      }
    }
    if (!_matched) {
      if (it instanceof TextField) {
        final TextField _textField = (TextField)it;
        _matched=true;
        CharSequence _exampleRowValueText = this.exampleRowValueText(_textField, dataEntity, number);
        _switchResult = _exampleRowValueText;
      }
    }
    if (!_matched) {
      if (it instanceof EmailField) {
        final EmailField _emailField = (EmailField)it;
        _matched=true;
        Entity _entity = _emailField.getEntity();
        Models _container = _entity.getContainer();
        Application _application = _container.getApplication();
        String _email = _application.getEmail();
        String _plus = ("\'" + _email);
        String _plus_1 = (_plus + "\'");
        _switchResult = _plus_1;
      }
    }
    if (!_matched) {
      if (it instanceof UrlField) {
        final UrlField _urlField = (UrlField)it;
        _matched=true;
        Entity _entity = _urlField.getEntity();
        Models _container = _entity.getContainer();
        Application _application = _container.getApplication();
        String _url = _application.getUrl();
        String _plus = ("\'" + _url);
        String _plus_1 = (_plus + "\'");
        _switchResult = _plus_1;
      }
    }
    if (!_matched) {
      if (it instanceof UploadField) {
        final UploadField _uploadField = (UploadField)it;
        _matched=true;
        CharSequence _exampleRowValueText = this.exampleRowValueText(_uploadField, dataEntity, number);
        _switchResult = _exampleRowValueText;
      }
    }
    if (!_matched) {
      if (it instanceof UserField) {
        final UserField _userField = (UserField)it;
        _matched=true;
        _switchResult = Integer.valueOf(2);
      }
    }
    if (!_matched) {
      if (it instanceof ArrayField) {
        final ArrayField _arrayField = (ArrayField)it;
        _matched=true;
        CharSequence _exampleRowValueNumber = this.exampleRowValueNumber(_arrayField, dataEntity, number);
        _switchResult = _exampleRowValueNumber;
      }
    }
    if (!_matched) {
      if (it instanceof ObjectField) {
        final ObjectField _objectField = (ObjectField)it;
        _matched=true;
        CharSequence _exampleRowValueText = this.exampleRowValueText(_objectField, dataEntity, number);
        _switchResult = _exampleRowValueText;
      }
    }
    if (!_matched) {
      if (it instanceof DatetimeField) {
        final DatetimeField _datetimeField = (DatetimeField)it;
        _matched=true;
        StringConcatenation _builder = new StringConcatenation();
        {
          boolean _isPast = _datetimeField.isPast();
          if (_isPast) {
            _builder.append("$dtPast");
          } else {
            boolean _isFuture = _datetimeField.isFuture();
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
        final DateField _dateField = (DateField)it;
        _matched=true;
        StringConcatenation _builder = new StringConcatenation();
        {
          boolean _isPast = _dateField.isPast();
          if (_isPast) {
            _builder.append("$dPast");
          } else {
            boolean _isFuture = _dateField.isFuture();
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
        final TimeField _timeField = (TimeField)it;
        _matched=true;
        StringConcatenation _builder = new StringConcatenation();
        {
          boolean _isPast = _timeField.isPast();
          if (_isPast) {
            _builder.append("$tPast");
          } else {
            boolean _isFuture = _timeField.isFuture();
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
        final FloatField _floatField = (FloatField)it;
        _matched=true;
        CharSequence _exampleRowValueNumber = this.exampleRowValueNumber(_floatField, dataEntity, number);
        _switchResult = _exampleRowValueNumber;
      }
    }
    if (!_matched) {
      if (it instanceof ListField) {
        final ListField _listField = (ListField)it;
        _matched=true;
        StringConcatenation _builder = new StringConcatenation();
        _builder.append("\'");
        {
          boolean _isMultiple = _listField.isMultiple();
          if (_isMultiple) {
            _builder.append("###");
            {
              Iterable<ListFieldItem> _defaultItems = this._modelExtensions.getDefaultItems(_listField);
              boolean _hasElements = false;
              for(final ListFieldItem item : _defaultItems) {
                if (!_hasElements) {
                  _hasElements = true;
                } else {
                  _builder.appendImmediate("###", "");
                }
                String _exampleRowValue = this.exampleRowValue(item);
                _builder.append(_exampleRowValue, "");
              }
            }
            _builder.append("###");
          } else {
            {
              Iterable<ListFieldItem> _defaultItems_1 = this._modelExtensions.getDefaultItems(_listField);
              for(final ListFieldItem item_1 : _defaultItems_1) {
                String _exampleRowValue_1 = this.exampleRowValue(item_1);
                _builder.append(_exampleRowValue_1, "");
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
      String _value = it.getValue();
      _xifexpression = _value;
    } else {
      _xifexpression = "";
    }
    return _xifexpression;
  }
}

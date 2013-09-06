package org.zikula.modulestudio.generator.cartridges.zclassic.models;

import com.google.inject.Inject;
import de.guite.modulestudio.metamodel.modulestudio.AbstractDateField;
import de.guite.modulestudio.metamodel.modulestudio.AbstractIntegerField;
import de.guite.modulestudio.metamodel.modulestudio.Application;
import de.guite.modulestudio.metamodel.modulestudio.ArrayField;
import de.guite.modulestudio.metamodel.modulestudio.BooleanField;
import de.guite.modulestudio.metamodel.modulestudio.DecimalField;
import de.guite.modulestudio.metamodel.modulestudio.DerivedField;
import de.guite.modulestudio.metamodel.modulestudio.EmailField;
import de.guite.modulestudio.metamodel.modulestudio.Entity;
import de.guite.modulestudio.metamodel.modulestudio.EntityField;
import de.guite.modulestudio.metamodel.modulestudio.FloatField;
import de.guite.modulestudio.metamodel.modulestudio.ListField;
import de.guite.modulestudio.metamodel.modulestudio.Models;
import de.guite.modulestudio.metamodel.modulestudio.StringField;
import de.guite.modulestudio.metamodel.modulestudio.TextField;
import de.guite.modulestudio.metamodel.modulestudio.UploadField;
import org.eclipse.emf.common.util.EList;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class EventListener {
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
  
  /**
   * Entry point for entity lifecycle callback methods.
   */
  public CharSequence generateBase(final Entity it) {
    CharSequence _stubMethodsForNowBaseImpl = this.stubMethodsForNowBaseImpl(it);
    return _stubMethodsForNowBaseImpl;
  }
  
  public CharSequence generateImpl(final Entity it) {
    CharSequence _stubMethodsForNowImpl = this.stubMethodsForNowImpl(it);
    return _stubMethodsForNowImpl;
  }
  
  /**
   * def private dispatch eventListenerBaseImpl(EntityEventListener it) {
   * }
   * def private dispatch eventListenerBaseImpl(PreProcess it) {
   * }
   * def private dispatch eventListenerBaseImpl(PostProcess it) {
   * }
   * 
   * def private dispatch eventListenerImpl(EntityEventListener it) {
   * }
   * def private dispatch eventListenerImpl(PreProcess it) {
   * }
   * def private dispatch eventListenerImpl(PostProcess it) {
   * }
   */
  private CharSequence stubMethodsForNowBaseImpl(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Post-Process the data after the entity has been constructed by the entity manager.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* The event happens after the entity has been loaded from database or after a refresh call.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Restrictions:");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*     - no access to entity manager or unit of work apis");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*     - no access to associations (not initialised yet)");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @see ");
    String _entityClassName = this._namingExtensions.entityClassName(it, "", Boolean.valueOf(false));
    _builder.append(_entityClassName, " ");
    _builder.append("::postLoadCallback()");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("* @return boolean true if completed successfully else false.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected function performPostLoadCallback()");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// echo \'loaded a record ...\';");
    _builder.newLine();
    _builder.append("    ");
    CharSequence _postLoadImpl = this.postLoadImpl(it);
    _builder.append(_postLoadImpl, "    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$this->prepareItemActions();");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return true;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Pre-Process the data prior to an insert operation.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* The event happens before the entity managers persist operation is executed for this entity.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Restrictions:");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*     - no access to entity manager or unit of work apis");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*     - no identifiers available if using an identity generator like sequences");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*     - Doctrine won\'t recognize changes on relations which are done here");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*       if this method is called by cascade persist");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*     - no creation of other entities allowed");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @see ");
    String _entityClassName_1 = this._namingExtensions.entityClassName(it, "", Boolean.valueOf(false));
    _builder.append(_entityClassName_1, " ");
    _builder.append("::prePersistCallback()");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("* @return boolean true if completed successfully else false.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected function performPrePersistCallback()");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// echo \'inserting a record ...\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$this->validate();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return true;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Post-Process the data after an insert operation.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* The event happens after the entity has been made persistant.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Will be called after the database insert operations.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* The generated primary key values are available.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Restrictions:");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*     - no access to entity manager or unit of work apis");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @see ");
    String _entityClassName_2 = this._namingExtensions.entityClassName(it, "", Boolean.valueOf(false));
    _builder.append(_entityClassName_2, " ");
    _builder.append("::postPersistCallback()");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("* @return boolean true if completed successfully else false.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected function performPostPersistCallback()");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// echo \'inserted a record ...\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return true;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Pre-Process the data prior a delete operation.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* The event happens before the entity managers remove operation is executed for this entity.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Restrictions:");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*     - no access to entity manager or unit of work apis");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*     - will not be called for a DQL DELETE statement");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @see ");
    String _entityClassName_3 = this._namingExtensions.entityClassName(it, "", Boolean.valueOf(false));
    _builder.append(_entityClassName_3, " ");
    _builder.append("::preRemoveCallback()");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("* @return boolean true if completed successfully else false.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected function performPreRemoveCallback()");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// delete workflow for this entity");
    _builder.newLine();
    {
      Models _container = it.getContainer();
      Application _application = _container.getApplication();
      boolean _targets = this._utils.targets(_application, "1.3.5");
      boolean _not = (!_targets);
      if (_not) {
        _builder.append("    ");
        _builder.append("$workflowHelper = new WorkflowUtil(ServiceUtil::getManager());");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$workflowHelper->normaliseWorkflowData($this);");
        _builder.newLine();
      }
    }
    _builder.append("    ");
    _builder.append("$workflow = $this[\'__WORKFLOW__\'];");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($workflow[\'id\'] > 0) {");
    _builder.newLine();
    {
      Models _container_1 = it.getContainer();
      Application _application_1 = _container_1.getApplication();
      boolean _targets_1 = this._utils.targets(_application_1, "1.3.5");
      if (_targets_1) {
        _builder.append("        ");
        _builder.append("$result = (bool) DBUtil::deleteObjectByID(\'workflows\', $workflow[\'id\']);");
        _builder.newLine();
      } else {
        _builder.append("        ");
        _builder.append("$serviceManager = ServiceUtil::getManager();");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("$entityManager = $serviceManager->getService(\'doctrine.entitymanager\');");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("$result = true;");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("try {");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("$workflow = $entityManager->find(\'Zikula\\Core\\Doctrine\\Entity\\WorkflowEntity\', $workflow[\'id\']);");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("$entityManager->remove($workflow);");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("$entityManager->flush();");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("} catch (\\Exception $e) {");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("$result = false;");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("}");
        _builder.newLine();
      }
    }
    _builder.append("        ");
    _builder.append("if ($result === false) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$dom = ZLanguage::getModuleDomain(\'");
    Models _container_2 = it.getContainer();
    Application _application_2 = _container_2.getApplication();
    String _appName = this._utils.appName(_application_2);
    _builder.append(_appName, "            ");
    _builder.append("\');");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("return LogUtil::registerError(__(\'Error! Could not remove stored workflow. Deletion has been aborted.\', $dom));");
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
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Post-Process the data after a delete.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* The event happens after the entity has been deleted.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Will be called after the database delete operations.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Restrictions:");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*     - no access to entity manager or unit of work apis");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*     - will not be called for a DQL DELETE statement");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @see ");
    String _entityClassName_4 = this._namingExtensions.entityClassName(it, "", Boolean.valueOf(false));
    _builder.append(_entityClassName_4, " ");
    _builder.append("::postRemoveCallback()");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("* @return boolean true if completed successfully else false.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected function performPostRemoveCallback()");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// echo \'deleted a record ...\';");
    _builder.newLine();
    {
      boolean _hasUploadFieldsEntity = this._modelExtensions.hasUploadFieldsEntity(it);
      if (_hasUploadFieldsEntity) {
        {
          boolean _hasCompositeKeys = this._modelExtensions.hasCompositeKeys(it);
          if (_hasCompositeKeys) {
            _builder.append("    ");
            _builder.append("$objectIds = array();");
            _builder.newLine();
            {
              Iterable<DerivedField> _primaryKeyFields = this._modelExtensions.getPrimaryKeyFields(it);
              for(final DerivedField pkField : _primaryKeyFields) {
                _builder.append("    ");
                _builder.append("$objectIds[] = $this[\'");
                String _name = pkField.getName();
                String _formatForCode = this._formattingExtensions.formatForCode(_name);
                _builder.append(_formatForCode, "    ");
                _builder.append("\'];");
                _builder.newLineIfNotEmpty();
              }
            }
            _builder.append("    ");
            _builder.append("$objectId = implode(\'-\', $objectIds);");
            _builder.newLine();
          } else {
            _builder.append("    ");
            _builder.append("$objectId = $this[\'");
            Iterable<DerivedField> _primaryKeyFields_1 = this._modelExtensions.getPrimaryKeyFields(it);
            DerivedField _head = IterableExtensions.<DerivedField>head(_primaryKeyFields_1);
            String _name_1 = _head.getName();
            String _formatForCode_1 = this._formattingExtensions.formatForCode(_name_1);
            _builder.append(_formatForCode_1, "    ");
            _builder.append("\'];");
            _builder.newLineIfNotEmpty();
          }
        }
        _builder.append("    ");
        _builder.append("// initialise the upload handler");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$uploadManager = new ");
        {
          Models _container_3 = it.getContainer();
          Application _application_3 = _container_3.getApplication();
          boolean _targets_2 = this._utils.targets(_application_3, "1.3.5");
          if (_targets_2) {
            Models _container_4 = it.getContainer();
            Application _application_4 = _container_4.getApplication();
            String _appName_1 = this._utils.appName(_application_4);
            _builder.append(_appName_1, "    ");
            _builder.append("_");
          }
        }
        _builder.append("UploadHandler();");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$uploadFields = array(");
        {
          Iterable<UploadField> _uploadFieldsEntity = this._modelExtensions.getUploadFieldsEntity(it);
          boolean _hasElements = false;
          for(final UploadField uploadField : _uploadFieldsEntity) {
            if (!_hasElements) {
              _hasElements = true;
            } else {
              _builder.appendImmediate(", ", "    ");
            }
            _builder.append("\'");
            String _name_2 = uploadField.getName();
            String _formatForCode_2 = this._formattingExtensions.formatForCode(_name_2);
            _builder.append(_formatForCode_2, "    ");
            _builder.append("\'");
          }
        }
        _builder.append(");");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("foreach ($uploadFields as $uploadField) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("if (empty($this->$uploadField)) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("        ");
        _builder.append("continue;");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("// remove upload file (and image thumbnails)");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("$uploadManager->deleteUploadFile(\'");
        String _name_3 = it.getName();
        String _formatForCode_3 = this._formattingExtensions.formatForCode(_name_3);
        _builder.append(_formatForCode_3, "        ");
        _builder.append("\', $this, $uploadField, $objectId);");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
      }
    }
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return true;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Pre-Process the data prior to an update operation.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* The event happens before the database update operations for the entity data.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Restrictions:");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*     - no access to entity manager or unit of work apis");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*     - will not be called for a DQL UPDATE statement");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*     - changes on associations are not allowed and won\'t be recognized by flush");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*     - changes on properties won\'t be recognized by flush as well");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*     - no creation of other entities allowed");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @see ");
    String _entityClassName_5 = this._namingExtensions.entityClassName(it, "", Boolean.valueOf(false));
    _builder.append(_entityClassName_5, " ");
    _builder.append("::preUpdateCallback()");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("* @return boolean true if completed successfully else false.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected function performPreUpdateCallback()");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// echo \'updating a record ...\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$this->validate();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return true;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Post-Process the data after an update operation.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* The event happens after the database update operations for the entity data.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Restrictions:");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*     - no access to entity manager or unit of work apis");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*     - will not be called for a DQL UPDATE statement");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @see ");
    String _entityClassName_6 = this._namingExtensions.entityClassName(it, "", Boolean.valueOf(false));
    _builder.append(_entityClassName_6, " ");
    _builder.append("::postUpdateCallback()");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("* @return boolean true if completed successfully else false.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected function performPostUpdateCallback()");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// echo \'updated a record ...\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return true;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Pre-Process the data prior to a save operation.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* This combines the PrePersist and PreUpdate events.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* For more information see corresponding callback handlers.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @see ");
    String _entityClassName_7 = this._namingExtensions.entityClassName(it, "", Boolean.valueOf(false));
    _builder.append(_entityClassName_7, " ");
    _builder.append("::preSaveCallback()");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("* @return boolean true if completed successfully else false.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected function performPreSaveCallback()");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// echo \'saving a record ...\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$this->validate();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return true;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Post-Process the data after a save operation.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* This combines the PostPersist and PostUpdate events.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* For more information see corresponding callback handlers.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @see ");
    String _entityClassName_8 = this._namingExtensions.entityClassName(it, "", Boolean.valueOf(false));
    _builder.append(_entityClassName_8, " ");
    _builder.append("::postSaveCallback()");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("* @return boolean true if completed successfully else false.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected function performPostSaveCallback()");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// echo \'saved a record ...\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return true;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence stubMethodsForNowImpl(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Post-Process the data after the entity has been constructed by the entity manager.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @ORM\\PostLoad");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @see ");
    String _entityClassName = this._namingExtensions.entityClassName(it, "", Boolean.valueOf(false));
    _builder.append(_entityClassName, " ");
    _builder.append("::performPostLoadCallback()");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("* @return void.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function postLoadCallback()");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$this->performPostLoadCallback();");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Pre-Process the data prior to an insert operation.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @ORM\\PrePersist");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @see ");
    String _entityClassName_1 = this._namingExtensions.entityClassName(it, "", Boolean.valueOf(false));
    _builder.append(_entityClassName_1, " ");
    _builder.append("::performPrePersistCallback()");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("* @return void.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function prePersistCallback()");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$this->performPrePersistCallback();");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Post-Process the data after an insert operation.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @ORM\\PostPersist");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @see ");
    String _entityClassName_2 = this._namingExtensions.entityClassName(it, "", Boolean.valueOf(false));
    _builder.append(_entityClassName_2, " ");
    _builder.append("::performPostPersistCallback()");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("* @return void.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function postPersistCallback()");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$this->performPostPersistCallback();");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Pre-Process the data prior a delete operation.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @ORM\\PreRemove");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @see ");
    String _entityClassName_3 = this._namingExtensions.entityClassName(it, "", Boolean.valueOf(false));
    _builder.append(_entityClassName_3, " ");
    _builder.append("::performPreRemoveCallback()");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("* @return void.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function preRemoveCallback()");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$this->performPreRemoveCallback();");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Post-Process the data after a delete.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @ORM\\PostRemove");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @see ");
    String _entityClassName_4 = this._namingExtensions.entityClassName(it, "", Boolean.valueOf(false));
    _builder.append(_entityClassName_4, " ");
    _builder.append("::performPostRemoveCallback()");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("* @return void");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function postRemoveCallback()");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$this->performPostRemoveCallback();");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Pre-Process the data prior to an update operation.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @ORM\\PreUpdate");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @see ");
    String _entityClassName_5 = this._namingExtensions.entityClassName(it, "", Boolean.valueOf(false));
    _builder.append(_entityClassName_5, " ");
    _builder.append("::performPreUpdateCallback()");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("* @return void.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function preUpdateCallback()");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$this->performPreUpdateCallback();");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Post-Process the data after an update operation.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @ORM\\PostUpdate");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @see ");
    String _entityClassName_6 = this._namingExtensions.entityClassName(it, "", Boolean.valueOf(false));
    _builder.append(_entityClassName_6, " ");
    _builder.append("::performPostUpdateCallback()");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("* @return void.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function postUpdateCallback()");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$this->performPostUpdateCallback();");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Pre-Process the data prior to a save operation.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @ORM\\PrePersist");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @ORM\\PreUpdate");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @see ");
    String _entityClassName_7 = this._namingExtensions.entityClassName(it, "", Boolean.valueOf(false));
    _builder.append(_entityClassName_7, " ");
    _builder.append("::performPreSaveCallback()");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("* @return void.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function preSaveCallback()");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$this->performPreSaveCallback();");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Post-Process the data after a save operation.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @ORM\\PostPersist");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @ORM\\PostUpdate");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @see ");
    String _entityClassName_8 = this._namingExtensions.entityClassName(it, "", Boolean.valueOf(false));
    _builder.append(_entityClassName_8, " ");
    _builder.append("::performPostSaveCallback()");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("* @return void.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function postSaveCallback()");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$this->performPostSaveCallback();");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence postLoadImpl(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    Models _container = it.getContainer();
    final Application app = _container.getApplication();
    _builder.newLineIfNotEmpty();
    _builder.append("$currentFunc = FormUtil::getPassedValue(\'func\', \'");
    {
      boolean _targets = this._utils.targets(app, "1.3.5");
      if (_targets) {
        _builder.append("main");
      } else {
        _builder.append("index");
      }
    }
    _builder.append("\', \'GETPOST\', FILTER_SANITIZE_STRING);");
    _builder.newLineIfNotEmpty();
    {
      boolean _hasUploadFieldsEntity = this._modelExtensions.hasUploadFieldsEntity(it);
      if (_hasUploadFieldsEntity) {
        _builder.newLine();
        _builder.append("// initialise the upload handler");
        _builder.newLine();
        _builder.append("$uploadManager = new ");
        {
          boolean _targets_1 = this._utils.targets(app, "1.3.5");
          if (_targets_1) {
            String _appName = this._utils.appName(app);
            _builder.append(_appName, "");
            _builder.append("_");
          }
        }
        _builder.append("UploadHandler();");
        _builder.newLineIfNotEmpty();
        _builder.append("$serviceManager = ServiceUtil::getManager();");
        _builder.newLine();
        _builder.append("$controllerHelper = new ");
        {
          boolean _targets_2 = this._utils.targets(app, "1.3.5");
          if (_targets_2) {
            String _appName_1 = this._utils.appName(app);
            _builder.append(_appName_1, "");
            _builder.append("_Util_Controller");
          } else {
            _builder.append("ControllerUtil");
          }
        }
        _builder.append("($serviceManager");
        {
          boolean _targets_3 = this._utils.targets(app, "1.3.5");
          boolean _not = (!_targets_3);
          if (_not) {
            _builder.append(", ModUtil::getModule(\'");
            String _appName_2 = this._utils.appName(app);
            _builder.append(_appName_2, "");
            _builder.append("\')");
          }
        }
        _builder.append(");");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.newLine();
    {
      EList<EntityField> _fields = it.getFields();
      for(final EntityField field : _fields) {
        CharSequence _sanitizeForOutput = this.sanitizeForOutput(field);
        _builder.append(_sanitizeForOutput, "");
      }
    }
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence sanitizeForOutput(final EntityField it) {
    CharSequence _switchResult = null;
    boolean _matched = false;
    if (!_matched) {
      if (it instanceof BooleanField) {
        final BooleanField _booleanField = (BooleanField)it;
        _matched=true;
        StringConcatenation _builder = new StringConcatenation();
        _builder.append("$this[\'");
        String _name = _booleanField.getName();
        String _formatForCode = this._formattingExtensions.formatForCode(_name);
        _builder.append(_formatForCode, "");
        _builder.append("\'] = (bool) $this[\'");
        String _name_1 = _booleanField.getName();
        String _formatForCode_1 = this._formattingExtensions.formatForCode(_name_1);
        _builder.append(_formatForCode_1, "");
        _builder.append("\'];");
        _builder.newLineIfNotEmpty();
        _switchResult = _builder;
      }
    }
    if (!_matched) {
      if (it instanceof AbstractIntegerField) {
        final AbstractIntegerField _abstractIntegerField = (AbstractIntegerField)it;
        _matched=true;
        StringConcatenation _builder = new StringConcatenation();
        _builder.append("$this[\'");
        String _name = _abstractIntegerField.getName();
        String _formatForCode = this._formattingExtensions.formatForCode(_name);
        _builder.append(_formatForCode, "");
        _builder.append("\'] = (int) ((isset($this[\'");
        String _name_1 = _abstractIntegerField.getName();
        String _formatForCode_1 = this._formattingExtensions.formatForCode(_name_1);
        _builder.append(_formatForCode_1, "");
        _builder.append("\']) && !empty($this[\'");
        String _name_2 = _abstractIntegerField.getName();
        String _formatForCode_2 = this._formattingExtensions.formatForCode(_name_2);
        _builder.append(_formatForCode_2, "");
        _builder.append("\'])) ? DataUtil::formatForDisplay($this[\'");
        String _name_3 = _abstractIntegerField.getName();
        String _formatForCode_3 = this._formattingExtensions.formatForCode(_name_3);
        _builder.append(_formatForCode_3, "");
        _builder.append("\']) : 0);");
        _builder.newLineIfNotEmpty();
        _switchResult = _builder;
      }
    }
    if (!_matched) {
      if (it instanceof DecimalField) {
        final DecimalField _decimalField = (DecimalField)it;
        _matched=true;
        StringConcatenation _builder = new StringConcatenation();
        _builder.append("$this[\'");
        String _name = _decimalField.getName();
        String _formatForCode = this._formattingExtensions.formatForCode(_name);
        _builder.append(_formatForCode, "");
        _builder.append("\'] = (float) ((isset($this[\'");
        String _name_1 = _decimalField.getName();
        String _formatForCode_1 = this._formattingExtensions.formatForCode(_name_1);
        _builder.append(_formatForCode_1, "");
        _builder.append("\']) && !empty($this[\'");
        String _name_2 = _decimalField.getName();
        String _formatForCode_2 = this._formattingExtensions.formatForCode(_name_2);
        _builder.append(_formatForCode_2, "");
        _builder.append("\'])) ? DataUtil::formatForDisplay($this[\'");
        String _name_3 = _decimalField.getName();
        String _formatForCode_3 = this._formattingExtensions.formatForCode(_name_3);
        _builder.append(_formatForCode_3, "");
        _builder.append("\']) : 0.00);");
        _builder.newLineIfNotEmpty();
        _switchResult = _builder;
      }
    }
    if (!_matched) {
      if (it instanceof StringField) {
        final StringField _stringField = (StringField)it;
        _matched=true;
        CharSequence _sanitizeForOutputHTML = this.sanitizeForOutputHTML(_stringField);
        _switchResult = _sanitizeForOutputHTML;
      }
    }
    if (!_matched) {
      if (it instanceof TextField) {
        final TextField _textField = (TextField)it;
        _matched=true;
        CharSequence _sanitizeForOutputHTML = this.sanitizeForOutputHTML(_textField);
        _switchResult = _sanitizeForOutputHTML;
      }
    }
    if (!_matched) {
      if (it instanceof EmailField) {
        final EmailField _emailField = (EmailField)it;
        _matched=true;
        CharSequence _sanitizeForOutputHTML = this.sanitizeForOutputHTML(_emailField);
        _switchResult = _sanitizeForOutputHTML;
      }
    }
    if (!_matched) {
      if (it instanceof ListField) {
        final ListField _listField = (ListField)it;
        _matched=true;
        CharSequence _sanitizeForOutputHTMLWithZero = this.sanitizeForOutputHTMLWithZero(_listField);
        _switchResult = _sanitizeForOutputHTMLWithZero;
      }
    }
    if (!_matched) {
      if (it instanceof UploadField) {
        final UploadField _uploadField = (UploadField)it;
        _matched=true;
        CharSequence _sanitizeForOutputUpload = this.sanitizeForOutputUpload(_uploadField);
        _switchResult = _sanitizeForOutputUpload;
      }
    }
    if (!_matched) {
      if (it instanceof ArrayField) {
        final ArrayField _arrayField = (ArrayField)it;
        _matched=true;
        StringConcatenation _builder = new StringConcatenation();
        _builder.append("$this[\'");
        String _name = _arrayField.getName();
        String _formatForCode = this._formattingExtensions.formatForCode(_name);
        _builder.append(_formatForCode, "");
        _builder.append("\'] = ((isset($this[\'");
        String _name_1 = _arrayField.getName();
        String _formatForCode_1 = this._formattingExtensions.formatForCode(_name_1);
        _builder.append(_formatForCode_1, "");
        _builder.append("\']) && is_array($this[\'");
        String _name_2 = _arrayField.getName();
        String _formatForCode_2 = this._formattingExtensions.formatForCode(_name_2);
        _builder.append(_formatForCode_2, "");
        _builder.append("\'])) ? DataUtil::formatForDisplay($this[\'");
        String _name_3 = _arrayField.getName();
        String _formatForCode_3 = this._formattingExtensions.formatForCode(_name_3);
        _builder.append(_formatForCode_3, "");
        _builder.append("\']) : array());");
        _builder.newLineIfNotEmpty();
        _switchResult = _builder;
      }
    }
    if (!_matched) {
      if (it instanceof AbstractDateField) {
        final AbstractDateField _abstractDateField = (AbstractDateField)it;
        _matched=true;
        _switchResult = "";
      }
    }
    if (!_matched) {
      if (it instanceof FloatField) {
        final FloatField _floatField = (FloatField)it;
        _matched=true;
        StringConcatenation _builder = new StringConcatenation();
        _builder.append("$this[\'");
        String _name = _floatField.getName();
        String _formatForCode = this._formattingExtensions.formatForCode(_name);
        _builder.append(_formatForCode, "");
        _builder.append("\'] = (float) ((isset($this[\'");
        String _name_1 = _floatField.getName();
        String _formatForCode_1 = this._formattingExtensions.formatForCode(_name_1);
        _builder.append(_formatForCode_1, "");
        _builder.append("\']) && !empty($this[\'");
        String _name_2 = _floatField.getName();
        String _formatForCode_2 = this._formattingExtensions.formatForCode(_name_2);
        _builder.append(_formatForCode_2, "");
        _builder.append("\'])) ? DataUtil::formatForDisplay($this[\'");
        String _name_3 = _floatField.getName();
        String _formatForCode_3 = this._formattingExtensions.formatForCode(_name_3);
        _builder.append(_formatForCode_3, "");
        _builder.append("\']) : 0.00);");
        _builder.newLineIfNotEmpty();
        _switchResult = _builder;
      }
    }
    if (!_matched) {
      StringConcatenation _builder = new StringConcatenation();
      _builder.append("$this[\'");
      String _name = it.getName();
      String _formatForCode = this._formattingExtensions.formatForCode(_name);
      _builder.append(_formatForCode, "");
      _builder.append("\'] = ((isset($this[\'");
      String _name_1 = it.getName();
      String _formatForCode_1 = this._formattingExtensions.formatForCode(_name_1);
      _builder.append(_formatForCode_1, "");
      _builder.append("\']) && !empty($this[\'");
      String _name_2 = it.getName();
      String _formatForCode_2 = this._formattingExtensions.formatForCode(_name_2);
      _builder.append(_formatForCode_2, "");
      _builder.append("\'])) ? DataUtil::formatForDisplay($this[\'");
      String _name_3 = it.getName();
      String _formatForCode_3 = this._formattingExtensions.formatForCode(_name_3);
      _builder.append(_formatForCode_3, "");
      _builder.append("\']) : \'\');");
      _builder.newLineIfNotEmpty();
      _switchResult = _builder;
    }
    return _switchResult;
  }
  
  private CharSequence sanitizeForOutputHTML(final EntityField it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("if ($currentFunc != \'edit\') {");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$this[\'");
    String _name = it.getName();
    String _formatForCode = this._formattingExtensions.formatForCode(_name);
    _builder.append(_formatForCode, "    ");
    _builder.append("\'] = ((isset($this[\'");
    String _name_1 = it.getName();
    String _formatForCode_1 = this._formattingExtensions.formatForCode(_name_1);
    _builder.append(_formatForCode_1, "    ");
    _builder.append("\']) && !empty($this[\'");
    String _name_2 = it.getName();
    String _formatForCode_2 = this._formattingExtensions.formatForCode(_name_2);
    _builder.append(_formatForCode_2, "    ");
    _builder.append("\'])) ? DataUtil::formatForDisplayHTML($this[\'");
    String _name_3 = it.getName();
    String _formatForCode_3 = this._formattingExtensions.formatForCode(_name_3);
    _builder.append(_formatForCode_3, "    ");
    _builder.append("\']) : \'\');");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence sanitizeForOutputHTMLWithZero(final EntityField it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("if ($currentFunc != \'edit\') {");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$this[\'");
    String _name = it.getName();
    String _formatForCode = this._formattingExtensions.formatForCode(_name);
    _builder.append(_formatForCode, "    ");
    _builder.append("\'] = (((isset($this[\'");
    String _name_1 = it.getName();
    String _formatForCode_1 = this._formattingExtensions.formatForCode(_name_1);
    _builder.append(_formatForCode_1, "    ");
    _builder.append("\']) && !empty($this[\'");
    String _name_2 = it.getName();
    String _formatForCode_2 = this._formattingExtensions.formatForCode(_name_2);
    _builder.append(_formatForCode_2, "    ");
    _builder.append("\'])) || $this[\'");
    String _name_3 = it.getName();
    String _formatForCode_3 = this._formattingExtensions.formatForCode(_name_3);
    _builder.append(_formatForCode_3, "    ");
    _builder.append("\'] == 0) ? DataUtil::formatForDisplayHTML($this[\'");
    String _name_4 = it.getName();
    String _formatForCode_4 = this._formattingExtensions.formatForCode(_name_4);
    _builder.append(_formatForCode_4, "    ");
    _builder.append("\']) : \'\');");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence sanitizeForOutputUpload(final UploadField it) {
    StringConcatenation _builder = new StringConcatenation();
    String _name = it.getName();
    final String realName = this._formattingExtensions.formatForCode(_name);
    _builder.newLineIfNotEmpty();
    _builder.append("if (!empty($this[\'");
    _builder.append(realName, "");
    _builder.append("\'])) {");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("try {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$basePath = $controllerHelper->getFileBaseFolder(\'");
    Entity _entity = it.getEntity();
    String _name_1 = _entity.getName();
    String _formatForCode = this._formattingExtensions.formatForCode(_name_1);
    _builder.append(_formatForCode, "        ");
    _builder.append("\', \'");
    _builder.append(realName, "        ");
    _builder.append("\');");
    _builder.newLineIfNotEmpty();
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
    _builder.append("$fullPath = $basePath .  $this[\'");
    _builder.append(realName, "    ");
    _builder.append("\'];");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("$this[\'");
    _builder.append(realName, "    ");
    _builder.append("FullPath\'] = $fullPath;");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("$this[\'");
    _builder.append(realName, "    ");
    _builder.append("FullPathURL\'] = System::getBaseUrl() . $fullPath;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// just some backwards compatibility stuff");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!isset($this[\'");
    _builder.append(realName, "    ");
    _builder.append("Meta\']) || !is_array($this[\'");
    _builder.append(realName, "    ");
    _builder.append("Meta\']) || !count($this[\'");
    _builder.append(realName, "    ");
    _builder.append("Meta\'])) {");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("// assign new meta data");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$this[\'");
    _builder.append(realName, "        ");
    _builder.append("Meta\'] = $uploadManager->readMetaDataForFile($this[\'");
    _builder.append(realName, "        ");
    _builder.append("\'], $fullPath);");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
}

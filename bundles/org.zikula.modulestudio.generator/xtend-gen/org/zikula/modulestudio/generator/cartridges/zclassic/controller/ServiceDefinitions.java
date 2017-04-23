package org.zikula.modulestudio.generator.cartridges.zclassic.controller;

import com.google.common.base.Objects;
import com.google.common.collect.Iterables;
import de.guite.modulestudio.metamodel.Application;
import de.guite.modulestudio.metamodel.ArrayField;
import de.guite.modulestudio.metamodel.DataObject;
import de.guite.modulestudio.metamodel.Entity;
import de.guite.modulestudio.metamodel.JoinRelationship;
import de.guite.modulestudio.metamodel.ListField;
import de.guite.modulestudio.metamodel.MappedSuperClass;
import java.util.ArrayList;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.CollectionLiterals;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.zikula.modulestudio.generator.extensions.ControllerExtensions;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.GeneratorSettingsExtensions;
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;
import org.zikula.modulestudio.generator.extensions.WorkflowExtensions;

/**
 * Service definitions in YAML format.
 */
@SuppressWarnings("all")
public class ServiceDefinitions {
  @Extension
  private ControllerExtensions _controllerExtensions = new ControllerExtensions();
  
  @Extension
  private FormattingExtensions _formattingExtensions = new FormattingExtensions();
  
  @Extension
  private GeneratorSettingsExtensions _generatorSettingsExtensions = new GeneratorSettingsExtensions();
  
  @Extension
  private ModelBehaviourExtensions _modelBehaviourExtensions = new ModelBehaviourExtensions();
  
  @Extension
  private ModelJoinExtensions _modelJoinExtensions = new ModelJoinExtensions();
  
  @Extension
  private ModelExtensions _modelExtensions = new ModelExtensions();
  
  @Extension
  private NamingExtensions _namingExtensions = new NamingExtensions();
  
  @Extension
  private Utils _utils = new Utils();
  
  @Extension
  private WorkflowExtensions _workflowExtensions = new WorkflowExtensions();
  
  private String modPrefix = "";
  
  private void generateServiceFile(final Application it, final IFileSystemAccess fsa, final String fileName, final CharSequence content) {
    String _resourcesPath = this._namingExtensions.getResourcesPath(it);
    String _plus = (_resourcesPath + "config/");
    String _plus_1 = (_plus + fileName);
    String definitionFilePath = (_plus_1 + ".yml");
    boolean _shouldBeSkipped = this._namingExtensions.shouldBeSkipped(it, definitionFilePath);
    boolean _not = (!_shouldBeSkipped);
    if (_not) {
      boolean _shouldBeMarked = this._namingExtensions.shouldBeMarked(it, definitionFilePath);
      if (_shouldBeMarked) {
        String _resourcesPath_1 = this._namingExtensions.getResourcesPath(it);
        String _plus_2 = (_resourcesPath_1 + "config/");
        String _plus_3 = (_plus_2 + fileName);
        String _plus_4 = (_plus_3 + ".generated.yml");
        definitionFilePath = _plus_4;
      }
      fsa.generateFile(definitionFilePath, content);
    }
  }
  
  /**
   * Entry point for service definitions.
   * This generates YAML files describing DI configuration.
   */
  public void generate(final Application it, final IFileSystemAccess fsa) {
    this.modPrefix = this._utils.appService(it);
    this.generateServiceFile(it, fsa, "services", this.mainServiceFile(it));
    this.generateServiceFile(it, fsa, "linkContainer", this.linkContainer(it));
    this.generateServiceFile(it, fsa, "entityFactory", this.entityFactory(it));
    this.generateServiceFile(it, fsa, "eventSubscriber", this.eventSubscriber(it));
    boolean _hasListFields = this._modelExtensions.hasListFields(it);
    if (_hasListFields) {
      this.generateServiceFile(it, fsa, "validators", this.validators(it));
    }
    boolean _hasEditActions = this._controllerExtensions.hasEditActions(it);
    if (_hasEditActions) {
      this.generateServiceFile(it, fsa, "formFields", this.formFields(it));
    }
    this.generateServiceFile(it, fsa, "forms", this.forms(it));
    this.generateServiceFile(it, fsa, "helpers", this.helpers(it));
    this.generateServiceFile(it, fsa, "twig", this.twig(it));
    this.generateServiceFile(it, fsa, "logger", this.logger(it));
  }
  
  private CharSequence mainServiceFile(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("imports:");
    _builder.newLine();
    _builder.append("  ");
    _builder.append("- { resource: \'linkContainer.yml\' }");
    _builder.newLine();
    _builder.append("  ");
    _builder.append("- { resource: \'entityFactory.yml\' }");
    _builder.newLine();
    _builder.append("  ");
    _builder.append("- { resource: \'eventSubscriber.yml\' }");
    _builder.newLine();
    {
      boolean _hasListFields = this._modelExtensions.hasListFields(it);
      if (_hasListFields) {
        _builder.append("  ");
        _builder.append("- { resource: \'validators.yml\' }");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      boolean _hasEditActions = this._controllerExtensions.hasEditActions(it);
      if (_hasEditActions) {
        _builder.append("  ");
        _builder.append("- { resource: \'formFields.yml\' }");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("  ");
    _builder.append("- { resource: \'forms.yml\' }");
    _builder.newLine();
    _builder.append("  ");
    _builder.append("- { resource: \'helpers.yml\' }");
    _builder.newLine();
    _builder.append("  ");
    _builder.append("- { resource: \'twig.yml\' }");
    _builder.newLine();
    _builder.append("  ");
    _builder.append("- { resource: \'logger.yml\' }");
    _builder.newLine();
    {
      boolean _hasImageFields = this._modelExtensions.hasImageFields(it);
      if (_hasImageFields) {
        _builder.newLine();
        _builder.append("parameters:");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("liip_imagine.cache.signer.class: ");
        String _appNamespace = this._utils.appNamespace(it);
        _builder.append(_appNamespace, "    ");
        _builder.append("\\Imagine\\Cache\\DummySigner");
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder;
  }
  
  private CharSequence linkContainer(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("services:");
    _builder.newLine();
    _builder.append("    ");
    _builder.append(this.modPrefix, "    ");
    _builder.append(".link_container:");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("class: ");
    String _appNamespace = this._utils.appNamespace(it);
    _builder.append(_appNamespace, "        ");
    _builder.append("\\Container\\LinkContainer");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("arguments:");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("- \"@translator.default\"");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("- \"@router\"");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("- \"@zikula_permissions_module.api.permission\"");
    _builder.newLine();
    {
      boolean _generateAccountApi = this._generatorSettingsExtensions.generateAccountApi(it);
      if (_generateAccountApi) {
        _builder.append("            ");
        _builder.append("- \"@zikula_extensions_module.api.variable\"");
        _builder.newLine();
      }
    }
    {
      if ((this._generatorSettingsExtensions.generateAccountApi(it) || this._controllerExtensions.hasEditActions(it))) {
        _builder.append("            ");
        _builder.append("- \"@zikula_users_module.current_user\"");
        _builder.newLine();
      }
    }
    _builder.append("            ");
    _builder.append("- \"@");
    _builder.append(this.modPrefix, "            ");
    _builder.append(".controller_helper\"");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("tags:");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("- { name: zikula.link_container }");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence entityFactory(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("services:");
    _builder.newLine();
    _builder.append("    ");
    CharSequence _servicesEntityFactory = this.servicesEntityFactory(it);
    _builder.append(_servicesEntityFactory, "    ");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence servicesEntityFactory(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("# Entity factory");
    _builder.newLine();
    _builder.append(this.modPrefix);
    _builder.append(".entity_factory:");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("class: ");
    String _appNamespace = this._utils.appNamespace(it);
    _builder.append(_appNamespace, "    ");
    _builder.append("\\Entity\\Factory\\");
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital, "    ");
    _builder.append("Factory");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("arguments:");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("- \"@");
    String _entityManagerService = this._namingExtensions.entityManagerService(it);
    _builder.append(_entityManagerService, "        ");
    _builder.append("\"");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("- \"@");
    _builder.append(this.modPrefix, "        ");
    _builder.append(".entity_initialiser\"");
    _builder.newLineIfNotEmpty();
    _builder.append("# Entity initialiser");
    _builder.newLine();
    _builder.append(this.modPrefix);
    _builder.append(".entity_initialiser:");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("class: ");
    String _appNamespace_1 = this._utils.appNamespace(it);
    _builder.append(_appNamespace_1, "    ");
    _builder.append("\\Entity\\Factory\\EntityInitialiser");
    _builder.newLineIfNotEmpty();
    {
      final Function1<ListField, Boolean> _function = (ListField it_1) -> {
        String _name = it_1.getName();
        return Boolean.valueOf((!Objects.equal(_name, "workflowState")));
      };
      boolean _isEmpty = IterableExtensions.isEmpty(IterableExtensions.<ListField>filter(this._modelExtensions.getAllListFields(it), _function));
      boolean _not = (!_isEmpty);
      if (_not) {
        _builder.append("    ");
        _builder.append("arguments:");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("- \"@");
        _builder.append(this.modPrefix, "        ");
        _builder.append(".listentries_helper\"");
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder;
  }
  
  private CharSequence eventSubscriber(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("services:");
    _builder.newLine();
    _builder.append("    ");
    CharSequence _servicesEventSubscriber = this.servicesEventSubscriber(it);
    _builder.append(_servicesEventSubscriber, "    ");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence servicesEventSubscriber(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("# Event subscribers and listeners");
    _builder.newLine();
    _builder.append(this.modPrefix);
    _builder.append(".entity_lifecycle_listener:");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("class: ");
    String _appNamespace = this._utils.appNamespace(it);
    _builder.append(_appNamespace, "    ");
    _builder.append("\\Listener\\EntityLifecycleListener");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("arguments:");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("- \"@service_container\"");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("tags:");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("- { name: doctrine.event_subscriber }");
    _builder.newLine();
    _builder.newLine();
    {
      ArrayList<String> _subscriberNames = this.getSubscriberNames(it);
      for(final String className : _subscriberNames) {
        _builder.append(this.modPrefix);
        _builder.append(".");
        String _lowerCase = className.toLowerCase();
        _builder.append(_lowerCase);
        _builder.append("_listener:");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("class: ");
        String _appNamespace_1 = this._utils.appNamespace(it);
        _builder.append(_appNamespace_1, "    ");
        _builder.append("\\Listener\\");
        _builder.append(className, "    ");
        _builder.append("Listener");
        _builder.newLineIfNotEmpty();
        {
          if (((Objects.equal(className, "ThirdParty") && this._workflowExtensions.needsApproval(it)) && this._generatorSettingsExtensions.generatePendingContentSupport(it))) {
            _builder.append("    ");
            _builder.append("arguments:");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("- \"@");
            _builder.append(this.modPrefix, "        ");
            _builder.append(".workflow_helper\"");
            _builder.newLineIfNotEmpty();
          } else {
            if ((Objects.equal(className, "User") && (this._modelBehaviourExtensions.hasStandardFieldEntities(it) || this._modelExtensions.hasUserFields(it)))) {
              _builder.append("    ");
              _builder.append("arguments:");
              _builder.newLine();
              _builder.append("    ");
              _builder.append("    ");
              _builder.append("- \"@translator.default\"");
              _builder.newLine();
              _builder.append("    ");
              _builder.append("    ");
              _builder.append("- \"@");
              _builder.append(this.modPrefix, "        ");
              _builder.append(".entity_factory\"");
              _builder.newLineIfNotEmpty();
              _builder.append("    ");
              _builder.append("    ");
              _builder.append("- \"@zikula_users_module.current_user\"");
              _builder.newLine();
              _builder.append("    ");
              _builder.append("    ");
              _builder.append("- \"@logger\"");
              _builder.newLine();
            } else {
              boolean _equals = Objects.equal(className, "IpTrace");
              if (_equals) {
                _builder.append("    ");
                _builder.append("arguments:");
                _builder.newLine();
                _builder.append("    ");
                _builder.append("    ");
                _builder.append("- \"@gedmo_doctrine_extensions.listener.ip_traceable\"");
                _builder.newLine();
                _builder.append("    ");
                _builder.append("    ");
                _builder.append("- \"@request_stack\"");
                _builder.newLine();
              }
            }
          }
        }
        _builder.append("    ");
        _builder.append("tags:");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("- { name: kernel.event_subscriber }");
        _builder.newLine();
        _builder.newLine();
      }
    }
    {
      Boolean _targets = this._utils.targets(it, "1.5");
      if ((_targets).booleanValue()) {
        _builder.append(this.modPrefix);
        _builder.append(".workflow_events_listener:");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("class: ");
        String _appNamespace_2 = this._utils.appNamespace(it);
        _builder.append(_appNamespace_2, "    ");
        _builder.append("\\Listener\\WorkflowEventsListener");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("arguments:");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("- \"@zikula_permissions_module.api.permission\"");
        _builder.newLine();
        {
          boolean _needsApproval = this._workflowExtensions.needsApproval(it);
          if (_needsApproval) {
            _builder.append("        ");
            _builder.append("- \"@");
            _builder.append(this.modPrefix, "        ");
            _builder.append(".notification_helper\"");
            _builder.newLineIfNotEmpty();
          }
        }
        _builder.append("    ");
        _builder.append("tags:");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("- { name: kernel.event_subscriber }");
        _builder.newLine();
        _builder.newLine();
      }
    }
    {
      boolean _contains = this.getSubscriberNames(it).contains("IpTrace");
      if (_contains) {
        _builder.append("gedmo_doctrine_extensions.listener.ip_traceable:");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("class: Gedmo\\IpTraceable\\IpTraceableListener");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("public: false");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("calls:");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("- [setAnnotationReader, [\"@annotation_reader\"]]");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("tags:");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("- { name: doctrine.event_subscriber, connection: default }");
        _builder.newLine();
        _builder.newLine();
      }
    }
    return _builder;
  }
  
  private ArrayList<String> getSubscriberNames(final Application it) {
    ArrayList<String> _xblockexpression = null;
    {
      ArrayList<String> listeners = CollectionLiterals.<String>newArrayList(
        "Kernel", "Installer", "ModuleDispatch", "Mailer", "Theme", 
        "UserLogin", "UserLogout", "User", "UserRegistration", "Users", "Group");
      final boolean needsDetailContentType = (this._generatorSettingsExtensions.generateDetailContentType(it) && this._controllerExtensions.hasDisplayActions(it));
      if (((this._generatorSettingsExtensions.generatePendingContentSupport(it) || this._generatorSettingsExtensions.generateListContentType(it)) || needsDetailContentType)) {
        listeners.add("ThirdParty");
      }
      final Function1<Entity, Boolean> _function = (Entity it_1) -> {
        return Boolean.valueOf(this._modelBehaviourExtensions.hasIpTraceableFields(it_1));
      };
      boolean _isEmpty = IterableExtensions.isEmpty(IterableExtensions.<Entity>filter(this._modelExtensions.getAllEntities(it), _function));
      boolean _not = (!_isEmpty);
      if (_not) {
        listeners.add("IpTrace");
      }
      _xblockexpression = listeners;
    }
    return _xblockexpression;
  }
  
  private CharSequence validators(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("services:");
    _builder.newLine();
    _builder.append("    ");
    CharSequence _validatorServices = this.validatorServices(it);
    _builder.append(_validatorServices, "    ");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence validatorServices(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("# Custom validators");
    _builder.newLine();
    _builder.append(this.modPrefix);
    _builder.append(".validator.list_entry.validator:");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("class: ");
    String _appNamespace = this._utils.appNamespace(it);
    _builder.append(_appNamespace, "    ");
    _builder.append("\\Validator\\Constraints\\ListEntryValidator");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("arguments:");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("- \"@translator.default\"");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("- \"@");
    _builder.append(this.modPrefix, "        ");
    _builder.append(".listentries_helper\"");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("tags:");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("- { name: validator.constraint_validator, alias: ");
    _builder.append(this.modPrefix, "        ");
    _builder.append(".validator.list_entry.validator }");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence formFields(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("services:");
    _builder.newLine();
    _builder.append("    ");
    CharSequence _formFieldsHelper = this.formFieldsHelper(it);
    _builder.append(_formFieldsHelper, "    ");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence formFieldsHelper(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("# Form field types");
    _builder.newLine();
    String _appNamespace = this._utils.appNamespace(it);
    final String nsBase = (_appNamespace + "\\Form\\Type\\");
    _builder.newLineIfNotEmpty();
    {
      final Function1<DataObject, Boolean> _function = (DataObject e) -> {
        boolean _isEmpty = IterableExtensions.isEmpty(Iterables.<ArrayField>filter(e.getFields(), ArrayField.class));
        return Boolean.valueOf((!_isEmpty));
      };
      boolean _isEmpty = IterableExtensions.isEmpty(IterableExtensions.<DataObject>filter(it.getEntities(), _function));
      boolean _not = (!_isEmpty);
      if (_not) {
        _builder.newLine();
        _builder.append(this.modPrefix);
        _builder.append(".form.type.field.array:");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("class: ");
        _builder.append(nsBase, "    ");
        _builder.append("Field\\ArrayType");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("tags:");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("- { name: form.type }");
        _builder.newLine();
      }
    }
    {
      boolean _hasColourFields = this._modelExtensions.hasColourFields(it);
      if (_hasColourFields) {
        _builder.newLine();
        _builder.append(this.modPrefix);
        _builder.append(".form.type.field.colour:");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("class: ");
        _builder.append(nsBase, "    ");
        _builder.append("Field\\ColourType");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("tags:");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("- { name: form.type }");
        _builder.newLine();
      }
    }
    {
      boolean _hasGeographical = this._modelBehaviourExtensions.hasGeographical(it);
      if (_hasGeographical) {
        _builder.newLine();
        _builder.append(this.modPrefix);
        _builder.append(".form.type.field.geo:");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("class: ");
        _builder.append(nsBase, "    ");
        _builder.append("Field\\GeoType");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("tags:");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("- { name: form.type }");
        _builder.newLine();
      }
    }
    {
      boolean _hasMultiListFields = this._modelExtensions.hasMultiListFields(it);
      if (_hasMultiListFields) {
        _builder.newLine();
        _builder.append(this.modPrefix);
        _builder.append(".form.type.field.multilist:");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("class: ");
        _builder.append(nsBase, "    ");
        _builder.append("Field\\MultiListType");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("arguments:");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("- \"@");
        _builder.append(this.modPrefix, "        ");
        _builder.append(".listentries_helper\"");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("tags:");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("- { name: form.type }");
        _builder.newLine();
      }
    }
    {
      boolean _hasTranslatable = this._modelBehaviourExtensions.hasTranslatable(it);
      if (_hasTranslatable) {
        _builder.newLine();
        _builder.append(this.modPrefix);
        _builder.append(".form.type.field.translation:");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("class: ");
        _builder.append(nsBase, "    ");
        _builder.append("Field\\TranslationType");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("tags:");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("- { name: form.type }");
        _builder.newLine();
      }
    }
    {
      boolean _hasTrees = this._modelBehaviourExtensions.hasTrees(it);
      if (_hasTrees) {
        _builder.newLine();
        _builder.append(this.modPrefix);
        _builder.append(".form.type.field.entitytree:");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("class: ");
        _builder.append(nsBase, "    ");
        _builder.append("Field\\EntityTreeType");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("tags:");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("- { name: form.type }");
        _builder.newLine();
      }
    }
    {
      boolean _hasUploads = this._modelExtensions.hasUploads(it);
      if (_hasUploads) {
        _builder.newLine();
        _builder.append(this.modPrefix);
        _builder.append(".form.type.field.upload:");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("class: ");
        _builder.append(nsBase, "    ");
        _builder.append("Field\\UploadType");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("arguments:");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("- \"@translator.default\"");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("- \"@request_stack\"");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("- \"@");
        _builder.append(this.modPrefix, "        ");
        _builder.append(".image_helper\"");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("- \"@");
        _builder.append(this.modPrefix, "        ");
        _builder.append(".upload_helper\"");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("tags:");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("- { name: form.type }");
        _builder.newLine();
      }
    }
    {
      boolean _needsUserAutoCompletion = this._modelBehaviourExtensions.needsUserAutoCompletion(it);
      if (_needsUserAutoCompletion) {
        _builder.newLine();
        _builder.append(this.modPrefix);
        _builder.append(".form.type.field.user:");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("class: ");
        _builder.append(nsBase, "    ");
        _builder.append("Field\\UserType");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("arguments:");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("- \"@zikula_users_module.user_repository\"");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("tags:");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("- { name: form.type }");
        _builder.newLine();
      }
    }
    {
      boolean _needsAutoCompletion = this._modelJoinExtensions.needsAutoCompletion(it);
      if (_needsAutoCompletion) {
        _builder.newLine();
        _builder.append(this.modPrefix);
        _builder.append(".form.type.field.autocompletionrelation:");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("class: ");
        _builder.append(nsBase, "    ");
        _builder.append("Field\\AutoCompletionRelationType");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("arguments:");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("- \"@router\"");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("- \"@");
        _builder.append(this.modPrefix, "        ");
        _builder.append(".entity_factory\"");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("tags:");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("- { name: form.type }");
        _builder.newLine();
      }
    }
    return _builder;
  }
  
  private CharSequence forms(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("services:");
    _builder.newLine();
    _builder.append("    ");
    CharSequence _formsHelper = this.formsHelper(it);
    _builder.append(_formsHelper, "    ");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence formsHelper(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("# Form types");
    _builder.newLine();
    String _appNamespace = this._utils.appNamespace(it);
    final String nsBase = (_appNamespace + "\\Form\\Type\\");
    _builder.newLineIfNotEmpty();
    {
      boolean _hasViewActions = this._controllerExtensions.hasViewActions(it);
      if (_hasViewActions) {
        {
          final Function1<Entity, Boolean> _function = (Entity it_1) -> {
            return Boolean.valueOf(this._controllerExtensions.hasViewAction(it_1));
          };
          Iterable<Entity> _filter = IterableExtensions.<Entity>filter(this._modelExtensions.getAllEntities(it), _function);
          for(final Entity entity : _filter) {
            _builder.newLine();
            _builder.append(this.modPrefix);
            _builder.append(".form.type.");
            String _formatForDB = this._formattingExtensions.formatForDB(entity.getName());
            _builder.append(_formatForDB);
            _builder.append("quicknav:");
            _builder.newLineIfNotEmpty();
            _builder.append("    ");
            _builder.append("class: ");
            _builder.append(nsBase, "    ");
            _builder.append("QuickNavigation\\");
            String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(entity.getName());
            _builder.append(_formatForCodeCapital, "    ");
            _builder.append("QuickNavType");
            _builder.newLineIfNotEmpty();
            _builder.append("    ");
            _builder.append("arguments:");
            _builder.newLine();
            _builder.append("        ");
            _builder.append("- \"@translator.default\"");
            _builder.newLine();
            {
              final Function1<JoinRelationship, Boolean> _function_1 = (JoinRelationship it_1) -> {
                DataObject _source = it_1.getSource();
                return Boolean.valueOf((_source instanceof Entity));
              };
              boolean _isEmpty = IterableExtensions.isEmpty(IterableExtensions.<JoinRelationship>filter(this._modelJoinExtensions.getBidirectionalIncomingJoinRelationsWithOneSource(entity), _function_1));
              boolean _not = (!_isEmpty);
              if (_not) {
                _builder.append("        ");
                _builder.append("- \"@request_stack\"");
                _builder.newLine();
              }
            }
            {
              boolean _hasListFieldsEntity = this._modelExtensions.hasListFieldsEntity(entity);
              if (_hasListFieldsEntity) {
                _builder.append("        ");
                _builder.append("- \"@");
                _builder.append(this.modPrefix, "        ");
                _builder.append(".listentries_helper\"");
                _builder.newLineIfNotEmpty();
              }
            }
            {
              boolean _hasLocaleFieldsEntity = this._modelExtensions.hasLocaleFieldsEntity(entity);
              if (_hasLocaleFieldsEntity) {
                _builder.append("        ");
                _builder.append("- \"@zikula_settings_module.locale_api\"");
                _builder.newLine();
              }
            }
            {
              boolean _needsFeatureActivationHelper = this._modelBehaviourExtensions.needsFeatureActivationHelper(it);
              if (_needsFeatureActivationHelper) {
                _builder.append("        ");
                _builder.append("- \"@");
                _builder.append(this.modPrefix, "        ");
                _builder.append(".feature_activation_helper\"");
                _builder.newLineIfNotEmpty();
              }
            }
            _builder.append("    ");
            _builder.append("tags:");
            _builder.newLine();
            _builder.append("        ");
            _builder.append("- { name: form.type }");
            _builder.newLine();
          }
        }
      }
    }
    {
      boolean _hasEditActions = this._controllerExtensions.hasEditActions(it);
      if (_hasEditActions) {
        {
          final Function1<DataObject, Boolean> _function_2 = (DataObject e) -> {
            return Boolean.valueOf(((e instanceof MappedSuperClass) || this._controllerExtensions.hasEditAction(((Entity) e))));
          };
          Iterable<DataObject> _filter_1 = IterableExtensions.<DataObject>filter(it.getEntities(), _function_2);
          for(final DataObject entity_1 : _filter_1) {
            {
              if ((entity_1 instanceof Entity)) {
                _builder.newLine();
                _builder.append(this.modPrefix);
                _builder.append(".form.handler.");
                String _formatForDB_1 = this._formattingExtensions.formatForDB(((Entity)entity_1).getName());
                _builder.append(_formatForDB_1);
                _builder.append(":");
                _builder.newLineIfNotEmpty();
                _builder.append("    ");
                _builder.append("class: ");
                String _replace = nsBase.replace("Type\\", "");
                _builder.append(_replace, "    ");
                _builder.append("Handler\\");
                String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(((Entity)entity_1).getName());
                _builder.append(_formatForCodeCapital_1, "    ");
                _builder.append("\\EditHandler");
                _builder.newLineIfNotEmpty();
                _builder.append("    ");
                _builder.append("arguments:");
                _builder.newLine();
                _builder.append("        ");
                _builder.append("- \"@kernel\"");
                _builder.newLine();
                _builder.append("        ");
                _builder.append("- \"@translator.default\"");
                _builder.newLine();
                _builder.append("        ");
                _builder.append("- \"@form.factory\"");
                _builder.newLine();
                _builder.append("        ");
                _builder.append("- \"@request_stack\"");
                _builder.newLine();
                _builder.append("        ");
                _builder.append("- \"@router\"");
                _builder.newLine();
                _builder.append("        ");
                _builder.append("- \"@logger\"");
                _builder.newLine();
                _builder.append("        ");
                _builder.append("- \"@zikula_permissions_module.api.permission\"");
                _builder.newLine();
                {
                  if ((this._modelBehaviourExtensions.hasTranslatable(it) || this._workflowExtensions.needsApproval(it))) {
                    _builder.append("        ");
                    _builder.append("- \"@zikula_extensions_module.api.variable\"");
                    _builder.newLine();
                  }
                }
                _builder.append("        ");
                _builder.append("- \"@zikula_users_module.current_user\"");
                _builder.newLine();
                {
                  boolean _needsApproval = this._workflowExtensions.needsApproval(it);
                  if (_needsApproval) {
                    _builder.append("        ");
                    _builder.append("- \"@zikula_groups_module.group_application_repository\"");
                    _builder.newLine();
                  }
                }
                _builder.append("        ");
                _builder.append("- \"@");
                _builder.append(this.modPrefix, "        ");
                _builder.append(".entity_factory\"");
                _builder.newLineIfNotEmpty();
                _builder.append("        ");
                _builder.append("- \"@");
                _builder.append(this.modPrefix, "        ");
                _builder.append(".controller_helper\"");
                _builder.newLineIfNotEmpty();
                _builder.append("        ");
                _builder.append("- \"@");
                _builder.append(this.modPrefix, "        ");
                _builder.append(".model_helper\"");
                _builder.newLineIfNotEmpty();
                _builder.append("        ");
                _builder.append("- \"@");
                _builder.append(this.modPrefix, "        ");
                _builder.append(".workflow_helper\"");
                _builder.newLineIfNotEmpty();
                {
                  boolean _hasHookSubscribers = this._modelExtensions.hasHookSubscribers(it);
                  if (_hasHookSubscribers) {
                    _builder.append("        ");
                    _builder.append("- \"@");
                    _builder.append(this.modPrefix, "        ");
                    _builder.append(".hook_helper\"");
                    _builder.newLineIfNotEmpty();
                  }
                }
                {
                  boolean _hasTranslatable = this._modelBehaviourExtensions.hasTranslatable(it);
                  if (_hasTranslatable) {
                    _builder.append("        ");
                    _builder.append("- \"@");
                    _builder.append(this.modPrefix, "        ");
                    _builder.append(".translatable_helper\"");
                    _builder.newLineIfNotEmpty();
                  }
                }
                {
                  boolean _needsFeatureActivationHelper_1 = this._modelBehaviourExtensions.needsFeatureActivationHelper(it);
                  if (_needsFeatureActivationHelper_1) {
                    _builder.append("        ");
                    _builder.append("- \"@");
                    _builder.append(this.modPrefix, "        ");
                    _builder.append(".feature_activation_helper\"");
                    _builder.newLineIfNotEmpty();
                  }
                }
                _builder.append("    ");
                _builder.append("calls:");
                _builder.newLine();
                _builder.append("        ");
                _builder.append("- [setLockingApi, [\"@?zikula_pagelock_module.api.locking\"]]");
                _builder.newLine();
                _builder.append("    ");
                _builder.append("tags:");
                _builder.newLine();
                _builder.append("        ");
                _builder.append("- { name: form.type }");
                _builder.newLine();
              }
            }
            _builder.newLine();
            _builder.append(this.modPrefix);
            _builder.append(".form.type.");
            String _formatForDB_2 = this._formattingExtensions.formatForDB(entity_1.getName());
            _builder.append(_formatForDB_2);
            _builder.append(":");
            _builder.newLineIfNotEmpty();
            _builder.append("    ");
            _builder.append("class: ");
            _builder.append(nsBase, "    ");
            String _formatForCodeCapital_2 = this._formattingExtensions.formatForCodeCapital(entity_1.getName());
            _builder.append(_formatForCodeCapital_2, "    ");
            _builder.append("Type");
            _builder.newLineIfNotEmpty();
            _builder.append("    ");
            _builder.append("arguments:");
            _builder.newLine();
            _builder.append("        ");
            _builder.append("- \"@translator.default\"");
            _builder.newLine();
            _builder.append("        ");
            _builder.append("- \"@");
            _builder.append(this.modPrefix, "        ");
            _builder.append(".entity_factory\"");
            _builder.newLineIfNotEmpty();
            {
              if (((entity_1 instanceof Entity) && this._modelBehaviourExtensions.hasTranslatableFields(((Entity) entity_1)))) {
                _builder.append("        ");
                _builder.append("- \"@zikula_extensions_module.api.variable\"");
                _builder.newLine();
                _builder.append("        ");
                _builder.append("- \"@");
                _builder.append(this.modPrefix, "        ");
                _builder.append(".translatable_helper\"");
                _builder.newLineIfNotEmpty();
              }
            }
            {
              boolean _hasListFieldsEntity_1 = this._modelExtensions.hasListFieldsEntity(entity_1);
              if (_hasListFieldsEntity_1) {
                _builder.append("        ");
                _builder.append("- \"@");
                _builder.append(this.modPrefix, "        ");
                _builder.append(".listentries_helper\"");
                _builder.newLineIfNotEmpty();
              }
            }
            {
              boolean _hasLocaleFieldsEntity_1 = this._modelExtensions.hasLocaleFieldsEntity(entity_1);
              if (_hasLocaleFieldsEntity_1) {
                _builder.append("        ");
                _builder.append("- \"@zikula_settings_module.locale_api\"");
                _builder.newLine();
              }
            }
            {
              boolean _needsFeatureActivationHelper_2 = this._modelBehaviourExtensions.needsFeatureActivationHelper(it);
              if (_needsFeatureActivationHelper_2) {
                _builder.append("        ");
                _builder.append("- \"@");
                _builder.append(this.modPrefix, "        ");
                _builder.append(".feature_activation_helper\"");
                _builder.newLineIfNotEmpty();
              }
            }
            _builder.append("    ");
            _builder.append("tags:");
            _builder.newLine();
            _builder.append("        ");
            _builder.append("- { name: form.type }");
            _builder.newLine();
          }
        }
      }
    }
    {
      if ((this._controllerExtensions.hasDeleteActions(it) && (!(this._utils.targets(it, "1.5")).booleanValue()))) {
        _builder.newLine();
        _builder.append(this.modPrefix);
        _builder.append(".form.type.deleteentity:");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("class: ");
        String _replace_1 = nsBase.replace("Type\\", "");
        _builder.append(_replace_1, "    ");
        _builder.append("DeleteEntityType");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("arguments:");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("- \"@translator.default\"");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("tags:");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("- { name: form.type }");
        _builder.newLine();
      }
    }
    {
      boolean _generateListBlock = this._generatorSettingsExtensions.generateListBlock(it);
      if (_generateListBlock) {
        _builder.newLine();
        _builder.append(this.modPrefix);
        _builder.append(".form.type.block.itemlist:");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("class: ");
        String _replace_2 = nsBase.replace("Form\\Type\\", "");
        _builder.append(_replace_2, "    ");
        _builder.append("Block\\Form\\Type\\ItemListBlockType");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("arguments:");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("- \"@translator.default\"");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("tags:");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("- { name: form.type }");
        _builder.newLine();
      }
    }
    {
      boolean _generateExternalControllerAndFinder = this._generatorSettingsExtensions.generateExternalControllerAndFinder(it);
      if (_generateExternalControllerAndFinder) {
        {
          Iterable<Entity> _allEntities = this._modelExtensions.getAllEntities(it);
          for(final Entity entity_2 : _allEntities) {
            _builder.newLine();
            _builder.append(this.modPrefix);
            _builder.append(".form.type.");
            String _formatForDB_3 = this._formattingExtensions.formatForDB(entity_2.getName());
            _builder.append(_formatForDB_3);
            _builder.append("finder:");
            _builder.newLineIfNotEmpty();
            _builder.append("    ");
            _builder.append("class: ");
            _builder.append(nsBase, "    ");
            _builder.append("Finder\\");
            String _formatForCodeCapital_3 = this._formattingExtensions.formatForCodeCapital(entity_2.getName());
            _builder.append(_formatForCodeCapital_3, "    ");
            _builder.append("FinderType");
            _builder.newLineIfNotEmpty();
            _builder.append("    ");
            _builder.append("arguments:");
            _builder.newLine();
            _builder.append("        ");
            _builder.append("- \"@translator.default\"");
            _builder.newLine();
            {
              boolean _needsFeatureActivationHelper_3 = this._modelBehaviourExtensions.needsFeatureActivationHelper(it);
              if (_needsFeatureActivationHelper_3) {
                _builder.append("        ");
                _builder.append("- \"@");
                _builder.append(this.modPrefix, "        ");
                _builder.append(".feature_activation_helper\"");
                _builder.newLineIfNotEmpty();
              }
            }
            _builder.append("    ");
            _builder.append("tags:");
            _builder.newLine();
            _builder.append("        ");
            _builder.append("- { name: form.type }");
            _builder.newLine();
          }
        }
      }
    }
    {
      boolean _needsConfig = this._utils.needsConfig(it);
      if (_needsConfig) {
        _builder.newLine();
        _builder.append(this.modPrefix);
        _builder.append(".form.type.appsettings:");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("class: ");
        String _replace_3 = nsBase.replace("Type\\", "");
        _builder.append(_replace_3, "    ");
        _builder.append("AppSettingsType");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("arguments:");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("- \"@translator.default\"");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("- \"@zikula_extensions_module.api.variable\"");
        _builder.newLine();
        {
          boolean _hasUserGroupSelectors = this._controllerExtensions.hasUserGroupSelectors(it);
          if (_hasUserGroupSelectors) {
            _builder.append("        ");
            _builder.append("- \"@zikula_groups_module.group_repository\"");
            _builder.newLine();
          }
        }
        _builder.append("    ");
        _builder.append("tags:");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("- { name: form.type }");
        _builder.newLine();
      }
    }
    return _builder;
  }
  
  private CharSequence helpers(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("services:");
    _builder.newLine();
    _builder.append("    ");
    CharSequence _servicesHelper = this.servicesHelper(it);
    _builder.append(_servicesHelper, "    ");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence servicesHelper(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("# Helper services");
    _builder.newLine();
    String _appNamespace = this._utils.appNamespace(it);
    final String nsBase = (_appNamespace + "\\Helper\\");
    _builder.newLineIfNotEmpty();
    {
      boolean _hasAutomaticArchiving = this._modelBehaviourExtensions.hasAutomaticArchiving(it);
      if (_hasAutomaticArchiving) {
        _builder.append(this.modPrefix);
        _builder.append(".archive_helper:");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("class: ");
        _builder.append(nsBase, "    ");
        _builder.append("ArchiveHelper");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("arguments:");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("- \"@translator.default\"");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("- \"@session\"");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("- \"@logger\"");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("- \"@zikula_permissions_module.api.permission\"");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("- \"@");
        _builder.append(this.modPrefix, "        ");
        _builder.append(".entity_factory\"");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("- \"@");
        _builder.append(this.modPrefix, "        ");
        _builder.append(".workflow_helper\"");
        _builder.newLineIfNotEmpty();
        {
          boolean _hasHookSubscribers = this._modelExtensions.hasHookSubscribers(it);
          if (_hasHookSubscribers) {
            _builder.append("        ");
            _builder.append("- \"@");
            _builder.append(this.modPrefix, "        ");
            _builder.append(".hook_helper\"");
            _builder.newLineIfNotEmpty();
          }
        }
        _builder.newLine();
      }
    }
    {
      boolean _hasCategorisableEntities = this._modelBehaviourExtensions.hasCategorisableEntities(it);
      if (_hasCategorisableEntities) {
        _builder.append(this.modPrefix);
        _builder.append(".category_helper:");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("class: ");
        _builder.append(nsBase, "    ");
        _builder.append("CategoryHelper");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("arguments:");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("- \"@translator.default\"");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("- \"@session\"");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("- \"@request_stack\"");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("- \"@logger\"");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("- \"@zikula_users_module.current_user\"");
        _builder.newLine();
        {
          Boolean _targets = this._utils.targets(it, "1.5");
          if ((_targets).booleanValue()) {
            _builder.append("        ");
            _builder.append("- \"@zikula_categories_module.category_registry_repository\"");
            _builder.newLine();
          } else {
            _builder.append("        ");
            _builder.append("- \"@zikula_categories_module.api.category_registry\"");
            _builder.newLine();
          }
        }
        _builder.append("        ");
        _builder.append("- \"@zikula_categories_module.api.category_permission\"");
        _builder.newLine();
        _builder.newLine();
      }
    }
    _builder.append(this.modPrefix);
    _builder.append(".controller_helper:");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("class: ");
    _builder.append(nsBase, "    ");
    _builder.append("ControllerHelper");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("arguments:");
    _builder.newLine();
    {
      boolean _hasUploads = this._modelExtensions.hasUploads(it);
      if (_hasUploads) {
        _builder.append("        ");
        _builder.append("- \"@translator.default\"");
        _builder.newLine();
      }
    }
    _builder.append("        ");
    _builder.append("- \"@request_stack\"");
    _builder.newLine();
    {
      boolean _hasUploads_1 = this._modelExtensions.hasUploads(it);
      if (_hasUploads_1) {
        _builder.append("        ");
        _builder.append("- \"@session\"");
        _builder.newLine();
      }
    }
    {
      if ((this._modelExtensions.hasUploads(it) || this._modelBehaviourExtensions.hasGeographical(it))) {
        _builder.append("        ");
        _builder.append("- \"@logger\"");
        _builder.newLine();
      }
    }
    {
      boolean _hasViewActions = this._controllerExtensions.hasViewActions(it);
      if (_hasViewActions) {
        _builder.append("        ");
        _builder.append("- \"@form.factory\"");
        _builder.newLine();
      }
    }
    {
      if ((this._controllerExtensions.hasViewActions(it) || this._modelBehaviourExtensions.hasGeographical(it))) {
        _builder.append("        ");
        _builder.append("- \"@zikula_extensions_module.api.variable\"");
        _builder.newLine();
      }
    }
    {
      boolean _hasGeographical = this._modelBehaviourExtensions.hasGeographical(it);
      if (_hasGeographical) {
        _builder.append("        ");
        _builder.append("- \"@zikula_users_module.current_user\"");
        _builder.newLine();
      }
    }
    _builder.append("        ");
    _builder.append("- \"@");
    _builder.append(this.modPrefix, "        ");
    _builder.append(".entity_factory\"");
    _builder.newLineIfNotEmpty();
    {
      if ((this._controllerExtensions.hasViewActions(it) && this._controllerExtensions.hasEditActions(it))) {
        _builder.append("        ");
        _builder.append("- \"@");
        _builder.append(this.modPrefix, "        ");
        _builder.append(".model_helper\"");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      boolean _hasUploads_2 = this._modelExtensions.hasUploads(it);
      if (_hasUploads_2) {
        _builder.append("        ");
        _builder.append("- \"@");
        _builder.append(this.modPrefix, "        ");
        _builder.append(".image_helper\"");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      boolean _needsFeatureActivationHelper = this._modelBehaviourExtensions.needsFeatureActivationHelper(it);
      if (_needsFeatureActivationHelper) {
        _builder.append("        ");
        _builder.append("- \"@");
        _builder.append(this.modPrefix, "        ");
        _builder.append(".feature_activation_helper\"");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      boolean _needsFeatureActivationHelper_1 = this._modelBehaviourExtensions.needsFeatureActivationHelper(it);
      if (_needsFeatureActivationHelper_1) {
        _builder.newLine();
        _builder.append(this.modPrefix);
        _builder.append(".feature_activation_helper:");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("class: ");
        _builder.append(nsBase, "    ");
        _builder.append("FeatureActivationHelper");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      boolean _hasHookSubscribers_1 = this._modelExtensions.hasHookSubscribers(it);
      if (_hasHookSubscribers_1) {
        _builder.newLine();
        _builder.append(this.modPrefix);
        _builder.append(".hook_helper:");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("class: ");
        _builder.append(nsBase, "    ");
        _builder.append("HookHelper");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("arguments:");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("- \"@hook_dispatcher\"");
        _builder.newLine();
      }
    }
    {
      boolean _hasUploads_3 = this._modelExtensions.hasUploads(it);
      if (_hasUploads_3) {
        _builder.newLine();
        _builder.append(this.modPrefix);
        _builder.append(".image_helper:");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("class: ");
        _builder.append(nsBase, "    ");
        _builder.append("ImageHelper");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("arguments:");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("- \"@translator.default\"");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("- \"@session\"");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("- \"@zikula_extensions_module.api.variable\"");
        _builder.newLine();
      }
    }
    {
      boolean _hasListFields = this._modelExtensions.hasListFields(it);
      if (_hasListFields) {
        _builder.newLine();
        _builder.append(this.modPrefix);
        _builder.append(".listentries_helper:");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("class: ");
        _builder.append(nsBase, "    ");
        _builder.append("ListEntriesHelper");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("arguments:");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("- \"@translator.default\"");
        _builder.newLine();
      }
    }
    _builder.newLine();
    _builder.append(this.modPrefix);
    _builder.append(".model_helper:");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("class: ");
    _builder.append(nsBase, "    ");
    _builder.append("ModelHelper");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("arguments:");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("- \"@");
    _builder.append(this.modPrefix, "        ");
    _builder.append(".entity_factory\"");
    _builder.newLineIfNotEmpty();
    {
      boolean _needsApproval = this._workflowExtensions.needsApproval(it);
      if (_needsApproval) {
        _builder.newLine();
        _builder.append(this.modPrefix);
        _builder.append(".notification_helper:");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("class: ");
        _builder.append(nsBase, "    ");
        _builder.append("NotificationHelper");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("arguments:");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("- \"@kernel\"");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("- \"@translator.default\"");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("- \"@session\"");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("- \"@router\"");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("- \"@request_stack\"");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("- \"@zikula_extensions_module.api.variable\"");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("- \"@twig\"");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("- \"@zikula_mailer_module.api.mailer\"");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("- \"@zikula_groups_module.group_repository\"");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("- \"@");
        _builder.append(this.modPrefix, "        ");
        _builder.append(".workflow_helper\"");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      boolean _generateSearchApi = this._generatorSettingsExtensions.generateSearchApi(it);
      if (_generateSearchApi) {
        _builder.newLine();
        _builder.append(this.modPrefix);
        _builder.append(".search_helper:");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("class: ");
        _builder.append(nsBase, "    ");
        _builder.append("SearchHelper");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("arguments:");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("- \"@translator.default\"");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("- \"@zikula_permissions_module.api.permission\"");
        _builder.newLine();
        {
          Boolean _targets_1 = this._utils.targets(it, "1.5");
          boolean _not = (!(_targets_1).booleanValue());
          if (_not) {
            _builder.append("        ");
            _builder.append("- \"@templating.engine.twig\"");
            _builder.newLine();
          }
        }
        _builder.append("        ");
        _builder.append("- \"@session\"");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("- \"@request_stack\"");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("- \"@");
        _builder.append(this.modPrefix, "        ");
        _builder.append(".entity_factory\"");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("- \"@");
        _builder.append(this.modPrefix, "        ");
        _builder.append(".controller_helper\"");
        _builder.newLineIfNotEmpty();
        {
          boolean _hasCategorisableEntities_1 = this._modelBehaviourExtensions.hasCategorisableEntities(it);
          if (_hasCategorisableEntities_1) {
            _builder.append("        ");
            _builder.append("- \"@");
            _builder.append(this.modPrefix, "        ");
            _builder.append(".feature_activation_helper\"");
            _builder.newLineIfNotEmpty();
            _builder.append("        ");
            _builder.append("- \"@");
            _builder.append(this.modPrefix, "        ");
            _builder.append(".category_helper\"");
            _builder.newLineIfNotEmpty();
          }
        }
        _builder.append("    ");
        _builder.append("tags:");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("- { name: zikula.searchable_module, bundleName: ");
        String _appName = this._utils.appName(it);
        _builder.append(_appName, "        ");
        _builder.append(" }");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      boolean _hasTranslatable = this._modelBehaviourExtensions.hasTranslatable(it);
      if (_hasTranslatable) {
        _builder.newLine();
        _builder.append(this.modPrefix);
        _builder.append(".translatable_helper:");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("class: ");
        _builder.append(nsBase, "    ");
        _builder.append("TranslatableHelper");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("arguments:");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("- \"@translator.default\"");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("- \"@request_stack\"");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("- \"@zikula_extensions_module.api.variable\"");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("- \"@zikula_settings_module.locale_api\"");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("- \"@");
        _builder.append(this.modPrefix, "        ");
        _builder.append(".entity_factory\"");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      boolean _hasUploads_4 = this._modelExtensions.hasUploads(it);
      if (_hasUploads_4) {
        _builder.newLine();
        _builder.append(this.modPrefix);
        _builder.append(".upload_helper:");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("class: ");
        _builder.append(nsBase, "    ");
        _builder.append("UploadHelper");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("arguments:");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("- \"@translator.default\"");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("- \"@session\"");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("- \"@liip_imagine.cache.manager\"");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("- \"@logger\"");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("- \"@zikula_users_module.current_user\"");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("- \"@zikula_extensions_module.api.variable\"");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("- \"%datadir%\"");
        _builder.newLine();
      }
    }
    _builder.newLine();
    _builder.append(this.modPrefix);
    _builder.append(".view_helper:");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("class: ");
    _builder.append(nsBase, "    ");
    _builder.append("ViewHelper");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("arguments:");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("- \"@twig\"");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("- \"@twig.loader\"");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("- \"@request_stack\"");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("- \"@zikula_permissions_module.api.permission\"");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("- \"@zikula_extensions_module.api.variable\"");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("- \"@zikula_core.common.theme.pagevars\"");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("- \"@");
    _builder.append(this.modPrefix, "        ");
    _builder.append(".controller_helper\"");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append(this.modPrefix);
    _builder.append(".workflow_helper:");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("class: ");
    _builder.append(nsBase, "    ");
    _builder.append("WorkflowHelper");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("arguments:");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("- \"@translator.default\"");
    _builder.newLine();
    {
      Boolean _targets_2 = this._utils.targets(it, "1.5");
      if ((_targets_2).booleanValue()) {
        _builder.append("        ");
        _builder.append("- \"@workflow.registry\"");
        _builder.newLine();
      }
    }
    {
      if (((this._utils.targets(it, "1.5")).booleanValue() || this._workflowExtensions.needsApproval(it))) {
        _builder.append("        ");
        _builder.append("- \"@logger\"");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("- \"@zikula_permissions_module.api.permission\"");
        _builder.newLine();
        {
          Boolean _targets_3 = this._utils.targets(it, "1.5");
          if ((_targets_3).booleanValue()) {
            _builder.append("        ");
            _builder.append("- \"@zikula_users_module.current_user\"");
            _builder.newLine();
          }
        }
        _builder.append("        ");
        _builder.append("- \"@");
        _builder.append(this.modPrefix, "        ");
        _builder.append(".entity_factory\"");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("        ");
    _builder.append("- \"@");
    _builder.append(this.modPrefix, "        ");
    _builder.append(".listentries_helper\"");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence twig(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("services:");
    _builder.newLine();
    _builder.append("    ");
    CharSequence _servicesTwig = this.servicesTwig(it);
    _builder.append(_servicesTwig, "    ");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence servicesTwig(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("# Twig extension");
    _builder.newLine();
    String _appNamespace = this._utils.appNamespace(it);
    final String nsBase = (_appNamespace + "\\Twig\\");
    _builder.newLineIfNotEmpty();
    _builder.append(this.modPrefix);
    _builder.append(".twig_extension:");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("class: ");
    _builder.append(nsBase, "    ");
    _builder.append("TwigExtension");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("arguments:");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("- \"@translator.default\"");
    _builder.newLine();
    {
      boolean _hasTrees = this._modelBehaviourExtensions.hasTrees(it);
      if (_hasTrees) {
        _builder.append("        ");
        _builder.append("- \"@router\"");
        _builder.newLine();
      }
    }
    {
      if ((this._generatorSettingsExtensions.generateIcsTemplates(it) && this._modelBehaviourExtensions.hasEntitiesWithIcsTemplates(it))) {
        _builder.append("        ");
        _builder.append("- \"@request_stack\"");
        _builder.newLine();
      }
    }
    _builder.append("        ");
    _builder.append("- \"@zikula_extensions_module.api.variable\"");
    _builder.newLine();
    {
      boolean _needsUserAvatarSupport = this._modelBehaviourExtensions.needsUserAvatarSupport(it);
      if (_needsUserAvatarSupport) {
        _builder.append("        ");
        _builder.append("- \"@zikula_users_module.user_repository\"");
        _builder.newLine();
      }
    }
    {
      boolean _hasTrees_1 = this._modelBehaviourExtensions.hasTrees(it);
      if (_hasTrees_1) {
        _builder.append("        ");
        _builder.append("- \"@");
        _builder.append(this.modPrefix, "        ");
        _builder.append(".entity_factory\"");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("        ");
    _builder.append("- \"@");
    _builder.append(this.modPrefix, "        ");
    _builder.append(".workflow_helper\"");
    _builder.newLineIfNotEmpty();
    {
      boolean _hasListFields = this._modelExtensions.hasListFields(it);
      if (_hasListFields) {
        _builder.append("        ");
        _builder.append("- \"@");
        _builder.append(this.modPrefix, "        ");
        _builder.append(".listentries_helper\"");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("    ");
    _builder.append("public: false");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("tags:");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("- { name: twig.extension }");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence logger(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("services:");
    _builder.newLine();
    _builder.append("    ");
    CharSequence _servicesLogger = this.servicesLogger(it);
    _builder.append(_servicesLogger, "    ");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence servicesLogger(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("# Log processor");
    _builder.newLine();
    _builder.append(this.modPrefix);
    _builder.append(".log.processor:");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("class: Monolog\\Processor\\PsrLogMessageProcessor");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("tags:");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("- { name: monolog.processor }");
    _builder.newLine();
    return _builder;
  }
}

package org.zikula.modulestudio.generator.cartridges.zclassic.view;

import com.google.common.base.Objects;
import com.google.common.collect.Iterables;
import de.guite.modulestudio.metamodel.Application;
import de.guite.modulestudio.metamodel.CustomAction;
import de.guite.modulestudio.metamodel.Entity;
import de.guite.modulestudio.metamodel.EntityTreeType;
import de.guite.modulestudio.metamodel.JoinRelationship;
import de.guite.modulestudio.metamodel.ManyToManyRelationship;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.zikula.modulestudio.generator.cartridges.zclassic.view.Layout;
import org.zikula.modulestudio.generator.cartridges.zclassic.view.additions.Emails;
import org.zikula.modulestudio.generator.cartridges.zclassic.view.extensions.Attributes;
import org.zikula.modulestudio.generator.cartridges.zclassic.view.extensions.Categories;
import org.zikula.modulestudio.generator.cartridges.zclassic.view.extensions.ModerationPanel;
import org.zikula.modulestudio.generator.cartridges.zclassic.view.extensions.StandardFields;
import org.zikula.modulestudio.generator.cartridges.zclassic.view.pagecomponents.FilterSyntaxDialog;
import org.zikula.modulestudio.generator.cartridges.zclassic.view.pagecomponents.Relations;
import org.zikula.modulestudio.generator.cartridges.zclassic.view.pages.Config;
import org.zikula.modulestudio.generator.cartridges.zclassic.view.pages.Custom;
import org.zikula.modulestudio.generator.cartridges.zclassic.view.pages.Delete;
import org.zikula.modulestudio.generator.cartridges.zclassic.view.pages.Display;
import org.zikula.modulestudio.generator.cartridges.zclassic.view.pages.History;
import org.zikula.modulestudio.generator.cartridges.zclassic.view.pages.Index;
import org.zikula.modulestudio.generator.cartridges.zclassic.view.pages.View;
import org.zikula.modulestudio.generator.cartridges.zclassic.view.pages.ViewHierarchy;
import org.zikula.modulestudio.generator.cartridges.zclassic.view.pages.export.Csv;
import org.zikula.modulestudio.generator.cartridges.zclassic.view.pages.export.Ics;
import org.zikula.modulestudio.generator.cartridges.zclassic.view.pages.export.Json;
import org.zikula.modulestudio.generator.cartridges.zclassic.view.pages.export.Kml;
import org.zikula.modulestudio.generator.cartridges.zclassic.view.pages.export.Xml;
import org.zikula.modulestudio.generator.cartridges.zclassic.view.pages.feed.Atom;
import org.zikula.modulestudio.generator.cartridges.zclassic.view.pages.feed.Rss;
import org.zikula.modulestudio.generator.extensions.ControllerExtensions;
import org.zikula.modulestudio.generator.extensions.GeneratorSettingsExtensions;
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;
import org.zikula.modulestudio.generator.extensions.WorkflowExtensions;

@SuppressWarnings("all")
public class Views {
  @Extension
  private ControllerExtensions _controllerExtensions = new ControllerExtensions();
  
  @Extension
  private GeneratorSettingsExtensions _generatorSettingsExtensions = new GeneratorSettingsExtensions();
  
  @Extension
  private ModelExtensions _modelExtensions = new ModelExtensions();
  
  @Extension
  private ModelBehaviourExtensions _modelBehaviourExtensions = new ModelBehaviourExtensions();
  
  @Extension
  private ModelJoinExtensions _modelJoinExtensions = new ModelJoinExtensions();
  
  @Extension
  private Utils _utils = new Utils();
  
  @Extension
  private WorkflowExtensions _workflowExtensions = new WorkflowExtensions();
  
  private IFileSystemAccess fsa;
  
  private Layout layoutHelper;
  
  private Relations relationHelper;
  
  public void generate(final Application it, final IFileSystemAccess fsa) {
    this.fsa = fsa;
    Layout _layout = new Layout(fsa);
    this.layoutHelper = _layout;
    Relations _relations = new Relations();
    this.relationHelper = _relations;
    Iterable<Entity> _allEntities = this._modelExtensions.getAllEntities(it);
    for (final Entity entity : _allEntities) {
      this.generateViews(it, entity);
    }
    boolean _hasAttributableEntities = this._modelBehaviourExtensions.hasAttributableEntities(it);
    if (_hasAttributableEntities) {
      new Attributes().generate(it, fsa);
    }
    boolean _hasCategorisableEntities = this._modelBehaviourExtensions.hasCategorisableEntities(it);
    if (_hasCategorisableEntities) {
      new Categories().generate(it, fsa);
    }
    if ((this._generatorSettingsExtensions.generateModerationPanel(it) && this._workflowExtensions.needsApproval(it))) {
      new ModerationPanel().generate(it, fsa);
    }
    boolean _hasStandardFieldEntities = this._modelBehaviourExtensions.hasStandardFieldEntities(it);
    if (_hasStandardFieldEntities) {
      new StandardFields().generate(it, fsa);
    }
    this.layoutHelper.baseTemplates(it);
    new FilterSyntaxDialog().generate(it, fsa);
    boolean _needsConfig = this._utils.needsConfig(it);
    if (_needsConfig) {
      new Config().generate(it, fsa);
    }
    boolean _needsApproval = this._workflowExtensions.needsApproval(it);
    if (_needsApproval) {
      new Emails().generate(it, fsa);
    }
    if ((this._generatorSettingsExtensions.generateExternalControllerAndFinder(it) || (!IterableExtensions.isEmpty(this._modelJoinExtensions.getJoinRelations(it))))) {
      this.layoutHelper.rawPageFile(it);
    }
    this.layoutHelper.pdfHeaderFile(it);
  }
  
  private void generateViews(final Application it, final Entity entity) {
    boolean _hasIndexAction = this._controllerExtensions.hasIndexAction(entity);
    if (_hasIndexAction) {
      new Index().generate(entity, this.fsa);
    }
    boolean _hasViewAction = this._controllerExtensions.hasViewAction(entity);
    if (_hasViewAction) {
      new View().generate(entity, this._utils.appName(it), Integer.valueOf(3), this.fsa);
      EntityTreeType _tree = entity.getTree();
      boolean _notEquals = (!Objects.equal(_tree, EntityTreeType.NONE));
      if (_notEquals) {
        new ViewHierarchy().generate(entity, this._utils.appName(it), this.fsa);
      }
      boolean _generateCsvTemplates = this._generatorSettingsExtensions.generateCsvTemplates(it);
      if (_generateCsvTemplates) {
        new Csv().generate(entity, this._utils.appName(it), this.fsa);
      }
      boolean _generateRssTemplates = this._generatorSettingsExtensions.generateRssTemplates(it);
      if (_generateRssTemplates) {
        new Rss().generate(entity, this._utils.appName(it), this.fsa);
      }
      boolean _generateAtomTemplates = this._generatorSettingsExtensions.generateAtomTemplates(it);
      if (_generateAtomTemplates) {
        new Atom().generate(entity, this._utils.appName(it), this.fsa);
      }
    }
    if ((this._controllerExtensions.hasViewAction(entity) || this._controllerExtensions.hasDisplayAction(entity))) {
      boolean _generateXmlTemplates = this._generatorSettingsExtensions.generateXmlTemplates(it);
      if (_generateXmlTemplates) {
        new Xml().generate(entity, this._utils.appName(it), this.fsa);
      }
      boolean _generateJsonTemplates = this._generatorSettingsExtensions.generateJsonTemplates(it);
      if (_generateJsonTemplates) {
        new Json().generate(entity, this._utils.appName(it), this.fsa);
      }
      if ((this._generatorSettingsExtensions.generateKmlTemplates(it) && entity.isGeographical())) {
        new Kml().generate(entity, this._utils.appName(it), this.fsa);
      }
    }
    boolean _hasDisplayAction = this._controllerExtensions.hasDisplayAction(entity);
    if (_hasDisplayAction) {
      if (((this._generatorSettingsExtensions.generateIcsTemplates(it) && (null != this._modelExtensions.getStartDateField(entity))) && (null != this._modelExtensions.getEndDateField(entity)))) {
        new Ics().generate(entity, this._utils.appName(it), this.fsa);
      }
    }
    boolean _hasDisplayAction_1 = this._controllerExtensions.hasDisplayAction(entity);
    if (_hasDisplayAction_1) {
      new Display().generate(entity, this._utils.appName(it), this.fsa);
    }
    boolean _hasDeleteAction = this._controllerExtensions.hasDeleteAction(entity);
    if (_hasDeleteAction) {
      new Delete().generate(entity, this._utils.appName(it), this.fsa);
    }
    boolean _isLoggable = entity.isLoggable();
    if (_isLoggable) {
      new History().generate(entity, this._utils.appName(it), this.fsa);
    }
    Custom customHelper = new Custom();
    Iterable<CustomAction> _customActions = this._controllerExtensions.getCustomActions(entity);
    for (final CustomAction action : _customActions) {
      customHelper.generate(action, it, entity, this.fsa);
    }
    final Function1<ManyToManyRelationship, Boolean> _function = (ManyToManyRelationship e) -> {
      return Boolean.valueOf(((e.getTarget() instanceof Entity) && Objects.equal(e.getTarget().getApplication(), entity.getApplication())));
    };
    Iterable<ManyToManyRelationship> _filter = IterableExtensions.<ManyToManyRelationship>filter(Iterables.<ManyToManyRelationship>filter(entity.getOutgoing(), ManyToManyRelationship.class), _function);
    final Function1<JoinRelationship, Boolean> _function_1 = (JoinRelationship e) -> {
      return Boolean.valueOf(((e.getSource() instanceof Entity) && Objects.equal(e.getSource().getApplication(), entity.getApplication())));
    };
    Iterable<JoinRelationship> _filter_1 = IterableExtensions.<JoinRelationship>filter(this._modelJoinExtensions.getIncomingJoinRelations(entity), _function_1);
    final Iterable<JoinRelationship> refedElems = Iterables.<JoinRelationship>concat(_filter, _filter_1);
    boolean _isEmpty = IterableExtensions.isEmpty(refedElems);
    boolean _not = (!_isEmpty);
    if (_not) {
      this.relationHelper.displayItemList(entity, it, Boolean.valueOf(false), this.fsa);
      this.relationHelper.displayItemList(entity, it, Boolean.valueOf(true), this.fsa);
    }
  }
}

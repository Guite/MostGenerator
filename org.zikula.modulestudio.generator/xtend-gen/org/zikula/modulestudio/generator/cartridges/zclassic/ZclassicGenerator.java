package org.zikula.modulestudio.generator.cartridges.zclassic;

import com.google.inject.Inject;
import de.guite.modulestudio.metamodel.modulestudio.AdminController;
import de.guite.modulestudio.metamodel.modulestudio.Application;
import de.guite.modulestudio.metamodel.modulestudio.Entity;
import de.guite.modulestudio.metamodel.modulestudio.UserController;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.emf.common.util.EList;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.generator.IGenerator;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.InputOutput;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.ControllerLayer;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.FormHandler;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.Installer;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.Listeners;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.Uploads;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.Workflow;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.additions.Newsletter;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.additions.Tag;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.apis.Account;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.apis.BlockList;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.apis.BlockModeration;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.apis.Cache;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.apis.ContentTypeList;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.apis.ContentTypeSingle;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.apis.Mailz;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.apis.Search;
import org.zikula.modulestudio.generator.cartridges.zclassic.models.Entities;
import org.zikula.modulestudio.generator.cartridges.zclassic.models.Repository;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.Bootstrap;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.ComposerFile;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.Docs;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.GitIgnore;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.ModuleFile;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.PhpUnitXmlDist;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.Translations;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.TravisFile;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.VersionFile;
import org.zikula.modulestudio.generator.cartridges.zclassic.tests.Tests;
import org.zikula.modulestudio.generator.cartridges.zclassic.view.Forms;
import org.zikula.modulestudio.generator.cartridges.zclassic.view.Images;
import org.zikula.modulestudio.generator.cartridges.zclassic.view.Plugins;
import org.zikula.modulestudio.generator.cartridges.zclassic.view.Styles;
import org.zikula.modulestudio.generator.cartridges.zclassic.view.Views;
import org.zikula.modulestudio.generator.extensions.ControllerExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.WorkflowExtensions;

@SuppressWarnings("all")
public class ZclassicGenerator implements IGenerator {
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
  private ModelExtensions _modelExtensions = new Function0<ModelExtensions>() {
    public ModelExtensions apply() {
      ModelExtensions _modelExtensions = new ModelExtensions();
      return _modelExtensions;
    }
  }.apply();
  
  @Inject
  @Extension
  private WorkflowExtensions _workflowExtensions = new Function0<WorkflowExtensions>() {
    public WorkflowExtensions apply() {
      WorkflowExtensions _workflowExtensions = new WorkflowExtensions();
      return _workflowExtensions;
    }
  }.apply();
  
  public void doGenerate(final Resource resource, final IFileSystemAccess fsa) {
    EList<EObject> _contents = resource.getContents();
    EObject _head = IterableExtensions.<EObject>head(_contents);
    this.generate(((Application) _head), fsa);
  }
  
  public void generate(final Application it, final IFileSystemAccess fsa) {
    this.generate(it, fsa, null);
  }
  
  public void generate(final Application it, final IFileSystemAccess fsa, final IProgressMonitor pm) {
    if (pm!=null) {
      pm.subTask("Basic information");
    }
    InputOutput.<String>println("Generating basic information");
    ModuleFile _moduleFile = new ModuleFile();
    _moduleFile.generate(it, fsa);
    VersionFile _versionFile = new VersionFile();
    _versionFile.generate(it, fsa);
    ComposerFile _composerFile = new ComposerFile();
    _composerFile.generate(it, fsa);
    GitIgnore _gitIgnore = new GitIgnore();
    _gitIgnore.generate(it, fsa);
    TravisFile _travisFile = new TravisFile();
    _travisFile.generate(it, fsa);
    PhpUnitXmlDist _phpUnitXmlDist = new PhpUnitXmlDist();
    _phpUnitXmlDist.generate(it, fsa);
    if (pm!=null) {
      pm.subTask("Model: Entity classes");
    }
    InputOutput.<String>println("Generating entity classes");
    Entities _entities = new Entities();
    _entities.generate(it, fsa);
    if (pm!=null) {
      pm.subTask("Model: Repository classes");
    }
    InputOutput.<String>println("Generating repository classes");
    Repository _repository = new Repository();
    _repository.generate(it, fsa);
    if (pm!=null) {
      pm.subTask("Controller: Application installer");
    }
    InputOutput.<String>println("Generating application installer");
    Installer _installer = new Installer();
    _installer.generate(it, fsa);
    if (pm!=null) {
      pm.subTask("Controller: Controller classes");
    }
    InputOutput.<String>println("Generating controller classes");
    ControllerLayer _controllerLayer = new ControllerLayer();
    _controllerLayer.generate(it, fsa);
    if (pm!=null) {
      pm.subTask("Controller: Action handler classes");
    }
    InputOutput.<String>println("Generating action handler classes");
    FormHandler _formHandler = new FormHandler();
    _formHandler.generate(it, fsa);
    if (pm!=null) {
      pm.subTask("Controller: Persistent event handlers");
    }
    InputOutput.<String>println("Generating persistent event handlers");
    Listeners _listeners = new Listeners();
    _listeners.generate(it, fsa);
    if (pm!=null) {
      pm.subTask("Controller: Bootstrapping");
    }
    InputOutput.<String>println("Generating bootstrapping");
    Bootstrap _bootstrap = new Bootstrap();
    _bootstrap.generate(it, fsa);
    if (pm!=null) {
      pm.subTask("Controller: Workflows");
    }
    InputOutput.<String>println("Generating workflows");
    Workflow _workflow = new Workflow();
    _workflow.generate(it, fsa);
    if (pm!=null) {
      pm.subTask("View: Rendering templates");
    }
    InputOutput.<String>println("Generating view templates");
    Views _views = new Views();
    _views.generate(it, fsa);
    if (pm!=null) {
      pm.subTask("View: Form templates");
    }
    InputOutput.<String>println("Generating form templates");
    Forms _forms = new Forms();
    _forms.generate(it, fsa);
    if (pm!=null) {
      pm.subTask("View: Module-specific plugins");
    }
    InputOutput.<String>println("Generating application-specific plugins");
    Plugins _plugins = new Plugins();
    _plugins.generate(it, fsa);
    if (pm!=null) {
      pm.subTask("View: CSS definitions");
    }
    InputOutput.<String>println("Generating css definitions");
    Styles _styles = new Styles();
    _styles.generate(it, fsa);
    if (pm!=null) {
      pm.subTask("View: Images");
    }
    InputOutput.<String>println("Generating images");
    Images _images = new Images();
    _images.generate(it, fsa);
    if (pm!=null) {
      pm.subTask("Additions: Blocks");
    }
    InputOutput.<String>println("Generating blocks");
    BlockList _blockList = new BlockList();
    _blockList.generate(it, fsa);
    boolean _needsApproval = this._workflowExtensions.needsApproval(it);
    if (_needsApproval) {
      BlockModeration _blockModeration = new BlockModeration();
      _blockModeration.generate(it, fsa);
    }
    if (pm!=null) {
      pm.subTask("Additions: Content type api");
    }
    InputOutput.<String>println("Generating content type api");
    ContentTypeList _contentTypeList = new ContentTypeList();
    _contentTypeList.generate(it, fsa);
    boolean _and = false;
    boolean _hasUserController = this._controllerExtensions.hasUserController(it);
    if (!_hasUserController) {
      _and = false;
    } else {
      UserController _mainUserController = this._controllerExtensions.getMainUserController(it);
      boolean _hasActions = this._controllerExtensions.hasActions(_mainUserController, "display");
      _and = (_hasUserController && _hasActions);
    }
    if (_and) {
      ContentTypeSingle _contentTypeSingle = new ContentTypeSingle();
      _contentTypeSingle.generate(it, fsa);
    }
    if (pm!=null) {
      pm.subTask("Additions: Newsletter plugin");
    }
    InputOutput.<String>println("Generating newsletter plugin");
    Newsletter _newsletter = new Newsletter();
    _newsletter.generate(it, fsa);
    if (pm!=null) {
      pm.subTask("Additions: Mailz api");
    }
    InputOutput.<String>println("Generating mailz api");
    Mailz _mailz = new Mailz();
    _mailz.generate(it, fsa);
    if (pm!=null) {
      pm.subTask("Additions: Account api");
    }
    InputOutput.<String>println("Generating account api");
    Account _account = new Account();
    _account.generate(it, fsa);
    if (pm!=null) {
      pm.subTask("Additions: Cache api");
    }
    InputOutput.<String>println("Generating cache api");
    Cache _cache = new Cache();
    _cache.generate(it, fsa);
    EList<Entity> _allEntities = this._modelExtensions.getAllEntities(it);
    final Function1<Entity,Boolean> _function = new Function1<Entity,Boolean>() {
        public Boolean apply(final Entity e) {
          boolean _hasAbstractStringFieldsEntity = ZclassicGenerator.this._modelExtensions.hasAbstractStringFieldsEntity(e);
          return Boolean.valueOf(_hasAbstractStringFieldsEntity);
        }
      };
    Iterable<Entity> _filter = IterableExtensions.<Entity>filter(_allEntities, _function);
    boolean _isEmpty = IterableExtensions.isEmpty(_filter);
    boolean _not = (!_isEmpty);
    if (_not) {
      if (pm!=null) {
        pm.subTask("Additions: Search api");
      }
      InputOutput.<String>println("Generating search api");
      Search _search = new Search();
      _search.generate(it, fsa);
    }
    boolean _hasUploads = this._modelExtensions.hasUploads(it);
    if (_hasUploads) {
      if (pm!=null) {
        pm.subTask("Additions: Upload handlers");
      }
      InputOutput.<String>println("Generating upload handlers");
      Uploads _uploads = new Uploads();
      _uploads.generate(it, fsa);
    }
    boolean _or = false;
    boolean _and_1 = false;
    boolean _hasUserController_1 = this._controllerExtensions.hasUserController(it);
    if (!_hasUserController_1) {
      _and_1 = false;
    } else {
      UserController _mainUserController_1 = this._controllerExtensions.getMainUserController(it);
      boolean _hasActions_1 = this._controllerExtensions.hasActions(_mainUserController_1, "display");
      _and_1 = (_hasUserController_1 && _hasActions_1);
    }
    if (_and_1) {
      _or = true;
    } else {
      boolean _and_2 = false;
      Iterable<AdminController> _allAdminControllers = this._controllerExtensions.getAllAdminControllers(it);
      boolean _isEmpty_1 = IterableExtensions.isEmpty(_allAdminControllers);
      boolean _not_1 = (!_isEmpty_1);
      if (!_not_1) {
        _and_2 = false;
      } else {
        Iterable<AdminController> _allAdminControllers_1 = this._controllerExtensions.getAllAdminControllers(it);
        AdminController _head = IterableExtensions.<AdminController>head(_allAdminControllers_1);
        boolean _hasActions_2 = this._controllerExtensions.hasActions(_head, "display");
        _and_2 = (_not_1 && _hasActions_2);
      }
      _or = (_and_1 || _and_2);
    }
    if (_or) {
      if (pm!=null) {
        pm.subTask("Additions: Tag support");
      }
      InputOutput.<String>println("Generating tag support");
      Tag _tag = new Tag();
      _tag.generate(it, fsa);
    }
    if (pm!=null) {
      pm.subTask("Additions: Translations");
    }
    InputOutput.<String>println("Generating translations");
    Translations _translations = new Translations();
    _translations.generate(it, fsa);
    if (pm!=null) {
      pm.subTask("Additions: Documentation");
    }
    InputOutput.<String>println("Generating documentation");
    Docs _docs = new Docs();
    _docs.generate(it, fsa);
    if (pm!=null) {
      pm.subTask("Additions: Tests");
    }
    InputOutput.<String>println("Generating unit tests");
    Tests _tests = new Tests();
    _tests.generate(it, fsa);
  }
}

package org.zikula.modulestudio.generator.cartridges.zclassic;

import de.guite.modulestudio.metamodel.Application;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.generator.IGenerator;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.InputOutput;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.ControllerLayer;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.Events;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.FormHandler;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.HelperServices;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.Installer;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.Listeners;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.ServiceDefinitions;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.Uploads;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.Workflow;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.additions.BlockList;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.additions.BlockModeration;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.additions.ContentTypeList;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.additions.ContentTypeSingle;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.additions.Mailz;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.additions.MultiHook;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.additions.Newsletter;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.additions.Tag;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.javascript.ConfigFunctions;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.javascript.DisplayFunctions;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.javascript.EditFunctions;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.javascript.Finder;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.javascript.GeoFunctions;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.javascript.TreeFunctions;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.javascript.Validation;
import org.zikula.modulestudio.generator.cartridges.zclassic.models.Entities;
import org.zikula.modulestudio.generator.cartridges.zclassic.models.Factory;
import org.zikula.modulestudio.generator.cartridges.zclassic.models.Repository;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.Bootstrap;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.ComposerFile;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.DependencyInjection;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.Docs;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.GitIgnore;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.ModuleFile;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.PhpUnitXmlDist;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.Translations;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.TravisFile;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.ZikulaManifest;
import org.zikula.modulestudio.generator.cartridges.zclassic.tests.Tests;
import org.zikula.modulestudio.generator.cartridges.zclassic.view.Forms;
import org.zikula.modulestudio.generator.cartridges.zclassic.view.Images;
import org.zikula.modulestudio.generator.cartridges.zclassic.view.Plugins;
import org.zikula.modulestudio.generator.cartridges.zclassic.view.Styles;
import org.zikula.modulestudio.generator.cartridges.zclassic.view.Views;
import org.zikula.modulestudio.generator.extensions.ControllerExtensions;
import org.zikula.modulestudio.generator.extensions.GeneratorSettingsExtensions;
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.WorkflowExtensions;

@SuppressWarnings("all")
public class ZclassicGenerator implements IGenerator {
  @Extension
  private ControllerExtensions _controllerExtensions = new ControllerExtensions();
  
  @Extension
  private GeneratorSettingsExtensions _generatorSettingsExtensions = new GeneratorSettingsExtensions();
  
  @Extension
  private ModelBehaviourExtensions _modelBehaviourExtensions = new ModelBehaviourExtensions();
  
  @Extension
  private ModelExtensions _modelExtensions = new ModelExtensions();
  
  @Extension
  private WorkflowExtensions _workflowExtensions = new WorkflowExtensions();
  
  private IFileSystemAccess fsa;
  
  private IProgressMonitor pm;
  
  @Override
  public void doGenerate(final Resource resource, final IFileSystemAccess fsa) {
    this.fsa = fsa;
    this.pm = null;
    EObject _head = IterableExtensions.<EObject>head(resource.getContents());
    this.generateApp(((Application) _head));
  }
  
  public void generate(final Application it, final IFileSystemAccess fsa, final IProgressMonitor pm) {
    this.fsa = fsa;
    this.pm = pm;
    this.generateApp(it);
  }
  
  private void generateApp(final Application it) {
    this.generateBasicFiles(it);
    this.generateModel(it);
    this.generateController(it);
    this.generateView(it);
    this.generateIntegration(it);
    this.generateAdditions(it);
  }
  
  private void generateBasicFiles(final Application it) {
    if (this.pm!=null) {
      this.pm.subTask("Basic information");
    }
    InputOutput.<String>println("Generating basic information");
    new ModuleFile().generate(it, this.fsa);
    new DependencyInjection().generate(it, this.fsa);
    new ComposerFile().generate(it, this.fsa);
    new ZikulaManifest().generate(it, this.fsa);
    new GitIgnore().generate(it, this.fsa);
    new TravisFile().generate(it, this.fsa);
    new PhpUnitXmlDist().generate(it, this.fsa);
  }
  
  private void generateModel(final Application it) {
    if (this.pm!=null) {
      this.pm.subTask("Model: Entity classes");
    }
    InputOutput.<String>println("Generating entity classes");
    new Entities().generate(it, this.fsa);
    if (this.pm!=null) {
      this.pm.subTask("Model: Repository classes");
    }
    InputOutput.<String>println("Generating repository classes");
    new Repository().generate(it, this.fsa);
    if (this.pm!=null) {
      this.pm.subTask("Model: Factory class");
    }
    InputOutput.<String>println("Generating factory class");
    new Factory().generate(it, this.fsa);
  }
  
  private void generateController(final Application it) {
    if (this.pm!=null) {
      this.pm.subTask("Controller: Application installer");
    }
    InputOutput.<String>println("Generating application installer");
    new Installer().generate(it, this.fsa);
    if (this.pm!=null) {
      this.pm.subTask("Controller: Controller classes");
    }
    InputOutput.<String>println("Generating controller classes");
    new ControllerLayer().generate(it, this.fsa);
    if (this.pm!=null) {
      this.pm.subTask("Controller: Helper service classes");
    }
    InputOutput.<String>println("Generating helper service classes");
    new HelperServices().generate(it, this.fsa);
    if (this.pm!=null) {
      this.pm.subTask("Controller: Action handler classes");
    }
    InputOutput.<String>println("Generating action handler classes");
    new FormHandler().generate(it, this.fsa);
    if (this.pm!=null) {
      this.pm.subTask("Controller: Event listeners");
    }
    InputOutput.<String>println("Generating Event listeners");
    new Listeners().generate(it, this.fsa);
    if (this.pm!=null) {
      this.pm.subTask("Controller: Service definitions");
    }
    InputOutput.<String>println("Generating service definitions");
    new ServiceDefinitions().generate(it, this.fsa);
    if (this.pm!=null) {
      this.pm.subTask("Controller: Custom event definitions");
    }
    InputOutput.<String>println("Generating custom event definitions");
    new Events().generate(it, this.fsa);
    if (this.pm!=null) {
      this.pm.subTask("Controller: Bootstrapping");
    }
    InputOutput.<String>println("Generating bootstrapping");
    new Bootstrap().generate(it, this.fsa);
    if (this.pm!=null) {
      this.pm.subTask("Controller: Workflows");
    }
    InputOutput.<String>println("Generating workflows");
    new Workflow().generate(it, this.fsa);
    boolean _hasUploads = this._modelExtensions.hasUploads(it);
    if (_hasUploads) {
      if (this.pm!=null) {
        this.pm.subTask("Controller: Upload handlers");
      }
      InputOutput.<String>println("Generating upload handlers");
      new Uploads().generate(it, this.fsa);
    }
    if (this.pm!=null) {
      this.pm.subTask("Controller: JavaScript files");
    }
    InputOutput.<String>println("Generating JavaScript files");
    boolean _hasImageFields = this._modelExtensions.hasImageFields(it);
    if (_hasImageFields) {
      new ConfigFunctions().generate(it, this.fsa);
    }
    new DisplayFunctions().generate(it, this.fsa);
    boolean _hasEditActions = this._controllerExtensions.hasEditActions(it);
    if (_hasEditActions) {
      new EditFunctions().generate(it, this.fsa);
    }
    final boolean needsDetailContentType = (this._generatorSettingsExtensions.generateDetailContentType(it) && this._controllerExtensions.hasDisplayActions(it));
    if ((this._generatorSettingsExtensions.generateExternalControllerAndFinder(it) || needsDetailContentType)) {
      new Finder().generate(it, this.fsa);
    }
    boolean _hasGeographical = this._modelBehaviourExtensions.hasGeographical(it);
    if (_hasGeographical) {
      new GeoFunctions().generate(it, this.fsa);
    }
    boolean _hasTrees = this._modelBehaviourExtensions.hasTrees(it);
    if (_hasTrees) {
      new TreeFunctions().generate(it, this.fsa);
    }
    new Validation().generate(it, this.fsa);
  }
  
  private Object generateView(final Application it) {
    Object _xblockexpression = null;
    {
      if (this.pm!=null) {
        this.pm.subTask("View: Rendering templates");
      }
      InputOutput.<String>println("Generating view templates");
      new Views().generate(it, this.fsa);
      if (this.pm!=null) {
        this.pm.subTask("View: Form templates");
      }
      InputOutput.<String>println("Generating form templates");
      new Forms().generate(it, this.fsa);
      if (this.pm!=null) {
        this.pm.subTask("View: Module-specific plugins");
      }
      InputOutput.<String>println("Generating application-specific plugins");
      new Plugins().generate(it, this.fsa);
      if (this.pm!=null) {
        this.pm.subTask("View: CSS definitions");
      }
      InputOutput.<String>println("Generating css definitions");
      new Styles().generate(it, this.fsa);
      if (this.pm!=null) {
        this.pm.subTask("View: Images");
      }
      InputOutput.<String>println("Generating images");
      _xblockexpression = new Images().generate(it, this.fsa);
    }
    return _xblockexpression;
  }
  
  private void generateIntegration(final Application it) {
    this.generateIntegrationBlocks(it);
    this.generateIntegrationContentTypes(it);
    this.generateIntegrationThirdParty(it);
  }
  
  private void generateIntegrationBlocks(final Application it) {
    final boolean needsModerationBlock = (this._generatorSettingsExtensions.generateModerationBlock(it) && this._workflowExtensions.needsApproval(it));
    if ((this._generatorSettingsExtensions.generateListBlock(it) || needsModerationBlock)) {
      if (this.pm!=null) {
        this.pm.subTask("Integration: Blocks");
      }
      InputOutput.<String>println("Generating blocks");
      boolean _generateListBlock = this._generatorSettingsExtensions.generateListBlock(it);
      if (_generateListBlock) {
        new BlockList().generate(it, this.fsa);
      }
      if (needsModerationBlock) {
        new BlockModeration().generate(it, this.fsa);
      }
    }
  }
  
  private void generateIntegrationContentTypes(final Application it) {
    final boolean needsDetailContentType = (this._generatorSettingsExtensions.generateDetailContentType(it) && this._controllerExtensions.hasDisplayActions(it));
    if ((this._generatorSettingsExtensions.generateListContentType(it) || needsDetailContentType)) {
      if (this.pm!=null) {
        this.pm.subTask("Integration: Content types");
      }
      InputOutput.<String>println("Generating content types");
      boolean _generateListContentType = this._generatorSettingsExtensions.generateListContentType(it);
      if (_generateListContentType) {
        new ContentTypeList().generate(it, this.fsa);
      }
      if (needsDetailContentType) {
        new ContentTypeSingle().generate(it, this.fsa);
      }
    }
  }
  
  private void generateIntegrationThirdParty(final Application it) {
    boolean _generateNewsletterPlugin = this._generatorSettingsExtensions.generateNewsletterPlugin(it);
    if (_generateNewsletterPlugin) {
      if (this.pm!=null) {
        this.pm.subTask("Integration: Newsletter plugin");
      }
      InputOutput.<String>println("Generating newsletter plugin");
      new Newsletter().generate(it, this.fsa);
    }
    boolean _generateMailzApi = this._generatorSettingsExtensions.generateMailzApi(it);
    if (_generateMailzApi) {
      if (this.pm!=null) {
        this.pm.subTask("Integration: Mailz api");
      }
      InputOutput.<String>println("Generating mailz api");
      new Mailz().generate(it, this.fsa);
    }
    boolean _generateMultiHookNeedles = this._generatorSettingsExtensions.generateMultiHookNeedles(it);
    if (_generateMultiHookNeedles) {
      if (this.pm!=null) {
        this.pm.subTask("Integration: MultiHook needles");
      }
      InputOutput.<String>println("Generating MultiHook needles");
      new MultiHook().generate(it, this.fsa);
    }
    if ((this._generatorSettingsExtensions.generateTagSupport(it) && this._controllerExtensions.hasDisplayActions(it))) {
      if (this.pm!=null) {
        this.pm.subTask("Integration: Tag support");
      }
      InputOutput.<String>println("Generating tag support");
      new Tag().generate(it, this.fsa);
    }
  }
  
  private void generateAdditions(final Application it) {
    if (this.pm!=null) {
      this.pm.subTask("Additions: Translations");
    }
    InputOutput.<String>println("Generating translations");
    new Translations().generate(it, this.fsa);
    if (this.pm!=null) {
      this.pm.subTask("Additions: Documentation");
    }
    InputOutput.<String>println("Generating documentation");
    new Docs().generate(it, this.fsa);
    boolean _generateTests = this._generatorSettingsExtensions.generateTests(it);
    if (_generateTests) {
      if (this.pm!=null) {
        this.pm.subTask("Additions: Tests");
      }
      InputOutput.<String>println("Generating unit tests");
      new Tests().generate(it, this.fsa);
    }
  }
}

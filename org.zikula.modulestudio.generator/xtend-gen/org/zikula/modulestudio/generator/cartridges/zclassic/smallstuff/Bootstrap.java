package org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff;

import com.google.inject.Inject;
import de.guite.modulestudio.metamodel.modulestudio.AbstractDateField;
import de.guite.modulestudio.metamodel.modulestudio.Application;
import de.guite.modulestudio.metamodel.modulestudio.Entity;
import de.guite.modulestudio.metamodel.modulestudio.ReferredApplication;
import org.eclipse.emf.common.util.EList;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class Bootstrap {
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
  
  public void generate(final Application it, final IFileSystemAccess fsa) {
    String _appSourcePath = this._namingExtensions.getAppSourcePath(it);
    String _plus = (_appSourcePath + "bootstrap.php");
    CharSequence _bootstrapFile = this.bootstrapFile(it);
    fsa.generateFile(_plus, _bootstrapFile);
  }
  
  private CharSequence bootstrapFile(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    FileHelper _fileHelper = new FileHelper();
    CharSequence _phpFileHeader = _fileHelper.phpFileHeader(it);
    _builder.append(_phpFileHeader, "");
    _builder.newLineIfNotEmpty();
    CharSequence _bootstrapImpl = this.bootstrapImpl(it);
    _builder.append(_bootstrapImpl, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence bootstrapImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Bootstrap called when application is first initialised at runtime.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* This is only called once, and only if the core has reason to initialise this module,");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* usually to dispatch a controller request or API.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* For example you can register additional AutoLoaders with ZLoader::addAutoloader($namespace, $path)");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* whereby $namespace is the first part of the PEAR class name");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* and $path is the path to the containing folder.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    CharSequence _initExtensions = this.initExtensions(it);
    _builder.append(_initExtensions, "");
    _builder.newLineIfNotEmpty();
    {
      EList<ReferredApplication> _referredApplications = it.getReferredApplications();
      boolean _isEmpty = _referredApplications.isEmpty();
      boolean _not = (!_isEmpty);
      if (_not) {
        _builder.newLine();
        {
          EList<ReferredApplication> _referredApplications_1 = it.getReferredApplications();
          for(final ReferredApplication referredApp : _referredApplications_1) {
            _builder.append("if (ModUtil::available(\'");
            String _name = referredApp.getName();
            String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(_name);
            _builder.append(_formatForCodeCapital, "");
            _builder.append("\')) {");
            _builder.newLineIfNotEmpty();
            _builder.append("    ");
            _builder.append("// load Doctrine 2 data of ");
            String _name_1 = referredApp.getName();
            String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(_name_1);
            _builder.append(_formatForCodeCapital_1, "    ");
            _builder.newLineIfNotEmpty();
            _builder.append("    ");
            _builder.append("ModUtil::initOOModule(\'");
            String _name_2 = referredApp.getName();
            String _formatForCodeCapital_2 = this._formattingExtensions.formatForCodeCapital(_name_2);
            _builder.append(_formatForCodeCapital_2, "    ");
            _builder.append("\');");
            _builder.newLineIfNotEmpty();
            _builder.append("}");
            _builder.newLine();
          }
        }
      }
    }
    CharSequence _archiveObjectsCall = this.archiveObjectsCall(it);
    _builder.append(_archiveObjectsCall, "");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence initExtensions(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _or = false;
      boolean _or_1 = false;
      boolean _or_2 = false;
      boolean _or_3 = false;
      boolean _or_4 = false;
      boolean _or_5 = false;
      boolean _hasTrees = this._modelBehaviourExtensions.hasTrees(it);
      if (_hasTrees) {
        _or_5 = true;
      } else {
        boolean _hasLoggable = this._modelBehaviourExtensions.hasLoggable(it);
        _or_5 = (_hasTrees || _hasLoggable);
      }
      if (_or_5) {
        _or_4 = true;
      } else {
        boolean _hasSluggable = this._modelBehaviourExtensions.hasSluggable(it);
        _or_4 = (_or_5 || _hasSluggable);
      }
      if (_or_4) {
        _or_3 = true;
      } else {
        boolean _hasSortable = this._modelBehaviourExtensions.hasSortable(it);
        _or_3 = (_or_4 || _hasSortable);
      }
      if (_or_3) {
        _or_2 = true;
      } else {
        boolean _hasTimestampable = this._modelBehaviourExtensions.hasTimestampable(it);
        _or_2 = (_or_3 || _hasTimestampable);
      }
      if (_or_2) {
        _or_1 = true;
      } else {
        boolean _hasTranslatable = this._modelBehaviourExtensions.hasTranslatable(it);
        _or_1 = (_or_2 || _hasTranslatable);
      }
      if (_or_1) {
        _or = true;
      } else {
        boolean _hasStandardFieldEntities = this._modelBehaviourExtensions.hasStandardFieldEntities(it);
        _or = (_or_1 || _hasStandardFieldEntities);
      }
      if (_or) {
        _builder.append("// initialise doctrine extension listeners");
        _builder.newLine();
        _builder.append("$helper = ServiceUtil::getService(\'doctrine_extensions\');");
        _builder.newLine();
        {
          boolean _hasTrees_1 = this._modelBehaviourExtensions.hasTrees(it);
          if (_hasTrees_1) {
            _builder.append("$helper->getListener(\'tree\');");
            _builder.newLine();
          }
        }
        {
          boolean _hasLoggable_1 = this._modelBehaviourExtensions.hasLoggable(it);
          if (_hasLoggable_1) {
            _builder.append("$loggableListener = $helper->getListener(\'loggable\');");
            _builder.newLine();
            _builder.append("// set current user name to loggable listener");
            _builder.newLine();
            _builder.append("$userName = UserUtil::isLoggedIn() ? UserUtil::getVar(\'uname\') : __(\'Guest\');");
            _builder.newLine();
            _builder.append("$loggableListener->setUsername($userName);");
            _builder.newLine();
          }
        }
        {
          boolean _hasSluggable_1 = this._modelBehaviourExtensions.hasSluggable(it);
          if (_hasSluggable_1) {
            _builder.append("$helper->getListener(\'sluggable\');");
            _builder.newLine();
          }
        }
        {
          boolean _and = false;
          boolean _hasSoftDeleteable = this._modelBehaviourExtensions.hasSoftDeleteable(it);
          if (!_hasSoftDeleteable) {
            _and = false;
          } else {
            boolean _targets = this._utils.targets(it, "1.3.5");
            boolean _not = (!_targets);
            _and = (_hasSoftDeleteable && _not);
          }
          if (_and) {
            _builder.append("$helper->getListener(\'softdeleteable\');");
            _builder.newLine();
          }
        }
        {
          boolean _hasSortable_1 = this._modelBehaviourExtensions.hasSortable(it);
          if (_hasSortable_1) {
            _builder.append("$helper->getListener(\'sortable\');");
            _builder.newLine();
          }
        }
        {
          boolean _or_6 = false;
          boolean _hasTimestampable_1 = this._modelBehaviourExtensions.hasTimestampable(it);
          if (_hasTimestampable_1) {
            _or_6 = true;
          } else {
            boolean _hasStandardFieldEntities_1 = this._modelBehaviourExtensions.hasStandardFieldEntities(it);
            _or_6 = (_hasTimestampable_1 || _hasStandardFieldEntities_1);
          }
          if (_or_6) {
            _builder.append("$helper->getListener(\'timestampable\');");
            _builder.newLine();
          }
        }
        {
          boolean _hasStandardFieldEntities_2 = this._modelBehaviourExtensions.hasStandardFieldEntities(it);
          if (_hasStandardFieldEntities_2) {
            _builder.append("$helper->getListener(\'standardfields\');");
            _builder.newLine();
          }
        }
        {
          boolean _hasTranslatable_1 = this._modelBehaviourExtensions.hasTranslatable(it);
          if (_hasTranslatable_1) {
            _builder.append("$translatableListener = $helper->getListener(\'translatable\');");
            _builder.newLine();
            _builder.append("//$translatableListener->setTranslatableLocale(ZLanguage::getLanguageCode());");
            _builder.newLine();
            _builder.append("$currentLanguage = preg_replace(\'#[^a-z-].#\', \'\', FormUtil::getPassedValue(\'lang\', System::getVar(\'language_i18n\', \'en\'), \'GET\'));");
            _builder.newLine();
            _builder.append("$translatableListener->setTranslatableLocale($currentLanguage);");
            _builder.newLine();
            _builder.append("/**");
            _builder.newLine();
            _builder.append(" ");
            _builder.append("* Sometimes it is desired to set a default translation as a fallback if record does not have a translation");
            _builder.newLine();
            _builder.append(" ");
            _builder.append("* on used locale. In that case Translation Listener takes the current value of Entity.");
            _builder.newLine();
            _builder.append(" ");
            _builder.append("* But there is a way to specify a default locale which would force Entity to not update it`s field");
            _builder.newLine();
            _builder.append(" ");
            _builder.append("* if current locale is not a default.");
            _builder.newLine();
            _builder.append(" ");
            _builder.append("*/");
            _builder.newLine();
            _builder.append("//$translatableListener->setDefaultLocale(System::getVar(\'language_i18n\', \'en\'));");
            _builder.newLine();
          }
        }
      }
    }
    return _builder;
  }
  
  private CharSequence archiveObjectsCall(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    EList<Entity> _allEntities = this._modelExtensions.getAllEntities(it);
    final Function1<Entity,Boolean> _function = new Function1<Entity,Boolean>() {
        public Boolean apply(final Entity e) {
          boolean _and = false;
          boolean _isHasArchive = e.isHasArchive();
          if (!_isHasArchive) {
            _and = false;
          } else {
            AbstractDateField _endDateField = Bootstrap.this._modelExtensions.getEndDateField(e);
            boolean _tripleNotEquals = (_endDateField != null);
            _and = (_isHasArchive && _tripleNotEquals);
          }
          return Boolean.valueOf(_and);
        }
      };
    final Iterable<Entity> entitiesWithArchive = IterableExtensions.<Entity>filter(_allEntities, _function);
    _builder.newLineIfNotEmpty();
    {
      boolean _isEmpty = IterableExtensions.isEmpty(entitiesWithArchive);
      boolean _not = (!_isEmpty);
      if (_not) {
        String _prefix = this._utils.prefix(it);
        _builder.append(_prefix, "");
        _builder.append("PerformRegularAmendments();");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        _builder.append("function ");
        String _prefix_1 = this._utils.prefix(it);
        _builder.append(_prefix_1, "");
        _builder.append("PerformRegularAmendments()");
        _builder.newLineIfNotEmpty();
        _builder.append("{");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$currentFunc = FormUtil::getPassedValue(\'func\', \'");
        {
          boolean _targets = this._utils.targets(it, "1.3.5");
          if (_targets) {
            _builder.append("main");
          } else {
            _builder.append("index");
          }
        }
        _builder.append("\', \'GETPOST\', FILTER_SANITIZE_STRING);");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("if ($currentFunc == \'edit\') {");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("return;");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$randProbability = mt_rand(1, 1000);");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("if ($randProbability < 850) {");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("return;");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$entityManager = ServiceUtil::getService(\'doctrine.entitymanager\');");
        _builder.newLine();
        {
          for(final Entity entity : entitiesWithArchive) {
            _builder.newLine();
            _builder.append("    ");
            _builder.append("// update for ");
            String _nameMultiple = entity.getNameMultiple();
            String _formatForDisplay = this._formattingExtensions.formatForDisplay(_nameMultiple);
            _builder.append(_formatForDisplay, "    ");
            _builder.append(" becoming archived");
            _builder.newLineIfNotEmpty();
            {
              boolean _targets_1 = this._utils.targets(it, "1.3.5");
              if (_targets_1) {
                _builder.append("    ");
                _builder.append("$entityClass = \'");
                String _appName = this._utils.appName(it);
                _builder.append(_appName, "    ");
                _builder.append("_Entity_");
                String _name = entity.getName();
                String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(_name);
                _builder.append(_formatForCodeCapital, "    ");
                _builder.append("\';");
                _builder.newLineIfNotEmpty();
              } else {
                _builder.append("    ");
                _builder.append("$entityClass = \'\\\\");
                String _appName_1 = this._utils.appName(it);
                _builder.append(_appName_1, "    ");
                _builder.append("\\\\Entity\\\\");
                String _name_1 = entity.getName();
                String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(_name_1);
                _builder.append(_formatForCodeCapital_1, "    ");
                _builder.append("Entity\';");
                _builder.newLineIfNotEmpty();
              }
            }
            _builder.append("    ");
            _builder.append("$repository = $entityManager->getRepository($entityClass);");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("$repository->archiveObjects();");
            _builder.newLine();
          }
        }
        _builder.append("}");
        _builder.newLine();
      }
    }
    return _builder;
  }
}

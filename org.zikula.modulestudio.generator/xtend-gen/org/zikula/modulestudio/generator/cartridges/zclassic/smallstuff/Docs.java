package org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff;

import com.google.common.base.Objects;
import com.google.inject.Inject;
import de.guite.modulestudio.metamodel.modulestudio.Application;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.documents.DeveloperHints;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.documents.License_GPL;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.documents.License_LGPL;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class Docs {
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
   * Entry point for module documentation.
   */
  public void generate(final Application it, final IFileSystemAccess fsa) {
    String _appSourcePath = this._namingExtensions.getAppSourcePath(it);
    String _plus = (_appSourcePath + "CHANGELOG.md");
    CharSequence _Changelog = this.Changelog(it);
    fsa.generateFile(_plus, _Changelog);
    String _appSourcePath_1 = this._namingExtensions.getAppSourcePath(it);
    String _plus_1 = (_appSourcePath_1 + "README.md");
    CharSequence _ReadmeMarkup = this.ReadmeMarkup(it);
    fsa.generateFile(_plus_1, _ReadmeMarkup);
    final String docPath = this._namingExtensions.getAppDocPath(it);
    String _plus_2 = (docPath + "credits.md");
    CharSequence _Credits = this.Credits(it);
    fsa.generateFile(_plus_2, _Credits);
    String _plus_3 = (docPath + "developers.md");
    DeveloperHints _developerHints = new DeveloperHints();
    CharSequence _generate = _developerHints.generate(it);
    fsa.generateFile(_plus_3, _generate);
    String _plus_4 = (docPath + "doctrine.md");
    CharSequence _DoctrineHints = this.DoctrineHints(it);
    fsa.generateFile(_plus_4, _DoctrineHints);
    String _plus_5 = (docPath + "modulestudio.md");
    CharSequence _MostText = this.MostText(it);
    fsa.generateFile(_plus_5, _MostText);
    String _plus_6 = (docPath + "install.md");
    CharSequence _Install = this.Install(it);
    fsa.generateFile(_plus_6, _Install);
    String _plus_7 = (docPath + "license.md");
    CharSequence _License = this.License(it);
    fsa.generateFile(_plus_7, _License);
  }
  
  private CharSequence Credits(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("CREDITS");
    _builder.newLine();
    _builder.append("=======");
    _builder.newLine();
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence Changelog(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("CHANGELOG");
    _builder.newLine();
    _builder.append("=========");
    _builder.newLine();
    _builder.newLine();
    _builder.append("Changes in ");
    String _appName = this._utils.appName(it);
    _builder.append(_appName, "");
    _builder.append(" ");
    String _version = it.getVersion();
    _builder.append(_version, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence DoctrineHints(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("NOTES ON USING DOCTRINE 2");
    _builder.newLine();
    _builder.append("=========================");
    _builder.newLine();
    _builder.newLine();
    _builder.append("Please note that you should not use print_r() for debugging Doctrine 2 entities.");
    _builder.newLine();
    _builder.append("The reason for that is that these objects contain too many references which will");
    _builder.newLine();
    _builder.append("result in a very huge output.");
    _builder.newLine();
    _builder.newLine();
    _builder.append("Instead use the Doctrine\\Common\\Util\\Debug::dump($data) method which reduces");
    _builder.newLine();
    _builder.append("the output to reasonable information.");
    _builder.newLine();
    _builder.newLine();
    _builder.append("Read more about Doctrine at http://docs.doctrine-project.org/projects/doctrine-orm/en/latest/index.html");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence MostText(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("MODULESTUDIO");
    _builder.newLine();
    _builder.append("============");
    _builder.newLine();
    _builder.newLine();
    _builder.append("This module has been generated by ModuleStudio ");
    String _msVersion = this._utils.msVersion();
    _builder.append(_msVersion, "");
    _builder.append(", a model-driven solution");
    _builder.newLineIfNotEmpty();
    _builder.append("for creating web applications for the Zikula Application Framework.");
    _builder.newLine();
    _builder.newLine();
    _builder.append("If you are interested in a new level of Zikula development, visit ");
    String _msUrl = this._utils.msUrl();
    _builder.append(_msUrl, "");
    _builder.append(".");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence Install(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("INSTALLATION INSTRUCTIONS");
    _builder.newLine();
    _builder.append("=========================");
    _builder.newLine();
    _builder.newLine();
    _builder.append("1) Copy ");
    String _appName = this._utils.appName(it);
    _builder.append(_appName, "");
    _builder.append(" to your modules folder.");
    _builder.newLineIfNotEmpty();
    _builder.append("2) Initialize and activate ");
    String _appName_1 = this._utils.appName(it);
    _builder.append(_appName_1, "");
    _builder.append(" in the modules administration.");
    _builder.newLineIfNotEmpty();
    {
      boolean _targets = this._utils.targets(it, "1.3.5");
      boolean _not = (!_targets);
      if (_not) {
        _builder.append("3) Move or copy the directory `Resources/userdata/");
        String _appName_2 = this._utils.appName(it);
        _builder.append(_appName_2, "");
        _builder.append("/` to `/userdata/");
        String _appName_3 = this._utils.appName(it);
        _builder.append(_appName_3, "");
        _builder.append("/`.");
        _builder.newLineIfNotEmpty();
        _builder.append("   ");
        _builder.append("Note this step is optional as the install process can create these folders, too.");
        _builder.newLine();
        {
          boolean _hasUploads = this._modelExtensions.hasUploads(it);
          if (_hasUploads) {
            _builder.append("4) Make the directory `/userdata/");
            String _appName_4 = this._utils.appName(it);
            _builder.append(_appName_4, "");
            _builder.append("/` writable including all sub folders.");
            _builder.newLineIfNotEmpty();
          }
        }
      } else {
        {
          boolean _hasUploads_1 = this._modelExtensions.hasUploads(it);
          if (_hasUploads_1) {
            _builder.append("3) Make the directory `/userdata/");
            String _appName_5 = this._utils.appName(it);
            _builder.append(_appName_5, "");
            _builder.append("/` writable including all sub folders.");
            _builder.newLineIfNotEmpty();
          }
        }
      }
    }
    _builder.newLine();
    _builder.append("For questions and other remarks visit our homepage ");
    String _url = it.getUrl();
    _builder.append(_url, "");
    _builder.append(".");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    CharSequence _ReadmeFooter = this.ReadmeFooter(it);
    _builder.append(_ReadmeFooter, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence ReadmeFooter(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    String _author = it.getAuthor();
    _builder.append(_author, "");
    {
      String _email = it.getEmail();
      boolean _notEquals = (!Objects.equal(_email, ""));
      if (_notEquals) {
        _builder.append(" (");
        String _email_1 = it.getEmail();
        _builder.append(_email_1, "");
        _builder.append(")");
      }
    }
    _builder.newLineIfNotEmpty();
    {
      String _url = it.getUrl();
      boolean _notEquals_1 = (!Objects.equal(_url, ""));
      if (_notEquals_1) {
        String _url_1 = it.getUrl();
        _builder.append(_url_1, "");
      }
    }
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  public CharSequence ReadmeMarkup(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    String _vendor = it.getVendor();
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(_vendor);
    _builder.append(_formatForDisplay, "");
    _builder.append("\\");
    String _appName = this._utils.appName(it);
    _builder.append(_appName, "");
    _builder.append(" ");
    String _version = it.getVersion();
    _builder.append(_version, "");
    _builder.newLineIfNotEmpty();
    _builder.append("===========================");
    _builder.newLine();
    _builder.newLine();
    {
      boolean _and = false;
      String _documentation = it.getDocumentation();
      boolean _tripleNotEquals = (_documentation != null);
      if (!_tripleNotEquals) {
        _and = false;
      } else {
        String _documentation_1 = it.getDocumentation();
        boolean _notEquals = (!Objects.equal(_documentation_1, ""));
        _and = (_tripleNotEquals && _notEquals);
      }
      if (_and) {
        String _documentation_2 = it.getDocumentation();
        String _replaceAll = _documentation_2.replaceAll("\'", "\\\'");
        _builder.append(_replaceAll, "");
        _builder.newLineIfNotEmpty();
      } else {
        String _vendor_1 = it.getVendor();
        String _formatForDisplayCapital = this._formattingExtensions.formatForDisplayCapital(_vendor_1);
        _builder.append(_formatForDisplayCapital, "");
        _builder.append("\\");
        String _appName_1 = this._utils.appName(it);
        _builder.append(_appName_1, "");
        _builder.append(" module generated by ModuleStudio ");
        String _msVersion = this._utils.msVersion();
        _builder.append(_msVersion, "");
        _builder.append(".");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.newLine();
    {
      boolean _targets = this._utils.targets(it, "1.3.5");
      if (_targets) {
        _builder.append("This module is intended for being used with Zikula 1.3.5.");
        _builder.newLine();
      } else {
        _builder.append("This module is intended for being used with Zikula 1.3.6 and later.");
        _builder.newLine();
      }
    }
    _builder.newLine();
    _builder.append("For questions and other remarks visit our homepage ");
    String _url = it.getUrl();
    _builder.append(_url, "");
    _builder.append(".");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    CharSequence _ReadmeFooter = this.ReadmeFooter(it);
    _builder.append(_ReadmeFooter, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence License(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _or = false;
      boolean _or_1 = false;
      boolean _or_2 = false;
      String _license = it.getLicense();
      boolean _equals = Objects.equal(_license, "http://www.gnu.org/licenses/lgpl.html GNU Lesser General Public License");
      if (_equals) {
        _or_2 = true;
      } else {
        String _license_1 = it.getLicense();
        boolean _equals_1 = Objects.equal(_license_1, "GNU Lesser General Public License");
        _or_2 = (_equals || _equals_1);
      }
      if (_or_2) {
        _or_1 = true;
      } else {
        String _license_2 = it.getLicense();
        boolean _equals_2 = Objects.equal(_license_2, "Lesser General Public License");
        _or_1 = (_or_2 || _equals_2);
      }
      if (_or_1) {
        _or = true;
      } else {
        String _license_3 = it.getLicense();
        boolean _equals_3 = Objects.equal(_license_3, "LGPL");
        _or = (_or_1 || _equals_3);
      }
      if (_or) {
        License_LGPL _license_LGPL = new License_LGPL();
        CharSequence _generate = _license_LGPL.generate(it);
        _builder.append(_generate, "");
        _builder.newLineIfNotEmpty();
      } else {
        boolean _or_3 = false;
        boolean _or_4 = false;
        boolean _or_5 = false;
        String _license_4 = it.getLicense();
        boolean _equals_4 = Objects.equal(_license_4, "http://www.gnu.org/copyleft/gpl.html GNU General Public License");
        if (_equals_4) {
          _or_5 = true;
        } else {
          String _license_5 = it.getLicense();
          boolean _equals_5 = Objects.equal(_license_5, "GNU General Public License");
          _or_5 = (_equals_4 || _equals_5);
        }
        if (_or_5) {
          _or_4 = true;
        } else {
          String _license_6 = it.getLicense();
          boolean _equals_6 = Objects.equal(_license_6, "General Public License");
          _or_4 = (_or_5 || _equals_6);
        }
        if (_or_4) {
          _or_3 = true;
        } else {
          String _license_7 = it.getLicense();
          boolean _equals_7 = Objects.equal(_license_7, "GPL");
          _or_3 = (_or_4 || _equals_7);
        }
        if (_or_3) {
          License_GPL _license_GPL = new License_GPL();
          CharSequence _generate_1 = _license_GPL.generate(it);
          _builder.append(_generate_1, "");
          _builder.newLineIfNotEmpty();
        } else {
          _builder.append("Please enter your license text here.");
          _builder.newLine();
        }
      }
    }
    return _builder;
  }
}

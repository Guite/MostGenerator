package org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff;

import com.google.common.base.Objects;
import de.guite.modulestudio.metamodel.Application;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.documents.License_GPL;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.documents.License_LGPL;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.GeneratorSettingsExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class Docs {
  @Extension
  private FormattingExtensions _formattingExtensions = new FormattingExtensions();
  
  @Extension
  private GeneratorSettingsExtensions _generatorSettingsExtensions = new GeneratorSettingsExtensions();
  
  @Extension
  private ModelExtensions _modelExtensions = new ModelExtensions();
  
  @Extension
  private NamingExtensions _namingExtensions = new NamingExtensions();
  
  @Extension
  private Utils _utils = new Utils();
  
  /**
   * Entry point for module documentation.
   */
  public void generate(final Application it, final IFileSystemAccess fsa) {
    String fileName = "CHANGELOG.md";
    String _appSourcePath = this._namingExtensions.getAppSourcePath(it);
    String _plus = (_appSourcePath + fileName);
    boolean _shouldBeSkipped = this._namingExtensions.shouldBeSkipped(it, _plus);
    boolean _not = (!_shouldBeSkipped);
    if (_not) {
      String _appSourcePath_1 = this._namingExtensions.getAppSourcePath(it);
      String _plus_1 = (_appSourcePath_1 + fileName);
      boolean _shouldBeMarked = this._namingExtensions.shouldBeMarked(it, _plus_1);
      if (_shouldBeMarked) {
        fileName = "CHANGELOG.generated.md";
      }
      String _appSourcePath_2 = this._namingExtensions.getAppSourcePath(it);
      String _plus_2 = (_appSourcePath_2 + fileName);
      fsa.generateFile(_plus_2, this.Changelog(it));
    }
    fileName = "README.md";
    String _appSourcePath_3 = this._namingExtensions.getAppSourcePath(it);
    String _plus_3 = (_appSourcePath_3 + fileName);
    boolean _shouldBeSkipped_1 = this._namingExtensions.shouldBeSkipped(it, _plus_3);
    boolean _not_1 = (!_shouldBeSkipped_1);
    if (_not_1) {
      String _appSourcePath_4 = this._namingExtensions.getAppSourcePath(it);
      String _plus_4 = (_appSourcePath_4 + fileName);
      boolean _shouldBeMarked_1 = this._namingExtensions.shouldBeMarked(it, _plus_4);
      if (_shouldBeMarked_1) {
        fileName = "README.generated.md";
      }
      String _appSourcePath_5 = this._namingExtensions.getAppSourcePath(it);
      String _plus_5 = (_appSourcePath_5 + fileName);
      fsa.generateFile(_plus_5, this.ReadmeMarkup(it));
    }
    final String docPath = this._namingExtensions.getAppDocPath(it);
    fileName = "credits.md";
    boolean _shouldBeSkipped_2 = this._namingExtensions.shouldBeSkipped(it, (docPath + "credits.md"));
    boolean _not_2 = (!_shouldBeSkipped_2);
    if (_not_2) {
      boolean _shouldBeMarked_2 = this._namingExtensions.shouldBeMarked(it, (docPath + fileName));
      if (_shouldBeMarked_2) {
        fileName = "credits.generated.md";
      }
      fsa.generateFile((docPath + fileName), this.Credits(it));
    }
    fileName = "modulestudio.md";
    boolean _shouldBeSkipped_3 = this._namingExtensions.shouldBeSkipped(it, (docPath + fileName));
    boolean _not_3 = (!_shouldBeSkipped_3);
    if (_not_3) {
      boolean _shouldBeMarked_3 = this._namingExtensions.shouldBeMarked(it, (docPath + fileName));
      if (_shouldBeMarked_3) {
        fileName = "modulestudio.generated.md";
      }
      fsa.generateFile((docPath + fileName), this.MostText(it));
    }
    fileName = "install.md";
    boolean _shouldBeSkipped_4 = this._namingExtensions.shouldBeSkipped(it, (docPath + fileName));
    boolean _not_4 = (!_shouldBeSkipped_4);
    if (_not_4) {
      boolean _shouldBeMarked_4 = this._namingExtensions.shouldBeMarked(it, (docPath + fileName));
      if (_shouldBeMarked_4) {
        fileName = "install.generated.md";
      }
      fsa.generateFile((docPath + fileName), this.Install(it));
    }
    boolean _isSystemModule = this._generatorSettingsExtensions.isSystemModule(it);
    boolean _not_5 = (!_isSystemModule);
    if (_not_5) {
      fileName = "translation.md";
      boolean _shouldBeSkipped_5 = this._namingExtensions.shouldBeSkipped(it, (docPath + fileName));
      boolean _not_6 = (!_shouldBeSkipped_5);
      if (_not_6) {
        boolean _shouldBeMarked_5 = this._namingExtensions.shouldBeMarked(it, (docPath + fileName));
        if (_shouldBeMarked_5) {
          fileName = "translation.generated.md";
        }
        fsa.generateFile((docPath + fileName), this.Translation(it));
      }
    }
    fileName = "LICENSE";
    String _appLicencePath = this._namingExtensions.getAppLicencePath(it);
    String _plus_6 = (_appLicencePath + fileName);
    boolean _shouldBeSkipped_6 = this._namingExtensions.shouldBeSkipped(it, _plus_6);
    boolean _not_7 = (!_shouldBeSkipped_6);
    if (_not_7) {
      String _appLicencePath_1 = this._namingExtensions.getAppLicencePath(it);
      String _plus_7 = (_appLicencePath_1 + fileName);
      boolean _shouldBeMarked_6 = this._namingExtensions.shouldBeMarked(it, _plus_7);
      if (_shouldBeMarked_6) {
        fileName = "LICENSE.generated";
      }
      String _appLicencePath_2 = this._namingExtensions.getAppLicencePath(it);
      String _plus_8 = (_appLicencePath_2 + fileName);
      fsa.generateFile(_plus_8, this.License(it));
    }
    boolean _writeModelToDocs = this._generatorSettingsExtensions.writeModelToDocs(it);
    if (_writeModelToDocs) {
      fsa.generateFile((docPath + "/model/.htaccess"), this.htAccessForModel(it));
    }
  }
  
  private CharSequence Credits(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("# CREDITS");
    _builder.newLine();
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence Changelog(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("# CHANGELOG");
    _builder.newLine();
    _builder.newLine();
    _builder.append("Changes in ");
    String _appName = this._utils.appName(it);
    _builder.append(_appName);
    _builder.append(" ");
    String _version = it.getVersion();
    _builder.append(_version);
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence MostText(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("# MODULESTUDIO");
    _builder.newLine();
    _builder.newLine();
    _builder.append("This module has been generated by ModuleStudio ");
    String _msVersion = this._utils.msVersion();
    _builder.append(_msVersion);
    _builder.append(", a model-driven solution");
    _builder.newLineIfNotEmpty();
    _builder.append("for creating web applications for the Zikula Application Framework.");
    _builder.newLine();
    _builder.newLine();
    _builder.append("If you are interested in a new level of Zikula development, visit ");
    String _msUrl = this._utils.msUrl();
    _builder.append(_msUrl);
    _builder.append(".");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence Install(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("# INSTALLATION INSTRUCTIONS");
    _builder.newLine();
    _builder.newLine();
    {
      boolean _isSystemModule = this._generatorSettingsExtensions.isSystemModule(it);
      if (_isSystemModule) {
        _builder.append("1. Copy ");
        String _appName = this._utils.appName(it);
        _builder.append(_appName);
        _builder.append(" into your `system` directory. Afterwards you should have a folder named `");
        String _relativeAppRootPath = this._namingExtensions.relativeAppRootPath(it);
        _builder.append(_relativeAppRootPath);
        _builder.append("/Resources`.");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("1. Copy ");
        String _appName_1 = this._utils.appName(it);
        _builder.append(_appName_1);
        _builder.append(" into your `modules` directory. Afterwards you should have a folder named `");
        String _relativeAppRootPath_1 = this._namingExtensions.relativeAppRootPath(it);
        _builder.append(_relativeAppRootPath_1);
        _builder.append("/Resources`.");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("2. Initialize and activate ");
    String _appName_2 = this._utils.appName(it);
    _builder.append(_appName_2);
    _builder.append(" in the extensions administration.");
    _builder.newLineIfNotEmpty();
    {
      boolean _hasUploads = this._modelExtensions.hasUploads(it);
      if (_hasUploads) {
        _builder.append("3. Move or copy the directory `Resources/userdata/");
        String _appName_3 = this._utils.appName(it);
        _builder.append(_appName_3);
        _builder.append("/` to `/userdata/");
        String _appName_4 = this._utils.appName(it);
        _builder.append(_appName_4);
        _builder.append("/`.");
        _builder.newLineIfNotEmpty();
        _builder.append("   ");
        _builder.append("Note this step is optional as the install process can create these folders, too.");
        _builder.newLine();
        _builder.append("4. Make the directory `/userdata/");
        String _appName_5 = this._utils.appName(it);
        _builder.append(_appName_5);
        _builder.append("/` writable including all sub folders.");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.newLine();
    _builder.append("For questions and other remarks visit our homepage ");
    String _url = it.getUrl();
    _builder.append(_url);
    _builder.append(".");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    CharSequence _ReadmeFooter = this.ReadmeFooter(it);
    _builder.append(_ReadmeFooter);
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence Translation(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("# TRANSLATION INSTRUCTIONS");
    _builder.newLine();
    _builder.newLine();
    _builder.append("To create a new translation follow the steps below:");
    _builder.newLine();
    _builder.newLine();
    _builder.append("1. First install the module like described in the `install.md` file.");
    _builder.newLine();
    _builder.append("2. Open a console and navigate to the Zikula root directory.");
    _builder.newLine();
    _builder.append("3. Execute this command replacing `en` by your desired locale code:");
    _builder.newLine();
    _builder.newLine();
    _builder.append("`php app/console translation:extract en --bundle=");
    String _appName = this._utils.appName(it);
    _builder.append(_appName);
    _builder.append(" --enable-extractor=jms_i18n_routing --output-format=po");
    {
      boolean _generateTagSupport = this._generatorSettingsExtensions.generateTagSupport(it);
      if (_generateTagSupport) {
        _builder.append(" --exclude-dir=TaggedObjectMeta");
      }
    }
    _builder.append("`");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("You can also use multiple locales at once, for example `de fr es`.");
    _builder.newLine();
    _builder.newLine();
    _builder.append("4. Translate the resulting `.po` files in `");
    String _relativeAppRootPath = this._namingExtensions.relativeAppRootPath(it);
    _builder.append(_relativeAppRootPath);
    _builder.append("/Resources/translations/` using your favourite Gettext tooling.");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("Note you can even include custom views in `app/Resources/");
    String _appName_1 = this._utils.appName(it);
    _builder.append(_appName_1);
    _builder.append("/views/` and JavaScript files in `app/Resources/");
    String _appName_2 = this._utils.appName(it);
    _builder.append(_appName_2);
    _builder.append("/public/js/` like this:");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("`php app/console translation:extract en --bundle=");
    String _appName_3 = this._utils.appName(it);
    _builder.append(_appName_3);
    _builder.append(" --enable-extractor=jms_i18n_routing --output-format=po");
    {
      boolean _generateTagSupport_1 = this._generatorSettingsExtensions.generateTagSupport(it);
      if (_generateTagSupport_1) {
        _builder.append(" --exclude-dir=TaggedObjectMeta");
      }
    }
    _builder.append(" --dir=./");
    String _relativeAppRootPath_1 = this._namingExtensions.relativeAppRootPath(it);
    _builder.append(_relativeAppRootPath_1);
    _builder.append(" --dir=./app/Resources/");
    String _appName_4 = this._utils.appName(it);
    _builder.append(_appName_4);
    _builder.append("`");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("For questions and other remarks visit our homepage ");
    String _url = it.getUrl();
    _builder.append(_url);
    _builder.append(".");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    CharSequence _ReadmeFooter = this.ReadmeFooter(it);
    _builder.append(_ReadmeFooter);
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence ReadmeFooter(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    String _author = it.getAuthor();
    _builder.append(_author);
    {
      String _email = it.getEmail();
      boolean _notEquals = (!Objects.equal(_email, ""));
      if (_notEquals) {
        _builder.append(" (");
        String _email_1 = it.getEmail();
        _builder.append(_email_1);
        _builder.append(")");
      }
    }
    _builder.newLineIfNotEmpty();
    {
      String _url = it.getUrl();
      boolean _notEquals_1 = (!Objects.equal(_url, ""));
      if (_notEquals_1) {
        String _url_1 = it.getUrl();
        _builder.append(_url_1);
      }
    }
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  public CharSequence ReadmeMarkup(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("# ");
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(it.getVendor());
    _builder.append(_formatForDisplay);
    _builder.append("\\");
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital);
    _builder.append(" ");
    String _version = it.getVersion();
    _builder.append(_version);
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    {
      if (((null != it.getDocumentation()) && (!Objects.equal(it.getDocumentation(), "")))) {
        String _replace = it.getDocumentation().replace("\'", "\\\'");
        _builder.append(_replace);
        _builder.newLineIfNotEmpty();
      } else {
        String _formatForDisplayCapital = this._formattingExtensions.formatForDisplayCapital(it.getVendor());
        _builder.append(_formatForDisplayCapital);
        _builder.append("\\");
        String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(it.getName());
        _builder.append(_formatForCodeCapital_1);
        _builder.append(" module generated by ModuleStudio ");
        String _msVersion = this._utils.msVersion();
        _builder.append(_msVersion);
        _builder.append(".");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.newLine();
    _builder.append("This module is intended for being used with Zikula ");
    {
      Boolean _targets = this._utils.targets(it, "1.5");
      if ((_targets).booleanValue()) {
        _builder.append("1.5.0-git");
      } else {
        _builder.append("1.4.6");
      }
    }
    _builder.append(" and later.");
    _builder.newLineIfNotEmpty();
    {
      Boolean _targets_1 = this._utils.targets(it, "1.5");
      if ((_targets_1).booleanValue()) {
        _builder.newLine();
        _builder.append("**Note this is a development version which is NOT READY for production yet.**");
        _builder.newLine();
      }
    }
    _builder.newLine();
    _builder.append("For questions and other remarks visit our homepage ");
    String _url = it.getUrl();
    _builder.append(_url);
    _builder.append(".");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    CharSequence _ReadmeFooter = this.ReadmeFooter(it);
    _builder.append(_ReadmeFooter);
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence License(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      if ((((Objects.equal(it.getLicense(), "http://www.gnu.org/licenses/lgpl.html GNU Lesser General Public License") || Objects.equal(it.getLicense(), "GNU Lesser General Public License")) || Objects.equal(it.getLicense(), "Lesser General Public License")) || Objects.equal(it.getLicense(), "LGPL"))) {
        CharSequence _generate = new License_LGPL().generate(it);
        _builder.append(_generate);
        _builder.newLineIfNotEmpty();
      } else {
        if ((((Objects.equal(it.getLicense(), "http://www.gnu.org/copyleft/gpl.html GNU General Public License") || Objects.equal(it.getLicense(), "GNU General Public License")) || Objects.equal(it.getLicense(), "General Public License")) || Objects.equal(it.getLicense(), "GPL"))) {
          CharSequence _generate_1 = new License_GPL().generate(it);
          _builder.append(_generate_1);
          _builder.newLineIfNotEmpty();
        } else {
          _builder.append("Please enter your license text here.");
          _builder.newLine();
        }
      }
    }
    return _builder;
  }
  
  private CharSequence htAccessForModel(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("# ");
    CharSequence _generatedBy = new FileHelper().generatedBy(it, Boolean.valueOf(this._generatorSettingsExtensions.timestampAllGeneratedFiles(it)), Boolean.valueOf(this._generatorSettingsExtensions.versionAllGeneratedFiles(it)));
    _builder.append(_generatedBy);
    _builder.newLineIfNotEmpty();
    _builder.append("# ------------------------------------------------------------");
    _builder.newLine();
    _builder.append("# Purpose of file: block any web access to unallowed files");
    _builder.newLine();
    _builder.append("# stored in this directory");
    _builder.newLine();
    _builder.append("# ------------------------------------------------------------");
    _builder.newLine();
    _builder.newLine();
    _builder.append("# Apache 2.2");
    _builder.newLine();
    _builder.append("<IfModule !mod_authz_core.c>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("Deny from all");
    _builder.newLine();
    _builder.append("</IfModule>");
    _builder.newLine();
    _builder.newLine();
    _builder.append("# Apache 2.4");
    _builder.newLine();
    _builder.append("<IfModule mod_authz_core.c>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("Require all denied");
    _builder.newLine();
    _builder.append("</IfModule>");
    _builder.newLine();
    return _builder;
  }
}

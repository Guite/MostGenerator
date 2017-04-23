package org.zikula.modulestudio.generator.cartridges.zclassic.controller;

import com.google.common.collect.Iterables;
import de.guite.modulestudio.metamodel.Application;
import de.guite.modulestudio.metamodel.Entity;
import de.guite.modulestudio.metamodel.UploadField;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.GeneratorSettingsExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class Uploads {
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
  
  private FileHelper fh = new FileHelper();
  
  private IFileSystemAccess fsa;
  
  /**
   * Entry point for the upload handler.
   */
  public void generate(final Application it, final IFileSystemAccess fsa) {
    this.fsa = fsa;
    this.createUploadFolders(it);
  }
  
  private void createUploadFolders(final Application it) {
    final String uploadPath = this._namingExtensions.getAppUploadPath(it);
    this._utils.createPlaceholder(it, this.fsa, uploadPath);
    Iterable<Entity> _filter = Iterables.<Entity>filter(this._modelExtensions.getUploadEntities(it), Entity.class);
    for (final Entity entity : _filter) {
      {
        String _formatForDB = this._formattingExtensions.formatForDB(entity.getNameMultiple());
        final String subFolderName = (_formatForDB + "/");
        this._utils.createPlaceholder(it, this.fsa, (uploadPath + subFolderName));
        final Iterable<UploadField> uploadFields = this._modelExtensions.getUploadFieldsEntity(entity);
        int _size = IterableExtensions.size(uploadFields);
        boolean _greaterThan = (_size > 1);
        if (_greaterThan) {
          for (final UploadField uploadField : uploadFields) {
            String _subFolderPathSegment = this._modelExtensions.subFolderPathSegment(uploadField);
            String _plus = (subFolderName + _subFolderPathSegment);
            this.uploadFolder(uploadField, uploadPath, _plus);
          }
        } else {
          int _size_1 = IterableExtensions.size(uploadFields);
          boolean _greaterThan_1 = (_size_1 > 0);
          if (_greaterThan_1) {
            UploadField _head = IterableExtensions.<UploadField>head(uploadFields);
            String _subFolderPathSegment_1 = this._modelExtensions.subFolderPathSegment(IterableExtensions.<UploadField>head(uploadFields));
            String _plus_1 = (subFolderName + _subFolderPathSegment_1);
            this.uploadFolder(_head, uploadPath, _plus_1);
          }
        }
      }
    }
    String _appDocPath = this._namingExtensions.getAppDocPath(it);
    String _plus = (_appDocPath + "htaccessTemplate");
    this.fsa.generateFile(_plus, this.htAccessTemplate(it));
  }
  
  private void uploadFolder(final UploadField it, final String basePath, final String folder) {
    this._utils.createPlaceholder(it.getEntity().getApplication(), this.fsa, ((basePath + folder) + "/"));
    String _appUploadPath = this._namingExtensions.getAppUploadPath(it.getEntity().getApplication());
    String _plus = (_appUploadPath + folder);
    String _plus_1 = (_plus + "/.htaccess");
    this.fsa.generateFile(_plus_1, this.htAccess(it));
  }
  
  private CharSequence htAccess(final UploadField it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("# ");
    CharSequence _generatedBy = this.fh.generatedBy(it.getEntity().getApplication(), Boolean.valueOf(this._generatorSettingsExtensions.timestampAllGeneratedFiles(it.getEntity().getApplication())), Boolean.valueOf(this._generatorSettingsExtensions.versionAllGeneratedFiles(it.getEntity().getApplication())));
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
    _builder.newLine();
    _builder.append("<FilesMatch \"\\.(");
    String _replace = it.getAllowedExtensions().replace(", ", "|");
    _builder.append(_replace);
    _builder.append(")$\">");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("# Apache 2.2");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<IfModule !mod_authz_core.c>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("Order allow,deny");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("Allow from all");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("</IfModule>");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("# Apache 2.4");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<IfModule mod_authz_core.c>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("Require all granted");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("</IfModule>");
    _builder.newLine();
    _builder.append("</filesmatch>");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence htAccessTemplate(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("# ");
    CharSequence _generatedBy = this.fh.generatedBy(it, Boolean.valueOf(this._generatorSettingsExtensions.timestampAllGeneratedFiles(it)), Boolean.valueOf(this._generatorSettingsExtensions.versionAllGeneratedFiles(it)));
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
    _builder.newLine();
    _builder.append("<FilesMatch \"\\.(__EXTENSIONS__)$\">");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("# Apache 2.2");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<IfModule !mod_authz_core.c>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("Order allow,deny");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("Allow from all");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("</IfModule>");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("# Apache 2.4");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<IfModule mod_authz_core.c>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("Require all granted");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("</IfModule>");
    _builder.newLine();
    _builder.append("</filesmatch>");
    _builder.newLine();
    return _builder;
  }
}

package org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff;

import com.google.inject.Inject;
import de.guite.modulestudio.metamodel.modulestudio.Application;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class TravisFile {
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
    boolean _targets = this._utils.targets(it, "1.3.5");
    if (_targets) {
      return;
    }
    String _appSourcePath = this._namingExtensions.getAppSourcePath(it);
    String _plus = (_appSourcePath + ".travis.yml");
    CharSequence _travisFile = this.travisFile(it);
    fsa.generateFile(_plus, _travisFile);
  }
  
  private CharSequence travisFile(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("language: php");
    _builder.newLine();
    _builder.newLine();
    _builder.append("before_script: composer install --dev --prefer-source");
    _builder.newLine();
    _builder.newLine();
    _builder.append("php:");
    _builder.newLine();
    _builder.append("  ");
    _builder.append("- 5.3");
    _builder.newLine();
    _builder.append("  ");
    _builder.append("- 5.4");
    _builder.newLine();
    _builder.append("  ");
    _builder.append("- 5.5");
    _builder.newLine();
    return _builder;
  }
}

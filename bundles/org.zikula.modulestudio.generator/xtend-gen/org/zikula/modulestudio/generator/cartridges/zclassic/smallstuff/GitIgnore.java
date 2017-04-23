package org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff;

import de.guite.modulestudio.metamodel.Application;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;

@SuppressWarnings("all")
public class GitIgnore {
  @Extension
  private NamingExtensions _namingExtensions = new NamingExtensions();
  
  public void generate(final Application it, final IFileSystemAccess fsa) {
    String _appSourcePath = this._namingExtensions.getAppSourcePath(it);
    String _plus = (_appSourcePath + ".gitignore");
    boolean _shouldBeSkipped = this._namingExtensions.shouldBeSkipped(it, _plus);
    boolean _not = (!_shouldBeSkipped);
    if (_not) {
      String _appSourcePath_1 = this._namingExtensions.getAppSourcePath(it);
      String _plus_1 = (_appSourcePath_1 + ".gitignore");
      fsa.generateFile(_plus_1, this.gitIgnoreContent(it));
    }
  }
  
  private CharSequence gitIgnoreContent(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("vendor/");
    _builder.newLine();
    _builder.append("composer.lock");
    _builder.newLine();
    _builder.append("phpunit.xml");
    _builder.newLine();
    return _builder;
  }
}

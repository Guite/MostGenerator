package org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff;

import com.google.inject.Inject;
import de.guite.modulestudio.metamodel.modulestudio.Application;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class Translations {
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
   * Entry point for module language defines.
   */
  public void generate(final Application it, final IFileSystemAccess fsa) {
    String _appLocalePath = this._namingExtensions.getAppLocalePath(it);
    String _plus = (_appLocalePath + "index.html");
    String _msUrl = this._utils.msUrl();
    fsa.generateFile(_plus, _msUrl);
    String _appLocalePath_1 = this._namingExtensions.getAppLocalePath(it);
    String _plus_1 = (_appLocalePath_1 + "de/index.html");
    String _msUrl_1 = this._utils.msUrl();
    fsa.generateFile(_plus_1, _msUrl_1);
    String _appLocalePath_2 = this._namingExtensions.getAppLocalePath(it);
    String _plus_2 = (_appLocalePath_2 + "de/LC_MESSAGES/index.html");
    String _msUrl_2 = this._utils.msUrl();
    fsa.generateFile(_plus_2, _msUrl_2);
  }
}

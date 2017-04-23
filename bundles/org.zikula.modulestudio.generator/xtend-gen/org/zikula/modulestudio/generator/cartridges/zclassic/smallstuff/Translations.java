package org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff;

import de.guite.modulestudio.metamodel.Application;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class Translations {
  @Extension
  private NamingExtensions _namingExtensions = new NamingExtensions();
  
  @Extension
  private Utils _utils = new Utils();
  
  /**
   * Entry point for module translations.
   */
  public void generate(final Application it, final IFileSystemAccess fsa) {
    final String localePath = this._namingExtensions.getAppLocalePath(it);
    this._utils.createPlaceholder(it, fsa, localePath);
  }
}

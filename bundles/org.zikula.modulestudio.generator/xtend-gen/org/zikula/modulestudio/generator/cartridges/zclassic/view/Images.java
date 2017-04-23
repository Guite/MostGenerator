package org.zikula.modulestudio.generator.cartridges.zclassic.view;

import de.guite.modulestudio.metamodel.Application;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class Images {
  @Extension
  private NamingExtensions _namingExtensions = new NamingExtensions();
  
  @Extension
  private Utils _utils = new Utils();
  
  /**
   * Entry point for all application images.
   */
  public Object generate(final Application it, final IFileSystemAccess fsa) {
    Object _xblockexpression = null;
    {
      final String imagePath = this._namingExtensions.getAppImagePath(it);
      this._utils.createPlaceholder(it, fsa, imagePath);
      Object _xifexpression = null;
      boolean _shouldBeSkipped = this._namingExtensions.shouldBeSkipped(it, (imagePath + "admin.png"));
      boolean _not = (!_shouldBeSkipped);
      if (_not) {
        _xifexpression = null;
      }
      _xblockexpression = _xifexpression;
    }
    return _xblockexpression;
  }
}

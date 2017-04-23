package org.zikula.modulestudio.generator.workflow;

import org.eclipse.xtend.lib.annotations.Accessors;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Pure;

/**
 * Represents an outlet of the generator.
 */
@SuppressWarnings("all")
public class Outlet {
  /**
   * Name of the outlet.
   */
  @Accessors
  private String outletName = IFileSystemAccess.DEFAULT_OUTPUT;
  
  /**
   * The output path.
   */
  @Accessors
  private String path;
  
  @Pure
  public String getOutletName() {
    return this.outletName;
  }
  
  public void setOutletName(final String outletName) {
    this.outletName = outletName;
  }
  
  @Pure
  public String getPath() {
    return this.path;
  }
  
  public void setPath(final String path) {
    this.path = path;
  }
}

package org.zikula.modulestudio.generator.workflow;

import org.eclipse.xtext.generator.IFileSystemAccess;

/**
 * Represents an outlet of the generator.
 */
@SuppressWarnings("all")
public class Outlet {
  /**
   * Name of the outlet.
   */
  private String _outletName = IFileSystemAccess.DEFAULT_OUTPUT;
  
  /**
   * Name of the outlet.
   */
  public String getOutletName() {
    return this._outletName;
  }
  
  /**
   * Name of the outlet.
   */
  public void setOutletName(final String outletName) {
    this._outletName = outletName;
  }
  
  /**
   * The output path.
   */
  private String _path;
  
  /**
   * The output path.
   */
  public String getPath() {
    return this._path;
  }
  
  /**
   * The output path.
   */
  public void setPath(final String path) {
    this._path = path;
  }
}

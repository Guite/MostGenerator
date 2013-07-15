package org.zikula.modulestudio.generator.cartridges.reporting;

import java.io.File;
import java.io.FilenameFilter;

/**
 * Filter for report files.
 */
@SuppressWarnings("all")
public class ReportFilenameFilter implements FilenameFilter {
  public boolean accept(final File dir, final String name) {
    boolean _xblockexpression = false;
    {
      boolean _contains = name.contains(".rptdesign");
      if (_contains) {
        return true;
      }
      _xblockexpression = (false);
    }
    return _xblockexpression;
  }
}

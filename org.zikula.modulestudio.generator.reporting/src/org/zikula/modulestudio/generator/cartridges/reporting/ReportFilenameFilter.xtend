package org.zikula.modulestudio.generator.cartridges.reporting

import java.io.FilenameFilter
import java.io.File

/**
 * Filter for report files.
 */
class ReportFilenameFilter implements FilenameFilter {

    override accept(File dir, String name) {
        if (name.contains('.rptdesign')) { //$NON-NLS-1$
            return true
        }
        false
    }
}
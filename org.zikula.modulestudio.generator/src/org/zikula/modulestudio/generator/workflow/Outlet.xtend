package org.zikula.modulestudio.generator.workflow

import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtext.generator.IFileSystemAccess

/**
 * Represents an outlet of the generator.
 */
public class Outlet {

    /**
     * Name of the outlet.
     */
    @Accessors
    String outletName = IFileSystemAccess.DEFAULT_OUTPUT

    /**
     * The output path.
     */
    @Accessors
    String path
}

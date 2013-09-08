package org.zikula.modulestudio.generator.workflow

import org.eclipse.xtext.generator.IFileSystemAccess

/**
 * Represents an outlet of the generator.
 */
public static class Outlet {

    /**
     * Name of the outlet.
     */
    @Property
    String outletName = IFileSystemAccess.DEFAULT_OUTPUT

    /**
     * The output path.
     */
    @Property
    String path
}

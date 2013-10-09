package org.zikula.modulestudio.generator.cartridges

import org.eclipse.core.resources.IFile
import org.eclipse.core.runtime.CoreException
import org.eclipse.xtext.builder.EclipseResourceFileSystemAccess2

class MostGenFileSystemAccess extends EclipseResourceFileSystemAccess2 {
    override protected getEncoding(IFile file) throws CoreException {
        'UTF-8'
    }
}

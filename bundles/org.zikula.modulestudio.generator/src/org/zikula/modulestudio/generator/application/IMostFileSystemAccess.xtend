package org.zikula.modulestudio.generator.application

import org.eclipse.xtext.generator.IFileSystemAccess2

interface IMostFileSystemAccess extends IFileSystemAccess2 {

    def void generateClassPair(String concretePath, CharSequence baseContent, CharSequence concreteContent)
}

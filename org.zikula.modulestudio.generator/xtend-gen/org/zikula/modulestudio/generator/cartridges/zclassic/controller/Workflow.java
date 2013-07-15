package org.zikula.modulestudio.generator.cartridges.zclassic.controller;

import de.guite.modulestudio.metamodel.modulestudio.Application;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.workflows.Definition;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.workflows.Operations;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.workflows.PermissionCheck;

/**
 * Entry point for all workflows.
 */
@SuppressWarnings("all")
public class Workflow {
  public void generate(final Application it, final IFileSystemAccess fsa) {
    Definition _definition = new Definition();
    _definition.generate(it, fsa);
    PermissionCheck _permissionCheck = new PermissionCheck();
    _permissionCheck.generate(it, fsa);
    Operations _operations = new Operations();
    _operations.generate(it, fsa);
  }
}

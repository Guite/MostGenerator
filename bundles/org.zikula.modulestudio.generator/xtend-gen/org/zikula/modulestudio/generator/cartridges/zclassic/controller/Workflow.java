package org.zikula.modulestudio.generator.cartridges.zclassic.controller;

import de.guite.modulestudio.metamodel.Application;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.workflows.Definition;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.workflows.LegacyDefinition;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.workflows.LegacyOperations;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.workflows.LegacyPermissionCheck;
import org.zikula.modulestudio.generator.extensions.Utils;

/**
 * Entry point for all workflows.
 */
@SuppressWarnings("all")
public class Workflow {
  @Extension
  private Utils _utils = new Utils();
  
  public void generate(final Application it, final IFileSystemAccess fsa) {
    Boolean _targets = this._utils.targets(it, "1.5");
    if ((_targets).booleanValue()) {
      new Definition().generate(it, fsa);
    } else {
      new LegacyDefinition().generate(it, fsa);
      new LegacyPermissionCheck().generate(it, fsa);
      new LegacyOperations().generate(it, fsa);
    }
  }
}

package org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener;

import de.guite.modulestudio.metamodel.Application;
import org.eclipse.xtend2.lib.StringConcatenation;

@SuppressWarnings("all")
public class CommonExample {
  public CharSequence generalEventProperties(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("// you can access general data available in the event");
    _builder.newLine();
    _builder.newLine();
    _builder.append("// the event name");
    _builder.newLine();
    _builder.append("// echo \'Event: \' . $event->getName();");
    _builder.newLine();
    _builder.newLine();
    _builder.append("// type of current request: MASTER_REQUEST or SUB_REQUEST");
    _builder.newLine();
    _builder.append("// if a listener should only be active for the master request,");
    _builder.newLine();
    _builder.append("// be sure to check that at the beginning of your method");
    _builder.newLine();
    _builder.append("// if ($event->getRequestType() !== HttpKernelInterface::MASTER_REQUEST) {");
    _builder.newLine();
    _builder.append("//     // don\'t do anything if it\'s not the master request");
    _builder.newLine();
    _builder.append("//     return;");
    _builder.newLine();
    _builder.append("// }");
    _builder.newLine();
    _builder.newLine();
    _builder.append("// kernel instance handling the current request");
    _builder.newLine();
    _builder.append("// $kernel = $event->getKernel();");
    _builder.newLine();
    _builder.newLine();
    _builder.append("// the currently handled request");
    _builder.newLine();
    _builder.append("// $request = $event->getRequest();");
    _builder.newLine();
    return _builder;
  }
}

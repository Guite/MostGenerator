package org.zikula.modulestudio.generator.cartridges.zclassic.controller;

import de.guite.modulestudio.metamodel.Application;
import org.eclipse.xtend2.lib.StringConcatenation;

@SuppressWarnings("all")
public class ControllerHelperFunctions {
  public CharSequence defaultSorting(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("$sort = $request->query->get(\'sort\', \'\');");
    _builder.newLine();
    _builder.append("if (empty($sort) || !in_array($sort, $repository->getAllowedSortingFields())) {");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$sort = $repository->getDefaultSortingField();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$request->query->set(\'sort\', $sort);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// set default sorting in route parameters (e.g. for the pager)");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$routeParams = $request->attributes->get(\'_route_params\');");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$routeParams[\'sort\'] = $sort;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$request->attributes->set(\'_route_params\', $routeParams);");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
}

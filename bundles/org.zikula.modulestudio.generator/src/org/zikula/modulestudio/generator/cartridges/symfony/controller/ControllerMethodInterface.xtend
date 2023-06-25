package org.zikula.modulestudio.generator.cartridges.symfony.controller

import de.guite.modulestudio.metamodel.Entity
import java.util.List

interface ControllerMethodInterface {
    def void init(Entity it)
    def List<String> imports(Entity it)
    def CharSequence generateMethod(Entity it)
}

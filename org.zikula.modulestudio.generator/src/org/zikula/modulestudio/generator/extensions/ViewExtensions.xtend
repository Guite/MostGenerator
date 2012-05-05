package org.zikula.modulestudio.generator.extensions

/**
 * This class contains extension methods used for view templates generation.
 */
import de.guite.modulestudio.metamodel.modulestudio.Controller
import de.guite.modulestudio.metamodel.modulestudio.UserController

class ViewExtensions {
    /**
     * Temporary hack due to Zikula core bug with theme parameter in short urls
     * as we use the Printer theme for the quick view.
     */
    def additionalUrlParametersForQuickViewLink(Controller it) {
        switch it {
            UserController: ' forcelongurl=true'
            default: ''
        }
    }
}

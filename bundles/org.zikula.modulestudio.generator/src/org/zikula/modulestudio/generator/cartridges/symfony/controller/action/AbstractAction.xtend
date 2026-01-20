package org.zikula.modulestudio.generator.cartridges.symfony.controller.action

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Entity
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.application.ImportList
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

abstract class AbstractAction implements ActionInterface {

    extension FormattingExtensions = new FormattingExtensions
    extension Utils = new Utils

    def private formattedName(Application it) {
        name().formatForCode
    }

    def private className(Application it) {
        formattedName.toFirstUpper
    }

    def protected Iterable<String> imports(Application it)

    def private resolveImports(Application it) {
        val imports = new ImportList
        imports.addAll(imports())
        imports
    }

    /**
     * Returns a list of constructor injections of action dependencies.
     */
    def protected Iterable<String> constructorArguments(Application it)

    /**
     * Returns a list of arguments for invoking the action.
     */
    def protected Iterable<String> invocationArguments(Application it, Boolean call)

    /**
     * Main entry point.
     */
    override generate(Application it, IMostFileSystemAccess fsa) {
        'Generating ' + formattedName + ' action'.printIfNotTesting(fsa)
        fsa.generateClassPair('Controller/Action/' + className + '.php', baseImpl, impl)
    }

    /**
     * Generates base implementation.
     */
    def private baseImpl(Application it) '''
        namespace «appNamespace»\Controller\Action\Base;

        «resolveImports.print»

        «docBlock»
        abstract class Abstract«className»
        {
            «constructor»
            «invoke»
        }
    '''

    def protected CharSequence docBlock(Application it)

    def private constructor(Application it) '''
        «IF !constructorArguments.empty»
            public function __construct(
                «FOR arg : constructorArguments»
                    protected readonly «arg»,
                «ENDFOR»
            ) {
            }

        «ENDIF»
    '''

    def private invoke(Application it) '''
        public function __invoke(
            «FOR arg : invocationArguments(false)»
                «arg»,
            «ENDFOR»
        ): «returnType» {
            «implBody»
        }
    '''

    def protected String returnType(Application it)

    def protected CharSequence implBody(Application it)

    /**
     * Generates concrete implementation.
     */
    def private impl(Application it) '''
        namespace «appNamespace»\Controller\Action;

        use «appNamespace»\Controller\Action\Base\Abstract«className»;

        class «className» extends Abstract«className»
        {
            // feel free to customise the «name().formatForDisplay» action
        }
    '''

    /**
     * Returns import statement for controllers.
     */
    override controllerImport(Application it) {
        appNamespace + '\\Controller\\Action\\' + className
    }

    /**
     * Returns constructor argument for controllers.
     */
    override controllerInjection(Application it) {
        'protected readonly ' + className + ' $' + formattedName + 'Action'
    }

    def protected controllerPreprocessing(Entity it) {}

    /**
     * Generates usage inside controllers.
     */
    override controllerUsage(Application it, Entity entity) '''
        «route(entity)»
        «controllerAttributes(entity)»
        public function «formattedName»(«invocationArguments(false).join(', ')»): Response
        {
            «entity.controllerPreprocessing»
            return ($this->«formattedName»Action)(«invocationArgumentsInCall»);
        }
    '''

    def private invocationArgumentsInCall(Application it) {
        invocationArguments(true).map[a|a.split(' ').toList.last].join(', ')
    } 

    def protected route(Application it, Entity entity) '''
        #[AdminRoute(path: '/«formattedName»', name: '«name().formatForDB»', options: «entity.routeMethodAndOptions»)]
    '''

    def protected controllerAttributes(Application it, Entity entity) {}

    def protected routeMethodAndOptions(Entity it) '''['methods' => «routeMethods»«IF 0 < routeOptions.length», «routeOptions»«ENDIF»]'''

    def protected routeMethods(Entity it) ''''''

    def protected routeOptions(Entity it) ''''''
}

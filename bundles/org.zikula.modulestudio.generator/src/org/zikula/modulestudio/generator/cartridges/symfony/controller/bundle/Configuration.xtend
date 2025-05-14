package org.zikula.modulestudio.generator.cartridges.symfony.controller.bundle

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.ArrayField
import de.guite.modulestudio.metamodel.BooleanField
import de.guite.modulestudio.metamodel.Field
import de.guite.modulestudio.metamodel.ListField
import de.guite.modulestudio.metamodel.ListFieldItem
import de.guite.modulestudio.metamodel.NumberField
import de.guite.modulestudio.metamodel.NumberFieldType
import de.guite.modulestudio.metamodel.NumberRole
import de.guite.modulestudio.metamodel.UserField
import de.guite.modulestudio.metamodel.Variables
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.symfony.models.entity.Property
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Configuration {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension Utils = new Utils

    /**
     * Entry point for application settings class.
     */
    def generate(Application it, IMostFileSystemAccess fsa) {
        if (getAllVariables.empty) {
            return
        }
        val definitionFilePath = 'config/definition.php'
        fsa.generateFile(definitionFilePath, configurationImpl)
    }

    def private configurationImpl(Application it) '''
        namespace «appNamespace»\DependencyInjection\Base;

        use Symfony\Component\Config\Definition\Configurator\DefinitionConfigurator;
        
        return static function (DefinitionConfigurator $definition): void
        {
            $definition->rootNode()
                «configurationBuilder»
            ;
        };
    '''

    def private configurationBuilder(Application it) '''
        ->children()
            «FOR varContainer : sortedVariableContainers»
                «varContainer.configSection»
            «ENDFOR»
        ->end()
    '''

    def private configSection(Variables it) '''
        ->arrayNode('«name.formatForSnakeCase»')
            «IF null !== documentation && !documentation.empty»
                ->info('«documentation.formatForDisplayCapital»')
            «ENDIF»
            ->addDefaultsIfNotSet()
            ->children()
                «FOR field : fields»
                    «field.definition»
                «ENDFOR»
            ->end()
        ->end()
    '''

    def private definition(Field it) '''
        ->«nodeType»Node('«name.formatForSnakeCase»')
            «IF null !== documentation && !documentation.empty»
                ->info('«documentation.formatForDisplayCapital»«IF null !== additionalInfo» «additionalInfo»«ENDIF»')
            «ELSEIF null !== additionalInfo»
                ->info('«additionalInfo»')
            «ENDIF»
            ->defaultValue(«initialValue»)
            «validation»
        ->end()
    '''

    def private additionalInfo(Field it) {
        if (it instanceof UserField) {
            return 'Needs to be a user ID.'
        } else if (it instanceof NumberField && (it as NumberField).isUserGroupSelector) {
            return 'Needs to be a group ID.';
        }
        null
    }

    def private nodeType(Field it) {
        switch (it) {
            BooleanField: 'boolean'
            NumberField case NumberFieldType.INTEGER === numberType: 'integer'
            NumberField/* case NumberFieldType.FLOAT === numberType*/: 'float'
            ListField: 'enum'
            ArrayField: 'array'
            default: 'scalar'
        }
    }

    def private initialValue(Field it) {
        Property.defaultFieldData(it)
    }

    def private validation(Field it) '''
        «IF it instanceof NumberField»
            «IF NumberRole.RANGE == role»
                ->min(«minValue»)
                ->max(«maxValue»)
            «ELSE»
                «IF minValue > 0»
                    ->min(«minValue»)
                «ENDIF»
                «IF maxValue > 0»
                    ->max(«maxValue»)
                «ENDIF»
            «ENDIF»
        «ELSEIF it instanceof ListField»
            ->values([«FOR item : items SEPARATOR ', '»'«item.listEntry»'«ENDFOR»])
        «ENDIF»
        «IF it instanceof ArrayField»
            «IF mandatory»
                ->isRequired()
                ->requiresAtLeastOneElement()
            «ENDIF»
            ->ignoreExtraKeys()
        «ELSE»
            «IF mandatory»
                ->isRequired()
                «IF !(it instanceof BooleanField || it instanceof NumberField)»
                ->cannotBeEmpty()
                «ENDIF»
            «ENDIF»
        «ENDIF»
    '''

    def private listEntry(ListFieldItem it) '''«IF null !== value»«value.replace("'", "")»«ELSE»«name.formatForCode.replace("'", "")»«ENDIF»'''
}

package org.zikula.modulestudio.generator.cartridges.zclassic.controller.di

import de.guite.modulestudio.metamodel.AbstractIntegerField
import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.ArrayField
import de.guite.modulestudio.metamodel.BooleanField
import de.guite.modulestudio.metamodel.DerivedField
import de.guite.modulestudio.metamodel.Field
import de.guite.modulestudio.metamodel.IntegerField
import de.guite.modulestudio.metamodel.ListField
import de.guite.modulestudio.metamodel.ListFieldItem
import de.guite.modulestudio.metamodel.NumberField
import de.guite.modulestudio.metamodel.UserField
import de.guite.modulestudio.metamodel.Variables
import java.math.BigInteger
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.Property
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
        if (variables.empty) {
            return
        }
        'Generating bundle configuration class'.printIfNotTesting(fsa)
        fsa.generateClassPair('DependencyInjection/Configuration.php', configurationBaseImpl, configurationImpl)
    }

    def private configurationBaseImpl(Application it) '''
        namespace «appNamespace»\DependencyInjection\Base;

        use Symfony\Component\Config\Definition\Builder\TreeBuilder;
        use Symfony\Component\Config\Definition\ConfigurationInterface;

        /**
         * Bundle configuration class.
         */
        abstract class AbstractConfiguration implements ConfigurationInterface
        {
            «getConfigTreeBuilder»
        }
    '''

    def private getConfigTreeBuilder(Application it) '''
        public function getConfigTreeBuilder(): TreeBuilder
        {
            $treeBuilder = new TreeBuilder('«vendor.formatForDB»_«name.formatForDB»');

            $treeBuilder->getRootNode()
                «configurationBuilder»
            ;

            return $treeBuilder;
        }
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
                «FOR field : fields.filter(DerivedField)»
                    «field.definition»
                «ENDFOR»
            ->end()
        ->end()
    '''

    def private definition(DerivedField it) '''
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

    def private additionalInfo(DerivedField it) {
        if (it instanceof UserField) {
            return 'Needs to be a user ID.'
        } else if (it instanceof IntegerField && (it as IntegerField).isUserGroupSelector) {
            return 'Needs to be a group ID.';
        }
        null
    }

    def private nodeType(DerivedField it) {
        switch (it) {
            BooleanField: 'boolean'
            AbstractIntegerField: 'integer'
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
        «IF it instanceof IntegerField»
            «IF range»
                ->min(«minValue»)
                ->max(«maxValue»)
            «ELSE»
                «IF minValue.compareTo(BigInteger.valueOf(0)) > 0»
                    ->min(«minValue»)
                «ENDIF»
                «IF maxValue.compareTo(BigInteger.valueOf(0)) > 0»
                    ->max(«maxValue»)
                «ENDIF»
            «ENDIF»
        «ELSEIF it instanceof NumberField»
            «IF minValue > 0»
                ->min(«minValue»)
            «ENDIF»
            «IF maxValue > 0»
                ->max(«maxValue»)
            «ENDIF»
        «ELSEIF it instanceof ListField»
            ->values([«FOR item : items SEPARATOR ', '»'«item.listEntry»'«ENDFOR»])
        «ENDIF»
        «IF it instanceof ArrayField»
            «IF (it as DerivedField).mandatory»
                ->isRequired()
                ->requiresAtLeastOneElement()
            «ENDIF»
            ->ignoreExtraKeys()
        «ELSE»
            «IF (it as DerivedField).mandatory»
                ->isRequired()
                «IF !(it instanceof BooleanField || it instanceof AbstractIntegerField || it instanceof NumberField)»
                ->cannotBeEmpty()
                «ENDIF»
            «ENDIF»
        «ENDIF»
    '''

    def private listEntry(ListFieldItem it) '''«IF null !== value»«value.replace("'", "")»«ELSE»«name.formatForCode.replace("'", "")»«ENDIF»'''

    def private configurationImpl(Application it) '''
        namespace «appNamespace»\DependencyInjection;

        use «appNamespace»\DependencyInjection\Base\AbstractConfiguration;

        /**
         * Bundle configuration class.
         */
        class Configuration extends AbstractConfiguration
        {
            // feel free to add your own methods here
        }
    '''
}

package org.zikula.modulestudio.generator.cartridges.zclassic.controller.di

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class DependencyInjection {

    extension FormattingExtensions = new FormattingExtensions
    extension Utils = new Utils

    def generate(Application it, IMostFileSystemAccess fsa) {
        val extensionFileName = vendor.formatForCodeCapital + name.formatForCodeCapital + 'Extension.php'
        fsa.generateClassPair('DependencyInjection/' + extensionFileName, extensionBaseImpl, extensionImpl)
    }

    def private extensionBaseImpl(Application it) '''
        namespace «appNamespace»\DependencyInjection\Base;

        use Symfony\Component\Config\FileLocator;
        use Symfony\Component\DependencyInjection\ContainerBuilder;
        use Symfony\Component\DependencyInjection\Loader\YamlFileLoader;
        use Symfony\Component\HttpKernel\DependencyInjection\Extension;
        use «appNamespace»\DependencyInjection\Configuration;

        /**
         * DependencyInjection extension base class.
         */
        abstract class Abstract«vendor.formatForCodeCapital»«name.formatForCodeCapital»Extension extends Extension
        {
            public function load(array $configs, ContainerBuilder $container)
            {
                $loader = new YamlFileLoader($container, new FileLocator(__DIR__ . '/../../Resources/config'));
                $loader->load('services.yaml');
                «IF needsConfig»

                    $configuration = new Configuration();
                    $config = $this->processConfiguration($configuration, $configs);

                    // TODO apply
                «ENDIF»
            }
        }
    '''

    def private extensionImpl(Application it) '''
        namespace «appNamespace»\DependencyInjection;

        use «appNamespace»\DependencyInjection\Base\Abstract«vendor.formatForCodeCapital»«name.formatForCodeCapital»Extension;

        /**
         * DependencyInjection extension implementation class.
         */
        class «vendor.formatForCodeCapital»«name.formatForCodeCapital»Extension extends Abstract«vendor.formatForCodeCapital»«name.formatForCodeCapital»Extension
        {
            // custom enhancements can go here
        }
    '''
}

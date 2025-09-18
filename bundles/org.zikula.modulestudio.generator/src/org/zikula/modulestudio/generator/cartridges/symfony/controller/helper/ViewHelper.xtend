package org.zikula.modulestudio.generator.cartridges.symfony.controller.helper

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.application.ImportList
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ViewHelper {

    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelExtensions = new ModelExtensions
    extension Utils = new Utils

    /**
     * Entry point for the helper class creation.
     */
    def generate(Application it, IMostFileSystemAccess fsa) {
        'Generating helper class for view layer'.printIfNotTesting(fsa)
        fsa.generateClassPair('Helper/ViewHelper.php', viewFunctionsBaseImpl, viewFunctionsImpl)
    }

    def private collectBaseImports(Application it) {
        val imports = new ImportList
        imports.addAll(#[
            'Symfony\\Component\\DependencyInjection\\Attribute\\Autowire',
            'Symfony\\Component\\HttpFoundation\\RequestStack',
            'Symfony\\Component\\HttpFoundation\\Response',
            'Twig\\Environment',
            'Twig\\Loader\\LoaderInterface',
            'Zikula\\CoreBundle\\Response\\PlainResponse',
            appNamespace + '\\Helper\\ControllerHelper',
            appNamespace + '\\Helper\\PermissionHelper'
        ])
        if (hasGeographical) {
            imports.add('Symfony\\Component\\Filesystem\\Filesystem')
            imports.add('Symfony\\Component\\HttpKernel\\KernelInterface')
        }
        if (!entities.filter[hasDateIntervalFieldsEntity].empty) {
            imports.add('Symfony\\Contracts\\Translation\\TranslatorInterface')
        }
        imports
    }

    def private viewFunctionsBaseImpl(Application it) '''
        namespace «appNamespace»\Helper\Base;

        «collectBaseImports.print»

        /**
         * Helper base class for view layer methods.
         */
        abstract class AbstractViewHelper
        {
            «helperBaseImpl»
        }
    '''

    def private helperBaseImpl(Application it) '''
        public function __construct(
            «IF hasGeographical»
                protected readonly KernelInterface $kernel,
                protected readonly Filesystem $filesystem,
            «ENDIF»
            «IF !entities.filter[hasDateIntervalFieldsEntity].empty»
                protected readonly TranslatorInterface $translator,
            «ENDIF»
            protected readonly Environment $twig,
            #[Autowire(service: 'twig.loader')]
            protected readonly LoaderInterface $twigLoader,
            protected readonly RequestStack $requestStack,
            protected readonly ControllerHelper $controllerHelper,
            protected readonly PermissionHelper $permissionHelper«IF hasGeographical»,
            protected readonly array $geoConfig«ENDIF»
        ) {
        }

        «getViewTemplate»

        «processTemplate»

        «determineExtension»
        «IF hasGeographical»

            «copyLeafletAssets»
        «ENDIF»
        «IF !entities.filter[hasDateIntervalFieldsEntity].empty»

            «getFormattedDateInterval»
        «ENDIF»
    '''

    def private getViewTemplate(Application it) '''
        /**
         * Determines the view template for a certain method with given parameters.
         */
        public function getViewTemplate(string $type, string $func): string
        {
            // create the base template name
            $template = '@«vendorAndName»/' . ucfirst($type) . '/' . $func;

            // check for template extension
            $templateExtension = '.' . $this->determineExtension($type, $func);

            // check whether a special template is used
            $request = $this->requestStack->getCurrentRequest();
            $tpl = $request?->query->getAlnum('tpl');
            if (!empty($tpl)) {
                // check if custom template exists
                $customTemplate = $template . ucfirst($tpl);
                if ($this->twigLoader->exists($customTemplate . $templateExtension)) {
                    $template = $customTemplate;
                }
            }

            $template .= $templateExtension;

            return $template;
        }
    '''

    def private processTemplate(Application it) '''
        /**
         * Helper method for managing view templates.
         */
        public function processTemplate(
            string $type,
            string $func,
            array $templateParameters = [],
            string $template = ''
        ): Response {
            $templateExtension = $this->determineExtension($type, $func);
            if (empty($template)) {
                $template = $this->getViewTemplate($type, $func);
            }
            «IF hasGeographical»
                $this->copyLeafletAssets();
                $templateParameters['geoConfig'] = $this->geoConfig;

            «ENDIF»
            // look whether we need output with or without the theme
            $request = $this->requestStack->getCurrentRequest();
            $raw = null !== $request ? $request->query->getBoolean('raw') : false;
            if (!$raw && 'html.twig' !== $templateExtension) {
                $raw = true;
            }

            $output = $this->twig->render($template, $templateParameters);
            $response = null;
            if (true === $raw) {
                // standalone output
                $response = new PlainResponse($output);
            } else {
                // normal output
                $response = new Response($output);
            }

            return $response;
        }
    '''

    def private determineExtension(Application it) '''
        /**
         * Get extension of the currently treated template.
         *
         * @deprecated
         */
        protected function determineExtension(string $type, string $func): string
        {
            $templateExtension = 'html.twig';

            return $templateExtension;
        }
    '''

    def private copyLeafletAssets(Application it) '''
        protected function copyLeafletAssets()
        {
            $bundle = $this->kernel->getBundle('«appName»');
            $leafletSrcPath = $bundle->getPath() . '/vendor/drmonty/leaflet/';
            $leafletPublicPath = $this->kernel->getProjectDir() . '/public/bundles/«vendor.toLowerCase»«name.toLowerCase»/leaflet/';
            if (!$this->filesystem->exists($leafletPublicPath)) {
                $this->filesystem->mkdir($leafletPublicPath);
            }

            $leafletFiles = [
                ['type' => 'css', 'file' => 'leaflet.css'],
                ['type' => 'images', 'file' => 'layers-2x.png'],
                ['type' => 'images', 'file' => 'layers.png'],
                ['type' => 'images', 'file' => 'marker-icon-2x.png'],
                ['type' => 'images', 'file' => 'marker-icon.png'],
                ['type' => 'images', 'file' => 'marker-shadow.png'],
                ['type' => 'js', 'file' => 'leaflet.min.js'],
            ];
            foreach ($leafletFiles as $fileDef) {
                $relativeFilePath = $fileDef['type'] . '/' . $fileDef['file'];
                if (!$this->filesystem->exists($leafletPublicPath . $relativeFilePath)) {
                    $this->filesystem->copy($leafletSrcPath . $relativeFilePath, $leafletPublicPath . $relativeFilePath);
                }
            }
        }
    '''

    def private getFormattedDateInterval(Application it) '''
        /**
         * Returns a formatted description for a given date interval (duration string).
         *
         * @see https://www.php.net/manual/en/dateinterval.format.php
         */
        public function getFormattedDateInterval(\DateInterval|string $duration): string
        {
            $interval = is_string($duration) ? new DateInterval($duration) : $duration;

            $description = 1 === $interval->invert ? '- ' : '';

            $parts = [];
            $amount = $interval->y;
            if (0 < $amount) {
                $parts[] = $this->translator->trans('%count% year|%count% years', ['%count%' => $amount]);
            }

            $amount = $interval->m;
            if (0 < $amount) {
                $parts[] = $this->translator->trans('%count% month|%count% months', ['%count%' => $amount]);
            }

            $amount = $interval->d;
            if (0 < $amount) {
                $parts[] = $this->translator->trans('%count% day|%count% days', ['%count%' => $amount]);
            }

            $amount = $interval->h;
            if (0 < $amount) {
                $parts[] = $this->translator->trans('%count% hour|%count% hours', ['%count%' => $amount]);
            }

            $amount = $interval->i;
            if (0 < $amount) {
                $parts[] = $this->translator->trans('%count% minute|%count% minutes', ['%count%' => $amount]);
            }

            $amount = $interval->s;
            if (0 < $amount) {
                $parts[] = $this->translator->trans('%count% second|%count% seconds', ['%count%' => $amount]);
            }

            $description .= implode(', ', $parts);

            return $description;
        }
    '''

    def private viewFunctionsImpl(Application it) '''
        namespace «appNamespace»\Helper;

        use «appNamespace»\Helper\Base\AbstractViewHelper;

        /**
         * Helper implementation class for view layer methods.
         */
        class ViewHelper extends AbstractViewHelper
        {
            // feel free to add your own convenience methods here
        }
    '''
}

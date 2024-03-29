package org.zikula.modulestudio.generator.cartridges.symfony.controller.helper

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.Utils
import org.zikula.modulestudio.generator.extensions.ViewExtensions
import org.zikula.modulestudio.generator.application.ImportList

class ViewHelper {

    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension Utils = new Utils
    extension ViewExtensions = new ViewExtensions

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
        if (generatePdfSupport) {
            imports.addAll(#[
                'Dompdf\\Dompdf',
                'Zikula\\CoreBundle\\Site\\SiteDefinitionInterface',
                'Zikula\\ThemeBundle\\Engine\\ParameterBag'
            ])
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
            protected readonly Environment $twig,
            #[Autowire(service: 'twig.loader')]
            protected readonly LoaderInterface $twigLoader,
            protected readonly RequestStack $requestStack,
            «IF generatePdfSupport»
                protected readonly SiteDefinitionInterface $site,
                #[Autowire(service: 'zikula_core.common.theme.pagevars')]
                protected readonly ParameterBag $pageVars,
            «ENDIF»
            protected readonly ControllerHelper $controllerHelper,
            protected readonly PermissionHelper $permissionHelper«IF hasGeographical»,
            protected readonly array $geoConfig«ENDIF»
        ) {
        }

        «getViewTemplate»

        «processTemplate»

        «determineExtension»

        «availableExtensions»
        «IF generatePdfSupport»

            «processPdf»
        «ENDIF»
        «IF hasGeographical»

            «copyLeafletAssets»
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
            «IF generatePdfSupport»

                if ('pdf.twig' === $templateExtension) {
                    $template = str_replace('.pdf', '.html', $template);

                    return $this->processPdf($templateParameters, $template);
                }
            «ENDIF»

            // look whether we need output with or without the theme
            $request = $this->requestStack->getCurrentRequest();
            $raw = null !== $request ? $request->query->getBoolean('raw') : false;
            if (!$raw && 'html.twig' !== $templateExtension) {
                $raw = true;
            }

            $output = $this->twig->render($template, $templateParameters);
            «val supportedFormats = getListOfViewFormats + getListOfDisplayFormats»
            $response = null;
            if (true === $raw) {
                // standalone output
                «IF supportedFormats.exists[it == 'csv']»
                    if ('csv.twig' === $templateExtension) {
                        // convert to UTF-16 for improved excel compatibility
                        // see http://stackoverflow.com/questions/4348802/how-can-i-output-a-utf-8-csv-in-php-that-excel-will-read-properly
                        $output = chr(255) . chr(254) . mb_convert_encoding($output, 'UTF-16LE', 'UTF-8');
                    }
                «ENDIF»

                $response = new PlainResponse($output);
            } else {
                // normal output
                $response = new Response($output);
            }
            «IF !supportedFormats.empty»

                // check if we need to set any custom headers
                switch ($templateExtension) {
                    «IF supportedFormats.exists[it == 'csv']»
                        case 'csv.twig':
                            $response->headers->set('Content-Encoding', 'UTF-8');
                            $response->headers->set('Content-Type', 'text/csv; charset=UTF-8');
                            $response->headers->set('Content-Disposition', 'attachment; filename=' . $type . '-list.csv');
                            break;
                    «ENDIF»
                    «IF supportedFormats.exists[it == 'ics']»
                        case 'ics.twig':
                            $response->headers->set('Content-Type', 'text/calendar; charset=utf-8');
                            break;
                    «ENDIF»
                    «IF supportedFormats.exists[it == 'json']»
                        case 'json.twig':
                            $response->headers->set('Content-Type', 'application/json');
                            break;
                    «ENDIF»
                    «IF supportedFormats.exists[it == 'kml']»
                        case 'kml.twig':
                            $response->headers->set('Content-Type', 'application/vnd.google-earth.kml+xml');
                            break;
                    «ENDIF»
                    «IF supportedFormats.exists[it == 'xml']»
                        case 'xml.twig':
                            $response->headers->set('Content-Type', 'text/xml');
                            break;
                    «ENDIF»
                    «IF supportedFormats.exists[it == 'atom']»
                        case 'atom.twig':
                            $response->headers->set('Content-Type', 'application/atom+xml');
                            break;
                    «ENDIF»
                    «IF supportedFormats.exists[it == 'rss']»
                        case 'rss.twig':
                            $response->headers->set('Content-Type', 'application/rss+xml');
                            break;
                    «ENDIF»
                }
            «ENDIF»

            return $response;
        }
    '''

    def private determineExtension(Application it) '''
        /**
         * Get extension of the currently treated template.
         */
        protected function determineExtension(string $type, string $func): string
        {
            $templateExtension = 'html.twig';
            if (!in_array($func, ['index', 'detail'])) {
                return $templateExtension;
            }

            $request = $this->requestStack->getCurrentRequest();
            if (null === $request) {
                return $templateExtension;
            }

            $extensions = $this->availableExtensions($type, $func);
            if ($request->query->has('_format') && in_array($customFormat = $request->query->get('_format'), $extensions, true)) {
                $request->setRequestFormat($customFormat);
            }

            $format = $request->getRequestFormat();
            if ('html' !== $format && in_array($format, $extensions, true)) {
                $templateExtension = $format . '.twig';
            }

            return $templateExtension;
        }
    '''

    def private availableExtensions(Application it) '''
        /**
         * Get list of available template extensions.
         *
         * @return string[] List of allowed template extensions
         */
        protected function availableExtensions(string $type, string $func): array
        {
            $extensions = [];
            $hasAdminAccess = $this->permissionHelper->hasComponentPermission($type, ACCESS_ADMIN);
            if ('index' === $func) {
                if ($hasAdminAccess) {
                    $extensions = [«FOR format : getListOfViewFormats SEPARATOR ', '»'«format»'«ENDFOR»];
                } else {
                    $extensions = [«FOR format : getListOfViewFormats.filter[#['rss', 'atom', 'pdf'].contains(it)] SEPARATOR ', '»'«format»'«ENDFOR»];
                }
            } elseif ('detail' === $func) {
                if ($hasAdminAccess) {
                    $extensions = [«FOR format : getListOfDisplayFormats SEPARATOR ', '»'«format»'«ENDFOR»];
                } else {
                    $extensions = [«FOR format : getListOfDisplayFormats.filter[#['ics', 'pdf'].contains(it)] SEPARATOR ', '»'«format»'«ENDFOR»];
                }
            }

            return $extensions;
        }
    '''

    def private processPdf(Application it) '''
        /**
         * Processes a template file using dompdf (LGPL).
         */
        protected function processPdf(array $templateParameters = [], string $template = ''): Response
        {
            // first the content, to set page vars
            $output = $this->twig->render($template, $templateParameters);

            // make local images absolute
            $request = $this->requestStack->getCurrentRequest();
            $output = str_replace(
                ['img src="' . $request->getSchemeAndHttpHost() . $request->getBasePath() . '/', 'img src="/'],
                ['img src="/', 'img src="' . $request->server->get('DOCUMENT_ROOT') . '/'],
                $output
            );

            // then the surrounding
            $output = $this->twig->render('@«vendorAndName»/includePdfHeader.html.twig') . $output . '</body></html>';

            // create name of the pdf output file
            $pageTitle = iconv('UTF-8', 'ASCII//TRANSLIT', $this->pageVars->get('title'));
            $fileTitle = iconv('UTF-8', 'ASCII//TRANSLIT', $this->site->getName())
               . '-'
               . ('' !== $pageTitle ? $pageTitle . '-' : '')
               . date('Ymd') . '.pdf'
            ;
            $fileTitle = str_replace(' ', '_', $fileTitle);

            /*
            if (true === $request->query->getBoolean('dbg', false)) {
                die($output);
            }
            */

            // instantiate pdf object
            $pdf = new Dompdf();
            // define page properties
            $pdf->setPaper('A4', 'portrait');
            // load html input data
            $pdf->loadHtml($output);
            // create the actual pdf file
            $pdf->render();
            // stream output to browser
            $pdf->stream($fileTitle);

            return new Response();
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

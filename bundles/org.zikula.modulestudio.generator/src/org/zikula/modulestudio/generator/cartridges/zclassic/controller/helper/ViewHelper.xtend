package org.zikula.modulestudio.generator.cartridges.zclassic.controller.helper

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.Utils
import org.zikula.modulestudio.generator.extensions.ViewExtensions

class ViewHelper {

    extension Utils = new Utils
    extension ViewExtensions = new ViewExtensions

    /**
     * Entry point for the helper class creation.
     */
    def generate(Application it, IMostFileSystemAccess fsa) {
        'Generating helper class for view layer'.printIfNotTesting(fsa)
        fsa.generateClassPair('Helper/ViewHelper.php', viewFunctionsBaseImpl, viewFunctionsImpl)
    }

    def private viewFunctionsBaseImpl(Application it) '''
        namespace «appNamespace»\Helper\Base;

        «IF generatePdfSupport»
            use Dompdf\Dompdf;
        «ENDIF»
        «IF !targets('3.0')»
            use Symfony\Bundle\TwigBundle\Loader\FilesystemLoader;
        «ENDIF»
        use Symfony\Component\HttpFoundation\RequestStack;
        use Symfony\Component\HttpFoundation\Response;
        use Twig«IF targets('3.0')»\«ELSE»_«ENDIF»Environment;
        «IF targets('3.0')»
            use Twig\Loader\LoaderInterface;
            use Zikula\Bundle\CoreBundle\Response\PlainResponse;
        «ELSE»
            use Zikula\Core\Response\PlainResponse;
        «ENDIF»
        use Zikula\ExtensionsModule\Api\ApiInterface\VariableApiInterface;
        «IF !targets('3.0')»
            use Zikula\ThemeModule\Engine\AssetFilter;
        «ENDIF»
        «IF generatePdfSupport»
            use Zikula\ThemeModule\Engine\ParameterBag;
        «ENDIF»
        use «appNamespace»\Helper\ControllerHelper;
        use «appNamespace»\Helper\PermissionHelper;

        /**
         * Helper base class for view layer methods.
         */
        abstract class AbstractViewHelper
        {
            «helperBaseImpl»
        }
    '''

    def private helperBaseImpl(Application it) '''
        /**
         * @var «IF !targets('3.0')»Twig_«ENDIF»Environment
         */
        protected $twig;

        /**
         * @var «IF targets('3.0')»LoaderInterface«ELSE»FilesystemLoader«ENDIF»
         */
        protected $twigLoader;

        /**
         * @var RequestStack
         */
        protected $requestStack;

        /**
         * @var VariableApiInterface
         */
        protected $variableApi;

        «IF !targets('3.0')»
            /**
             * @var AssetFilter
             */
            protected $assetFilter;

        «ENDIF»
        «IF generatePdfSupport»
            /**
             * @var ParameterBag
             */
            protected $pageVars;

        «ENDIF»
        /**
         * @var ControllerHelper
         */
        protected $controllerHelper;

        /**
         * @var PermissionHelper
         */
        protected $permissionHelper;

        public function __construct(
            «IF !targets('3.0')»Twig_«ENDIF»Environment $twig,
            «IF targets('3.0')»LoaderInterface«ELSE»FilesystemLoader«ENDIF» $twigLoader,
            RequestStack $requestStack,
            VariableApiInterface $variableApi,
            «IF !targets('3.0')»
                AssetFilter $assetFilter,
            «ENDIF»
            «IF generatePdfSupport»
                ParameterBag $pageVars,
            «ENDIF»
            ControllerHelper $controllerHelper,
            PermissionHelper $permissionHelper
        ) {
            $this->twig = $twig;
            $this->twigLoader = $twigLoader;
            $this->requestStack = $requestStack;
            $this->variableApi = $variableApi;
            «IF !targets('3.0')»
                $this->assetFilter = $assetFilter;
            «ENDIF»
            «IF generatePdfSupport»
                $this->pageVars = $pageVars;
            «ENDIF»
            $this->controllerHelper = $controllerHelper;
            $this->permissionHelper = $permissionHelper;
        }

        «getViewTemplate»

        «processTemplate»
        «IF !targets('3.0')»

            «injectAssetsIntoRawOutput»
        «ENDIF»

        «determineExtension»

        «availableExtensions»
        «IF generatePdfSupport»

            «processPdf»
        «ENDIF»
    '''

    def private getViewTemplate(Application it) '''
        /**
         * Determines the view template for a certain method with given parameters.
         «IF !targets('3.0')»
         *
         «IF separateAdminTemplates»
         * @param string $type Current controller (name of currently treated entity)
         * @param string $func Current function (index, view, ...)
         * @param bool $isAdmin Whether an admin template is desired or not
         «ELSE»
         * @param string $type Current controller (name of currently treated entity)
         * @param string $func Current function (index, view, ...)
         «ENDIF»
         *
         * @return string name of template file
         «ENDIF»
         */
        public function getViewTemplate(«IF targets('3.0')»string «ENDIF»$type, «IF targets('3.0')»string «ENDIF»$func«IF separateAdminTemplates», «IF targets('3.0')»bool «ENDIF»$isAdmin = false«ENDIF»)«IF targets('3.0')»: string«ENDIF»
        {
            // create the base template name
            $template = '@«appName»/' . ucfirst($type) . '/' . «IF separateAdminTemplates»($isAdmin ? 'Admin/' : '') . «ENDIF»$func;

            // check for template extension
            $templateExtension = '.' . $this->determineExtension($type, $func);

            // check whether a special template is used
            $request = $this->requestStack->getCurrentRequest();
            $tpl = null !== $request ? $request->query->getAlnum('tpl') : '';
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
         «IF !targets('3.0')»
         *
         * @param string $type Current controller (name of currently treated entity)
         * @param string $func Current function (index, view, ...)
         * @param array $templateParameters Template data
         * @param string $template Optional assignment of precalculated template file
         *
         * @return Response
         «ENDIF»
         */
        public function processTemplate(
            «IF targets('3.0')»string «ENDIF»$type,
            «IF targets('3.0')»string «ENDIF»$func,
            array $templateParameters = [],
            «IF targets('3.0')»string «ENDIF»$template = ''
        )«IF targets('3.0')»: Response«ENDIF» {
            $templateExtension = $this->determineExtension($type, $func);
            if (empty($template)) {
                «IF separateAdminTemplates»
                    $isAdmin = isset($templateParameters['routeArea']) && 'admin' === $templateParameters['routeArea'];
                «ENDIF»
                $template = $this->getViewTemplate($type, $func«IF separateAdminTemplates», $isAdmin«ENDIF»);
            }
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
                «IF !targets('3.0')»
                    $output = $this->injectAssetsIntoRawOutput($output);
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

    def private injectAssetsIntoRawOutput(Application it) '''
        /**
         * Adds assets to a raw page which is not processed by the Theme engine.
         «IF !targets('3.0')»
         *
         * @param string $output The output to be enhanced
         *
         * @return string Output including additional assets
         «ENDIF»
         */
        protected function injectAssetsIntoRawOutput(«IF targets('3.0')»string «ENDIF»$output = '')«IF targets('3.0')»: string«ENDIF»
        {
            return $this->assetFilter->filter($output);
        }
    '''

    def private determineExtension(Application it) '''
        /**
         * Get extension of the currently treated template.
         «IF !targets('3.0')»
         *
         * @param string $type Current controller (name of currently treated entity)
         * @param string $func Current function (index, view, ...)
         *
         * @return string Template extension
         «ENDIF»
         */
        protected function determineExtension(«IF targets('3.0')»string «ENDIF»$type, «IF targets('3.0')»string «ENDIF»$func)«IF targets('3.0')»: string«ENDIF»
        {
            $templateExtension = 'html.twig';
            if (!in_array($func, ['view', 'display'])) {
                return $templateExtension;
            }

            $extensions = $this->availableExtensions($type, $func);
            $request = $this->requestStack->getCurrentRequest();
            if (null === $request) {
                return $templateExtension;
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
         «IF !targets('3.0')»
         *
         * @param string $type Current controller (name of currently treated entity)
         * @param string $func Current function (index, view, ...)
         «ENDIF»
         *
         * @return string[] List of allowed template extensions
         */
        protected function availableExtensions(«IF targets('3.0')»string «ENDIF»$type, «IF targets('3.0')»string «ENDIF»$func)«IF targets('3.0')»: array«ENDIF»
        {
            $extensions = [];
            $hasAdminAccess = $this->permissionHelper->hasComponentPermission($type, ACCESS_ADMIN);
            if ('view' === $func) {
                if ($hasAdminAccess) {
                    $extensions = [«FOR format : getListOfViewFormats SEPARATOR ', '»'«format»'«ENDFOR»];
                } else {
                    $extensions = [«FOR format : getListOfViewFormats.filter[#['rss', 'atom', 'pdf'].contains(it)] SEPARATOR ', '»'«format»'«ENDFOR»];
                }
            } elseif ('display' === $func) {
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
         «IF !targets('3.0')»
         *
         * @param array $templateParameters Template data
         * @param string $template Name of template to use
         *
         * @return Response
         «ENDIF»
         */
        protected function processPdf(array $templateParameters = [], «IF targets('3.0')»string «ENDIF»$template = '')«IF targets('3.0')»: Response«ENDIF»
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
            $output = $this->twig->render('@«appName»/includePdfHeader.html.twig') . $output . '</body></html>';

            // create name of the pdf output file
            $siteName = $this->variableApi->getSystemVar('sitename');
            $pageTitle = iconv('UTF-8', 'ASCII//TRANSLIT', $this->pageVars->get('title'));
            $fileTitle = iconv('UTF-8', 'ASCII//TRANSLIT', $siteName)
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

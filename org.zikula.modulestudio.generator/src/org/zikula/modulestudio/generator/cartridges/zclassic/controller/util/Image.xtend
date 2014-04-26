package org.zikula.modulestudio.generator.cartridges.zclassic.controller.util

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Image {
    @Inject extension NamingExtensions = new NamingExtensions
    @Inject extension Utils = new Utils

    FileHelper fh = new FileHelper

    /**
     * Entry point for the utility class creation.
     */
    def generate(Application it, IFileSystemAccess fsa) {
        println('Generating utility class for image handling')
        generateClassPair(fsa, getAppSourceLibPath + 'Util/Image' + (if (targets('1.3.5')) '' else 'Util') + '.php',
            fh.phpFileContent(it, imageFunctionsBaseImpl), fh.phpFileContent(it, imageFunctionsImpl)
        )
    }

    def private imageFunctionsBaseImpl(Application it) '''
        «IF !targets('1.3.5')»
            namespace «appNamespace»\Util\Base;

            use SystemPlugin_Imagine_Preset;
            use Zikula_AbstractBase;

        «ENDIF»
        /**
         * Utility base class for image helper methods.
         */
        class «IF targets('1.3.5')»«appName»_Util_Base_Image«ELSE»ImageUtil«ENDIF» extends Zikula_AbstractBase
        {
            «getPreset»

            «getCustomPreset»
        }
    '''

    def private getPreset(Application it) '''
        /**
         * This method returns an Imagine preset for the given arguments.
         *
         * @param string $objectType Currently treated entity type.
         * @param string $fieldName  Name of upload field.
         * @param string $context    Usage context (allowed values: controllerAction, api, actionHandler, block, contentType).
         * @param array  $args       Additional arguments.
         *
         * @return SystemPlugin_Imagine_Preset The selected preset.
         */
        public function getPreset($objectType = '', $fieldName = '', $context = '', $args = array())
        {
            if (!in_array($context, array('controllerAction', 'api', 'actionHandler', 'block', 'contentType'))) {
                $context = 'controllerAction';
            }

            $presetName = '';
            if ($context == 'controllerAction') {
                if (!isset($args['controller'])) {
                    $args['controller'] = 'user';
                }
                if (!isset($args['action'])) {
                    $args['action'] = '«IF targets('1.3.5')»main«ELSE»index«ENDIF»';
                }

                if ($args['controller'] == 'ajax' && $args['action'] == 'getItemListAutoCompletion') {
                    $presetName = $this->name . '_ajax_autocomplete';
                } else {
                    $presetName = $this->name . '_' . $args['controller'] . '_' . $args['action'];
                }
            }
            if (empty($presetName)) {
                $presetName = $this->name . '_default';
            }

            $preset = $this->getCustomPreset($objectType, $fieldName, $presetName, $context, $args);

            return $preset;
        }
    '''

    def private getCustomPreset(Application it) '''
        /**
         * This method returns an Imagine preset for the given arguments.
         *
         * @param string $objectType Currently treated entity type.
         * @param string $fieldName  Name of upload field.
         * @param string $presetName Name of desired preset.
         * @param string $context    Usage context (allowed values: controllerAction, api, actionHandler, block, contentType).
         * @param array  $args       Additional arguments.
         *
         * @return SystemPlugin_Imagine_Preset The selected preset.
         */
        public function getCustomPreset($objectType = '', $fieldName = '', $presetName = '', $context = '', $args = array())
        {
            $presetData = array(
                'width'     => 100,      // thumbnail width in pixels
                'height'    => 100,      // thumbnail height in pixels
                'mode'      => 'inset',  // inset or outbound
                'extension' => null      // file extension for thumbnails (jpg, png, gif; null for original file type)
            );

            if ($presetName == $this->name . '_ajax_autocomplete') {
                $presetData['width'] = 100;
                $presetData['height'] = 80;
            } elseif ($presetName == $this->name . '_relateditem') {
                $presetData['width'] = 50;
                $presetData['height'] = 40;
            } elseif ($context == 'controllerAction') {
                if ($args['action'] == 'view') {
                    $presetData['width'] = 32;
                    $presetData['height'] = 20;
                } elseif ($args['action'] == 'display') {
                    $presetData['width'] = 250;
                    $presetData['height'] = 150;
                }
            }

            $preset = new SystemPlugin_Imagine_Preset($presetName, $presetData);

            return $preset;
        }
    '''

    def private imageFunctionsImpl(Application it) '''
        «IF !targets('1.3.5')»
            namespace «appNamespace»\Util;

            use «appNamespace»\Util\Base\ImageUtil as BaseImageUtil;

        «ENDIF»
        /**
         * Utility implementation class for image helper methods.
         */
        «IF targets('1.3.5')»
        class «appName»_Util_Image extends «appName»_Util_Base_Image
        «ELSE»
        class ImageUtil extends BaseImageUtil
        «ENDIF»
        {
            // feel free to add your own convenience methods here
        }
    '''
}

package org.zikula.modulestudio.generator.cartridges.zclassic.view

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.DateField
import de.guite.modulestudio.metamodel.TimeField
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.ActionUrl
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.FormatGeoData
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.FormatIcalText
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.GetCountryName
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.GetFileSize
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.GetListEntry
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.ModerationObjects
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.ObjectState
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.ObjectTypeSelector
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.TemplateHeaders
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.TemplateSelector
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.TreeData
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.TreeSelection
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.ValidationError
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.form.AbstractObjectSelector
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.form.ColourInput
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.form.CountrySelector
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.form.DateInput
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.form.Frame
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.form.GeoInput
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.form.ItemSelector
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.form.RelationSelectorAutoComplete
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.form.RelationSelectorList
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.form.TimeInput
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.form.TreeSelector
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.form.UserInput
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.GeneratorSettingsExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils
import org.zikula.modulestudio.generator.extensions.WorkflowExtensions

class Plugins {
    extension ControllerExtensions = new ControllerExtensions
    extension GeneratorSettingsExtensions = new GeneratorSettingsExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils
    extension WorkflowExtensions = new WorkflowExtensions

    IFileSystemAccess fsa

    def generate(Application it, IFileSystemAccess fsa) {
        this.fsa = fsa
        if (!targets('1.3.x')) {
            println('Generating Twig extension class')
            val fh = new FileHelper
            val twigFolder = 'Twig'
            generateClassPair(fsa, getAppSourceLibPath + twigFolder + '/TwigExtension.php',
                fh.phpFileContent(it, twigExtensionBaseImpl), fh.phpFileContent(it, twigExtensionImpl)
            )
        } else {
        	generateInternal
        }
    }

    def generateInternal(Application it) {
        viewPlugins
        if (targets('1.3.x')) {
            if (hasEditActions || needsConfig) {
                new Frame().generate(it, fsa)
            }
            if (hasEditActions) {
                editPlugins
                new ValidationError().generate(it, fsa)
            }
        }
        otherPlugins
    }

    // 1.4.x only
    def private twigExtensionBaseImpl(Application it) '''
        namespace «appNamespace»\Twig\Base;

        /**
         * Twig extension base class.
         */
        class TwigExtension extends \Twig_Extension
        {
            «twigExtensionBody»
        }
    '''

    // 1.4.x only
    def private twigExtensionBody(Application it) '''
        «val appNameLower = appName.toLowerCase»
        /**
         * Returns a list of custom Twig functions.
         *
         * @return array
         */
        public function getFunctions()
        {
            return [
                new \Twig_SimpleFunction('«appNameLower»_templateHeaders', [$this, 'templateHeaders']),
                «IF hasTrees»
                    new \Twig_SimpleFunction('«appNameLower»_treeData', [$this, 'getTreeData']),
                    new \Twig_SimpleFunction('«appNameLower»_treeSelection', [$this, 'getTreeSelection']),
                «ENDIF»
                «IF generateModerationPanel && needsApproval»
                    new \Twig_SimpleFunction('«appNameLower»_moderationObjects', [$this, 'getModerationObjects']),
                «ENDIF»
                new \Twig_SimpleFunction('«appNameLower»_objectTypeSelector', [$this, 'getObjectTypeSelector']),
                new \Twig_SimpleFunction('«appNameLower»_templateSelector', [$this, 'getTemplateSelector']),
                «IF hasCategorisableEntities»
                    new \Twig_SimpleFunction('«appNameLower»_categoryProperties', [$this, 'getCategoryProperties']),
                    new \Twig_SimpleFunction('«appNameLower»_isCategoryMultiValued', [$this, 'isCategoryMultiValued']),
                «ENDIF»
                new \Twig_SimpleFunction('«appNameLower»_userVar', [$this, 'getUserVar']),
                new \Twig_SimpleFunction('«appNameLower»_userAvatar', [$this, 'getUserAvatar']),
                new \Twig_SimpleFunction('«appNameLower»_thumb', [$this, 'getImageThumb'])
            ];
        }

        /**
         * Returns a list of custom Twig filters.
         *
         * @return array
         */
        public function getFilters()
        {
            return [
                new \Twig_SimpleFilter('«appNameLower»_actionUrl', [$this, 'buildActionUrl']),
                new \Twig_SimpleFilter('«appNameLower»_objectState', [$this, 'getObjectState']),
                «IF hasCountryFields»
                    new \Twig_SimpleFilter('«appNameLower»_countryName', [$this, 'getCountryName']),
                «ENDIF»
                «IF hasUploads»
                    new \Twig_SimpleFilter('«appNameLower»_fileSize', [$this, 'getFileSize']),
                «ENDIF»
                «IF hasListFields»
                    new \Twig_SimpleFilter('«appNameLower»_listEntry', [$this, 'getListEntry']),
                «ENDIF»
                «IF hasGeographical»
                    new \Twig_SimpleFilter('«appNameLower»_geoData', [$this, 'formatGeoData']),
                «ENDIF»
                «IF (generateIcsTemplates && !entities.filter[getStartDateField !== null && getEndDateField !== null].empty)»
                    new \Twig_SimpleFilter('«appNameLower»_icalText', [$this, 'formatIcalText']),
                «ENDIF»
                new \Twig_SimpleFilter('«appNameLower»_profileLink', [$this, 'profileLink'])
            ];
        }

        «generateInternal»

        «twigExtensionCompat»

        /**
         * Returns internal name of this extension.
         *
         * @return string
         */
        public function getName()
        {
            return '«appName.formatForDB»_twigextension';
        }
    '''

    // 1.4.x only
    def private twigExtensionCompat(Application it) '''
        «IF hasCategorisableEntities»
            /**
             * Returns all properties for categories of a certain object type.
             *
             * @param string $objectType Name of object type.
             *
             * @return array
             */
            public function getCategoryProperties($objectType)
            {
                $result = \ModUtil::apiFunc('«appName», 'category', 'getAllProperties', ['ot' => $objectType]);

                return $result;
            }

            /**
             * Checks whether a category field is multi-valued or not.
             *
             * @param string $objectType Name of object type.
             * @param string $registry   Property name of registry.
             *
             * @return boolean
             */
            public function isCategoryMultiValued($objectType, $registry)
            {
                $result = \ModUtil::apiFunc('«appName», 'category', 'hasMultipleSelection', ['ot' => $objectType, 'registry' => $registry]);

                return $result;
            }

        «ENDIF»
        /**
         * Returns the value of a user variable.
         *
         * @param string     $name    Name of desired property.
         * @param int        $uid     The user's id.
         * @param string|int $default The default value.
         *
         * @return string
         */
        public function getUserVar($name, $uid = -1, $default = '')
        {
            if (!$uid) {
                $uid = -1;
        	}

            $result = \UserUtil::getVar($name, $uid, $default);

            return $result;
        }

        /**
         * Display the avatar of a user.
         *
         * @param int    $uid    The user's id.
         * @param int    $width  Image width (optional).
         * @param int    $height Image height (optional).
         * @param int    $size   Gravatar size (optional).
         * @param string $rating Gravatar self-rating [g|pg|r|x] see: http://en.gravatar.com/site/implement/images/ (optional).
         *
         * @return string
         */
        public function getUserAvatar($uid, $width, $height, $size, $rating)
        {
            $params = ['uid' => $uid];
            if ($width) {
                $params['width'] = $width;
        	}
            if ($height) {
                $params['height'] = $height;
        	}
            if ($size) {
                $params['size'] = $size;
        	}
            if ($rating) {
                $params['rating'] = $rating;
        	}

            include_once 'lib/legacy/viewplugins/function.useravatar.php';

            $view = \Zikula_View::getInstance('«appName»');
            $result = smarty_function_useravatar($params, $view)

            return $result;
        }

        /**
         * Display an image thumbnail using Imagine system plugin.
         *
         * @param array $params Parameters assigned to bridged Smarty plugin.
         *
         * @return string Thumb path.
         */
        public function getImageThumb($params)
        {
            include_once 'plugins/Imagine/templates/plugins/function.thumb.php';

            $view = \Zikula_View::getInstance('«appName»');
            $result = smarty_function_thumb($params, $view)

            return $result;
        }

        /**
         * Returns a link to the user's profile.
         *
         * @param int     $uid       The user's id (optional).
         * @param string  $class     The class name for the link (optional).
         * @param integer $maxLength If set then user names are truncated to x chars.
         *
         * @return string
         */
        public function profileLink($uid, $class = '', $maxLength = 0)
        {
            $result = '';
            $image = '';

            if ($uid == '') {
                return $result;
            }

            if (\ModUtil::getVar('ZConfig, 'profilemodule') != '') {
                include_once 'lib/legacy/viewplugins/modifier.profilelinkbyuid.php';
                $result = smarty_modifier_profilelinkbyuid($uid, $class, $image, $maxLength);
            } else {
                $result = \UserUtil::getVar('uname', $uid);
            }

            return $result;
        }
    '''

    // 1.4.x only
    def private twigExtensionImpl(Application it) '''
        namespace «appNamespace»\Twig;

        use «appNamespace»\Twig\Base\TwigExtension as BaseTwigExtension;

        /**
         * Twig extension implementation class.
         */
        class TwigExtension extends BaseTwigExtension
        {
            // feel free to add your own Twig extension methods here
        }
    '''

    def private viewPlugins(Application it) {
        new ActionUrl().generate(it, fsa)
        new ObjectState().generate(it, fsa)
        new TemplateHeaders().generate(it, fsa)
        if (hasCountryFields) {
            new GetCountryName().generate(it, fsa)
        }
        if (hasUploads) {
            new GetFileSize().generate(it, fsa)
        }
        if (hasListFields) {
            new GetListEntry().generate(it, fsa)
        }
        if (hasGeographical) {
            new FormatGeoData().generate(it, fsa)
        }
        if (hasTrees) {
            new TreeData().generate(it, fsa)
            new TreeSelection().generate(it, fsa)
        }
        if (generateModerationPanel && needsApproval) {
            new ModerationObjects().generate(it, fsa)
        }
        if (generateIcsTemplates && !entities.filter[getStartDateField !== null && getEndDateField !== null].empty) {
            new FormatIcalText().generate(it, fsa)
        }
    }

    def private editPlugins(Application it) {
        if (hasColourFields) {
            new ColourInput().generate(it, fsa)
        }
        if (hasCountryFields) {
            new CountrySelector().generate(it, fsa)
        }
        if (hasGeographical) {
            new GeoInput().generate(it, fsa)
        }
        if (!entities.filter[!fields.filter(DateField).empty].empty) {
            new DateInput().generate(it, fsa)
        }
        if (!entities.filter[!fields.filter(TimeField).empty].empty) {
            new TimeInput().generate(it, fsa)
        }
        val hasRelations = !relations.empty
        if (hasTrees || hasRelations) {
            new AbstractObjectSelector().generate(it, fsa)
        }
        if (hasTrees) {
            new TreeSelector().generate(it, fsa)
        }
        if (hasRelations) {
            new RelationSelectorList().generate(it, fsa)
            new RelationSelectorAutoComplete().generate(it, fsa)
        }
        if (hasUserFields) {
            new UserInput().generate(it, fsa)
        }
    }

    def private otherPlugins(Application it) {
        new ItemSelector().generate(it, fsa)
        new ObjectTypeSelector().generate(it, fsa)
        new TemplateSelector().generate(it, fsa)
    }
}

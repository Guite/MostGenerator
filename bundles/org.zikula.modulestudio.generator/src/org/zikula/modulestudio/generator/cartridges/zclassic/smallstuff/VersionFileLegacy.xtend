package org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.JoinRelationship
import de.guite.modulestudio.metamodel.ReferredApplication
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.GeneratorSettingsExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils
import org.zikula.modulestudio.generator.extensions.WorkflowExtensions

class VersionFileLegacy {
    extension FormattingExtensions = new FormattingExtensions
    extension GeneratorSettingsExtensions = new GeneratorSettingsExtensions 
    extension ModelExtensions = new ModelExtensions
    extension ModelJoinExtensions = new ModelJoinExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils
    extension WorkflowExtensions = new WorkflowExtensions

    FileHelper fh = new FileHelper

    def generate(Application it, IFileSystemAccess fsa) {
        if (!targets('1.3.x')) {
            return
        }
        generateClassPair(fsa, getAppSourceLibPath + 'Version.php', versionBaseFile, versionFile)
    }

    def private versionBaseFile(Application it) '''
        «fh.phpFileHeaderVersionClass(it)»
        «appInfoBaseImpl»
    '''

    def private versionFile(Application it) '''
        «fh.phpFileHeaderVersionClass(it)»
        «appInfoImpl»
    '''

    def private appInfoBaseImpl(Application it) '''
        /**
         * Version information base class.
         */
        abstract class «appName»_Base_AbstractVersion extends Zikula_AbstractVersion
        {
            /**
             * Retrieves meta data information for this application.
             *
             * @return array List of meta data
             */
            public function getMetaData()
            {
                $meta = array();
                // the current module version
                $meta['version']              = '«version»';
                // the displayed name of the module
                $meta['displayname']          = $this->__('«name.formatForDisplayCapital»');
                // the module description
                $meta['description']          = $this->__('«IF null !== documentation && documentation != ''»«documentation.replace("'", "\\'")»«ELSE»«name.formatForDisplayCapital» module generated by ModuleStudio «msVersion».«ENDIF»');
                //! url version of name, should be in lowercase without space
                $meta['url']                  = $this->__('«name.formatForDB»');
                // core requirement
                $meta['core_min']             = '1.3.5'; // requires minimum 1.3.5
                $meta['core_max']             = '1.3.99'; // not ready for 1.4.0 yet

                // define special capabilities of this module
                $meta['capabilities'] = array(
                      «IF null !== capabilities && capabilities != ''»
                          «FOR capability : capabilities.replaceAll(', ', '').split(',')»
                              '«capability.formatForDisplay»' => array('version' => '1.0'),
                          «ENDFOR»
                      «ENDIF»
                      HookUtil::SUBSCRIBER_CAPABLE => array('enabled' => true)
        /*,
                      HookUtil::PROVIDER_CAPABLE => array('enabled' => true), // TODO: see #15
        */
                );

                // permission schema
                «permissionSchema»

                «IF !referredApplications.empty»
                    // module dependencies
                    $meta['dependencies'] = array(
                        «FOR referredApp : referredApplications SEPARATOR ','»«appDependency(referredApp)»«ENDFOR»
                    );
                «ENDIF»

                return $meta;
            }

            /**
             * Defines hook subscriber«/* and provider (TODO see #15) */» bundles.
             */
            protected function setupHookBundles()
            {
                «val hookHelper = new HookBundles()»
                «hookHelper.setup(it)»
            }
        }
    '''

    def private appInfoImpl(Application it) '''
        /**
         * Version information implementation class.
         */
        class «appName»_Version extends «appName»_Base_AbstractVersion
        {
            // custom enhancements can go here
        }
    '''

    /**
     * Definition of permission schema arrays.
     */
    def private permissionSchema(Application it) '''
        $meta['securityschema'] = array(
            '«appName»::' => '::',
            '«appName»::Ajax' => '::',
            «IF generateListBlock»
                '«appName»:ItemListBlock:' => 'Block title::',
            «ENDIF»
            «IF needsApproval»
                '«appName»:ModerationBlock:' => 'Block title::',
            «ENDIF»
            «FOR entity : getAllEntities»«entity.permissionSchema(appName)»«ENDFOR»
        );
    '''

    def private appDependency(Application app, ReferredApplication it) '''
        array('modname'    => '«name.formatForCode.toFirstUpper»',
              'minversion' => '«minVersion»',
              'maxversion' => '«maxVersion»',
              'status'     => ModUtil::DEPENDENCY_«appDependencyType»«IF !app.targets('1.3.x')»,
              'reason'     => '«documentation.replace("'", "")»'«ENDIF»)
    '''

    def private appDependencyType(ReferredApplication it) {
        switch it.dependencyType {
            case RECOMMENDATION: 'RECOMMENDED'
            case CONFLICT: 'CONFLICTS'
            default: 'REQUIRED'
        }
    }

    def private permissionSchema(Entity it, String appName) '''
        '«appName»:«name.formatForCodeCapital»:' => '«name.formatForCodeCapital» ID::',
        «val incomingRelations = getIncomingJoinRelations/*.filter[e|e.source.container == it.container]*/»
        «IF !incomingRelations.empty»
            «FOR relation : incomingRelations»«relation.permissionSchema(appName)»«ENDFOR»
        «ENDIF»
    '''

    def private permissionSchema(JoinRelationship it, String modName) '''
        '«modName»:«source.name.formatForCodeCapital»:«target.name.formatForCodeCapital»' => '«source.name.formatForCodeCapital» ID:«target.name.formatForCodeCapital» ID:',
    '''
}

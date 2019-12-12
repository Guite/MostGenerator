package org.zikula.modulestudio.generator.cartridges.zclassic.models

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.DerivedField
import de.guite.modulestudio.metamodel.ListField
import de.guite.modulestudio.metamodel.UploadField
import de.guite.modulestudio.metamodel.UserField
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.Property
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class AppSettings {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelExtensions = new ModelExtensions
    extension Utils = new Utils

    Property thProp

    /**
     * Entry point for application settings class.
     */
    def generate(Application it, IMostFileSystemAccess fsa) {
        if (variables.empty) {
            return
        }
        'Generating application settings class'.printIfNotTesting(fsa)
        thProp = new Property(it, null)
        fsa.generateClassPair('AppSettings.php', appSettingsBaseImpl, appSettingsImpl)
    }

    def private imports(Application it) '''
        «IF !getAllVariables.filter(UploadField).empty»
            use Symfony\Component\HttpFoundation\File\File;
        «ENDIF»
        use Symfony\Component\Validator\Constraints as Assert;
        use Zikula\ExtensionsModule\Api\ApiInterface\VariableApiInterface;
        «IF hasUserVariables»
            use Zikula\UsersModule\Constant as UsersConstant;
            use Zikula\UsersModule\Entity\RepositoryInterface\UserRepositoryInterface;
        «ENDIF»
        «IF hasUserGroupSelectors»
            use Zikula\GroupsModule\Constant as GroupsConstant;
            use Zikula\GroupsModule\Entity\RepositoryInterface\GroupRepositoryInterface;
        «ENDIF»
        «IF hasUserVariables»
            use Zikula\UsersModule\Entity\UserEntity;
        «ENDIF»
        «IF hasLoggable»
            use «appNamespace»\Entity\Factory\EntityFactory;
        «ENDIF»
        «IF !getAllVariables.filter(ListField).empty»
            use «appNamespace»\Validator\Constraints as «name.formatForCodeCapital»Assert;
        «ENDIF»
    '''

    def private appSettingsBaseImpl(Application it) '''
        namespace «appNamespace»\Base;

        «imports»

        «appSettingsBaseImplClass»
    '''

    def private appSettingsBaseImplClass(Application it) '''
        /**
         * Application settings class for handling module variables.
         */
        abstract class AbstractAppSettings
        {
            «appSettingsBaseImplBody»
        }
    '''

    def private appSettingsBaseImplBody(Application it) '''
        /**
         * @var VariableApiInterface
         */
        protected $variableApi;

        «IF hasUserVariables»
            /**
             * @var UserRepositoryInterface
             */
            protected $userRepository;

        «ENDIF»
        «IF hasUserGroupSelectors»
            /**
             * @var GroupRepositoryInterface
             */
            protected $groupRepository;

        «ENDIF»
        «IF hasLoggable»
            /**
             * @var EntityFactory
             */
            protected $entityFactory;

        «ENDIF»
        «memberVars»

        «constructor»
        «accessors»

        «load»

        «save»
    '''

    def private memberVars(Application it) '''
        «FOR varContainer : getSortedVariableContainers»
            «FOR field : varContainer.fields.filter(DerivedField)»«thProp.persistentProperty(field)»«ENDFOR»
        «ENDFOR»
    '''

    def private accessors(Application it) '''
        «FOR varContainer : getSortedVariableContainers»
            «FOR field : varContainer.fields.filter(DerivedField)»«thProp.fieldAccessor(field)»«ENDFOR»
        «ENDFOR»
    '''

    def private constructor(Application it) '''
        public function __construct(
            VariableApiInterface $variableApi«IF hasUserVariables»,
            UserRepositoryInterface $userRepository«ENDIF»«IF hasUserGroupSelectors»,
            GroupRepositoryInterface $groupRepository«ENDIF»«IF hasLoggable»,
            EntityFactory $entityFactory«ENDIF»
        ) {
            $this->variableApi = $variableApi;
            «IF hasUserVariables»
                $this->userRepository = $userRepository;
            «ENDIF»
            «IF hasUserGroupSelectors»
                $this->groupRepository = $groupRepository;
            «ENDIF»
            «IF hasLoggable»
                $this->entityFactory = $entityFactory;
            «ENDIF»

            $this->load();
        }
    '''

    def private load(Application it) '''
        /**
         * Loads module variables from the database.
         */
        protected function load()«IF targets('3.0')»: void«ENDIF»
        {
            $moduleVars = $this->variableApi->getAll('«appName»');

            «FOR varContainer : getSortedVariableContainers»
                «IF varContainer.composite»
                    $«varContainer.name.formatForCode» = $moduleVars['«varContainer.name.formatForCode»'];
                    «FOR field : varContainer.fields»
                        if (isset($«varContainer.name.formatForCode»['«field.name.formatForCode»'])) {
                            $this->set«field.name.formatForCodeCapital»($«varContainer.name.formatForCode»['«field.name.formatForCode»']);
                        }
                    «ENDFOR»
                «ELSE»
                    «FOR field : varContainer.fields»
                        if (isset($moduleVars['«field.name.formatForCode»'])) {
                            $this->set«field.name.formatForCodeCapital»($moduleVars['«field.name.formatForCode»']);
                        }
                    «ENDFOR»
                «ENDIF»
            «ENDFOR»
            «IF hasUserVariables»

                // prepare user fields, fallback to admin user for undefined values
                $adminUserId = UsersConstant::USER_ID_ADMIN;
                «FOR userField : getAllVariables.filter(UserField)»
                    $userId = $this->get«userField.name.formatForCodeCapital»();
                    if (USER_ID_ANONYMOUS > $userId) {
                        $userId = $adminUserId;
                    }

                    $this->set«userField.name.formatForCodeCapital»($this->userRepository->find($userId));
                «ENDFOR»
            «ENDIF»
            «IF hasUserGroupSelectors»

                // prepare group selectors, fallback to admin group for undefined values
                $adminGroupId = GroupsConstant::GROUP_ID_ADMIN;
                «FOR groupSelector : getUserGroupSelectors»
                    $groupId = $this->get«groupSelector.name.formatForCodeCapital»();
                    if (GroupsConstant::GROUP_ID_USERS > $groupId) {
                        $groupId = $adminGroupId;
                    }

                    $this->set«groupSelector.name.formatForCodeCapital»($this->groupRepository->find($groupId));
                «ENDFOR»
            «ENDIF»
        }
    '''

    def private save(Application it) '''
        /**
         * Saves module variables into the database.
         */
        public function save()«IF targets('3.0')»: void«ENDIF»
        {
            «IF hasUserVariables»
                // normalise user selector values
                «FOR userField : getAllVariables.filter(UserField)»
                    $user = $this->get«userField.name.formatForCodeCapital»();
                    $user = is_object($user) ? $user->getUid() : intval($user);
                    $this->set«userField.name.formatForCodeCapital»($user);
                «ENDFOR»

            «ENDIF»
            «IF hasUserGroupSelectors»
                // normalise group selector values
                «FOR groupSelector : getUserGroupSelectors»
                    $group = $this->get«groupSelector.name.formatForCodeCapital»();
                    $group = is_object($group) ? $group->getGid() : intval($group);
                    $this->set«groupSelector.name.formatForCodeCapital»($group);
                «ENDFOR»

            «ENDIF»
            «FOR varContainer : getSortedVariableContainers»
                «IF varContainer.composite»
                    $«varContainer.name.formatForCode» = [];
                    «FOR field : varContainer.fields»
                        $«varContainer.name.formatForCode»['«field.name.formatForCode»'] = $this->get«field.name.formatForCodeCapital»();
                    «ENDFOR»
                    $this->variableApi->set('«appName»', '«varContainer.name.formatForCode»', $«varContainer.name.formatForCode»);
                «ELSE»
                    «FOR field : varContainer.fields»
                        $this->variableApi->set('«appName»', '«field.name.formatForCode»', $this->get«field.name.formatForCodeCapital»());
                    «ENDFOR»
                «ENDIF»
            «ENDFOR»
            «IF hasLoggable»

                $entityManager = $this->entityFactory->getEntityManager();
                «FOR entity : getLoggableEntities»
                    $revisionHandling = $this->getRevisionHandlingFor«entity.name.formatForCodeCapital»();
                    $limitParameter = '';
                    if ('limitedByAmount' === $revisionHandling) {
                        $limitParameter = $this->getMaximumAmountOf«entity.name.formatForCodeCapital»Revisions();
                    }«IF entity.application.targets('2.0')» elseif ('limitedByDate' === $revisionHandling) {
                        $limitParameter = $this->getPeriodFor«entity.name.formatForCodeCapital»Revisions();
                    }«ENDIF»

                    $logEntriesRepository = $entityManager->getRepository('«entity.application.appName»:«entity.name.formatForCodeCapital»LogEntryEntity');
                    $logEntriesRepository->purgeHistory($revisionHandling, $limitParameter);
                «ENDFOR»
            «ENDIF»
        }
    '''

    def private appSettingsImpl(Application it) '''
        namespace «appNamespace»;

        use «appNamespace»\Base\AbstractAppSettings;

        /**
         * Application settings class for handling module variables.
         */
        class AppSettings extends AbstractAppSettings
        {
            // feel free to add your own methods here
        }
    '''
}

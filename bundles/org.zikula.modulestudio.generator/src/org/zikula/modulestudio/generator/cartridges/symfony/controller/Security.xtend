package org.zikula.modulestudio.generator.cartridges.symfony.controller

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Entity
import java.util.List
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.application.ImportList
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.Utils
import org.zikula.modulestudio.generator.extensions.WorkflowExtensions

class Security {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension Utils = new Utils
    extension WorkflowExtensions = new WorkflowExtensions

    /**
     * Entry point for security voters.
     */
    def generate(Application it, IMostFileSystemAccess fsa) {
        'Generating Security voters'.printIfNotTesting(fsa)
        for (entity: entities) {
            fsa.generateClassPair('Security/' + entity.name.formatForCodeCapital + 'Voter.php', entity.voterBaseClass, entity.voterImpl)
        }
        fsa.generateFile('src/Security/Permission.php', permissionEnumImpl)
    }

    def private collectBaseImports(Entity it) {
        val imports = new ImportList
        imports.addAll(#[
            'Symfony\\Component\\Security\\Core\\Authentication\\Token\\TokenInterface',
            'Symfony\\Component\\Security\\Core\\Authorization\\AccessDecisionManagerInterface',
            'Symfony\\Component\\Security\\Core\\Authorization\\Voter\\Vote',
            'Symfony\\Component\\Security\\Core\\Authorization\\Voter\\Voter',
            application.appNamespace + '\\Entity\\' + name.formatForCodeCapital,
            application.appNamespace + '\\Security\\Permission'
        ])
        imports
    }

    def private voterBaseClass(Entity it) '''
        namespace «application.appNamespace»\Security\Base;

        «collectBaseImports.print»

        /**
         * «name.formatForDisplayCapital» voter base class.
         *
         * @see https://symfony.com/doc/current/security/voters.html
         */
        abstract class Abstract«name.formatForCodeCapital»Voter extends Voter
        {
            «voterBaseImpl»
        }
    '''

    def private voterBaseImpl(Entity it) '''
        public function __construct(
            protected readonly AccessDecisionManagerInterface $accessDecisionManager,
            «IF loggable»
                protected readonly bool $showHistory,
            «ENDIF»
        ) {
        }

        «supportsAttribute»

        «supportsType»

        «supports»

        «voteOnAttribute»
    '''

    def private supportsAttribute(Entity it) '''
        public function supportsAttribute(string $attribute): bool
        {
            return «supportedPermissionAttributes.checkAttributeForEnumValues»;
        }
    '''

    // is_a() returns also true if subject type is a Doctrine proxy class
    def private supportsType(Entity it) '''
        public function supportsType(string $subjectType): bool
        {
            return 'null' === $subjectType«/* for bulk handling */»«IF hasIndexAction || hasEditAction»
            «''»    || 'string' === $subjectType«/* for index page and new action */»«ENDIF»
                || is_a($subjectType, «name.formatForCodeCapital»::class, true)
            ;
        }
    '''

    def private supports(Entity it) '''
        protected function supports(string $attribute, mixed $subject): bool
        {
            if (!«supportedPermissionAttributes.checkAttributeForEnumValues») {
                return false;
            }

            return null === $subject«IF hasIndexAction || hasEditAction»
            «''»    || «name.formatForCodeCapital»::class === $subject«ENDIF»
                || $subject instanceof «name.formatForCodeCapital»
            ;
        }
    '''

    def private voteOnAttribute(Entity it) '''
        protected function voteOnAttribute(string $attribute, mixed $subject, TokenInterface $token, ?Vote $vote = null): bool
        {
            $user = $token->getUser();

            if (null === $user) {
                «IF hasIndexAction || hasDetailAction»
                    return «filteredPermissions(displayPermissions).checkAttributeForEnumValues»;
                «ELSE»
                    return false;
                «ENDIF»
            }

            // admin override
            if («decisionCall('ROLE_SUPER_ADMIN')») {
                return true;
            }
            if («decisionCall('ROLE_ADMIN')») {
                return true;
            }
            «IF loggable»

                if (Permission::FILTER->value === $attribute && !$this->showHistory) {
                    return false;
                }
            «ENDIF»

            // map attributes to roles
            return match ($attribute) {
                «IF hasIndexAction || hasDetailAction»
                    «filteredPermissions(displayPermissions).permissionEnumValueArray» => «displayDecision»,
                «ENDIF»
                «IF hasEditAction || hasDeleteAction || loggable || approval»
                    «filteredPermissions(editorPermissions).permissionEnumValueArray» => «editorDecision»,
                «ENDIF»
                default => throw new \LogicException('Unchecked permission attribute "' . $attribute . '" in «name.formatForCodeCapital»Voter!'),
            };
        }
    '''

    def private displayDecision(Entity it) '''«decisionCall('ROLE_USER')»'''

    def private editorDecision(Entity it) '''«IF ownerPermission»(is_object($subject) && $user->getId() === $subject->getCreatedBy()) || «ENDIF»«decisionCall('ROLE_EDITOR')»'''

    def private decisionCall(Entity it, String role) '''$this->accessDecisionManager->decide($token, ['«role»'])'''

    def private voterImpl(Entity it) '''
        namespace «application.appNamespace»\Security;

        use «application.appNamespace»\Security\Base\Abstract«name.formatForCodeCapital»Voter;

        /**
         * «name.formatForDisplayCapital» voter implementation class.
         */
        class «name.formatForCodeCapital»Voter extends Abstract«name.formatForCodeCapital»Voter
        {
            // feel free to extend the «name.formatForDisplay» voter here
        }
    '''

    def private displayPermissions() {
        #['LIST', 'ACCESS', 'FILTER', 'DETAIL']
    }

    def private editorPermissions() {
        #['COMMENT', 'EDIT', 'CREATE', 'DELETE', 'HISTORY', 'MODERATE']
    }

    def private permissionEnumImpl(Application it) '''
        namespace «appNamespace»\Security;

        /**
         * Permission attribute names.
         */
        enum Permission: string
        {
            case LIST = 'LIST';
            «IF hasIndexActions || hasDetailActions»
                case ACCESS = 'ACCESS'; // used for entity permission checks in index + detail actions
            «ENDIF»
            «IF hasIndexActions»
                case FILTER = 'FILTER';
            «ENDIF»
            «IF hasDetailActions»
                case DETAIL = 'DETAIL';
            «ENDIF»
            «IF needsApproval»
                case COMMENT = 'COMMENT';
            «ENDIF»
            «IF hasEditActions»
                case EDIT = 'EDIT';
                case CREATE = 'CREATE';
            «ENDIF»
            «IF hasDeleteActions»
                case DELETE = 'DELETE';
            «ENDIF»
            «IF hasLoggable»
                case HISTORY = 'HISTORY';
            «ENDIF»
            «IF needsApproval»
                case MODERATE = 'MODERATE';
            «ENDIF»
            case ADMIN = 'ADMIN';
        }
    '''

    def private filteredPermissions(Entity it, List<String> values) {
        supportedPermissionAttributes.filter[a|values.contains(a)].toList
    }

    def private checkAttributeForEnumValues(List<String> it) '''in_array($attribute, [«permissionEnumValueArray»], true)'''

    def private permissionEnumValueArray(List<String> it) '''«asPermissionEnumValues.join(', ')»'''

    def private asPermissionEnumValues(List<String> it) {
        map[a|'Permission::' + a + '->value']
    }

    def private getSupportedPermissionAttributes(Entity it) {
        val result = <String>newArrayList
        result += 'LIST'
        if (hasIndexAction || hasDetailAction) {
            result += 'ACCESS'
        }
        if (hasIndexAction) {
            result += 'FILTER'
        }
        if (hasDetailAction) {
            result += 'DETAIL'
        }
        if (approval) {
            result += 'COMMENT'
        }
        if (hasEditAction) {
            result += 'EDIT'
            result += 'CREATE'
        }
        if (hasDeleteAction) {
            result += 'DELETE'
        }
        if (loggable) {
            result += 'HISTORY'
        }
        if (approval) {
            result += 'MODERATE'
        }
        result += 'ADMIN'
        result
    }
}

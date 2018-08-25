package org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype.trait

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.EntityWorkflowType
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.Utils
import org.zikula.modulestudio.generator.extensions.WorkflowExtensions

class WorkflowFormFieldsTrait {

    extension Utils = new Utils
    extension WorkflowExtensions = new WorkflowExtensions

    def generate(Application it, IMostFileSystemAccess fsa) {
        if (!needsApproval) {
            return
        }
        val filePath = 'Traits/WorkflowFormFieldsTrait.php'
        fsa.generateFile(filePath, traitFile)
    }

    def private traitFile(Application it) '''
        namespace «appNamespace»\Traits;

        use Symfony\Component\Form\Extension\Core\Type\TextareaType;
        use Symfony\Component\Form\FormBuilderInterface;

        /**
         * Workflow form fields trait implementation class.
         */
        trait WorkflowFormFieldsTrait
        {
            «traitImpl»
        }
    '''

    def private traitImpl(Application it) '''
        /**
         * Adds a field for additional notification remarks.
         *
         * @param FormBuilderInterface $builder The form builder
         * @param array                $options The options
         */
        public function addAdditionalNotificationRemarksField(FormBuilderInterface $builder, array $options = [])
        {
            $helpText = '';
            if ($options['is_moderator']«IF hasWorkflow(EntityWorkflowType.ENTERPRISE)» || $options['is_super_moderator']«ENDIF») {
                $helpText = $this->__('These remarks (like a reason for deny) are not stored, but added to any notification emails send to the creator.');
            } elseif ($options['is_creator']) {
                $helpText = $this->__('These remarks (like questions about conformance) are not stored, but added to any notification emails send to our moderators.');
            }

            $builder->add('additionalNotificationRemarks', TextareaType::class, [
                'mapped' => false,
                'label' => $this->__('Additional remarks'),
                'label_attr' => [
                    'class' => 'tooltips',
                    'title' => $helpText
                ],
                'attr' => [
                    'title' => 'create' == $options['mode'] ? $this->__('Enter any additions about your content') : $this->__('Enter any additions about your changes')
                ],
                'required' => false,
                'help' => $helpText
            ]);
        }
    '''
}
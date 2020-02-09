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
        «IF targets('3.0')»
            use Translation\Extractor\Annotation\Ignore;
            use Translation\Extractor\Annotation\Translate;
        «ENDIF»

        /**
         * Workflow form fields trait.
         */
        trait WorkflowFormFieldsTrait
        {
            «traitImpl»
        }
    '''

    def private traitImpl(Application it) '''
        /**
         * Adds a field for additional notification remarks.
         «IF !targets('3.0')»
         *
         * @param FormBuilderInterface $builder The form builder
         * @param array $options The options
         «ENDIF»
         */
        public function addAdditionalNotificationRemarksField(FormBuilderInterface $builder, array $options = [])«IF targets('3.0')»: void«ENDIF»
        {
            $helpText = '';
            if ($options['is_moderator']«IF hasWorkflow(EntityWorkflowType.ENTERPRISE)» || $options['is_super_moderator']«ENDIF») {
                $helpText = «IF targets('3.0')»/** @Translate */«ELSE»$this->__(«ENDIF»'These remarks (like a reason for deny) are not stored, but added to any notification emails send to the creator.'«IF !targets('3.0')»)«ENDIF»;
            } elseif ($options['is_creator']) {
                $helpText = «IF targets('3.0')»/** @Translate */«ELSE»$this->__(«ENDIF»'These remarks (like questions about conformance) are not stored, but added to any notification emails send to our moderators.'«IF !targets('3.0')»)«ENDIF»;
            }

            $builder->add('additionalNotificationRemarks', TextareaType::class, [
                'mapped' => false,
                'label' => «IF !targets('3.0')»$this->__(«ENDIF»'Additional remarks'«IF !targets('3.0')»)«ENDIF»,
                'label_attr' => [
                    'class' => 'tooltips',
                    «IF targets('3.0')»
                        /** @Ignore */
                    «ENDIF»
                    'title' => $helpText
                ],
                'attr' => [
                    «IF targets('3.0')»
                        /** @Ignore */
                    «ENDIF»
                    'title' => 'create' == $options['mode']
                        ? «IF targets('3.0')»/** @Translate */«ELSE»$this->__(«ENDIF»'Enter any additions about your content'«IF !targets('3.0')»)«ENDIF»
                        : «IF targets('3.0')»/** @Translate */«ELSE»$this->__(«ENDIF»'Enter any additions about your changes'«IF !targets('3.0')»)«ENDIF»
                ],
                'required' => false,
                'help' => $helpText
            ]);
        }
    '''
}

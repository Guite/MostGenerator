package org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.HookProviderMode
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class FormAwareProviderInnerForms {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelExtensions = new ModelExtensions
    extension Utils = new Utils

    Application app

    /**
     * Entry point for form aware hook provider inner form type.
     */
    def generate(Application it, IMostFileSystemAccess fsa) {
        if (!hasFormAwareHookProviders) {
            return
        }
        app = it
        for (entity : getAllEntities.filter[formAwareHookProvider != HookProviderMode.DISABLED]) {
            fsa.generateClassPair('Form/Type/Hook/Edit' + entity.name.formatForCodeCapital + 'Type.php',
                entity.innerFormTypeBaseImpl('edit'), entity.innerFormTypeImpl('edit')
            )
            fsa.generateClassPair('Form/Type/Hook/Delete' + entity.name.formatForCodeCapital + 'Type.php',
                entity.innerFormTypeBaseImpl('delete'), entity.innerFormTypeImpl('delete')
            )
        }
    }

    def private innerFormTypeBaseImpl(Entity it, String action) '''
        namespace «app.appNamespace»\Form\Type\Hook\Base;

        use Symfony\Component\Form\AbstractType;
        use Symfony\Component\Form\Extension\Core\Type\ChoiceType;
        use Symfony\Component\Form\Extension\Core\Type\TextType;
        use Symfony\Component\Form\FormBuilderInterface;
        «IF app.targets('3.0')»
            «IF !app.isSystemModule»
                use Symfony\Component\OptionsResolver\OptionsResolver;
            «ENDIF»
        «ELSE»
            use Zikula\Common\Translator\TranslatorInterface;
            use Zikula\Common\Translator\TranslatorTrait;
        «ENDIF»

        /**
         * «action.formatForDisplayCapital» «name.formatForDisplay» form type base class.
         */
        abstract class Abstract«action.formatForCodeCapital»«name.formatForCodeCapital»Type extends AbstractType
        {
            «IF !app.targets('3.0')»
                use TranslatorTrait;

                public function __construct(TranslatorInterface $translator)
                {
                    $this->setTranslator($translator);
                }

                «app.setTranslatorMethod»

            «ENDIF»
            public function buildForm(FormBuilderInterface $builder, array $options)
            {
                $builder
                    ->add('dummyName', TextType::class, [
                        'label' => «IF !app.targets('3.0')»$this->__(«ENDIF»'Dummy «name.formatForDisplay» text'«IF !app.targets('3.0')»)«ENDIF»,
                        'required' => true
                    ])
                    ->add('dummyChoice', ChoiceType::class, [
                        'label' => «IF !app.targets('3.0')»$this->__(«ENDIF»'Dummy «name.formatForDisplay» choice'«IF !app.targets('3.0')»)«ENDIF»,
                        'label_attr' => [
                            'class' => 'checkbox-«IF app.targets('3.0')»custom«ELSE»inline«ENDIF»'
                        ],
                        'choices' => [
                            «IF !app.targets('3.0')»$this->__(«ENDIF»'Option A'«IF !app.targets('3.0')»)«ENDIF» => 'A',
                            «IF !app.targets('3.0')»$this->__(«ENDIF»'Option B'«IF !app.targets('3.0')»)«ENDIF» => 'B',
                            «IF !app.targets('3.0')»$this->__(«ENDIF»'Option C'«IF !app.targets('3.0')»)«ENDIF» => 'C'
                        ],
                        «IF !app.targets('2.0')»
                            'choices_as_values' => true,
                        «ENDIF»
                        'required' => true,
                        'multiple' => true,
                        'expanded' => true
                    ])
                ;
            }

            public function getBlockPrefix()
            {
                return '«app.appName.formatForDB»_hook_«action.formatForDB»«name.formatForDB»';
            }
            «IF app.targets('3.0') && !app.isSystemModule»

                public function configureOptions(OptionsResolver $resolver)
                {
                    $resolver->setDefaults([
                        'translation_domain' => 'hooks'
                    ]);
                }
            «ENDIF»
        }
    '''

    def private innerFormTypeImpl(Entity it, String action) '''
        namespace «app.appNamespace»\Form\Type\Hook;

        use «app.appNamespace»\Form\Type\Hook\Base\Abstract«action.formatForCodeCapital»«name.formatForCodeCapital»Type;

        /**
         * «action.formatForDisplayCapital» «name.formatForDisplay» form type implementation class.
         */
        class «action.formatForCodeCapital»«name.formatForCodeCapital»Type extends Abstract«action.formatForCodeCapital»«name.formatForCodeCapital»Type
        {
            // feel free to extend the base form type class here
        }
    '''
}

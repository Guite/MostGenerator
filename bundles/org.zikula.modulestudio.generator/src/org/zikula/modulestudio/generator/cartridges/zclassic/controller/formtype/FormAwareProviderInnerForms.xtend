package org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.HookProviderMode
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class FormAwareProviderInnerForms {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    FileHelper fh = new FileHelper
    Application app

    /**
     * Entry point for form aware hook provider inner form type.
     */
    def generate(Application it, IFileSystemAccess fsa) {
        if (!hasFormAwareHookProviders) {
            return
        }
        app = it
        for (entity : getAllEntities.filter[formAwareHookProvider != HookProviderMode.DISABLED]) {
            generateClassPair(fsa, getAppSourceLibPath + 'Form/Type/Hook/Edit' + entity.name.formatForCodeCapital + 'Type.php',
                fh.phpFileContent(it, entity.innerFormTypeBaseImpl('edit')), fh.phpFileContent(it, entity.innerFormTypeImpl('edit'))
            )
            generateClassPair(fsa, getAppSourceLibPath + 'Form/Type/Hook/Delete' + entity.name.formatForCodeCapital + 'Type.php',
                fh.phpFileContent(it, entity.innerFormTypeBaseImpl('delete')), fh.phpFileContent(it, entity.innerFormTypeImpl('delete'))
            )
        }
    }

    def private innerFormTypeBaseImpl(Entity it, String action) '''
        namespace «app.appNamespace»\Form\Type\Hook\Base;

        use Symfony\Component\Form\AbstractType;
        use Symfony\Component\Form\Extension\Core\Type\ChoiceType;
        use Symfony\Component\Form\Extension\Core\Type\TextType;
        use Symfony\Component\Form\FormBuilderInterface;
        use Symfony\Component\OptionsResolver\OptionsResolver;
        use Zikula\Common\Translator\IdentityTranslator;

        /**
         * «action.formatForDisplayCapital» «name.formatForDisplay» form type base class.
         */
        abstract class Abstract«action.formatForCodeCapital»«name.formatForCodeCapital»Type extends AbstractType
        {
            /**
             * @inheritDoc
             */
            public function buildForm(FormBuilderInterface $builder, array $options)
            {
                $translator = $options['translator'];
                $builder
                    ->add('dummyName', TextType::class, [
                        'label' => $translator->__('Dummy «name.formatForDisplay» text'),
                        'required' => true
                    ])
                    ->add('dummmyChoice', ChoiceType::class, [
                        'label' => $translator->__('Dummy «name.formatForDisplay» choice'),
                        'choices' => [
                            $translator->__('Option A') => 'A',
                            $translator->__('Option A') => 'B',
                            $translator->__('Option A') => 'C'
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

            /**
             * @inheritDoc
             */
            public function getBlockPrefix()
            {
                return '«app.appName.formatForDB»_hook_«action.formatForDB»«name.formatForDB»';
            }

            /**
             * @inheritDoc
             */
            public function configureOptions(OptionsResolver $resolver)
            {
                $resolver->setDefaults([
                    'translator' => new IdentityTranslator()
                ]);
            }
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

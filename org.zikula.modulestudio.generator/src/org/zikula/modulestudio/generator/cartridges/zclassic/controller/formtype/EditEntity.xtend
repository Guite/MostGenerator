package org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.EntityWorkflowType
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class EditEntity {
    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    FileHelper fh = new FileHelper
    Application app
    String nsSymfonyFormType = 'Symfony\\Component\\Form\\Extension\\Core\\Type\\'

    /**
     * Entry point for entity editing form type.
     * 1.4.x only.
     */
    def generate(Entity it, IFileSystemAccess fsa) {
        if (!hasActions('edit')) {
            return
        }
        app = it.application
        app.generateClassPair(fsa, app.getAppSourceLibPath + 'Form/Type/' + name.formatForCodeCapital + 'Type.php',
            fh.phpFileContent(app, editTypeBaseImpl), fh.phpFileContent(app, editTypeImpl)
        )
    }

    def private editTypeBaseImpl(Entity it) '''
        namespace «app.appNamespace»\Form\Type\Base;

        use Symfony\Component\Form\AbstractType as SymfonyAbstractType;
        use Symfony\Component\Form\FormBuilderInterface;
        use Symfony\Component\OptionsResolver\OptionsResolver;
        use Symfony\Component\Translation\TranslatorInterface;
        «IF metaData»
            use Symfony\Component\Validator\Constraints\Valid;
        «ENDIF»

        /**
         * «name.formatForDisplayCapital» editing form type base class.
         */
        class «name.formatForCodeCapital»Type extends SymfonyAbstractType
        {
            /**
             * @var TranslatorInterface
             */
            private $translator;

            /**
             * «name.formatForCodeCapital»Type constructor.
             *
             * @param TranslatorInterface $translator Translator service instance.
             */
            public function __construct(TranslatorInterface $translator)
            {
                $this->translator = $translator;
            }

            /**
             * {@inheritdoc}
             */
            public function buildForm(FormBuilderInterface $builder, array $options)
            {
                $objectType = '«name.formatForCode»';

«/* TODO
required form options


required template vars
'«entity.name.formatForDB»' -> entity instance
'mode' -> create or edit
'form' -> edit form
'actions' -> list of workflow actions
 */»
                «/* TODO add fields */»

                «/* note: */»
                // all form fields not existing in the mapped object cause an exception
                // hence additional form fields need mapped=false
                // $builder->add('addition', '«nsSymfonyFormType»TextType', ['mapped' => false]);
                // form fields not contained in submitted data are explictly set to null

                «IF geographical»
                    «/* TODO */»
                «ENDIF»
                «IF attributable»
                    «/* TODO */»
                «ENDIF»
                «IF categorisable»
                    $builder->add('categories', 'Zikula\CategoriesModule\Form\Type\CategoriesType', [
                        'label' => $this->translator->trans('«IF categorisableMultiSelection»Categories«ELSE»Category«ENDIF»', [], '«app.appName.formatForDB»') . ':',
                        'empty_data' => [],
                        'attr' => [
                            'class' => 'category-selector'
                        ],
                        'required' => false,
                        'multiple' => «categorisableMultiSelection.displayBool»,
                        'module' => '«app.appName»',
                        'entity' => ucfirst($objectType) . 'Entity',
                        'entityCategoryClass' => '«app.appNamespace»\Entity\' . ucfirst($objectType) . 'CategoryEntity'
                    ]);
                «ENDIF»
                «/* TODO relations */»
                «IF metaData»

                    // embedded meta data form
                    $builder->add('metadata', '«app.appNamespace»\Form\EntityMetaDataType', [
                        'constraints' => new Valid()
                    ]);
                «ENDIF»
                «IF workflow != EntityWorkflowType.NONE»
                    «/* TODO additionalNotificationRemarks
                    <div class="form-group">
                        {formlabel for='additionalNotificationRemarks' __text='Additional remarks' cssClass='col-sm-3 control-label'}
                        {% set fieldTitle = __('Enter any additions about your changes') %}
                        {% if mode == 'create' %}
                            {% set fieldTitle = __('Enter any additions about your content') %}
                        {% if %}
                        {formtextinput group='«name.formatForDB»' id='additionalNotificationRemarks' mandatory=false title=$fieldTitle textMode='multiline' rows='6'}
                        {% if isModerator or isSuperModerator %}
                            <span class="help-block">{{ __('These remarks (like a reason for deny) are not stored, but added to any notification emails send to the creator.') }}</span>
                        {% elseif isCreator %}
                            <span class="help-block">{{ __('These remarks (like questions about conformance) are not stored, but added to any notification emails send to our moderators.') }}</span>
                        {% endif %}
                    </div>

                     */»
                «ENDIF»
                «/* TODO return control
                        {formlabel for='repeatCreation' __text='Create another item after save' cssClass='col-sm-3 control-label'}
                        <div class="col-sm-9">
                            {formcheckbox group='«name.formatForDB»' id='repeatCreation' readOnly=false}
                        </div>
                */»
                «/* TODO submit buttons
                 for ($actions as $action) {
fieldName: $action['id']
label -> __($action['title'])
attr
	id -> 'btn' . ucfirst($action['id'])
	class -> $action['buttonClass']
	title -> __($action['description'])

                 }
                 cancel
                   -> __('Cancel')
                   -> id btnCancel
                 */»
            }

            /**
             * {@inheritdoc}
             */
            public function getBlockPrefix()
            {
                return '«app.appName.formatForDB»_«name.formatForDB»';
            }

            /**
             * {@inheritdoc}
             */
            public function configureOptions(OptionsResolver $resolver)
            {
                $resolver->setDefaults([
                    // define class for underlying data (required for embedding forms)
                    'data_class' => '«entityClassName('', false)»'
                ]);
            }
        }
    '''

    def private editTypeImpl(Entity it) '''
        namespace «app.appNamespace»\Form\Type;

        use «app.appNamespace»\Form\Type\Base\«name.formatForCodeCapital»Type as Base«name.formatForCodeCapital»Type;

        /**
         * «name.formatForDisplayCapital» editing form type implementation class.
         */
        class «name.formatForCodeCapital»Type extends Base«name.formatForCodeCapital»Type
        {
            // feel free to extend the «name.formatForDisplay» editing form type class here
        }
    '''
}

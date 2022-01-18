package org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype.field

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.ListField
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class MultiListType {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension Utils = new Utils

    Application app

    def generate(Application it, IMostFileSystemAccess fsa) {
        if (!hasMultiListFields && variables.map[fields].flatten.filter(ListField).filter[multiple].empty) {
            return
        }
        app = it
        fsa.generateClassPair('Form/Type/Field/MultiListType.php', multiListTypeBaseImpl, multiListTypeImpl)
    }

    def private multiListTypeBaseImpl(Application it) '''
        namespace «appNamespace»\Form\Type\Field\Base;

        use Symfony\Component\Form\AbstractType;
        use Symfony\Component\Form\Extension\Core\Type\ChoiceType;
        use Symfony\Component\Form\FormBuilderInterface;
        use «appNamespace»\Form\DataTransformer\ListFieldTransformer;
        use «app.appNamespace»\Helper\ListEntriesHelper;

        /**
         * Multi list field type base class.
         */
        abstract class AbstractMultiListType extends AbstractType
        {
            public function __construct(protected ListEntriesHelper $listHelper)
            {
            }

            public function buildForm(FormBuilderInterface $builder, array $options)
            {
                $transformer = new ListFieldTransformer($this->listHelper);
                $builder->addModelTransformer($transformer);
            }

            public function getParent()
            {
                return ChoiceType::class;
            }

            public function getBlockPrefix()
            {
                return '«appName.formatForDB»_field_multilist';
            }
        }
    '''

    def private multiListTypeImpl(Application it) '''
        namespace «appNamespace»\Form\Type\Field;

        use «appNamespace»\Form\Type\Field\Base\AbstractMultiListType;

        /**
         * Multi list field type implementation class.
         */
        class MultiListType extends AbstractMultiListType
        {
            // feel free to extend the base form type class here
        }
    '''
}

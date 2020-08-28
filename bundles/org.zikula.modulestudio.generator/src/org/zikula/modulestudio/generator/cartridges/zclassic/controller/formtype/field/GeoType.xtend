package org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype.field

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class GeoType {

    extension FormattingExtensions = new FormattingExtensions
    extension Utils = new Utils

    def generate(Application it, IMostFileSystemAccess fsa) {
        fsa.generateClassPair('Form/Type/Field/GeoType.php', geoTypeBaseImpl, geoTypeImpl)
    }

    def private geoTypeBaseImpl(Application it) '''
        namespace «appNamespace»\Form\Type\Field\Base;

        use Symfony\Component\Form\AbstractType;
        use Symfony\Component\Form\Extension\Core\Type\NumberType;
        use Symfony\Component\OptionsResolver\OptionsResolver;

        /**
         * Geo field type base class.
         */
        abstract class AbstractGeoType extends AbstractType
        {
            public function configureOptions(OptionsResolver $resolver)
            {
                parent::configureOptions($resolver);

                $resolver->setDefaults([
                    'scale' => 7,
                    'attr' => [
                        'maxlength' => 12,
                        'class' => 'geo-date',
                    ],
                ]);
            }

            public function getParent()
            {
                return NumberType::class;
            }

            public function getBlockPrefix()
            {
                return '«appName.formatForDB»_field_geo';
            }
        }
    '''

    def private geoTypeImpl(Application it) '''
        namespace «appNamespace»\Form\Type\Field;

        use «appNamespace»\Form\Type\Field\Base\AbstractGeoType;

        /**
         * Geo field type implementation class.
         */
        class GeoType extends AbstractGeoType
        {
            // feel free to add your customisation here
        }
    '''
}

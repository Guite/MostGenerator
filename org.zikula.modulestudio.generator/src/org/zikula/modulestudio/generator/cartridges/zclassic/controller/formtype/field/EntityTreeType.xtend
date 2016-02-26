package org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype.field

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class EntityTreeType {
    extension FormattingExtensions = new FormattingExtensions()
    extension NamingExtensions = new NamingExtensions()
    extension Utils = new Utils()

    FileHelper fh = new FileHelper()

    def generate(Application it, IFileSystemAccess fsa) {
        generateClassPair(fsa, getAppSourceLibPath + 'Form/Type/Field/EntityTreeType.php',
            fh.phpFileContent(it, entityTreeTypeBaseImpl), fh.phpFileContent(it, entityTreeTypeImpl)
        )
    }

    def private entityTreeTypeBaseImpl(Application it) '''
        namespace «appNamespace»\Form\Type\Field\Base;

        use Symfony\Component\Form\AbstractType;
        use Symfony\Component\OptionsResolver\Options;
        use Symfony\Component\OptionsResolver\OptionsResolver;

        /**
         * Entity tree type base class.
         */
        class EntityTreeType extends AbstractType
        {
            /**
             * {@inheritdoc}
             */
            public static function createChoiceLabel($choice)
            {
                // determine current list hierarchy level depending on root node inclusion
                $shownLevel = $choice->getLvl();
                if (!$options['includeRootNode']) {
                    $shownLevel--;
                }
                $prefix = str_repeat('- - ', $shownLevel);

                $itemLabel = $prefix . $choice->getTitleFromDisplayPattern();

                return $itemLabel;
            }

            /**
             * Sets dynamic option for retrieving the choices.
             *
             * @param array $options The options.
             */
            $choices = function(Options $options) {
                return $this->loadChoices($options);
            };

            /**
             * {@inheritdoc}
             */
            public function configureOptions(OptionsResolver $resolver)
            {
                parent::configureOptions($resolver);

                $resolver
                    ->setDefaults([
                        'root' => 1,
                        'includeLeafNodes' => true,
                        'includeRootNode' => false,
                        'useJoins' => true,
                        'attr' => [
                            'class' => 'entity-tree'
                        ],
                        «/*'query_builder' => function (EntityRepository $er) {
                            return $er->selectTree($options['root'], $options['useJoins']);
                        },*/»
                        'choices' => $choices,
                        'choices_as_values' => true
                    ])
                    ->setAllowedTypes([
                        'root' => 'int',
                        'includeLeafNodes' => 'bool',
                        'includeRootNode' => 'bool',
                        'useJoins' => 'bool'
                    ])
                ;
            }

            /**
             * {@inheritdoc}
             */
            public function getParent()
            {
                return 'Symfony\Component\Form\Extension\Core\Type\EntityType';
            }

            /**
             * {@inheritdoc}
             */
            public function getBlockPrefix()
            {
                return '«appName.formatForDB»_field_entitytree';
            }

            /**
             * {@inheritdoc}
             */
            public function getName()
            {
                return $this->getBlockPrefix();
            }

            /**
             * Performs the actual data selection.
             *
             * @param array $options The options.
             *
             * @return array List of selected objects.
             */
            protected function loadChoices(array $options)
            {
                $repository = $options['em']->getRepository($options['class']);

                $items = $repository->selectTree($options['root'], $options['useJoins'])

                $choices = array();
                foreach ($items as $item) {
                    if (!$this->isIncluded($item)) {
                        continue;
                    }

                    $choices[$this->createChoiceLabel($item)] = $item->createCompositeIdentifier();
                }

                return $choices;
            }

            /**
             * Determines whether a certain list item should be included or not.
             * Allows to exclude undesired items after the selection has happened.
             *
             * @param Doctrine\ORM\Entity $item The treated entity.
             *
             * @return boolean Whether this entity should be included into the list.
             */
            protected function isIncluded($item)
            {
                $nodeLevel = $item->getLvl();

                if (!$this->includeRootNode && $nodeLevel == 0) {
                    // if we do not include the root node skip it
                    return false;
                }

                if (!$this->includeLeafNodes && $this->repository->childCount($item) == 0) {
                    // if we do not include leaf nodes skip them
                    return false;
                }

                return true;
            }
        }
    '''

    def private entityTreeTypeImpl(Application it) '''
        namespace «appNamespace»\Form\Type\Field;

        use «appNamespace»\Form\Type\Field\Base\EntityTreeType as BaseEntityTreeType;

        /**
         * Entity tree type implementation class.
         */
        class EntityTreeType extends BaseEntityTreeType
        {
            // feel free to add your customisation here
        }
    '''
}

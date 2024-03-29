package org.zikula.modulestudio.generator.cartridges.symfony.controller.formtype.field

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.Utils
import org.zikula.modulestudio.generator.application.ImportList

class EntityTreeType {

    extension FormattingExtensions = new FormattingExtensions
    extension Utils = new Utils

    def generate(Application it, IMostFileSystemAccess fsa) {
        fsa.generateClassPair('Form/Type/Field/EntityTreeType.php', entityTreeTypeBaseImpl, entityTreeTypeImpl)
    }

    def private collectBaseImports(Application it) {
        val imports = new ImportList
        imports.addAll(#[
            'Doctrine\\ORM\\EntityRepository',
            'Symfony\\Bridge\\Doctrine\\Form\\Type\\EntityType',
            'Symfony\\Component\\Form\\AbstractType',
            'Symfony\\Component\\OptionsResolver\\Options',
            'Symfony\\Component\\OptionsResolver\\OptionsResolver',
            appNamespace + '\\Entity\\EntityInterface',
            appNamespace + '\\Helper\\EntityDisplayHelper'
        ])
        imports
    }

    def private entityTreeTypeBaseImpl(Application it) '''
        namespace «appNamespace»\Form\Type\Field\Base;

        «collectBaseImports.print»

        /**
         * Entity tree type base class.
         */
        abstract class AbstractEntityTreeType extends AbstractType
        {
            public function __construct(protected readonly EntityDisplayHelper $entityDisplayHelper)
            {
            }

            public function configureOptions(OptionsResolver $resolver): void
            {
                parent::configureOptions($resolver);

                $resolver
                    ->setDefaults([
                        'root' => 0,
                        'include_leaf_nodes' => true,
                        'include_root_nodes' => true,
                        'use_joins' => true,
                        'attr' => [
                            'class' => 'entity-tree',
                        ],«/*
                        'query_builder' => function (EntityRepository $er) {
                            return $er->selectTree($options['root'], $options['use_joins']);
                        },*/»
                    ])
                    ->setAllowedTypes('root', 'int')
                    ->setAllowedTypes('include_leaf_nodes', 'bool')
                    ->setAllowedTypes('include_root_nodes', 'bool')
                    ->setAllowedTypes('use_joins', 'bool')
                ;
                $resolver->setNormalizer('choices', function (Options $options, $choices) {
                    if (empty($choices)) {
                        $choices = $this->loadChoices($options);
                    }

                    return $choices;
                });
                $resolver->setNormalizer('choice_label', function (Options $options, $choice_label) {
                    return function ($choice, $key, $value) use ($options) {
                        return $this->createChoiceLabel($choice, $options['include_root_nodes']);
                    };
                });
            }

            /**
             * Performs the actual data selection.
             */
            protected function loadChoices(Options $options): array
            {
                $repository = $options['em']->getRepository($options['class']);
                $treeNodes = $repository->selectTree($options['root'], $options['use_joins']);
                $trees = [];

                if (0 < $options['root']) {
                    $trees[$options['root']] = $treeNodes;
                } else {
                    $trees = $treeNodes;
                }

                $choices = [];
                foreach ($trees as $treeNodes) {
                    foreach ($treeNodes as $node) {
                        if (null === $node) {
                            continue;
                        }
                        if (!$this->isIncluded($node, $repository, $options)) {
                            continue;
                        }

                        $choices[$node->getId()] = $node;
                    }
                }

                return $choices;
            }

            /**
             * Determines whether a certain list item should be included or not.
             * Allows to exclude undesired items after the selection has happened.
             */
            protected function isIncluded(EntityInterface $entity, EntityRepository $repository, Options $options): bool
            {
                $nodeLevel = $entity->getLvl();

                if (0 === $nodeLevel && !$options['include_root_nodes']) {
                    // if we do not include the root node skip it
                    return false;
                }

                if (!$options['include_leaf_nodes'] && 0 === $repository->childCount($entity)) {
                    // if we do not include leaf nodes skip them
                    return false;
                }

                return true;
            }

            /**
             * Creates the label for a choice.
             */
            protected function createChoiceLabel($choice, bool $includeRootNode = false): string
            {
                // determine current list hierarchy level depending on root node inclusion
                $shownLevel = $choice->getLvl();
                if (!$includeRootNode) {
                    --$shownLevel;
                }
                $prefix = str_repeat('- - ', $shownLevel);

                return $prefix . $this->entityDisplayHelper->getFormattedTitle($choice);
            }

            public function getParent(): ?string
            {
                return EntityType::class;
            }

            public function getBlockPrefix(): string
            {
                return '«appName.formatForDB»_field_entitytree';
            }
        }
    '''

    def private entityTreeTypeImpl(Application it) '''
        namespace «appNamespace»\Form\Type\Field;

        use «appNamespace»\Form\Type\Field\Base\AbstractEntityTreeType;

        /**
         * Entity tree type implementation class.
         */
        class EntityTreeType extends AbstractEntityTreeType
        {
            // feel free to add your customisation here
        }
    '''
}

package org.zikula.modulestudio.generator.cartridges.zclassic.models.business

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.Utils

class ListEntryValidator {

    extension Utils = new Utils

    /**
     * Creates constraint and validator classes for list field items.
     */
    def generate(Application it, IMostFileSystemAccess fsa) {
        'Generating list entry constraint and validator classes'.printIfNotTesting(fsa)
        fsa.generateClassPair('Validator/Constraints/ListEntry.php', constraintBaseImpl, constraintImpl)
        fsa.generateClassPair('Validator/Constraints/ListEntryValidator.php', validatorBaseImpl, validatorImpl)
    }

    def private constraintBaseImpl(Application it) '''
        namespace «appNamespace»\Validator\Constraints\Base;

        use Symfony\Component\Validator\Constraint;

        /**
         * List entry validation constraint.
         */
        abstract class AbstractListEntry extends Constraint
        {
            /**
             * Entity name.
             *
             * @var string
             */
            public $entityName = '';

            /**
             * Property name.
             *
             * @var string
             */
            public $propertyName = '';

            /**
             * Whether multiple list values are allowed or not.
             *
             * @var bool
             */
            public $multiple = false;

            /**
             * Minimum amount of values for multiple lists.
             *
             * @var int
             */
            public $min;

            /**
             * Maximum amount of values for multiple lists.
             *
             * @var int
             */
            public $max;
        }
    '''

    def private constraintImpl(Application it) '''
        namespace «appNamespace»\Validator\Constraints;

        use «appNamespace»\Validator\Constraints\Base\AbstractListEntry;

        /**
         * List entry validation constraint.
         *
         * @Annotation
         */
        class ListEntry extends AbstractListEntry
        {
            // here you can customise the constraint
        }
    '''

    def private validatorBaseImpl(Application it) '''
        namespace «appNamespace»\Validator\Constraints\Base;

        use Symfony\Component\Validator\Constraint;
        use Symfony\Component\Validator\ConstraintValidator;
        use Symfony\Component\Validator\Exception\UnexpectedTypeException;
        use Symfony\Contracts\Translation\TranslatorInterface;
        use Zikula\Bundle\CoreBundle\Translation\TranslatorTrait;
        use «appNamespace»\Helper\ListEntriesHelper;
        use «appNamespace»\Validator\Constraints\ListEntry;

        /**
         * List entry validator.
         */
        abstract class AbstractListEntryValidator extends ConstraintValidator
        {
            use TranslatorTrait;

            /**
             * @var ListEntriesHelper
             */
            protected $listEntriesHelper;

            public function __construct(TranslatorInterface $translator, ListEntriesHelper $listEntriesHelper)
            {
                $this->setTranslator($translator);
                $this->listEntriesHelper = $listEntriesHelper;
            }

            public function validate($value, Constraint $constraint)
            {
                if (!$constraint instanceof ListEntry) {
                    throw new UnexpectedTypeException($constraint, ListEntry::class);
                }
                if (null === $value) {
                    return;
                }

                if ('workflowState' === $constraint->propertyName && in_array($value, ['initial', 'deleted'], true)) {
                    return;
                }

                $listEntries = $this->listEntriesHelper->getEntries($constraint->entityName, $constraint->propertyName);
                $allowedValues = [];
                foreach ($listEntries as $entry) {
                    $allowedValues[] = $entry['value'];
                }

                if (!$constraint->multiple) {
                    // single-valued list
                    if ('' !== $value && !in_array($value, $allowedValues/*, true*/)) {
                        $this->context->buildViolation(
                            $this->trans(
                                'The value "%value%" is not allowed for the "%property%" property.',
                                [
                                    '%value%' => $value,
                                    '%property%' => $constraint->propertyName,
                                ],
                                'validators'
                            )
                        )->addViolation();
                    }

                    return;
                }

                // multi-values list
                $selected = explode('###', $value);
                foreach ($selected as $singleValue) {
                    if ('' === $singleValue) {
                        continue;
                    }
                    if (!in_array($singleValue, $allowedValues/*, true*/)) {
                        $this->context->buildViolation(
                            $this->trans(
                                'The value "%value%" is not allowed for the "%property%" property.',
                                [
                                    '%value%' => $singleValue,
                                    '%property%' => $constraint->propertyName,
                                ],
                                'validators'
                            )
                        )->addViolation();
                    }
                }

                $count = count($selected);

                if (null !== $constraint->min && $count < $constraint->min) {
                    $this->context->buildViolation(
                        $this->translator->trans(
                            'You must select at least "%limit%" choice.|You must select at least "%limit%" choices.',
                            [
                                '%count%' => $count,
                                '%limit%' => $constraint->min,
                            ],
                            'validators'
                        )
                    )->addViolation();
                }
                if (null !== $constraint->max && $count > $constraint->max) {
                    $this->context->buildViolation(
                        $this->translator->trans(
                            'You must select at most "%limit%" choice.|You must select at most "%limit%" choices.',
                            [
                                '%count%' => $count,
                                '%limit%' => $constraint->max,
                            ],
                            'validators'
                        )
                    )->addViolation();
                }
            }
        }
    '''

    def private validatorImpl(Application it) '''
        namespace «appNamespace»\Validator\Constraints;

        use «appNamespace»\Validator\Constraints\Base\AbstractListEntryValidator;

        /**
         * List entry validator.
         */
        class ListEntryValidator extends AbstractListEntryValidator
        {
            // here you can customise the validator
        }
    '''
}

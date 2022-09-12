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
            public string $entityName = '';

            public string $propertyName = '';

            /**
             * Whether multiple list values are allowed or not.
             */
            public bool $multiple = false;

            /**
             * Minimum amount of values for multiple lists.
             */
            public ?int $min = null;

            /**
             * Maximum amount of values for multiple lists.
             */
            public ?int $max = null;

            public function __construct(
                array $options = null,
                string $entityName = '',
                string $propertyName = '',
                bool $multiple = false,
                ?int $min = null,
                ?int $max = null,
                array $groups = null,
                $payload = null
            ) {
                parent::__construct($options, $groups, $payload);
                $this->entityName = $entityName;
                $this->propertyName = $propertyName;
                $this->multiple = $multiple;
                $this->min = $min;
                $this->max = $max;
            }
        }
    '''

    def private constraintImpl(Application it) '''
        namespace «appNamespace»\Validator\Constraints;

        use «appNamespace»\Validator\Constraints\Base\AbstractListEntry;

        /**
         * List entry validation constraint.
         */
        #[\Attribute(\Attribute::TARGET_PROPERTY | \Attribute::TARGET_METHOD | \Attribute::IS_REPEATABLE)]
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
        use «appNamespace»\Helper\ListEntriesHelper;
        use «appNamespace»\Validator\Constraints\ListEntry;

        /**
         * List entry validator.
         */
        abstract class AbstractListEntryValidator extends ConstraintValidator
        {
            public function __construct(protected readonly TranslatorInterface $translator, protected readonly ListEntriesHelper $listEntriesHelper)
            {
            }

            public function validate($value, Constraint $constraint)
            {
                if (!$constraint instanceof ListEntry) {
                    throw new UnexpectedTypeException($constraint, ListEntry::class);
                }
                if (null === $value) {
                    return;
                }

                if (!$constraint->multiple && 'workflowState' === $constraint->propertyName && in_array($value, ['initial', 'deleted'], true)) {
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
                            $this->translator->trans(
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

                // multi-valued list
                foreach ($value as $singleValue) {
                    if ('' === $singleValue) {
                        continue;
                    }
                    if (!in_array($singleValue, $allowedValues/*, true*/)) {
                        $this->context->buildViolation(
                            $this->translator->trans(
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

                $amountOfSelectedEntries = count($value);

                if (null !== $constraint->min && $amountOfSelectedEntries < $constraint->min) {
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
                if (null !== $constraint->max && $amountOfSelectedEntries > $constraint->max) {
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

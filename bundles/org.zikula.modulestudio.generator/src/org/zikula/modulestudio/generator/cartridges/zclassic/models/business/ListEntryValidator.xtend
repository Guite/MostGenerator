package org.zikula.modulestudio.generator.cartridges.zclassic.models.business

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ListEntryValidator {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
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
             * Entity name
             * @var string
             */
            public $entityName = '';

            /**
             * Property name
             * @var string
             */
            public $propertyName = '';

            /**
             * Whether multiple list values are allowed or not
             * @var boolean
             */
            public $multiple = false;

            /**
             * Minimum amount of values for multiple lists
             * @var integer
             */
            public $min;

            /**
             * Maximum amount of values for multiple lists
             * @var integer
             */
            public $max;
            «IF !targets('3.0')»

                public function validatedBy()
                {
                    return '«appService».validator.list_entry.validator';
                }
            «ENDIF»
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
        use Zikula\Common\Translator\TranslatorInterface;
        use Zikula\Common\Translator\TranslatorTrait;
        use «appNamespace»\Helper\ListEntriesHelper;

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

            «setTranslatorMethod»

            public function validate($value, Constraint $constraint)
            {
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
                            $this->__f('The value "%value%" is not allowed for the "%property%" property.', [
                                '%value%' => $value,
                                '%property%' => $constraint->propertyName
                            ])
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
                            $this->__f('The value "%value%" is not allowed for the "%property%" property.', [
                                '%value%' => $singleValue,
                                '%property%' => $constraint->propertyName
                            ])
                        )->addViolation();
                    }
                }

                $count = count($selected);

                if (null !== $constraint->min && $count < $constraint->min) {
                    $this->context->buildViolation(
                        «IF targets('3.0')»
                            $this->translator->trans(
                                'You must select at least "%limit%" choice.|You must select at least "%limit%" choices.',
                                $count,
                                [
                                    '%count%' => $count,
                                    '%limit%' => $constraint->min
                                ]«IF !isSystemModule»,
                                '«appName.formatForDB»'«ENDIF»
                            )
                        «ELSE»
                            $this->translator->transChoice(
                                'You must select at least "%limit%" choice.|You must select at least "%limit%" choices.',
                                $count,
                                [
                                    '%limit%' => $constraint->min
                                ]«IF !isSystemModule»,
                                '«appName.formatForDB»'«ENDIF»
                            )
                        «ENDIF»
                    )->addViolation();
                }
                if (null !== $constraint->max && $count > $constraint->max) {
                    $this->context->buildViolation(
                        «IF targets('3.0')»
                            $this->translator->trans(
                                'You must select at most "%limit%" choice.|You must select at most "%limit%" choices.',
                                $count,
                                [
                                    '%count%' => $count,
                                    '%limit%' => $constraint->max
                                ]«IF !isSystemModule»,
                                '«appName.formatForDB»'«ENDIF»
                            )
                        «ELSE»
                            $this->translator->transChoice(
                                'You must select at most "%limit%" choice.|You must select at most "%limit%" choices.',
                                $count,
                                [
                                    '%limit%' => $constraint->max
                                ]«IF !isSystemModule»,
                                '«appName.formatForDB»'«ENDIF»
                            )
                        «ENDIF»
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

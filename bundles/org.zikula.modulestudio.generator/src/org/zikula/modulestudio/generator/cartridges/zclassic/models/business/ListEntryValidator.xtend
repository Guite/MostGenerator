package org.zikula.modulestudio.generator.cartridges.zclassic.models.business

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ListEntryValidator {

    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    FileHelper fh = new FileHelper

    /**
     * Creates constraint and validator classes for list field items.
     */
    def generate(Application it, IFileSystemAccess fsa) {
        println('Generating list entry constraint and validator classes')
        generateClassPair(fsa, getAppSourceLibPath + 'Validator/Constraints/ListEntry.php',
            fh.phpFileContent(it, constraintBaseImpl), fh.phpFileContent(it, constraintImpl)
        )
        generateClassPair(fsa, getAppSourceLibPath + 'Validator/Constraints/ListEntryValidator.php',
            fh.phpFileContent(it, validatorBaseImpl), fh.phpFileContent(it, validatorImpl)
        )
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

            /**
             * @inheritDoc
             */
            public function validatedBy()
            {
                return '«appService».validator.list_entry.validator';
            }
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

            /**
             * ListEntryValidator constructor.
             *
             * @param TranslatorInterface $translator        Translator service instance
             * @param ListEntriesHelper   $listEntriesHelper ListEntriesHelper service instance
             */
            public function __construct(TranslatorInterface $translator, ListEntriesHelper $listEntriesHelper)
            {
                $this->setTranslator($translator);
                $this->listEntriesHelper = $listEntriesHelper;
            }

            «setTranslatorMethod»

            /**
             * @inheritDoc
             */
            public function validate($value, Constraint $constraint)
            {
                if (null === $value) {
                    return;
                }

                if ($constraint->propertyName == 'workflowState' && in_array($value, ['initial', 'deleted'])) {
                    return;
            	}

                $listEntries = $this->listEntriesHelper->getEntries($constraint->entityName, $constraint->propertyName);
                $allowedValues = [];
                foreach ($listEntries as $entry) {
                    $allowedValues[] = $entry['value'];
                }

                if (!$constraint->multiple) {
                    // single-valued list
                    if (!in_array($value, $allowedValues, true)) {
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
                    if ($singleValue == '') {
                        continue;
                    }
                    if (!in_array($singleValue, $allowedValues, true)) {
                        $this->context->buildViolation(
                            $this->__f('The value "%value%" is not allowed for the "%property%" property.', [
                                '%value%' => $singleValue,
                                '%property%' => $constraint->propertyName
                            ])
                        )->addViolation();
                    }
                }

                $count = count($value);

                if (null !== $constraint->min && $count < $constraint->min) {
                    $this->context->buildViolation(
                        $this->__fn('You must select at least "%limit%" choice.', 'You must select at least "%limit%" choices.', $count, [
                            '%limit%' => $constraint->min
                        ])
                    )->addViolation();
                }
                if (null !== $constraint->max && $count > $constraint->max) {
                    $this->context->buildViolation(
                        $this->__fn('You must select at most "%limit%" choice.', 'You must select at most "%limit%" choices.', $count, [
                            '%limit%' => $constraint->max
                        ])
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

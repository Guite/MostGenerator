package org.zikula.modulestudio.generator.cartridges.zclassic.controller.form

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class TranslationListener {

    extension NamingExtensions = new NamingExtensions()
    extension Utils = new Utils()

    FileHelper fh = new FileHelper()

    def generate(Application it, IFileSystemAccess fsa) {
        generateClassPair(fsa, getAppSourceLibPath + 'Form/EventListener/TranslationListener.php',
            fh.phpFileContent(it, listenerBaseImpl), fh.phpFileContent(it, listenerImpl)
        )
    }

    def private listenerBaseImpl(Application it) '''
        namespace «appNamespace»\Form\EventListener\Base;

        use Symfony\Component\EventDispatcher\EventSubscriberInterface;
        use Symfony\Component\Form\FormEvent;
        use Symfony\Component\Form\FormEvents;
        use Symfony\Component\Form\FormInterface;

        /**
         * Translation listener base class.
         *
         * Based on https://github.com/a2lix/TranslationFormBundle/blob/master/Form/EventListener/TranslationsListener.php
         */
        abstract class AbstractTranslationListener implements EventSubscriberInterface
        {
            «listenerBaseImplBody»
        }
    '''

    def private listenerBaseImplBody(Application it) '''
        /**
         * @inheritDoc
         */
        public static function getSubscribedEvents()
        {
            return [
                FormEvents::PRE_SET_DATA => 'preSetData'
            ];
        }

        /**
         * Adds translation fields to the form.
         *
         * @param FormEvent $event
         */
        public function preSetData(FormEvent $event)
        {
            $form = $event->getForm();
            $formOptions = $form->getConfig()->getOptions();

            $entityForm = $this->getEntityForm($form->getParent());

            foreach ($formOptions['fields'] as $fieldName) {
                if (!$entityForm->has($fieldName)) {
                    continue;
                }

                $originalFieldConfig = $entityForm->get($fieldName)->getConfig();
                $fieldOptions = $originalFieldConfig->getOptions();
                $fieldOptions['required'] = $fieldOptions['required'] && in_array($fieldName, $formOptions['mandatory_fields']);
                $fieldOptions['data'] = isset($formOptions['values'][$fieldName]) ? $formOptions['values'][$fieldName] : null;

                $form->add($fieldName, get_class($originalFieldConfig->getType()->getInnerType()), $fieldOptions);
            }
        }

        /**
         * Returns parent form editing the entity.
         *
         * @param FormInterface $form
         *
         * @return FormInterface
         */
        protected function getEntityForm(FormInterface $form)
        {
            $parentForm = $form;
            do {
                $parentForm = $form;
            } while ($form->getConfig()->getInheritData() && ($form = $form->getParent()));

            return $parentForm;
        }
    '''

    def private listenerImpl(Application it) '''
        namespace «appNamespace»\Form\EventListener;

        use «appNamespace»\Form\EventListener\Base\AbstractTranslationListener;

        /**
         * Translation listener implementation class.
         */
        class TranslationListener extends AbstractTranslationListener
        {
            // feel free to add your customisation here
        }
    '''
}

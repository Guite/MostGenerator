package org.zikula.modulestudio.generator.cartridges.symfony.view.plugin

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class GetFormattedDateInterval {

    extension FormattingExtensions = new FormattingExtensions
    extension Utils = new Utils

    def generate(Application it) '''
        /**
         * The «appName.formatForDB»_dateInterval filter outputs a formatted description for a given date interval (duration string).
         * Example:
         *     {{ myDateIntervalString|«appName.formatForDB»_dateInterval }}
         *
         * @see http://php.net/manual/en/dateinterval.format.php
         */
        #[AsTwigFilter('«appName.formatForDB»_dateInterval')]
        public function getFormattedDateInterval(string $duration): string
        {
            $interval = new DateInterval($duration);

            $description = 1 === $interval->invert ? '- ' : '';

            $amount = $interval->y;
            if (0 < $amount) {
                $description .= $this->translator->trans('%count% year|%count% years', ['%count%' => $amount]);
            }

            $amount = $interval->m;
            if (0 < $amount) {
                $description .= ', ' . $this->translator->trans('%count% month|%count% months', ['%count%' => $amount]);
            }

            $amount = $interval->d;
            if (0 < $amount) {
                $description .= ', ' . $this->translator->trans('%count% day|%count% days', ['%count%' => $amount]);
            }

            $amount = $interval->h;
            if (0 < $amount) {
                $description .= ', ' . $this->translator->trans('%count% hour|%count% hours', ['%count%' => $amount]);
            }

            $amount = $interval->i;
            if (0 < $amount) {
                $description .= ', ' . $this->translator->trans('%count% minute|%count% minutes', ['%count%' => $amount]);
            }

            $amount = $interval->s;
            if (0 < $amount) {
                $description .= ', ' . $this->translator->trans('%count% second|%count% seconds', ['%count%' => $amount]);
            }

            return $description;
        }
    '''
}

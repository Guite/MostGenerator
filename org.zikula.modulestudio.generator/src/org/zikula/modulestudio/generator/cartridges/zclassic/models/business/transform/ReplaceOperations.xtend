package org.zikula.modulestudio.generator.cartridges.zclassic.models.business.transform

import de.guite.modulestudio.metamodel.modulestudio.ReplaceGermanSpecialChars

class ReplaceOperations {

    def Function(ReplaceGermanSpecialChars it, String src, String dest) '''
        // This method is used to transform data acquired from input
        // in such a way that only 7-bit ASCII characters remain. 

        // initialize transformation parameters
        $special1 = 'ÄÖÜäöüß';
        $special2 = 'AOUaous';

        // now perform our transformation 
        $obj['«dest»'] = strtr($obj['«src»'], $special1, $special2);
    '''
}

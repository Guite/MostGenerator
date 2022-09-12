package org.zikula.modulestudio.generator.application

class ImportList {
    val imports = <String>newArrayList

    /**
     * Adds an entry to current imports.
     */
    def add(String subject) {
        if (!imports.contains(subject)) {
            imports.add(subject)
        }
        this
    }

    /**
     * Adds multiple entries to current imports.
     */
    def addAll(String[] subjects) {
        for (subject : subjects) {
            add(subject)
        }
        this
    }

    /**
     * Output imports
     */
    def print() '''
        «FOR entry : imports.sort»
            use «entry»;
        «ENDFOR»
    '''
}

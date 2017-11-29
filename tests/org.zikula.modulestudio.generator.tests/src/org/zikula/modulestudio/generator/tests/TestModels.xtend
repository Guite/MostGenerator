/**
 * Copyright (c) 2007-2017 Axel Guckelsberger
 */
package org.zikula.modulestudio.generator.tests

import de.guite.modulestudio.metamodel.ModuleStudioFactory

class TestModels {

    def static simpleNews() {
        return '''
        application "SimpleNews" {
            documentation "Simple news extension"
            vendor "Guite"
            author "Axel Guckelsberger"
            email "info@guite.de"
            url "https://guite.de"
            prefix "sinew"
            entities {
                entity "article" leading {
                    nameMultiple "articles"
                    displayPattern "#title#"
                    fields {
                        string "title" {
                            length 200
                        }
                    }
                    actions {
                        mainAction "Index"
                    }
                }
            }
        }
    '''
    }

    def static simpleNewsSerialised() {
        return '''application "SimpleNews" { documentation "Simple news extension" vendor "Guite" author "Axel Guckelsberger" email "info@guite.de" url "https://guite.de" prefix "sinew" entities { entity "article" leading { nameMultiple "articles" displayPattern "#title#" fields { string "title" { length 200 } } actions { mainAction "Index" } } } }'''
    }

    /**
     * Create a minimal but valid model instance to start from.
     *
     * @return Application instance
     */
    def static validModel() {
        val factory = ModuleStudioFactory.eINSTANCE
        val app = factory.createApplication => [
            vendor = 'Guite'
            name = 'SimpleNews'
        ]

        val entity = factory.createEntity => [
            name = 'article'
            nameMultiple = 'articles'
            leading = true
            displayPattern = '#title#'
        ]
        entity.fields += factory.createStringField => [
            name = 'title'
            sluggablePosition = 1
        ]
        entity.actions += factory.createMainAction => [
            name = 'Index'
        ]
        app.entities += entity

        val entity2 = factory.createEntity => [
            name = 'category'
            nameMultiple = 'categories'
            displayPattern = '#title#'
        ]
        val field2 = factory.createStringField => [
            name = 'title'
            sluggablePosition = 1
        ]
        entity2.fields += field2
        entity2.actions += factory.createMainAction => [
            name = 'Index'
        ]
        app.entities += entity2

        app
    }
}

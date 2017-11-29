/**
 * Copyright (c) 2007-2017 Axel Guckelsberger
 */
package org.zikula.modulestudio.generator.tests

import de.guite.modulestudio.metamodel.ModuleStudioFactory

class TestModels {

    // Factory for instantiating meta objects.
    val factory = ModuleStudioFactory.eINSTANCE

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
    def validModel() {
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
        val field = factory.createStringField => [
            name = 'title'
            sluggablePosition = 1
        ]
        entity.fields.add(field)
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

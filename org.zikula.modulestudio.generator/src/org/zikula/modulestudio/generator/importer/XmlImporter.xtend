package org.zikula.modulestudio.generator.importer

import de.guite.modulestudio.metamodel.modulestudio.Application
import de.guite.modulestudio.metamodel.modulestudio.DerivedField
import de.guite.modulestudio.metamodel.modulestudio.Entity
import de.guite.modulestudio.metamodel.modulestudio.ModulestudioFactory
import de.guite.modulestudio.metamodel.modulestudio.ModulestudioPackage
import java.io.IOException
import java.util.Collections
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.eclipse.gmf.runtime.emf.core.resources.GMFResourceFactory
import org.w3c.dom.Document
import org.w3c.dom.Element
import org.w3c.dom.NodeList

/**
 * This class allows the creation of new models by importing a given xml file
 * which has previously been created from a pntables.php file.
 */
class XmlImporter {

    /**
     * The application.
     */
    Application app

    /**
     * The factory for creating semantic elements.
     */
    ModulestudioFactory factory

    /**
     * Application name.
     */
    String appName

    /**
     * The xml input document.
     */
    Document document

    /**
     * The constructor reading the input file.
     *
     * @param fileName Name of the xml input file.
     * @throws Exception In case something goes wrong.
     */
    new(String fileName) throws Exception {
        if (fileName.isEmpty) {
            throw new Exception(
                    'Error: invalid filename given. Please provide an xml file.')
        }
        val xmlReader = new XmlReader(fileName)
        val fileNameParts = fileName.split('/')
        val rawFileName = fileNameParts.get(fileNameParts.size - 1).replaceAll(' ', '').replaceAll('.xml', '')
        appName = convertToMixedCase(rawFileName)
        document = xmlReader.document
    }

    /**
     * Wrapper for the actual import process.
     */
    def process() {
        createModel
        processElements
        saveModel
    }

    /**
     * Creates the model instance and sets basic properties.
     */
    def private createModel() {
        // Initialise the model (probably unneeded now)
        //ModulestudioPackage::eINSTANCE::eClass

        // Retrieve the default factory singleton
        factory = ModulestudioFactory::eINSTANCE

        // Create initial model content
        app = factory.createApplication
        app.name = appName

        val modelContainer = factory.createModels
        modelContainer.name = 'Model'
        app.models.add(modelContainer)

        val controllerContainer = factory.createControllers
        controllerContainer.name = 'Controller'
        app.controllers.add(controllerContainer)

        val viewContainer = factory.createViews
        viewContainer.name = 'View'
        app.views.add(viewContainer)

        controllerContainer.modelContext.add(modelContainer)
        controllerContainer.processViews = viewContainer
    }

    /**
     * Processes the elements in the xml file.
     */
    def private processElements() {
        val NodeList nodes = document.getElementsByTagName('table')
        val modelContainer = app.models.head

        var i = 0
        while (i < nodes.length) {
        	i = i + 1
            val table = nodes.item(i) as Element
            val entity = factory.createEntity
            val fields = table.getElementsByTagName('column')

            var entityName = table.getAttribute('name')
            if (!entityName.isEmpty && fields.length > 0) {
                if (entityName.isEmpty) {
                    entityName = 'Table ' + i.toString
                }

                entity.name = entityName
                entity.nameMultiple = entityName

                entity.attributable = table.getAttribute('enableAttribution').equalsIgnoreCase('true')
                entity.categorisable = table.getAttribute('enableCategorization').equalsIgnoreCase('true')

                var j = 0
                while (j < fields.length) {
                    j = j + 1
                    val fieldData = fields.item(j) as Element
                    if (!isStandardField(fieldData.getAttribute('name'))) {
                        entity.processField(fieldData)
                    }
                }

                val NodeList indexes = table.getElementsByTagName('index')
                j = 0
                while (j < indexes.length) {
                    j = j + 1
                    val indexData = indexes.item(j) as Element
                    entity.processIndex(indexData)
                }
                modelContainer.entities.add(entity)
            }
        }
    }

    /**
     * Determines whether a given field name should be considered as a standard field or not.
     *
     * @param fieldName Name of given field.
     * @return boolean whether it is a standard field or not.
     */
    def private isStandardField(String fieldName) {
        return (fieldName.equalsIgnoreCase('obj_status')
        	 || fieldName.equalsIgnoreCase('cr_date') || fieldName.equalsIgnoreCase('cr_uid')
        	 || fieldName.equalsIgnoreCase('lu_date') || fieldName.equalsIgnoreCase('lu_uid'))
    }

    /**
     * Processes a given field.
     *
     * @param it The {@link Entity} where this field belongs to.
     * @param fieldData Xml input data for the field.
     */
    def private processField(Entity it, Element fieldData) {
        val fieldName = fieldData.getAttribute('name')
        val fieldType = fieldData.getAttribute('type').toUpperCase
        val fieldLength = fieldData.getAttribute('length')
        val fieldNullable = fieldData.getAttribute('nullable')
        val fieldDefault = fieldData.getAttribute('default')
        if (!fieldName.isEmpty && !fieldType.isEmpty
                && !fieldNullable.isEmpty) {
            if (fieldType.equals('BOOLEAN')) {
                val field = factory.createBooleanField
                setBasicFieldProperties(field, fieldData)
                field.defaultValue = (if (!fieldDefault.isEmpty && fieldDefault.toLowerCase == 'true') 'true' else 'false')
                fields.add(field)
            } else if (fieldType.equals('INT') || fieldType.equals('TINYINT')
                    || fieldType.equals('SMALLINT')
                    || fieldType.equals('MEDIUMINT') || fieldType.equals('BIGINT')) {
                val fieldAutoInc = fieldData.getAttribute('autoincrement')
                val fieldPrimary = fieldData.getAttribute('primary')

                if (fieldName.equalsIgnoreCase('uid') || fieldName.equalsIgnoreCase('userid')
                        || fieldName.equalsIgnoreCase('user_id') || fieldName.equalsIgnoreCase('user')) {
                    val field = factory.createUserField
                    setBasicFieldProperties(field, fieldData)
                    if (!fieldLength.isEmpty)
                        field.length = Integer::parseInt(fieldLength)
                    else
                        field.length = getIntegerLength(fieldType)
                    field.primaryKey = (fieldPrimary.equalsIgnoreCase('true') && fieldAutoInc.equalsIgnoreCase('true'))
                    if (!fieldDefault.isEmpty)
                        field.defaultValue = Integer::parseInt(fieldDefault).toString
                    fields.add(field)
                } else {
                    val field = factory.createIntegerField
                    setBasicFieldProperties(field, fieldData)
                    if (!fieldLength.isEmpty)
                        field.length = Integer::parseInt(fieldLength)
                    else
                        field.length = getIntegerLength(fieldType)
                        field.primaryKey = (fieldPrimary.equalsIgnoreCase('true') && fieldAutoInc.equalsIgnoreCase('true'))
                    if (!fieldDefault.isEmpty)
                        field.defaultValue = Integer::parseInt(fieldDefault).toString
                    fields.add(field)
                }
            } else if (fieldType.equals('VARCHAR')) {
                if (fieldName.equals('file') || fieldName.equals('filename')
                        || fieldName.equalsIgnoreCase('image')
                        || fieldName.equalsIgnoreCase('imagefile')
                        || fieldName.equalsIgnoreCase('video')
                        || fieldName.equalsIgnoreCase('videofile')
                        || fieldName.equalsIgnoreCase('upload')
                        || fieldName.equalsIgnoreCase('uploadfile')) {
                    val field = factory.createUploadField
                    setBasicFieldProperties(field, fieldData)
                    if (!fieldLength.isEmpty) {
                        field.length = Integer::parseInt(fieldLength)
                    }
                    fields.add(field)
                } else if (fieldName.equalsIgnoreCase('email') || fieldName.equalsIgnoreCase('emailaddress') || fieldName.equalsIgnoreCase('mailaddress')) {
                    val field = factory.createEmailField
                    setBasicFieldProperties(field, fieldData)
                    if (!fieldLength.isEmpty)
                        field.length = Integer::parseInt(fieldLength)
                    if (!fieldDefault.isEmpty)
                        field.defaultValue = fieldDefault
                    fields.add(field)
                } else if (fieldName.equalsIgnoreCase('url') || fieldName.equalsIgnoreCase('homepage') || fieldName.equalsIgnoreCase('website')) {
                    val field = factory.createUrlField
                    setBasicFieldProperties(field, fieldData)
                    if (!fieldLength.isEmpty)
                        field.length = Integer::parseInt(fieldLength)
                    if (!fieldDefault.isEmpty)
                        field.defaultValue = fieldDefault
                    fields.add(field)
                } else {
                    val field = factory.createStringField
                    setBasicFieldProperties(field, fieldData)
                    if (!fieldLength.isEmpty)
                        field.length = Integer::parseInt(fieldLength)
                    if (fieldName.equalsIgnoreCase('country')) {
                        field.country = true
                        field.nospace = true
                    } else if (fieldName.equalsIgnoreCase('colour') || fieldName.equalsIgnoreCase('color')) {
                        field.htmlcolour = true
                        field.nospace = true
                    } else if (fieldName.equalsIgnoreCase('language') || fieldName.equalsIgnoreCase('lang') || fieldName.equalsIgnoreCase('locale')) {
                        field.language = true
                        field.nospace = true
                    }
                    if (!fieldDefault.isEmpty)
                        field.defaultValue = fieldDefault
                    fields.add(field)
                }
            } else if (fieldType.equals('TEXT') || fieldType.equals('LONGTEXT')) {
                val field = factory.createTextField
                setBasicFieldProperties(field, fieldData)
                if (!fieldLength.isEmpty)
                    field.length = Integer::parseInt(fieldLength)
                if (!fieldDefault.isEmpty)
                    field.defaultValue = fieldDefault
                fields.add(field)
            } else if (fieldType.equals('NUMERIC')) {
                val field = factory.createDecimalField
                setBasicFieldProperties(field, fieldData)
                if (!fieldLength.isEmpty)
                    field.length = Integer::parseInt(fieldLength)
                if (!fieldDefault.isEmpty)
                    field.defaultValue = Float::parseFloat(fieldDefault).toString
                    fields.add(field)
            } else if (fieldType.equals('FLOAT')) {
                val field = factory.createFloatField
                setBasicFieldProperties(field, fieldData)
                if (!fieldLength.isEmpty)
                    field.length = Integer::parseInt(fieldLength)
                if (!fieldDefault.isEmpty)
                    field.defaultValue = Float::parseFloat(fieldDefault).toString
                fields.add(field)
            } else if (fieldType.equals('DATETIME')) {
                val field = factory.createDatetimeField
                setBasicFieldProperties(field, fieldData)
                if (!fieldDefault.isEmpty)
                    field.defaultValue = fieldDefault
                fields.add(field)
            } else if (fieldType.equals('DATE')) {
                val field = factory.createDateField
                setBasicFieldProperties(field, fieldData)
                if (!fieldDefault.isEmpty)
                    field.defaultValue = fieldDefault
                fields.add(field)
            }
        }
    }

    /**
     * Returns the length for an integer field, depending on a given field type.
     *
     * @param fieldType The given integer type.
     * @return integer The proposed length for this integer field.
     */
    def private getIntegerLength(String fieldType) {
        var result = 0
        if (fieldType.equals('INT')) result = 4
        if (fieldType.equals('TINYINT')) result = 1
        if (fieldType.equals('SMALLINT')) result = 2
        if (fieldType.equals('MEDIUMINT')) result = 4
        if (fieldType.equals('BIGINT')) result = 8
        if (result == 0) result = 10
        result
    }

    /**
     * Configures basic field properties.
     *
     * @param it The {@link DerivedField} which should be configured.
     * @param fieldData Xml input data for the field.
     * @return Object The block expression of this method.
     */
    def private setBasicFieldProperties(DerivedField it, Element fieldData) {
        val fieldName = convertToMixedCase(fieldData.getAttribute('name'))
        val fieldType = fieldData.getAttribute("type")
        val fieldNullable = fieldData.getAttribute('nullable').toLowerCase
        val fieldDefault = fieldData.getAttribute('default')
        val isDateField = fieldType.equals('DATETIME') || fieldType.equals('DATE')
        name = fieldName
        nullable = fieldNullable.equals('true')
        if (!fieldDefault.isEmpty && !fieldDefault.equals("''") && !fieldDefault.equals('NULL')) {
            if (fieldType.equals('BOOLEAN')) {
                val isSet = fieldDefault.equalsIgnoreCase('true') || fieldDefault.equals('1')
                defaultValue = (if (isSet) 'true' else 'false')
            } else if (!(isDateField && fieldDefault.equals('DEFTIMESTAMP'))) {
                defaultValue = fieldDefault
            }
        }
    }

    /**
     * Converts a given field name to mixed case.
     *
     * @param fieldName The given field name.
     * @return string The field name in mixed case.
     */
    def private convertToMixedCase(String fieldName) {
        var result = ""
        if (!fieldName.contains('_')) {
            result = fieldName
        } else {
            val fieldNameParts = fieldName.split('_')
            val sb = new StringBuilder()
            for (fieldNamePart : fieldNameParts) {
                sb.append(fieldNamePart.substring(0, 1).toUpperCase)
                sb.append(fieldNamePart.substring(1).toLowerCase)
            }
            result = sb.toString
        }
        result
    }

    /**
     * Processes a given index.
     *
     * @param it The {@link EntityIndex} which should be processed.
     * @param indexData Xml input data for the index.
     * @return boolean whether everything was okay or not.
     */
    def private processIndex(Entity it, Element indexData) {
        val indexName = indexData.getAttribute('name')
        val indexFieldList = indexData.getAttribute('fields')
        if (!indexName.isEmpty && !indexFieldList.isEmpty) {
            val indexFields = indexFieldList.split(',')
            val index = factory.createEntityIndex
            index.name = indexName
            for (indexField : indexFields) {
                val indexItem = factory.createEntityIndexItem
                indexItem.name = indexField
                index.items.add(indexItem)
            }
            indexes.add(index)
        }
    }

    /**
     * Saves the created model content into a .mostapp file.
     */
    def private saveModel() {
        // Obtain a new resource set
        val resourceSet = new ResourceSetImpl()

        resourceSet.resourceFactoryRegistry.extensionToFactoryMap.put('mostapp', new GMFResourceFactory())
        resourceSet.packageRegistry.put(ModulestudioPackage::eNS_URI, ModulestudioPackage::eINSTANCE)

        // Create a resource
        val resource = resourceSet.createResource(URI::createURI('MOST_output/' + appName + '.mostapp'))
        // Get the first model element and cast it to the right type
        resource.contents.add(app)

        // Now save the content.
        try {
            resource.save(Collections::EMPTY_MAP)
        } catch (IOException e) {
            // TODO Auto-generated catch block
            e.printStackTrace
        }
    }
}

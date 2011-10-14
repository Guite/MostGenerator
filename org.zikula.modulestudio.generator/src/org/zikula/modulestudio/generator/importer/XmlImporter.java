package org.zikula.modulestudio.generator.importer;

import java.io.IOException;
import java.util.Collections;

import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.ResourceSet;
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl;
import org.eclipse.gmf.runtime.emf.core.resources.GMFResourceFactory;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NodeList;

import de.guite.modulestudio.metamodel.modulestudio.Application;
import de.guite.modulestudio.metamodel.modulestudio.BooleanField;
import de.guite.modulestudio.metamodel.modulestudio.Controllers;
import de.guite.modulestudio.metamodel.modulestudio.DateField;
import de.guite.modulestudio.metamodel.modulestudio.DatetimeField;
import de.guite.modulestudio.metamodel.modulestudio.DecimalField;
import de.guite.modulestudio.metamodel.modulestudio.DerivedField;
import de.guite.modulestudio.metamodel.modulestudio.EmailField;
import de.guite.modulestudio.metamodel.modulestudio.Entity;
import de.guite.modulestudio.metamodel.modulestudio.EntityIndex;
import de.guite.modulestudio.metamodel.modulestudio.EntityIndexItem;
import de.guite.modulestudio.metamodel.modulestudio.FloatField;
import de.guite.modulestudio.metamodel.modulestudio.IntegerField;
import de.guite.modulestudio.metamodel.modulestudio.Models;
import de.guite.modulestudio.metamodel.modulestudio.ModulestudioFactory;
import de.guite.modulestudio.metamodel.modulestudio.ModulestudioPackage;
import de.guite.modulestudio.metamodel.modulestudio.StringField;
import de.guite.modulestudio.metamodel.modulestudio.TextField;
import de.guite.modulestudio.metamodel.modulestudio.UploadField;
import de.guite.modulestudio.metamodel.modulestudio.UrlField;
import de.guite.modulestudio.metamodel.modulestudio.UserField;
import de.guite.modulestudio.metamodel.modulestudio.Views;

/**
 * This class allows the creation of new models by importing a given xml file
 * which has previously been created from a pntables.php file.
 * 
 * @author axel
 * 
 */
public class XmlImporter {

    private Application app;
    private ModulestudioFactory factory;
    private final String appName;
    private final Document document;

    public XmlImporter(String fileName) throws Exception {
        if (fileName.isEmpty()) {
            throw new Exception(
                    "Error: invalid filename given. Please provide an xml file.");
        }
        final XmlReader xmlReader = new XmlReader(fileName);
        final String fileNameParts[] = fileName.split("/");
        appName = convertToCamelCase(fileNameParts[fileNameParts.length - 1]
                .replaceAll(" ", "").replaceAll(".xml", ""));
        document = xmlReader.getDocument();
    }

    public void process() {
        createModel();
        processElements();
        saveModel();
    }

    /**
     * Create basic model instance and set basic properties.
     */
    private void createModel() {
        // Initialise the model
        ModulestudioPackage.eINSTANCE.eClass();
        // Retrieve the default factory singleton
        factory = ModulestudioFactory.eINSTANCE;

        // Create initial model content
        app = factory.createApplication();
        app.setName(appName);

        final Models modelContainer = factory.createModels();
        modelContainer.setName("Model");
        app.getModels().add(modelContainer);

        final Controllers controllerContainer = factory.createControllers();
        controllerContainer.setName("Controller");
        app.getControllers().add(controllerContainer);

        final Views viewContainer = factory.createViews();
        viewContainer.setName("View");
        app.getViews().add(viewContainer);

        controllerContainer.getModelContext().add(modelContainer);
        controllerContainer.setProcessViews(viewContainer);
    }

    private void processElements() {
        final NodeList nodes = document.getElementsByTagName("table");
        final Models modelContainer = app.getModels().get(0);

        for (Integer i = 0; i < nodes.getLength(); i++) {
            final Element table = (Element) nodes.item(i);
            final Entity entity = factory.createEntity();
            final NodeList fields = table.getElementsByTagName("column");

            String entityName = table.getAttribute("name");
            if (entityName.isEmpty() || fields.getLength() == 0) {
                continue;
            }

            if (entityName.isEmpty()) {
                entityName = "Table " + i.toString();
            }

            entity.setName(entityName);
            entity.setNameMultiple(entityName);

            entity.setAttributable(table.getAttribute("enableAttribution")
                    .equals("true"));
            entity.setCategorisable(table.getAttribute("enableCategorization")
                    .equals("true"));

            for (int j = 0; j < fields.getLength(); j++) {
                final Element fieldData = (Element) fields.item(j);
                if (isStandardField(fieldData.getAttribute("name"))) {
                    continue;
                }
                processField(entity, fieldData);
            }

            final NodeList indexes = table.getElementsByTagName("index");
            for (int j = 0; j < indexes.getLength(); j++) {
                final Element indexData = (Element) indexes.item(j);
                processIndex(entity, indexData);
            }
            modelContainer.getEntities().add(entity);
        }
    }

    private Boolean isStandardField(String fieldName) {
        return (fieldName.equals("obj_status") || fieldName.equals("cr_date")
                || fieldName.equals("cr_uid") || fieldName.equals("lu_date") || fieldName
                    .equals("lu_uid"));
    }

    private Boolean processField(Entity entity, Element fieldData) {
        final String fieldName = fieldData.getAttribute("name");
        final String fieldType = fieldData.getAttribute("type");
        final String fieldLength = fieldData.getAttribute("length");
        final String fieldNullable = fieldData.getAttribute("nullable");
        final String fieldDefault = fieldData.getAttribute("default");
        if (fieldName.isEmpty() || fieldType.isEmpty()
                || fieldNullable.isEmpty()) {
            return false;
        }

        if (fieldType.equals("BOOLEAN")) {
            final BooleanField field = factory.createBooleanField();
            setBasicFieldProperties(field, fieldData);
            entity.getFields().add(field);
        }
        else if (fieldType.equals("INT") || fieldType.equals("TINYINT")
                || fieldType.equals("SMALLINT")
                || fieldType.equals("MEDIUMINT") || fieldType.equals("BIGINT")) {
            final String fieldAutoInc = fieldData.getAttribute("autoincrement");
            final String fieldPrimary = fieldData.getAttribute("primary");

            if (fieldName.equals("uid") || fieldName.equals("userid")
                    || fieldName.equals("user_id") || fieldName.equals("user")) {
                UserField field;
                field = factory.createUserField();
                setBasicFieldProperties(field, fieldData);
                if (!fieldLength.isEmpty()) {
                    field.setLength(Integer.parseInt(fieldLength));
                }
                else {
                    field.setLength(getIntegerLength(fieldType));
                }
                field.setPrimaryKey((fieldPrimary.equals("true") && fieldAutoInc
                        .equals("true")));
                entity.getFields().add(field);
            }
            else {
                IntegerField field;
                field = factory.createIntegerField();
                setBasicFieldProperties(field, fieldData);
                if (!fieldLength.isEmpty()) {
                    field.setLength(Integer.parseInt(fieldLength));
                }
                else {
                    field.setLength(getIntegerLength(fieldType));
                }
                field.setPrimaryKey((fieldPrimary.equals("true") && fieldAutoInc
                        .equals("true")));
                entity.getFields().add(field);
            }
        }
        else if (fieldType.equals("VARCHAR")) {
            if (fieldName.equals("file") || fieldName.equals("filename")
                    || fieldName.equals("image")
                    || fieldName.equals("imagefile")
                    || fieldName.equals("upload")
                    || fieldName.equals("uploadfile")) {
                final UploadField field = factory.createUploadField();
                setBasicFieldProperties(field, fieldData);
                if (!fieldLength.isEmpty()) {
                    field.setLength(Integer.parseInt(fieldLength));
                }
                entity.getFields().add(field);
            }
            else if (fieldName.equals("email")
                    || fieldName.equals("emailaddress")) {
                final EmailField field = factory.createEmailField();
                setBasicFieldProperties(field, fieldData);
                if (!fieldLength.isEmpty()) {
                    field.setLength(Integer.parseInt(fieldLength));
                }
                entity.getFields().add(field);
            }
            else if (fieldName.equals("url") || fieldName.equals("homepage")) {
                final UrlField field = factory.createUrlField();
                setBasicFieldProperties(field, fieldData);
                if (!fieldLength.isEmpty()) {
                    field.setLength(Integer.parseInt(fieldLength));
                }
                entity.getFields().add(field);
            }
            else {
                final StringField field = factory.createStringField();
                setBasicFieldProperties(field, fieldData);
                if (!fieldLength.isEmpty()) {
                    field.setLength(Integer.parseInt(fieldLength));
                }
                if (fieldName.equals("country")) {
                    field.setCountry(true);
                    field.setNospace(true);
                }
                else if (fieldName.equals("colour")) {
                    field.setHtmlcolour(true);
                    field.setNospace(true);
                }
                else if (fieldName.equals("language")) {
                    field.setLanguage(true);
                    field.setNospace(true);
                }
                entity.getFields().add(field);
            }
        }
        else if (fieldType.equals("TEXT") || fieldType.equals("LONGTEXT")) {
            final TextField field = factory.createTextField();
            setBasicFieldProperties(field, fieldData);
            if (!fieldLength.isEmpty()) {
                field.setLength(Integer.parseInt(fieldLength));
            }
            entity.getFields().add(field);
        }
        else if (fieldType.equals("NUMERIC")) {
            final DecimalField field = factory.createDecimalField();
            setBasicFieldProperties(field, fieldData);
            if (!fieldLength.isEmpty()) {
                field.setLength(Integer.parseInt(fieldLength));
            }
            entity.getFields().add(field);
        }
        else if (fieldType.equals("FLOAT")) {
            final FloatField field = factory.createFloatField();
            setBasicFieldProperties(field, fieldData);
            if (!fieldLength.isEmpty()) {
                field.setLength(Integer.parseInt(fieldLength));
            }
            entity.getFields().add(field);
        }
        else if (fieldType.equals("DATETIME")) {
            final DatetimeField field = factory.createDatetimeField();
            setBasicFieldProperties(field, fieldData);
            entity.getFields().add(field);
        }
        else if (fieldType.equals("DATE")) {
            final DateField field = factory.createDateField();
            setBasicFieldProperties(field, fieldData);
            entity.getFields().add(field);
        }
        return true;
    }

    private Integer getIntegerLength(String fieldType) {
        if (fieldType.equals("INT")) {
            return 4;
        }
        if (fieldType.equals("TINYINT")) {
            return 1;
        }
        if (fieldType.equals("SMALLINT")) {
            return 2;
        }
        if (fieldType.equals("MEDIUMINT")) {
            return 4;
        }
        if (fieldType.equals("BIGINT")) {
            return 8;
        }
        return 10;
    }

    private void setBasicFieldProperties(DerivedField field, Element fieldData) {
        final String fieldName = convertToCamelCase(fieldData
                .getAttribute("name"));
        final String fieldType = fieldData.getAttribute("type");
        final String fieldNullable = fieldData.getAttribute("nullable");
        final String fieldDefault = fieldData.getAttribute("default");
        final Boolean isDateField = fieldType.equals("DATETIME")
                || fieldType.equals("DATE");
        field.setName(fieldName);
        field.setNullable(fieldNullable.equals("true"));
        if (!fieldDefault.isEmpty() && !fieldDefault.equals("''")
                && !fieldDefault.equals("NULL")) {
            if (fieldType.equals("BOOLEAN")) {
                final Boolean isSet = fieldDefault.equals("true")
                        || fieldDefault.equals("1");
                field.setDefaultValue((isSet) ? "true" : "false");
            }
            else if (!(isDateField && fieldDefault.equals("DEFTIMESTAMP"))) {
                field.setDefaultValue(fieldDefault);
            }
        }
    }

    private String convertToCamelCase(String fieldName) {
        if (!fieldName.contains("_")) {
            return fieldName;
        }

        final String result = "";
        final String fieldNameParts[] = fieldName.split("_");
        final StringBuilder sb = new StringBuilder();
        for (final String fieldNamePart : fieldNameParts) {
            sb.append(fieldNamePart.substring(0, 1).toUpperCase());
            sb.append(fieldNamePart.substring(1).toLowerCase());
        }
        return sb.toString();
    }

    private Boolean processIndex(Entity entity, Element indexData) {
        final String indexName = indexData.getAttribute("name");
        final String indexFieldList = indexData.getAttribute("fields");
        if (indexName.isEmpty() || indexFieldList.isEmpty()) {
            return false;
        }
        final String[] indexFields = indexFieldList.split(",");
        final EntityIndex index = factory.createEntityIndex();
        index.setName(indexName);
        for (final String indexField : indexFields) {
            final EntityIndexItem indexItem = factory.createEntityIndexItem();
            indexItem.setName(indexField);
            index.getItems().add(indexItem);
        }
        entity.getIndexes().add(index);
        return true;
    }

    /**
     * Save the created model content to a .mostapp file.
     */
    private void saveModel() {
        // Obtain a new resource set
        final ResourceSet resourceSet = new ResourceSetImpl();

        resourceSet.getResourceFactoryRegistry().getExtensionToFactoryMap()
                .put("mostapp", new GMFResourceFactory());
        resourceSet.getPackageRegistry().put(ModulestudioPackage.eNS_URI,
                ModulestudioPackage.eINSTANCE);

        // Create a resource
        final Resource resource = resourceSet.createResource(URI
                .createURI("MOST_output/" + appName + ".mostapp"));
        // Get the first model element and cast it to the right type, in my
        // example everything is hierarchical included in this first node
        resource.getContents().add(app);

        // Now save the content.
        try {
            resource.save(Collections.EMPTY_MAP);
        } catch (final IOException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
    }
}

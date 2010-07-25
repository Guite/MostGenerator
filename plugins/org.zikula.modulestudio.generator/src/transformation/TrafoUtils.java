package transformation;

import de.guite.modulestudio.metamodel.modulestudio.Entity;
import de.guite.modulestudio.metamodel.modulestudio.IntegerField;
import de.guite.modulestudio.metamodel.modulestudio.ModulestudioFactory;
import de.guite.modulestudio.metamodel.modulestudio.Relationship;
import de.guite.modulestudio.metamodel.modulestudio.impl.ModulestudioFactoryImpl;
import extensions.Utils;

/*
 * various helper functions sharing common naming conventions and so on
 */

public class TrafoUtils {

    /**
     * add a primary key to a table
     * 
     * @params Entity given Entity instance
     * @return flag if insertion was sucessful
     */
    public static boolean addPrimaryKey(Entity entity) {
        try {
            entity.getFields().add(0, createIDColumn(entity.getName(), true));
        } catch (Exception e) {
            return false;
        } finally {
            // nothing to do here (yet)
        }
        return true;
    }

    /**
     * add a relation id fields to a table
     * 
     * @params Entity given Entity instance
     * @return flag if process was sucessful
     */
    public static boolean addRelationFields(Entity entity) {
        try {
            for (Object element : entity.getIncoming()) {
                Relationship rel = (Relationship) element;
                entity.getFields().add(
                        createIDColumn(rel.getSource().getName(), false));
            }
        } catch (Exception e) {
            return false;
        } finally {
            // nothing to do here (yet)
        }
        return true;
    }

    private static IntegerField createIDColumn(String colName, Boolean isPrimary) {
        ModulestudioFactory factory = new ModulestudioFactoryImpl();
        IntegerField idField = factory.createIntegerField();
        idField.setName(Utils.dbName(colName + "id"));
        idField.setPrimaryKey(isPrimary);
        idField.setLength(11);
        return idField;
    }
}

package transformation;

import de.guite.modulestudio.metamodel.modulestudio.Entity;
import de.guite.modulestudio.metamodel.modulestudio.IntegerField;
import de.guite.modulestudio.metamodel.modulestudio.JoinRelationship;
import de.guite.modulestudio.metamodel.modulestudio.ModulestudioFactory;
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
        } catch (final Exception e) {
            return false;
        } finally {
            // nothing to do here (yet)
        }
        return true;
    }

    /**
     * add a relation id fields to a table
     * 
     * @param JoinRelationship
     *            the relationship to be referenced
     * @params Entity given Entity instance
     * @return flag if process was sucessful
     */
    public static boolean addRelationField(JoinRelationship rel, Entity entity) {
        try {
            final String idFieldName = rel.getSource().getName() + "id";
            if (rel.getTargetField() == "id"
                    || rel.getTargetField() == idFieldName) {
                entity.getFields().add(
                        createIDColumn(rel.getSource().getName(), false));
            }
        } catch (final Exception e) {
            return false;
        } finally {
            // nothing to do here (yet)
        }
        return true;
    }

    private static IntegerField createIDColumn(String colName, Boolean isPrimary) {
        final ModulestudioFactory factory = new ModulestudioFactoryImpl();
        final IntegerField idField = factory.createIntegerField();
        idField.setName(Utils.formatForDB(colName) + "id");
        idField.setLength(11);
        idField.setPrimaryKey(isPrimary);
        idField.setUnique(isPrimary);
        idField.setUnsigned(true);
        return idField;
    }
}

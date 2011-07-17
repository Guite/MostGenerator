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
     * @param Entity
     *            given Entity instance
     * @return flag if insertion was successful
     */
    public static boolean addPrimaryKey(Entity entity) {
        try {
            entity.getFields().add(0,
                    createIDColumn(/* entity.getName() */"", true));
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
     * @param Entity
     *            given Entity instance
     * @return flag if process was successful
     */
    public static boolean addRelationField(JoinRelationship rel, Entity entity) {
        try {
            final String fieldName = Utils.formatForCode(rel.getSource()
                    .getName());
            final String[] targetFieldParts = rel.getTargetField().split(", ");
            for (final String singleField : targetFieldParts) {
                if (singleField == "id" || singleField == fieldName + "id"
                        || singleField == fieldName + "_id") {
                    entity.getFields().add(
                            createIDColumn(rel.getSource().getName(), false));
                }
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
        if (isPrimary) {
            idField.setName("id");
        }
        else {
            idField.setName(Utils.formatForCode(colName) + "_id");
        }
        idField.setLength(9);
        idField.setPrimaryKey(isPrimary);
        idField.setUnique(isPrimary);
        return idField;
    }
}

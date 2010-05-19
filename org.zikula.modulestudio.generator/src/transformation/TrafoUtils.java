package transformation;

import java.util.Iterator;

import de.guite.modulestudio.metamodel.persistence.IntegerField;
import de.guite.modulestudio.metamodel.persistence.PersistenceContainer;
import de.guite.modulestudio.metamodel.persistence.PersistenceFactory;
import de.guite.modulestudio.metamodel.persistence.Relationship;
import de.guite.modulestudio.metamodel.persistence.Table;
import de.guite.modulestudio.metamodel.persistence.impl.PersistenceFactoryImpl;
import extensions.Utils;

/*
 * various helper functions sharing common naming conventions and so on
 */

public class TrafoUtils {

	/**
	 * add a primary key to a table
	 * 
	 * @params    Table          given Table instance
	 * @return                   flag if insertion was sucessful
	 */
	public static boolean addPrimaryKey(Table table) {
		try {
			table.getColumns().add(0, createIDColumn(table.getName(), true));
		}
		catch (Exception e) {
			return false;
		}
		finally {}
		return true;
	}

	/**
	 * add a relation id fields to a table
	 * 
	 * @params    Table          given Table instance
	 * @return                   flag if process was sucessful
	 */
	public static boolean addRelationFields(Table table) {
		try {
			PersistenceContainer container = table.getTableContainer();
			for (Iterator relIter = container.getRelations().iterator(); relIter.hasNext();) {
				Relationship rel = (Relationship) relIter.next();
				if (rel.getTarget().equals(table)) {
					table.getColumns().add(createIDColumn(rel.getSource().getName(), false));
				}
			}
		}
		catch (Exception e) {
			return false;
		}
		finally {}
		return true;
	}

	private static IntegerField createIDColumn(String colName, Boolean isPrimary) {
		PersistenceFactory factory = new PersistenceFactoryImpl();
		IntegerField idField = factory.createIntegerField();
		idField.setName(Utils.dbName(colName + "id"));
		idField.setIsPrimaryKey(isPrimary);
		idField.setLength(11);
		return idField;
	}

}
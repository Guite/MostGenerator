package org.zikula.modulestudio.generator.extensions;

import com.google.common.base.Objects;
import com.google.common.collect.Iterables;
import de.guite.modulestudio.metamodel.Application;
import de.guite.modulestudio.metamodel.Entity;
import de.guite.modulestudio.metamodel.JoinRelationship;
import java.util.ArrayList;
import org.eclipse.xtext.xbase.lib.CollectionLiterals;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.zikula.modulestudio.generator.extensions.ControllerExtensions;
import org.zikula.modulestudio.generator.extensions.GeneratorSettingsExtensions;

/**
 * This class contains view related extension methods.
 */
@SuppressWarnings("all")
public class ViewExtensions {
  @Extension
  private ControllerExtensions _controllerExtensions = new ControllerExtensions();
  
  @Extension
  private GeneratorSettingsExtensions _generatorSettingsExtensions = new GeneratorSettingsExtensions();
  
  /**
   * Determines whether grouping tabs are generated or not.
   * 
   * @param it Given {@link Entity} instance.
   * @param page The page template name.
   * 
   * @return Boolean The result.
   */
  public boolean useGroupingTabs(final Entity it, final String page) {
    return ((!it.isGeographical()) && (this.panelWeight(it, page) > 3));
  }
  
  /**
   * Determines if a given relationship is part
   * of an edit form or not.
   * 
   * @param it Given {@link JoinRelationship} instance.
   * @param useTarget Whether the target side or the source side should be used.
   * 
   * @return Boolean The determined result.
   */
  private boolean isPartOfEditForm(final JoinRelationship it, final Boolean useTarget) {
    int _editStageCode = this._controllerExtensions.getEditStageCode(it, Boolean.valueOf((!(useTarget).booleanValue())));
    return (_editStageCode > 0);
  }
  
  /**
   * Counts the amount of visible groups of a given {@link Entity}
   * for display and edit pages.
   * 
   * @param it Given {@link Entity} instance.
   * @param page The page template name.
   * 
   * @return Integer The resulting panel weight.
   */
  private int panelWeight(final Entity it, final String page) {
    int _xblockexpression = (int) 0;
    {
      int weight = 1;
      if ((Objects.equal(page, "edit") && (IterableExtensions.size(IterableExtensions.<JoinRelationship>filter(Iterables.<JoinRelationship>filter(it.getIncoming(), JoinRelationship.class), ((Function1<JoinRelationship, Boolean>) (JoinRelationship it_1) -> {
        return Boolean.valueOf(this.isPartOfEditForm(it_1, Boolean.valueOf(true)));
      }))) > 1))) {
        weight = (weight + 1);
      }
      if ((Objects.equal(page, "edit") && (IterableExtensions.size(IterableExtensions.<JoinRelationship>filter(Iterables.<JoinRelationship>filter(it.getOutgoing(), JoinRelationship.class), ((Function1<JoinRelationship, Boolean>) (JoinRelationship it_1) -> {
        return Boolean.valueOf(this.isPartOfEditForm(it_1, Boolean.valueOf(false)));
      }))) > 1))) {
        weight = (weight + 1);
      }
      boolean _isAttributable = it.isAttributable();
      if (_isAttributable) {
        weight = (weight + 1);
      }
      boolean _isCategorisable = it.isCategorisable();
      if (_isCategorisable) {
        weight = (weight + 1);
      }
      boolean _isStandardFields = it.isStandardFields();
      if (_isStandardFields) {
        weight = (weight + 1);
      }
      boolean _isGeographical = it.isGeographical();
      if (_isGeographical) {
        weight = (weight + 1);
      }
      _xblockexpression = weight;
    }
    return _xblockexpression;
  }
  
  /**
   * Returns a list of view formats supported by an application.
   */
  public ArrayList<String> getListOfViewFormats(final Application it) {
    ArrayList<String> _xblockexpression = null;
    {
      ArrayList<String> formats = CollectionLiterals.<String>newArrayList();
      boolean _generateCsvTemplates = this._generatorSettingsExtensions.generateCsvTemplates(it);
      if (_generateCsvTemplates) {
        formats.add("csv");
      }
      boolean _generateRssTemplates = this._generatorSettingsExtensions.generateRssTemplates(it);
      if (_generateRssTemplates) {
        formats.add("rss");
      }
      boolean _generateAtomTemplates = this._generatorSettingsExtensions.generateAtomTemplates(it);
      if (_generateAtomTemplates) {
        formats.add("atom");
      }
      boolean _generateXmlTemplates = this._generatorSettingsExtensions.generateXmlTemplates(it);
      if (_generateXmlTemplates) {
        formats.add("xml");
      }
      boolean _generateJsonTemplates = this._generatorSettingsExtensions.generateJsonTemplates(it);
      if (_generateJsonTemplates) {
        formats.add("json");
      }
      boolean _generateKmlTemplates = this._generatorSettingsExtensions.generateKmlTemplates(it);
      if (_generateKmlTemplates) {
        formats.add("kml");
      }
      _xblockexpression = formats;
    }
    return _xblockexpression;
  }
  
  /**
   * Returns a list of display formats supported by an application.
   */
  public ArrayList<String> getListOfDisplayFormats(final Application it) {
    ArrayList<String> _xblockexpression = null;
    {
      ArrayList<String> formats = CollectionLiterals.<String>newArrayList();
      boolean _generateXmlTemplates = this._generatorSettingsExtensions.generateXmlTemplates(it);
      if (_generateXmlTemplates) {
        formats.add("xml");
      }
      boolean _generateJsonTemplates = this._generatorSettingsExtensions.generateJsonTemplates(it);
      if (_generateJsonTemplates) {
        formats.add("json");
      }
      boolean _generateKmlTemplates = this._generatorSettingsExtensions.generateKmlTemplates(it);
      if (_generateKmlTemplates) {
        formats.add("kml");
      }
      boolean _generateIcsTemplates = this._generatorSettingsExtensions.generateIcsTemplates(it);
      if (_generateIcsTemplates) {
        formats.add("ics");
      }
      _xblockexpression = formats;
    }
    return _xblockexpression;
  }
}

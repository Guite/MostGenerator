package org.zikula.modulestudio.generator.extensions;

import de.guite.modulestudio.metamodel.Application;
import de.guite.modulestudio.metamodel.CoreVersion;
import de.guite.modulestudio.metamodel.SettingsContainer;
import java.util.List;
import org.eclipse.xtext.xbase.lib.CollectionLiterals;
import org.eclipse.xtext.xbase.lib.Conversions;
import org.eclipse.xtext.xbase.lib.ExclusiveRange;
import org.eclipse.xtext.xbase.lib.IterableExtensions;

/**
 * This class contains several helper functions for accessing and using generator settings.
 */
@SuppressWarnings("all")
public class GeneratorSettingsExtensions {
  /**
   * Retrieves the target core version.
   */
  public CoreVersion getCoreVersion(final Application it) {
    CoreVersion _xifexpression = null;
    boolean _hasSettings = this.hasSettings(it);
    if (_hasSettings) {
      _xifexpression = this.getSettings(it).getTargetCoreVersion();
    } else {
      _xifexpression = CoreVersion.ZK14;
    }
    return _xifexpression;
  }
  
  /**
   * Determines whether the model describes a system module or not.
   */
  public boolean isSystemModule(final Application it) {
    boolean _xifexpression = false;
    boolean _hasSettings = this.hasSettings(it);
    if (_hasSettings) {
      _xifexpression = this.getSettings(it).isIsSystemModule();
    } else {
      _xifexpression = false;
    }
    return _xifexpression;
  }
  
  /**
   * Returns the desired amount of example rows created during installation.
   */
  public int amountOfExampleRows(final Application it) {
    int _xifexpression = (int) 0;
    boolean _hasSettings = this.hasSettings(it);
    if (_hasSettings) {
      _xifexpression = this.getSettings(it).getAmountOfExampleRows();
    } else {
      _xifexpression = 0;
    }
    return _xifexpression;
  }
  
  /**
   * Determines whether account panel integration should be generated or not.
   */
  public boolean generateAccountApi(final Application it) {
    boolean _xifexpression = false;
    boolean _hasSettings = this.hasSettings(it);
    if (_hasSettings) {
      _xifexpression = this.getSettings(it).isGenerateAccountApi();
    } else {
      _xifexpression = true;
    }
    return _xifexpression;
  }
  
  /**
   * Determines whether search integration should be generated or not.
   */
  public boolean generateSearchApi(final Application it) {
    boolean _xifexpression = false;
    boolean _hasSettings = this.hasSettings(it);
    if (_hasSettings) {
      _xifexpression = this.getSettings(it).isGenerateSearchApi();
    } else {
      _xifexpression = true;
    }
    return _xifexpression;
  }
  
  /**
   * Determines whether Mailz support should be generated or not.
   */
  public boolean generateMailzApi(final Application it) {
    boolean _xifexpression = false;
    boolean _hasSettings = this.hasSettings(it);
    if (_hasSettings) {
      _xifexpression = this.getSettings(it).isGenerateMailzApi();
    } else {
      _xifexpression = false;
    }
    return _xifexpression;
  }
  
  /**
   * Determines whether a generic list block should be generated or not.
   */
  public boolean generateListBlock(final Application it) {
    boolean _xifexpression = false;
    boolean _hasSettings = this.hasSettings(it);
    if (_hasSettings) {
      _xifexpression = this.getSettings(it).isGenerateListBlock();
    } else {
      _xifexpression = true;
    }
    return _xifexpression;
  }
  
  /**
   * Determines whether a moderation block should be generated or not.
   */
  public boolean generateModerationBlock(final Application it) {
    boolean _xifexpression = false;
    boolean _hasSettings = this.hasSettings(it);
    if (_hasSettings) {
      _xifexpression = this.getSettings(it).isGenerateModerationBlock();
    } else {
      _xifexpression = true;
    }
    return _xifexpression;
  }
  
  /**
   * Determines whether a content type for collection lists should be generated or not.
   */
  public boolean generateListContentType(final Application it) {
    boolean _xifexpression = false;
    boolean _hasSettings = this.hasSettings(it);
    if (_hasSettings) {
      _xifexpression = this.getSettings(it).isGenerateListContentType();
    } else {
      _xifexpression = true;
    }
    return _xifexpression;
  }
  
  /**
   * Determines whether a content type for single objects should be generated or not.
   */
  public boolean generateDetailContentType(final Application it) {
    boolean _xifexpression = false;
    boolean _hasSettings = this.hasSettings(it);
    if (_hasSettings) {
      _xifexpression = this.getSettings(it).isGenerateDetailContentType();
    } else {
      _xifexpression = true;
    }
    return _xifexpression;
  }
  
  /**
   * Determines whether a Newsletter plugin should be generated or not.
   */
  public boolean generateNewsletterPlugin(final Application it) {
    boolean _xifexpression = false;
    boolean _hasSettings = this.hasSettings(it);
    if (_hasSettings) {
      _xifexpression = this.getSettings(it).isGenerateNewsletterPlugin();
    } else {
      _xifexpression = false;
    }
    return _xifexpression;
  }
  
  /**
   * Determines whether a moderation panel should be generated or not.
   */
  public boolean generateModerationPanel(final Application it) {
    boolean _xifexpression = false;
    boolean _hasSettings = this.hasSettings(it);
    if (_hasSettings) {
      _xifexpression = this.getSettings(it).isGenerateModerationPanel();
    } else {
      _xifexpression = true;
    }
    return _xifexpression;
  }
  
  /**
   * Determines whether support for pending content should be generated or not.
   */
  public boolean generatePendingContentSupport(final Application it) {
    boolean _xifexpression = false;
    boolean _hasSettings = this.hasSettings(it);
    if (_hasSettings) {
      _xifexpression = this.getSettings(it).isGeneratePendingContentSupport();
    } else {
      _xifexpression = true;
    }
    return _xifexpression;
  }
  
  /**
   * Determines whether a controller for external calls providing a generic finder component should be generated or not.
   */
  public boolean generateExternalControllerAndFinder(final Application it) {
    boolean _xifexpression = false;
    boolean _hasSettings = this.hasSettings(it);
    if (_hasSettings) {
      _xifexpression = this.getSettings(it).isGenerateExternalControllerAndFinder();
    } else {
      _xifexpression = true;
    }
    return _xifexpression;
  }
  
  /**
   * Determines whether support for several Scribite editors should be generated or not.
   */
  public boolean generateScribitePlugins(final Application it) {
    boolean _xifexpression = false;
    boolean _hasSettings = this.hasSettings(it);
    if (_hasSettings) {
      _xifexpression = this.getSettings(it).isGenerateScribitePlugins();
    } else {
      _xifexpression = true;
    }
    return _xifexpression;
  }
  
  /**
   * Determines whether tag support should be generated or not.
   */
  public boolean generateTagSupport(final Application it) {
    boolean _xifexpression = false;
    boolean _hasSettings = this.hasSettings(it);
    if (_hasSettings) {
      _xifexpression = this.getSettings(it).isGenerateTagSupport();
    } else {
      _xifexpression = false;
    }
    return _xifexpression;
  }
  
  /**
   * Determines whether MultiHook needles should be generated or not.
   */
  public boolean generateMultiHookNeedles(final Application it) {
    boolean _xifexpression = false;
    boolean _hasSettings = this.hasSettings(it);
    if (_hasSettings) {
      _xifexpression = this.getSettings(it).isGenerateMultiHookNeedles();
    } else {
      _xifexpression = false;
    }
    return _xifexpression;
  }
  
  /**
   * Determines whether rss view templates should be generated or not.
   */
  public boolean generateRssTemplates(final Application it) {
    boolean _xifexpression = false;
    boolean _hasSettings = this.hasSettings(it);
    if (_hasSettings) {
      _xifexpression = this.getSettings(it).isGenerateRssTemplates();
    } else {
      _xifexpression = true;
    }
    return _xifexpression;
  }
  
  /**
   * Determines whether atom view templates should be generated or not.
   */
  public boolean generateAtomTemplates(final Application it) {
    boolean _xifexpression = false;
    boolean _hasSettings = this.hasSettings(it);
    if (_hasSettings) {
      _xifexpression = this.getSettings(it).isGenerateAtomTemplates();
    } else {
      _xifexpression = true;
    }
    return _xifexpression;
  }
  
  /**
   * Determines whether csv view templates should be generated or not.
   */
  public boolean generateCsvTemplates(final Application it) {
    boolean _xifexpression = false;
    boolean _hasSettings = this.hasSettings(it);
    if (_hasSettings) {
      _xifexpression = this.getSettings(it).isGenerateCsvTemplates();
    } else {
      _xifexpression = true;
    }
    return _xifexpression;
  }
  
  /**
   * Determines whether xml display and view templates should be generated or not.
   */
  public boolean generateXmlTemplates(final Application it) {
    boolean _xifexpression = false;
    boolean _hasSettings = this.hasSettings(it);
    if (_hasSettings) {
      _xifexpression = this.getSettings(it).isGenerateXmlTemplates();
    } else {
      _xifexpression = true;
    }
    return _xifexpression;
  }
  
  /**
   * Determines whether json templates should be generated or not.
   */
  public boolean generateJsonTemplates(final Application it) {
    boolean _xifexpression = false;
    boolean _hasSettings = this.hasSettings(it);
    if (_hasSettings) {
      _xifexpression = this.getSettings(it).isGenerateJsonTemplates();
    } else {
      _xifexpression = true;
    }
    return _xifexpression;
  }
  
  /**
   * Determines whether kml templates should be generated or not.
   */
  public boolean generateKmlTemplates(final Application it) {
    boolean _xifexpression = false;
    boolean _hasSettings = this.hasSettings(it);
    if (_hasSettings) {
      _xifexpression = this.getSettings(it).isGenerateKmlTemplates();
    } else {
      _xifexpression = true;
    }
    return _xifexpression;
  }
  
  /**
   * Determines whether ics templates should be generated or not.
   */
  public boolean generateIcsTemplates(final Application it) {
    boolean _xifexpression = false;
    boolean _hasSettings = this.hasSettings(it);
    if (_hasSettings) {
      _xifexpression = this.getSettings(it).isGenerateIcsTemplates();
    } else {
      _xifexpression = true;
    }
    return _xifexpression;
  }
  
  /**
   * Determines whether only base classes should be generated.
   */
  public boolean generateOnlyBaseClasses(final Application it) {
    boolean _xifexpression = false;
    boolean _hasSettings = this.hasSettings(it);
    if (_hasSettings) {
      _xifexpression = this.getSettings(it).isGenerateOnlyBaseClasses();
    } else {
      _xifexpression = false;
    }
    return _xifexpression;
  }
  
  /**
   * Determines a blacklist with each entry representing a file which should not be generated.
   */
  public List<String> getListOfFilesToBeSkipped(final Application it) {
    List<String> _xifexpression = null;
    if ((this.hasSettings(it) && (null != this.getSettings(it).getSkipFiles()))) {
      _xifexpression = this.getListOfAffectedFiles(this.getSettings(it).getSkipFiles());
    } else {
      _xifexpression = CollectionLiterals.<String>newArrayList("");
    }
    return _xifexpression;
  }
  
  /**
   * Determines a list with file pathes which should be marked by special file names.
   */
  public List<String> getListOfFilesToBeMarked(final Application it) {
    List<String> _xifexpression = null;
    if ((this.hasSettings(it) && (null != this.getSettings(it).getMarkFiles()))) {
      _xifexpression = this.getListOfAffectedFiles(this.getSettings(it).getMarkFiles());
    } else {
      _xifexpression = CollectionLiterals.<String>newArrayList("");
    }
    return _xifexpression;
  }
  
  /**
   * Prepares a list of file pathes for further processing.
   */
  private List<String> getListOfAffectedFiles(final String setting) {
    List<String> _xblockexpression = null;
    {
      List<String> list = IterableExtensions.<String>toList(((Iterable<String>)Conversions.doWrapArray(setting.replace("\t", "").replace("\n", "").split(","))));
      int _size = list.size();
      ExclusiveRange _doubleDotLessThan = new ExclusiveRange(0, _size, true);
      for (final Integer i : _doubleDotLessThan) {
        list.set((i).intValue(), list.get((i).intValue()).trim());
      }
      _xblockexpression = list;
    }
    return _xblockexpression;
  }
  
  /**
   * Determines whether the generated by message should contain a timestamp
   * in all files or only in the Version class.
   */
  public boolean timestampAllGeneratedFiles(final Application it) {
    boolean _xifexpression = false;
    boolean _hasSettings = this.hasSettings(it);
    if (_hasSettings) {
      _xifexpression = this.getSettings(it).isTimestampAllGeneratedFiles();
    } else {
      _xifexpression = false;
    }
    return _xifexpression;
  }
  
  /**
   * Determines whether the generated by message should contain the
   * ModuleStudio version in all files or only in the Version class.
   */
  public boolean versionAllGeneratedFiles(final Application it) {
    boolean _xifexpression = false;
    boolean _hasSettings = this.hasSettings(it);
    if (_hasSettings) {
      _xifexpression = this.getSettings(it).isVersionAllGeneratedFiles();
    } else {
      _xifexpression = true;
    }
    return _xifexpression;
  }
  
  /**
   * Determines whether generated footer templates should contain backlinks
   * to the ModuleStudio homepage.
   */
  public boolean generatePoweredByBacklinksIntoFooterTemplates(final Application it) {
    boolean _xifexpression = false;
    boolean _hasSettings = this.hasSettings(it);
    if (_hasSettings) {
      _xifexpression = this.getSettings(it).isGeneratePoweredByBacklinksIntoFooterTemplates();
    } else {
      _xifexpression = true;
    }
    return _xifexpression;
  }
  
  /**
   * Determines whether test cases should be generated or not.
   */
  public boolean generateTests(final Application it) {
    boolean _xifexpression = false;
    boolean _hasSettings = this.hasSettings(it);
    if (_hasSettings) {
      _xifexpression = this.getSettings(it).isGenerateTests();
    } else {
      _xifexpression = true;
    }
    return _xifexpression;
  }
  
  /**
   * Determines whether the model should be written into the docs folder or not.
   */
  public boolean writeModelToDocs(final Application it) {
    boolean _xifexpression = false;
    boolean _hasSettings = this.hasSettings(it);
    if (_hasSettings) {
      _xifexpression = this.getSettings(it).isWriteModelToDocs();
    } else {
      _xifexpression = false;
    }
    return _xifexpression;
  }
  
  /**
   * Retrieves the SettingsContainer if present.
   */
  private SettingsContainer getSettings(final Application it) {
    SettingsContainer _xifexpression = null;
    boolean _hasSettings = this.hasSettings(it);
    if (_hasSettings) {
      _xifexpression = IterableExtensions.<SettingsContainer>head(it.getGeneratorSettings());
    } else {
      _xifexpression = null;
    }
    return _xifexpression;
  }
  
  /**
   * Determines whether the given Application instance has a settings container
   * or not.
   */
  private boolean hasSettings(final Application it) {
    boolean _isEmpty = it.getGeneratorSettings().isEmpty();
    return (!_isEmpty);
  }
}

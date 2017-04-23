package org.zikula.modulestudio.generator.cartridges.zclassic.models.repository;

import de.guite.modulestudio.metamodel.Application;
import de.guite.modulestudio.metamodel.ManyToManyRelationship;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class LinkTable {
  @Extension
  private FormattingExtensions _formattingExtensions = new FormattingExtensions();
  
  @Extension
  private NamingExtensions _namingExtensions = new NamingExtensions();
  
  @Extension
  private Utils _utils = new Utils();
  
  private FileHelper fh = new FileHelper();
  
  /**
   * Creates a reference table class file for every many-to-many relationship instance.
   */
  public void generate(final ManyToManyRelationship it, final Application app, final IFileSystemAccess fsa) {
    String _appSourceLibPath = this._namingExtensions.getAppSourceLibPath(app);
    String _plus = (_appSourceLibPath + "Entity/Repository/");
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(it.getRefClass());
    String _plus_1 = (_plus + _formatForCodeCapital);
    String _plus_2 = (_plus_1 + "Repository.php");
    this._namingExtensions.generateClassPair(app, fsa, _plus_2, 
      this.fh.phpFileContent(app, this.modelRefRepositoryBaseImpl(it, app)), this.fh.phpFileContent(app, this.modelRefRepositoryImpl(it, app)));
  }
  
  private CharSequence modelRefRepositoryBaseImpl(final ManyToManyRelationship it, final Application app) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("namespace ");
    String _appNamespace = this._utils.appNamespace(app);
    _builder.append(_appNamespace);
    _builder.append("\\Entity\\Repository\\Base;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("use Doctrine\\ORM\\EntityRepository;");
    _builder.newLine();
    _builder.append("use Psr\\Log\\LoggerInterface;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Repository class used to implement own convenience methods for performing certain DQL queries.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* This is the base repository class for the many to many relationship");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* between ");
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(it.getSource().getName());
    _builder.append(_formatForDisplay, " ");
    _builder.append(" and ");
    String _formatForDisplay_1 = this._formattingExtensions.formatForDisplay(it.getTarget().getName());
    _builder.append(_formatForDisplay_1, " ");
    _builder.append(" entities.");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("class Abstract");
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(it.getRefClass());
    _builder.append(_formatForCodeCapital);
    _builder.append("Repository extends EntityRepository");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* Deletes all items in this table.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @param LoggerInterface $logger Logger service instance");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("public function truncateTable(LoggerInterface $logger)");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$qb = $this->getEntityManager()->createQueryBuilder();");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$qb->delete(\'\\\\");
    String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(app.getVendor());
    _builder.append(_formatForCodeCapital_1, "        ");
    _builder.append("\\\\");
    String _formatForCodeCapital_2 = this._formattingExtensions.formatForCodeCapital(app.getName());
    _builder.append(_formatForCodeCapital_2, "        ");
    _builder.append("Module\\\\Entity\\\\");
    String _formatForCodeCapital_3 = this._formattingExtensions.formatForCodeCapital(it.getRefClass());
    _builder.append(_formatForCodeCapital_3, "        ");
    _builder.append("\', \'tbl\');");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("$query = $qb->getQuery();");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$query->execute();");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$logArgs = [\'app\' => \'");
    String _appName = this._utils.appName(app);
    _builder.append(_appName, "        ");
    _builder.append("\', \'entity\' => \'");
    String _formatForDisplay_2 = this._formattingExtensions.formatForDisplay(it.getRefClass());
    _builder.append(_formatForDisplay_2, "        ");
    _builder.append("\'];");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("$logger->debug(\'{app}: Truncated the {entity} entity table.\', $logArgs);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence modelRefRepositoryImpl(final ManyToManyRelationship it, final Application app) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("namespace ");
    String _appNamespace = this._utils.appNamespace(app);
    _builder.append(_appNamespace);
    _builder.append("\\Entity\\Repository;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("use ");
    String _appNamespace_1 = this._utils.appNamespace(app);
    _builder.append(_appNamespace_1);
    _builder.append("\\Entity\\Repository\\Base\\Abstract");
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(it.getRefClass());
    _builder.append(_formatForCodeCapital);
    _builder.append("Repository;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Repository class used to implement own convenience methods for performing certain DQL queries.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* This is the concrete repository class for the many to many relationship");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* between ");
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(it.getSource().getName());
    _builder.append(_formatForDisplay, " ");
    _builder.append(" and ");
    String _formatForDisplay_1 = this._formattingExtensions.formatForDisplay(it.getTarget().getName());
    _builder.append(_formatForDisplay_1, " ");
    _builder.append(" entities.");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("class ");
    String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(it.getRefClass());
    _builder.append(_formatForCodeCapital_1);
    _builder.append("Repository extends Abstract");
    String _formatForCodeCapital_2 = this._formattingExtensions.formatForCodeCapital(it.getRefClass());
    _builder.append(_formatForCodeCapital_2);
    _builder.append("Repository");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// feel free to add your own methods here, like for example reusable DQL queries");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
}

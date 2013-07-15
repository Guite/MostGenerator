package org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff;

import com.google.inject.Inject;
import de.guite.modulestudio.metamodel.modulestudio.Application;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class PhpUnitXmlDist {
  @Inject
  @Extension
  private NamingExtensions _namingExtensions = new Function0<NamingExtensions>() {
    public NamingExtensions apply() {
      NamingExtensions _namingExtensions = new NamingExtensions();
      return _namingExtensions;
    }
  }.apply();
  
  @Inject
  @Extension
  private Utils _utils = new Function0<Utils>() {
    public Utils apply() {
      Utils _utils = new Utils();
      return _utils;
    }
  }.apply();
  
  public void generate(final Application it, final IFileSystemAccess fsa) {
    boolean _targets = this._utils.targets(it, "1.3.5");
    if (_targets) {
      return;
    }
    String _appSourcePath = this._namingExtensions.getAppSourcePath(it);
    String _plus = (_appSourcePath + "phpunit.xml.dist");
    CharSequence _phpUnitXml = this.phpUnitXml(it);
    fsa.generateFile(_plus, _phpUnitXml);
  }
  
  private CharSequence phpUnitXml(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("<?xml version=\"1.0\" encoding=\"UTF-8\"?>");
    _builder.newLine();
    _builder.newLine();
    _builder.append("<phpunit backupGlobals=\"false\"");
    _builder.newLine();
    _builder.append("         ");
    _builder.append("backupStaticAttributes=\"false\"");
    _builder.newLine();
    _builder.append("         ");
    _builder.append("colors=\"true\"");
    _builder.newLine();
    _builder.append("         ");
    _builder.append("convertErrorsToExceptions=\"true\"");
    _builder.newLine();
    _builder.append("         ");
    _builder.append("convertNoticesToExceptions=\"true\"");
    _builder.newLine();
    _builder.append("         ");
    _builder.append("convertWarningsToExceptions=\"true\"");
    _builder.newLine();
    _builder.append("         ");
    _builder.append("processIsolation=\"false\"");
    _builder.newLine();
    _builder.append("         ");
    _builder.append("stopOnFailure=\"false\"");
    _builder.newLine();
    _builder.append("         ");
    _builder.append("syntaxCheck=\"false\"");
    _builder.newLine();
    _builder.append("         ");
    _builder.append("bootstrap=\"vendor/autoload.php\"");
    _builder.newLine();
    _builder.append(">");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<testsuites>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<testsuite name=\"");
    String _appName = this._utils.appName(it);
    _builder.append(_appName, "        ");
    _builder.append(" Module Test Suite\">");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("<directory>./Tests/</directory>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("</testsuite>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("</testsuites>");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<filter>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<whitelist>");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("<directory>./</directory>");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("<exclude>");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("<directory>./Resources</directory>");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("<directory>./Tests</directory>");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("<directory>./vendor</directory>");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("</exclude>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("</whitelist>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("</filter>");
    _builder.newLine();
    _builder.append("</phpunit>");
    _builder.newLine();
    return _builder;
  }
}

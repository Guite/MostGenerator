package org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff;

import de.guite.modulestudio.metamodel.Application;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class PhpUnitXmlDist {
  @Extension
  private NamingExtensions _namingExtensions = new NamingExtensions();
  
  @Extension
  private Utils _utils = new Utils();
  
  public void generate(final Application it, final IFileSystemAccess fsa) {
    String fileName = "phpunit.xml.dist";
    String _appSourcePath = this._namingExtensions.getAppSourcePath(it);
    String _plus = (_appSourcePath + fileName);
    boolean _shouldBeSkipped = this._namingExtensions.shouldBeSkipped(it, _plus);
    boolean _not = (!_shouldBeSkipped);
    if (_not) {
      String _appSourcePath_1 = this._namingExtensions.getAppSourcePath(it);
      String _plus_1 = (_appSourcePath_1 + fileName);
      boolean _shouldBeMarked = this._namingExtensions.shouldBeMarked(it, _plus_1);
      if (_shouldBeMarked) {
        fileName = "phpunit.xml.generated.dist";
      }
      String _appSourcePath_2 = this._namingExtensions.getAppSourcePath(it);
      String _plus_2 = (_appSourcePath_2 + fileName);
      fsa.generateFile(_plus_2, this.phpUnitXml(it));
    }
  }
  
  private CharSequence phpUnitXml(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("<?xml version=\"1.0\" encoding=\"UTF-8\"?>");
    _builder.newLine();
    _builder.append("<phpunit");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("bootstrap=\"./../../../lib/bootstrap.php\"");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("backupGlobals=\"false\"");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("backupStaticAttributes=\"false\"");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("colors=\"true\"");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("convertErrorsToExceptions=\"true\"");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("convertNoticesToExceptions=\"true\"");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("convertWarningsToExceptions=\"true\"");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("processIsolation=\"false\"");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("stopOnFailure=\"false\"");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("syntaxCheck=\"true\"");
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
    _builder.append("<directory>./Tests</directory>");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("<exclude>./Tests/Entity/*/Repository</exclude>");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("<exclude>./vendor</exclude>");
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

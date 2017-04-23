package org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff;

import com.google.common.base.Objects;
import de.guite.modulestudio.metamodel.Application;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.GeneratorSettingsExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class TravisFile {
  @Extension
  private FormattingExtensions _formattingExtensions = new FormattingExtensions();
  
  @Extension
  private GeneratorSettingsExtensions _generatorSettingsExtensions = new GeneratorSettingsExtensions();
  
  @Extension
  private NamingExtensions _namingExtensions = new NamingExtensions();
  
  @Extension
  private Utils _utils = new Utils();
  
  public void generate(final Application it, final IFileSystemAccess fsa) {
    String fileName = ".travis.yml";
    String _appSourcePath = this._namingExtensions.getAppSourcePath(it);
    String _plus = (_appSourcePath + fileName);
    boolean _shouldBeSkipped = this._namingExtensions.shouldBeSkipped(it, _plus);
    boolean _not = (!_shouldBeSkipped);
    if (_not) {
      String _appSourcePath_1 = this._namingExtensions.getAppSourcePath(it);
      String _plus_1 = (_appSourcePath_1 + fileName);
      boolean _shouldBeMarked = this._namingExtensions.shouldBeMarked(it, _plus_1);
      if (_shouldBeMarked) {
        fileName = ".travis.generated.yml";
      }
      String _appSourcePath_2 = this._namingExtensions.getAppSourcePath(it);
      String _plus_2 = (_appSourcePath_2 + fileName);
      fsa.generateFile(_plus_2, this.travisFile(it));
    }
  }
  
  private CharSequence travisFile(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("language: php");
    _builder.newLine();
    _builder.newLine();
    _builder.append("sudo: false");
    _builder.newLine();
    _builder.newLine();
    _builder.append("php:");
    _builder.newLine();
    {
      Boolean _targets = this._utils.targets(it, "1.5");
      boolean _not = (!(_targets).booleanValue());
      if (_not) {
        _builder.append("  ");
        _builder.append("- 5.4");
        _builder.newLine();
      }
    }
    _builder.append("  ");
    _builder.append("- 5.5");
    _builder.newLine();
    _builder.append("  ");
    _builder.append("- 5.6");
    _builder.newLine();
    _builder.append("  ");
    _builder.append("- 7.0");
    _builder.newLine();
    _builder.append("  ");
    _builder.append("- 7.1");
    _builder.newLine();
    _builder.append("  ");
    _builder.append("- hhvm");
    _builder.newLine();
    _builder.newLine();
    _builder.append("matrix:");
    _builder.newLine();
    _builder.append("  ");
    _builder.append("fast_finish: true");
    _builder.newLine();
    _builder.append("  ");
    _builder.append("allow_failures:");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("- php: 7.0");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("- php: 7.1");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("- php: hhvm");
    _builder.newLine();
    _builder.newLine();
    _builder.append("services:");
    _builder.newLine();
    _builder.append("  ");
    _builder.append("- mysql");
    _builder.newLine();
    _builder.newLine();
    _builder.append("before_install:");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("- if [[ \"$TRAVIS_PHP_VERSION\" != \"nightly\" ]] && [[ \"$TRAVIS_PHP_VERSION\" != \"hhvm\" ]] && [ $(php -r \"echo PHP_MINOR_VERSION;\") -le 4 ]; then echo \"extension = apc.so\" >> ~/.phpenv/versions/$(phpenv version-name)/etc/php.ini; fi;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("- if [[ \"$TRAVIS_PHP_VERSION\" != \"nightly\" ]] && [[ \"$TRAVIS_PHP_VERSION\" != \"hhvm\" ]]; then (pecl install -f memcached-2.1.0 && echo \"extension = memcache.so\" >> ~/.phpenv/versions/$(phpenv version-name)/etc/php.ini) || echo \"Let\'s continue without memcache extension\"; fi;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("# - if [[ \"$TRAVIS_PHP_VERSION\" != \"nightly\" ]] && [[ \"$TRAVIS_PHP_VERSION\" != \"hhvm\" ]]; then php -i; fi;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("# Set the COMPOSER_ROOT_VERSION to the right version according to the branch being built");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("- if [ \"$TRAVIS_BRANCH\" = \"master\" ]; then export COMPOSER_ROOT_VERSION=dev-master; else export COMPOSER_ROOT_VERSION=\"$TRAVIS_BRANCH\".x-dev; fi;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("- composer self-update");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("- if [ -n \"$GH_TOKEN\" ]; then composer config github-oauth.github.com ${GH_TOKEN}; fi;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("- mysql -e \'create database zk_test;\'");
    _builder.newLine();
    _builder.newLine();
    _builder.append("install:");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("- composer install");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("- zip -qr ");
    String _appName = this._utils.appName(it);
    _builder.append(_appName, "    ");
    _builder.append(".zip .");
    _builder.newLineIfNotEmpty();
    {
      Boolean _targets_1 = this._utils.targets(it, "1.5");
      if ((_targets_1).booleanValue()) {
        _builder.append("    ");
        _builder.append("- wget http://ci.zikula.org/job/Zikula_Core-1.5.0/lastSuccessfulBuild/artifact/build/archive/Zikula_Core-1.5.0.tar.gz");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("- tar -xpzf Zikula_Core-1.5.0.tar.gz");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("- rm Zikula_Core-1.5.0.tar.gz");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("- cd Zikula_Core-1.5.0");
        _builder.newLine();
      } else {
        _builder.append("    ");
        _builder.append("- wget http://ci.zikula.org/job/Zikula_Core-1.4.6/119/artifact/build/archive/Zikula_Core-1.4.6.build119.tar.gz");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("- tar -xpzf Zikula_Core-1.4.6.build119.tar.gz");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("- rm Zikula_Core-1.4.6.build119.tar.gz");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("- cd Zikula_Core-1.4.6");
        _builder.newLine();
      }
    }
    _builder.append("    ");
    _builder.append("- php app/console zikula:install:start -n --database_user=root --database_name=zk_test --password=12345678 --email=admin@example.com --router:request_context:host=localhost");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("- php app/console zikula:install:finish");
    _builder.newLine();
    {
      boolean _isSystemModule = this._generatorSettingsExtensions.isSystemModule(it);
      if (_isSystemModule) {
        _builder.append("    ");
        _builder.append("- cd system");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("- mkdir ");
        String _appName_1 = this._utils.appName(it);
        _builder.append(_appName_1, "    ");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("- cd ");
        String _appName_2 = this._utils.appName(it);
        _builder.append(_appName_2, "    ");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("- unzip -q ../../../");
        String _appName_3 = this._utils.appName(it);
        _builder.append(_appName_3, "    ");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("- cd  ../..");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("- php app/console bootstrap:bundles");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("- mysql -e \"INSERT INTO zk_test.modules (id, name, type, displayname, url, description, directory, version, capabilities, state, securityschema, core_min, core_max) VALUES (NULL, \'");
        String _appName_4 = this._utils.appName(it);
        _builder.append(_appName_4, "    ");
        _builder.append("\', \'3\', \'");
        String _formatForDisplayCapital = this._formattingExtensions.formatForDisplayCapital(it.getName());
        _builder.append(_formatForDisplayCapital, "    ");
        _builder.append("\', \'");
        String _formatForDB = this._formattingExtensions.formatForDB(it.getName());
        _builder.append(_formatForDB, "    ");
        _builder.append("\', \'");
        {
          if (((null != it.getDocumentation()) && (!Objects.equal(it.getDocumentation(), "")))) {
            String _replace = it.getDocumentation().replace("\"", "\'");
            _builder.append(_replace, "    ");
          } else {
            String _appName_5 = this._utils.appName(it);
            _builder.append(_appName_5, "    ");
            _builder.append(" module generated by ModuleStudio ");
            String _msVersion = this._utils.msVersion();
            _builder.append(_msVersion, "    ");
            _builder.append(".");
          }
        }
        _builder.append("\', \'");
        String _appName_6 = this._utils.appName(it);
        _builder.append(_appName_6, "    ");
        _builder.append("\', \'");
        String _version = it.getVersion();
        _builder.append(_version, "    ");
        _builder.append("\', \'N;\', \'3\', \'N;\', \'");
        {
          Boolean _targets_2 = this._utils.targets(it, "1.5");
          if ((_targets_2).booleanValue()) {
            _builder.append("1.5.0");
          } else {
            _builder.append("1.4.6");
          }
        }
        _builder.append("\', \'2.0.0\');\"");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("    ");
        _builder.append("- cd modules");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("- mkdir ");
        String _formatForDB_1 = this._formattingExtensions.formatForDB(it.getVendor());
        _builder.append(_formatForDB_1, "    ");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("- cd ");
        String _formatForDB_2 = this._formattingExtensions.formatForDB(it.getVendor());
        _builder.append(_formatForDB_2, "    ");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("- mkdir ");
        String _formatForDB_3 = this._formattingExtensions.formatForDB(it.getName());
        _builder.append(_formatForDB_3, "    ");
        _builder.append("-module");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("- cd ");
        String _formatForDB_4 = this._formattingExtensions.formatForDB(it.getName());
        _builder.append(_formatForDB_4, "    ");
        _builder.append("-module");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("- unzip -q ../../../../");
        String _appName_7 = this._utils.appName(it);
        _builder.append(_appName_7, "    ");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("- cd  ../../..");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("- php app/console bootstrap:bundles");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("- mysql -e \"INSERT INTO zk_test.modules (id, name, type, displayname, url, description, directory, version, capabilities, state, securityschema, core_min, core_max) VALUES (NULL, \'");
        String _appName_8 = this._utils.appName(it);
        _builder.append(_appName_8, "    ");
        _builder.append("\', \'3\', \'");
        String _formatForDisplayCapital_1 = this._formattingExtensions.formatForDisplayCapital(it.getName());
        _builder.append(_formatForDisplayCapital_1, "    ");
        _builder.append("\', \'");
        String _formatForDB_5 = this._formattingExtensions.formatForDB(it.getName());
        _builder.append(_formatForDB_5, "    ");
        _builder.append("\', \'");
        {
          if (((null != it.getDocumentation()) && (!Objects.equal(it.getDocumentation(), "")))) {
            String _replace_1 = it.getDocumentation().replace("\"", "\'");
            _builder.append(_replace_1, "    ");
          } else {
            String _appName_9 = this._utils.appName(it);
            _builder.append(_appName_9, "    ");
            _builder.append(" module generated by ModuleStudio ");
            String _msVersion_1 = this._utils.msVersion();
            _builder.append(_msVersion_1, "    ");
            _builder.append(".");
          }
        }
        _builder.append("\', \'");
        String _formatForDB_6 = this._formattingExtensions.formatForDB(it.getVendor());
        _builder.append(_formatForDB_6, "    ");
        _builder.append("/");
        String _formatForDB_7 = this._formattingExtensions.formatForDB(it.getName());
        _builder.append(_formatForDB_7, "    ");
        _builder.append("-module\', \'");
        String _version_1 = it.getVersion();
        _builder.append(_version_1, "    ");
        _builder.append("\', \'N;\', \'3\', \'N;\', \'");
        {
          Boolean _targets_3 = this._utils.targets(it, "1.5");
          if ((_targets_3).booleanValue()) {
            _builder.append("1.5.0");
          } else {
            _builder.append("1.4.6");
          }
        }
        _builder.append("\', \'2.0.0\');\"");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("    ");
    _builder.append("- php app/console cache:warmup");
    _builder.newLine();
    _builder.newLine();
    _builder.append("script:");
    _builder.newLine();
    {
      boolean _isSystemModule_1 = this._generatorSettingsExtensions.isSystemModule(it);
      if (_isSystemModule_1) {
        _builder.append("    ");
        _builder.append("- php app/console lint:yaml system/");
        String _appName_10 = this._utils.appName(it);
        _builder.append(_appName_10, "    ");
        _builder.append("/Resources");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("- php app/console lint:twig @");
        String _appName_11 = this._utils.appName(it);
        _builder.append(_appName_11, "    ");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("- phpunit --configuration system/");
        String _appName_12 = this._utils.appName(it);
        _builder.append(_appName_12, "    ");
        _builder.append("/phpunit.xml.dist --coverage-text --coverage-clover=coverage.clover -v");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("    ");
        _builder.append("- php app/console lint:yaml modules/");
        String _formatForDB_8 = this._formattingExtensions.formatForDB(it.getVendor());
        _builder.append(_formatForDB_8, "    ");
        _builder.append("/");
        String _formatForDB_9 = this._formattingExtensions.formatForDB(it.getName());
        _builder.append(_formatForDB_9, "    ");
        _builder.append("-module/Resources");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("- php app/console lint:twig @");
        String _appName_13 = this._utils.appName(it);
        _builder.append(_appName_13, "    ");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("- phpunit --configuration modules/");
        String _formatForDB_10 = this._formattingExtensions.formatForDB(it.getVendor());
        _builder.append(_formatForDB_10, "    ");
        _builder.append("/");
        String _formatForDB_11 = this._formattingExtensions.formatForDB(it.getName());
        _builder.append(_formatForDB_11, "    ");
        _builder.append("-module/phpunit.xml.dist --coverage-text --coverage-clover=coverage.clover -v");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.newLine();
    _builder.append("after_script:");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("- wget https://scrutinizer-ci.com/ocular.phar");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("- php ocular.phar code-coverage:upload --format=php-clover coverage.clover");
    _builder.newLine();
    _builder.newLine();
    _builder.append("before_deploy:");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("- cd ..");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("- mkdir release");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("- cd release");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("- unzip -q ../");
    String _appName_14 = this._utils.appName(it);
    _builder.append(_appName_14, "    ");
    _builder.append(".zip");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("- rm -Rf vendor");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("- rm -Rf .git");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("- composer install --no-dev --prefer-dist");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("- rm auth.json");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("- zip -qr ");
    String _appName_15 = this._utils.appName(it);
    _builder.append(_appName_15, "    ");
    _builder.append(".zip .");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("deploy:");
    _builder.newLine();
    _builder.append("  ");
    _builder.append("provider: releases");
    _builder.newLine();
    _builder.append("  ");
    _builder.append("api_key:");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("secure: \"\" # Enter your api key here!");
    _builder.newLine();
    _builder.append("  ");
    _builder.append("file: ");
    String _appName_16 = this._utils.appName(it);
    _builder.append(_appName_16, "  ");
    _builder.append(".zip");
    _builder.newLineIfNotEmpty();
    _builder.append("  ");
    _builder.append("on:");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("tags: true");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("repo: ");
    String _formatForCode = this._formattingExtensions.formatForCode(it.getVendor());
    _builder.append(_formatForCode, "    ");
    _builder.append("/");
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital, "    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    return _builder;
  }
}

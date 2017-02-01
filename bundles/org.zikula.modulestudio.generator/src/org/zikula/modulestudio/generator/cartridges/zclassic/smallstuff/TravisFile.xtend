package org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.GeneratorSettingsExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class TravisFile {

    extension FormattingExtensions = new FormattingExtensions
    extension GeneratorSettingsExtensions = new GeneratorSettingsExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    def generate(Application it, IFileSystemAccess fsa) {
        var fileName = '.travis.yml'
        if (!shouldBeSkipped(getAppSourcePath + fileName)) {
            if (shouldBeMarked(getAppSourcePath + fileName)) {
                fileName = '.travis.generated.yml'
            }
            fsa.generateFile(getAppSourcePath + fileName, travisFile)
        }
    }

    def private travisFile(Application it) '''
        language: php

        sudo: false

        php:
          - 5.4
          - 5.5
          - 5.6
          - 7.0
          - 7.1
          - hhvm

        matrix:
          fast_finish: true
          allow_failures:
            - php: 7.0
            - php: 7.1
            - php: hhvm

        services:
          - mysql

        before_install:
            - if [[ "$TRAVIS_PHP_VERSION" != "nightly" ]] && [[ "$TRAVIS_PHP_VERSION" != "hhvm" ]] && [ $(php -r "echo PHP_MINOR_VERSION;") -le 4 ]; then echo "extension = apc.so" >> ~/.phpenv/versions/$(phpenv version-name)/etc/php.ini; fi;
            - if [[ "$TRAVIS_PHP_VERSION" != "nightly" ]] && [[ "$TRAVIS_PHP_VERSION" != "hhvm" ]]; then (pecl install -f memcached-2.1.0 && echo "extension = memcache.so" >> ~/.phpenv/versions/$(phpenv version-name)/etc/php.ini) || echo "Let's continue without memcache extension"; fi;
            # - if [[ "$TRAVIS_PHP_VERSION" != "nightly" ]] && [[ "$TRAVIS_PHP_VERSION" != "hhvm" ]]; then php -i; fi;
            # Set the COMPOSER_ROOT_VERSION to the right version according to the branch being built
            - if [ "$TRAVIS_BRANCH" = "master" ]; then export COMPOSER_ROOT_VERSION=dev-master; else export COMPOSER_ROOT_VERSION="$TRAVIS_BRANCH".x-dev; fi;
            - composer self-update
            - if [ -n "$GH_TOKEN" ]; then composer config github-oauth.github.com ${GH_TOKEN}; fi;
            - mysql -e 'create database zk_test;'

        install:
            - composer install
            - zip -qr «appName».zip .
            «IF targets('1.4-dev')»
            - wget http://ci.zikula.org/job/Zikula_Core-1.4.6/97/artifact/build/archive/Zikula_Core-1.4.6.build97.tar.gz
            - tar -xpzf Zikula_Core-1.4.6.build97.tar.gz
            - rm Zikula_Core-1.4.6.build97.tar.gz
            - cd Zikula_Core-1.4.6
            «ELSE»
            - wget http://ci.zikula.org/job/Zikula_Core-1.4.5/106/artifact/build/archive/Zikula_Core-1.4.5.build106.tar.gz
            - tar -xpzf Zikula_Core-1.4.5.build106.tar.gz
            - rm Zikula_Core-1.4.5.build106.tar.gz
            - cd Zikula_Core-1.4.5
            «ENDIF»
            - php app/console zikula:install:start -n --database_user=root --database_name=zk_test --password=12345678 --email=admin@example.com --router:request_context:host=localhost
            - php app/console zikula:install:finish
            «IF isSystemModule»
                - cd system
                - mkdir «appName»
                - cd «appName»
                - unzip -q ../../../«appName»
                - cd  ../..
                - php app/console bootstrap:bundles
                - mysql -e "INSERT INTO zk_test.modules (id, name, type, displayname, url, description, directory, version, capabilities, state, securityschema, core_min, core_max) VALUES (NULL, '«appName»', '3', '«name.formatForDisplayCapital»', '«name.formatForDB»', '«IF null !== documentation && documentation != ''»«documentation.replace('"', "'")»«ELSE»«appName» module generated by ModuleStudio «msVersion».«ENDIF»', '«appName»', '«version»', 'N;', '3', 'N;', '1.4.«IF targets('1.4-dev')»6«ELSE»5«ENDIF»', '2.0.0');"
            «ELSE»
                - cd modules
                - mkdir «vendor.formatForDB»
                - cd «vendor.formatForDB»
                - mkdir «name.formatForDB»-module
                - cd «name.formatForDB»-module
                - unzip -q ../../../../«appName»
                - cd  ../../..
                - php app/console bootstrap:bundles
                - mysql -e "INSERT INTO zk_test.modules (id, name, type, displayname, url, description, directory, version, capabilities, state, securityschema, core_min, core_max) VALUES (NULL, '«appName»', '3', '«name.formatForDisplayCapital»', '«name.formatForDB»', '«IF null !== documentation && documentation != ''»«documentation.replace('"', "'")»«ELSE»«appName» module generated by ModuleStudio «msVersion».«ENDIF»', '«vendor.formatForDB»/«name.formatForDB»-module', '«version»', 'N;', '3', 'N;', '1.4.4', '2.0.0');"
            «ENDIF»
            - php app/console cache:warmup

        script:
            «IF isSystemModule»
                - php app/console lint:yaml system/«appName»/Resources
                - php app/console lint:twig @«appName»
                - phpunit --configuration system/«appName»/phpunit.xml.dist --coverage-text --coverage-clover=coverage.clover -v
            «ELSE»
                - php app/console lint:yaml modules/«vendor.formatForDB»/«name.formatForDB»-module/Resources
                - php app/console lint:twig @«appName»
                - phpunit --configuration modules/«vendor.formatForDB»/«name.formatForDB»-module/phpunit.xml.dist --coverage-text --coverage-clover=coverage.clover -v
            «ENDIF»

        after_script:
            - wget https://scrutinizer-ci.com/ocular.phar
            - php ocular.phar code-coverage:upload --format=php-clover coverage.clover

        before_deploy:
            - cd ..
            - mkdir release
            - cd release
            - unzip -q ../«appName».zip
            - rm -Rf vendor
            - rm -Rf .git
            - composer install --no-dev --prefer-dist
            - rm auth.json
            - zip -qr «appName».zip .

        deploy:
          provider: releases
          api_key:
            secure: "" # Enter your api key here!
          file: «appName».zip
          on:
            tags: true
            repo: «vendor.formatForCode»/«name.formatForCodeCapital»

    '''
}

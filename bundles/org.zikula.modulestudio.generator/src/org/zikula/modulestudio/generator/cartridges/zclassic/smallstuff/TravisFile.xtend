package org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class TravisFile {

    extension FormattingExtensions = new FormattingExtensions
    extension Utils = new Utils

    def generate(Application it, IMostFileSystemAccess fsa) {
        fsa.generateFile('.travis.yml', travisFile)
    }

    def private travisFile(Application it) '''
        language: php

        sudo: false

        php:
          - 5.5
          - 5.6
          - 7.0
          - 7.1
          - 7.2
          - nightly

        matrix:
          fast_finish: true
          allow_failures:
            «IF !targets('2.0')»
                - php: 7.0
                - php: 7.1
                - php: 7.2
            «ENDIF»
            - php: nightly

        services:
          - mysql

        before_install:
            - if [[ "$TRAVIS_PHP_VERSION" != "nightly" ]]; then phpenv config-rm xdebug.ini; fi;
            # load memcache.so for php 5
            - if [[ "$TRAVIS_PHP_VERSION" != "nightly" ]] && [ $(php -r "echo PHP_MAJOR_VERSION;") == 5 ]; then (pecl install -f memcached-2.1.0 && echo "extension = memcache.so" >> ~/.phpenv/versions/$(phpenv version-name)/etc/php.ini) || echo "Continuing without memcache extension"; fi;
            # load memcache.so for php >= 7.1
            - if [[ "$TRAVIS_PHP_VERSION" != "nightly" ]] && [ $(php -r "echo PHP_MAJOR_VERSION;") == 7 ] && [ $(php -r "echo PHP_MINOR_VERSION;") >= 1 ]; then (pecl install -f memcached-2.1.0 && echo "extension = memcache.so" >> ~/.phpenv/versions/$(phpenv version-name)/etc/php.ini) || echo "Continuing without memcache extension"; fi;
            # Set the COMPOSER_ROOT_VERSION to the right version according to the branch being built
            - if [ "$TRAVIS_BRANCH" = "master" ]; then export COMPOSER_ROOT_VERSION=dev-master; else export COMPOSER_ROOT_VERSION="$TRAVIS_BRANCH".x-dev; fi;

            - composer self-update
            - if [ -n "$GH_TOKEN" ]; then composer config github-oauth.github.com ${GH_TOKEN}; fi;
            - mysql -e 'create database zk_test;'

        install:
            - composer install
            - zip -qr «appName».zip .
            «IF targets('2.0-dev') || (!targets('2.0') && targets('1.5-dev'))»
            - wget http://ci.zikula.org/job/Zikula/job/«targetSemVer(false)»/lastSuccessfulBuild/artifact/build_work/archive/«targetSemVer(false)».tar.gz
            - tar -xpzf «targetSemVer(false)».tar.gz
            - rm «targetSemVer(false)».tar.gz
            «ELSEIF targets('2.0') || !targets('1.5-dev')»
            - wget https://github.com/zikula/core/releases/download/«targetSemVer(true)»/«targetSemVer(false)».tar.gz
            - tar -xpzf «targetSemVer(false)».tar.gz
            - rm «targetSemVer(false)».tar.gz
            «ENDIF»
            - cd «targetSemVer(false)»
            - php «consoleCmd» zikula:install:start -n --database_user=root --database_name=zk_test --password=12345678 --email=admin@example.com --router:request_context:host=localhost
            - php «consoleCmd» zikula:install:finish
            «IF isSystemModule»
                - cd system
                - mkdir «appName»
                - cd «appName»
                - unzip -q ../../../«appName»
                - cd  ../..
                - php «consoleCmd» bootstrap:bundles
                - mysql -e "INSERT INTO zk_test.modules (id, name, type, displayname, url, description, directory, version, capabilities, state, securityschema, core_min, core_max) VALUES (NULL, '«appName»', '3', '«name.formatForDisplayCapital»', '«name.formatForDB»', '«appDescription»', '«appName»', '«version»', 'N;', '3', 'N;', '«targetSemVer(true)»', '3.0.0');"
            «ELSE»
                - cd modules
                - mkdir «vendor.formatForDB»
                - cd «vendor.formatForDB»
                - mkdir «name.formatForDB»-module
                - cd «name.formatForDB»-module
                - unzip -q ../../../../«appName»
                - cd  ../../..
                - php «consoleCmd» bootstrap:bundles
                - mysql -e "INSERT INTO zk_test.modules (id, name, type, displayname, url, description, directory, version, capabilities, state, securityschema, core_min, core_max) VALUES (NULL, '«appName»', '3', '«name.formatForDisplayCapital»', '«name.formatForDB»', '«appDescription»', '«vendor.formatForDB»/«name.formatForDB»-module', '«version»', 'N;', '3', 'N;', '«targetSemVer(true)»', '3.0.0');"
            «ENDIF»
            - php «consoleCmd» cache:warmup

        script:
            «IF isSystemModule»
                - php «consoleCmd» lint:yaml system/«appName»/Resources
                - php «consoleCmd» lint:twig @«appName»
                «IF generateTests»
                    - phpunit --configuration system/«appName»/phpunit.xml.dist --coverage-text --coverage-clover=coverage.clover -v
                «ENDIF»
            «ELSE»
                - php «consoleCmd» lint:yaml modules/«vendor.formatForDB»/«name.formatForDB»-module/Resources
                - php «consoleCmd» lint:twig @«appName»
                «IF generateTests»
                    - phpunit --configuration modules/«vendor.formatForDB»/«name.formatForDB»-module/phpunit.xml.dist --coverage-text --coverage-clover=coverage.clover -v
                «ENDIF»
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

    def private consoleCmd(Application it) {
        if (targets('2.0')) {
            return 'bin/console'
        }
        'app/console'
    }
}

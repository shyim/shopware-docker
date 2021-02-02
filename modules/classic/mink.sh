#!/usr/bin/env bash

cd /var/www/html/"$SHOPWARE_PROJECT" || exit 1
URL=$(get_url "$SHOPWARE_PROJECT")

php "${DIR}"/modules/classic/fix-config.php "$SHOPWARE_FOLDER/config.php" csrf

./bin/console dbal:run-sql 'UPDATE s_core_config_elements SET value = "b:0;" WHERE name = "show_cookie_note"'

./bin/console sw:rebuild:seo:index
./bin/console sw:cache:clear

# Shopware 5.7
if [[ -f engine/Shopware/Shopware.php ]]; then

  echo "default:
    extensions:
        SensioLabs\Behat\PageObjectExtension:
            namespaces:
                page: Shopware\Tests\Mink\Page
                element: Shopware\Tests\Mink\Element
        Shopware\Behat\ShopwareExtension: ~
        Behat\MinkExtension:
            ## defined in buildscript
            base_url: '$URL'
            default_session: 'selenium2'
            javascript_session: 'selenium2'
            browser_name: chrome
            selenium2:
                wd_host: \"http://selenium:4444/wd/hub\"
                capabilities:
                    browser: chrome
                    marionette: true
                    extra_capabilities:
                        chromeOptions:
                            w3c: false

    gherkin:
      filters:
        tags: ~@knownFailing

    suites:
        default:
            paths:    [ '%paths.base%/features' ]
            template: Responsive
            contexts:
                - Behat\MinkExtension\Context\MinkContext
                - Shopware\Tests\Mink\FeatureContext
                - Shopware\Tests\Mink\BackendContext
                - Shopware\Tests\Mink\AccountContext
                - Shopware\Tests\Mink\BlogContext
                - Shopware\Tests\Mink\CheckoutContext
                - Shopware\Tests\Mink\DetailContext
                - Shopware\Tests\Mink\FormContext
                - Shopware\Tests\Mink\ListingContext
                - Shopware\Tests\Mink\NoteContext
                - Shopware\Tests\Mink\SeoContext
                - Shopware\Tests\Mink\ShopwareContext
                - Shopware\Tests\Mink\SitemapContext
                - Shopware\Tests\Mink\SpecialContext
                - Shopware\Tests\Mink\TransformContext
                - Shopware\Tests\Mink\SecurityContext
                - Shopware\Tests\Mink\ExportContext" >tests/Mink/behat.yml

else

  echo "default:
    extensions:
        SensioLabs\Behat\PageObjectExtension:
            namespaces:
                page: Shopware\Tests\Mink\Page
                element: Shopware\Tests\Mink\Element
        Shopware\Behat\ShopwareExtension: ~
        Behat\MinkExtension:
            ## defined in buildscript
            base_url: '$URL'
            default_session: 'goutte'
            javascript_session: 'selenium2'
            goutte: ~
            browser_name: chrome
            selenium2:
                wd_host: \"http://selenium:4444/wd/hub\"
                capabilities:
                    chrome:
                        switches:
                            - \"--disable-gpu\"
                            - \"--headless\"
                            - \"--no-sandbox\"

    gherkin:
      filters:
        tags: ~@knownFailing

    suites:
        default:
            paths:    [ '%paths.base%/features' ]
            template: Responsive
            contexts:
                - Behat\MinkExtension\Context\MinkContext
                - Shopware\Tests\Mink\FeatureContext
                - Shopware\Tests\Mink\BackendContext
                - Shopware\Tests\Mink\AccountContext
                - Shopware\Tests\Mink\BlogContext
                - Shopware\Tests\Mink\CheckoutContext
                - Shopware\Tests\Mink\DetailContext
                - Shopware\Tests\Mink\FormContext
                - Shopware\Tests\Mink\ListingContext
                - Shopware\Tests\Mink\NoteContext
                - Shopware\Tests\Mink\SeoContext
                - Shopware\Tests\Mink\ShopwareContext
                - Shopware\Tests\Mink\SitemapContext
                - Shopware\Tests\Mink\SpecialContext
                - Shopware\Tests\Mink\TransformContext
                - Shopware\Tests\Mink\SecurityContext
                - Shopware\Tests\Mink\ExportContext" >tests/Mink/behat.yml
fi

vendor/bin/behat -vv --config=tests/Mink/behat.yml --format=pretty --out=std --format=junit --out=build/artifacts/mink "${@:3}"

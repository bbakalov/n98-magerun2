#!/bin/bash

# Debugging
# set -x;

ADDITIONAL_OPTIONS="";
PHAR_FILE=$1;
MAGENTO_ROOT_DIR=$2;
TESTS_WITH_ERRORS=false;

function verify() {
	if [ -z "$PHAR_FILE" ]; then
		echo "usage: $0 <phar-file> <magento-root-dir>";
		exit 1;
	fi

	if [ -z "$MAGENTO_ROOT_DIR" ]; then
		echo "usage: $0 <phar-file> <magento-root-dir>";
  	exit 1;
  fi
}

function db_query {
	local sql=$1;
	$PHAR_FILE --no-interaction --root-dir="$MAGENTO_ROOT_DIR" --skip-core-commands db:query "$sql"
}

function assert_command_contains {
	local command=$1;
	local find=$2;

	echo -n "- $command"

  local output=""
	output=$(($PHAR_FILE --no-interaction --root-dir="$MAGENTO_ROOT_DIR" $command $ADDITIONAL_OPTIONS | grep "$find") 2>&1);

	if [ $? -eq 0 ]; then
		echo -e "\t\tok";
	else
		TESTS_WITH_ERRORS=true;
		echo -e "\t\tfailure";
		echo "----------------------------------------------------------------";
		echo "$output";
		echo "----------------------------------------------------------------";
	fi;
}

function test_magerun_commands() {
	# List of commands was generated by
	# $> ./n98-magerun2.phar --skip-core-commands list --format json | jq -r '.commands[] | .name'
	ADDITIONAL_OPTIONS="--skip-core-commands";

	#  open-browser
	#  script
	#  self-update
	#  shell
	#  admin:notifications
	#assert_command_contains "admin:notifications --off" "username"
	#  admin:token:create
	#  admin:user:change-password
	#  admin:user:change-status
	#  admin:user:delete
	#  admin:user:list
	assert_command_contains "admin:user:list" "username"
	#  cache:clean
	assert_command_contains "cache:clean layout" "cache cleaned"
	#  cache:disable
	assert_command_contains "cache:disable full_page" "The following cache types were disabled"
	#  cache:enable
	assert_command_contains "cache:enable full_page" "The following cache types were enabled"
	#  cache:flush
	assert_command_contains "cache:flush" "cache flushed"
	#  cache:list
	assert_command_contains "cache:list" "full_page"
	#  cache:report
	assert_command_contains "cache:report" "EXPIRE"
	#  cache:view
	assert_command_contains "cache:view INITIAL_CONFIG" "data"
	#  cms:block:toggle
	#  config:data:acl
	assert_command_contains "config:data:acl" "ACL Tree"
	#  config:data:di
	assert_command_contains "config:data:di" "DateTimeInterface"
	#  config:env:create
	#  config:env:set
	assert_command_contains "config:env:set magerun.example foo" "Config magerun.example successfully set to foo"
	#  config:env:delete
	assert_command_contains "config:env:delete magerun.example" "Config magerun.example successfully removed"
	#  config:env:show
	assert_command_contains "config:env:show" "backend.frontName"
	#  config:store:set
	assert_command_contains "config:store:set n98/magerun/example 1" "n98/magerun/example => 1"
	#  config:store:get
	assert_command_contains "config:store:get n98/magerun/example" "n98/magerun/example"
	#  config:store:delete
	assert_command_contains "config:store:delete n98/magerun/example" "deleted path"
	#  customer:create
	db_query "DELETE FROM customer_entity WHERE email = 'foo@example.com'"
	assert_command_contains "customer:create foo@example.com Password123 Firstname Lastname" "Customer foo@example.com successfully created"
	#  customer:info
	assert_command_contains "customer:info foo@example.com" "foo@example.com"
	#  customer:list
	assert_command_contains "customer:list foo@example.com"
	#  customer:change-password
	assert_command_contains "customer:change-password foo@example.com Password1234" "Password successfully change"
	#  customer:token:create
	#  db:add-default-authorization-entries
	assert_command_contains "db:add-default-authorization-entries" "OK"
	#  db:console
	#  db:create
	#  db:drop
	#  db:dump
	#  db:import
	#  db:info
	assert_command_contains "db:info" "PDO-Connection-String"
	#  db:maintain:check-tables
	#  db:query
	#assert_command_contains "db:query 'SELECT 1'" "1"
	#  db:status
	assert_command_contains "db:status" "InnoDB Buffer Pool hit"
	#  db:variables
	assert_command_contains "db:variables" "innodb_buffer_pool_size"
	#  design:demo-notice
	assert_command_contains "design:demo-notice --on" "Demo Notice enabled for store default"
	assert_command_contains "design:demo-notice --off" "Demo Notice disabled for store default"
	#  dev:asset:clear (we can run the command after we have created assets)
	#assert_command_contains "dev:asset:clear" "deployed_version.txt"
	#  dev:console
	#  dev:module:create
	#  dev:module:list
	assert_command_contains "dev:module:list" "Magento_Store"
	#  dev:module:observer:list
	assert_command_contains "dev:module:observer:list sales_order_place_after global" "Observer name"
	#  dev:report:count
	#  dev:symlinks
	#  dev:template-hints
	assert_command_contains "dev:template-hints --on" "enabled"
	assert_command_contains "dev:template-hints --off" "disabled"
	#  dev:template-hints-blocks
	assert_command_contains "dev:template-hints-blocks --on" "enabled"
	assert_command_contains "dev:template-hints-blocks --off" "disabled"
	#  dev:theme:list
	assert_command_contains "dev:theme:list" "Magento/backend"
	#  eav:attribute:list
	assert_command_contains "eav:attribute:list" "sku"
	#  eav:attribute:remove
	#  eav:attribute:view
	assert_command_contains "eav:attribute:view catalog_product sku" "catalog_product_entity"
	#  generation:flush
	assert_command_contains "generation:flush Symfony" "Removed"
	#  index:list
	assert_command_contains "index:list" "catalogsearch_fulltext"
	#  index:trigger:recreate
	assert_command_contains "index:trigger:recreate" "Skipped indexer Catalog Search."
	#  integration:create
	assert_command_contains "integration:create magerun-test magerun@example.com https://localhost" "Integration ID"
	#  integration:list
	assert_command_contains "integration:list" "magerun-test"
	#  integration:show
	assert_command_contains "integration:show magerun-test" "Consumer Key"
	#  integration:delete
	assert_command_contains "integration:delete magerun-test" "Successfully deleted integration"
	#  media:dump
	assert_command_contains "media:dump" "Compress"
	#  script:repo:list
	assert_command_contains "script:repo:list" "Script"
	#  script:repo:run
	#  search:engine:list
	assert_command_contains "search:engine:list" "label"
	#  sys:check
	assert_command_contains "sys:check" "Env"
	#  sys:cron:list
	assert_command_contains "sys:cron:list" "indexer_reindex_all_invalid"
	#  sys:cron:run
	assert_command_contains "sys:cron:run sales_clean_quotes" "done"
	#  sys:cron:schedule
	assert_command_contains "sys:cron:schedule sales_clean_quotes" "done"
	#  sys:cron:history
	assert_command_contains "sys:cron:history" "Last executed jobs"
	#  sys:info
	assert_command_contains "sys:info" "Magento System Information"
	#  sys:maintenance
	assert_command_contains "sys:maintenance --on" "on"
	assert_command_contains "sys:maintenance --off" "off"
	#  sys:setup:change-version
	#  sys:setup:compare-versions
	assert_command_contains "sys:setup:compare-versions" "Setup"
	#  sys:setup:downgrade-versions
	#  sys:store:config:base-url:list
	assert_command_contains "sys:store:config:base-url:list" "unsecure_baseurl"
	#  sys:store:list
	assert_command_contains "sys:store:list" "default"
	#  sys:url:list
	assert_command_contains "sys:url:list --add-cmspages default '{host},{path}'" "/"
	#  sys:website:list
	assert_command_contains "sys:website:list" "base"
	assert_command_contains "sys:website:list --format=csv" "1,base"
}

function test_magento_core_commands() {
	# List of commands are generated by
	# $> bin/magento list --format json | jq -r '.commands[] | .name'
	ADDITIONAL_OPTIONS="";

	#  admin:user:create
	assert_command_contains \
		"admin:user:create --admin-user=foo --admin-password=Password123 --admin-email=foo@example.com --admin-firstname=Foo --admin-lastname=Foo" \
		"Created Magento administrator user named foo"
	# admin:user:unlock
	assert_command_contains "admin:user:unlock xyz" "Couldn't find the user account"
	#  app:config:dump
	assert_command_contains "app:config:dump" "Done"
	#  app:config:import
	assert_command_contains "app:config:import" "Nothing to import."
	#  app:config:status
	assert_command_contains "app:config:status" "Config files are up to date."
	#  cache:clean
	assert_command_contains "cache:clean" "cache cleaned"
	#  cache:disable
	assert_command_contains "cache:disable full_page" "The following cache types were disabled"
	#  cache:enable
	assert_command_contains "cache:enable full_page" "The following cache types were enabled"
	#  cache:flush
	assert_command_contains "cache:flush" "config cache flushed"
	#  cache:status
	assert_command_contains "cache:status" "Current status"
	#  catalog:images:resize
	#  catalog:product:attributes:cleanup (disabled because it runs in the background and breaks current test logic)
	#assert_command_contains "catalog:product:attributes:cleanup" "Unused product attributes successfully cleaned up"
	#  cms:wysiwyg:restrict
	#  config:sensitive:set
	#  config:set
	#  config:show
	assert_command_contains "config:show" "catalog/category/root_id"
	#  cron:install (cannot be tested without crontab)
	#  cron:remove
	#  cron:run
	#  customer:hash:upgrade
	assert_command_contains "customer:hash:upgrade" "Finished"
	#  deploy:mode:set
	#  deploy:mode:show
	#  dev:di:info
	assert_command_contains "dev:di:info Magento\\Catalog\\Api\\Data\\ProductInterface" "DI configuration for the class"
	#  dev:profiler:disable
	assert_command_contains "dev:profiler:disable" "Profiler disabled."
	#  dev:profiler:enable
	assert_command_contains "dev:profiler:enable" "Profiler enabled with html output."
	#  dev:query-log:disable
	assert_command_contains "dev:query-log:disable" "DB query logging disabled."
	#  dev:query-log:enable
	assert_command_contains "dev:query-log:enable" "DB query logging enabled."
	#  dev:source-theme:deploy
	#  dev:template-hints:disable
	assert_command_contains "dev:template-hints:disable" "Template hints disabled. Refresh cache types"
	#  dev:template-hints:enable
	assert_command_contains "dev:template-hints:enable" "Template hints enabled."
	#  dev:tests:run
	#  dev:urn-catalog:generate
	#  dev:xml:convert
	#  dotdigital:connector:automap
	#  dotdigital:connector:enable
	#  dotdigital:migrate
	#  dotdigital:sync
	#  downloadable:domains:add
	assert_command_contains "downloadable:domains:add example.com" "example.com was added to the whitelist."
	#  downloadable:domains:show
	assert_command_contains "downloadable:domains:show" "example.com"
	#  downloadable:domains:remove
	assert_command_contains "downloadable:domains:remove example.com" "example.com was removed from the whitelist."
	#  encryption:payment-data:update
	#  help (covered by n98-magerun2)
	#  i18n:collect-phrases
	#  i18n:pack
	#  i18n:uninstall
	#  indexer:info
	assert_command_contains "indexer:info" "catalog_category_product"
	#  indexer:reindex
	assert_command_contains "indexer:reindex" "Catalog Search index has been rebuilt successfully"
	#  indexer:reset
	assert_command_contains "indexer:reset" "Catalog Search indexer has been invalidated."
	#  indexer:set-dimensions-mode
	assert_command_contains "indexer:set-dimensions-mode" "Indexer"
	#  indexer:set-mode
	assert_command_contains "indexer:set-mode realtime" "Index mode for Indexer"
	#  indexer:show-dimensions-mode
	assert_command_contains "indexer:show-dimensions-mode" "Product Price"
	#  indexer:show-mode
	assert_command_contains "indexer:show-mode" "Catalog Search"
	#  indexer:status
	assert_command_contains "indexer:status" "Update On"
	#  info:adminuri
	assert_command_contains "info:adminuri" "Admin URI:"
	#  info:backups:list
	assert_command_contains "info:backup:list" "No backup files found."
	#  info:currency:list
	assert_command_contains "info:currency:list" "S Dollar (USD)"
	#  info:dependencies:show-framework
	#  info:dependencies:show-modules
	assert_command_contains "info:dependencies:show-modules" "Report successfully processed."
	#  info:dependencies:show-modules-circular
	#  info:language:list
	assert_command_contains "info:language:list" "German (Germany)"
	#  info:timezone:list
	assert_command_contains "info:timezone:list" "Europe/Berlin"
	#  inventory-geonames:import
	#  inventory:reservation:create-compensations
	#  inventory:reservation:list-inconsistencies
	#  list (covered by n98-magerun list command)
	#  maintenance:allow-ips
	assert_command_contains "maintenance:allow-ips 127.0.0.1" "Set exempt IP-addresses: 127.0.0.1"
	#  maintenance:enable
	assert_command_contains "maintenance:enable" "Enabled maintenance mode"
	#  maintenance:disable
	assert_command_contains "maintenance:disable" "Disabled maintenance mode"
	#  maintenance:status
	assert_command_contains "maintenance:status" "Status: maintenance mode is not active"
	#  module:config:status
	assert_command_contains "module:config:status" "The modules configuration is up to date."
	#  module:disable
	#  module:enable
	#  module:status
	assert_command_contains "module:status" "List of enabled modules"
	#  module:uninstall
	#  msp:security:recaptcha:disable
	#  msp:security:tfa:disable
	#  msp:security:tfa:providers
	#  msp:security:tfa:reset
	#  newrelic:create:deploy-marker
	#  queue:consumers:list
	assert_command_contains "queue:consumers:list" "async.operations.all"
	#  queue:consumers:start
	#  sampledata:deploy
	#  sampledata:remove
	#  sampledata:reset
	#  setup:backup
	#  setup:config:set
	#  setup:db-data:upgrade
	assert_command_contains "setup:db-data:upgrade" "Data install/update"
	#  setup:db-declaration:generate-patch
	#  setup:db-declaration:generate-whitelist
	#  setup:db-schema:upgrade
	assert_command_contains "setup:db-schema:upgrade" "Schema creation/updates"
	#  setup:db:status (currently disabled. Seems to be inconsistent between different Magento versions)
	#assert_command_contains "setup:db:status" "All modules are up to date."
	#  setup:di:compile
	#  setup:install
	#  setup:performance:generate-fixtures
	#  setup:rollback
	#  setup:static-content:deploy
	#  setup:store-config:set
	#  setup:uninstall
	#  setup:upgrade
	#  store:list
	assert_command_contains "store:list" "Website ID"
	#  store:website:list
	assert_command_contains "store:website:list" "Admin"
	#  theme:uninstall
	#  varnish:vcl:generate
	assert_command_contains "varnish:vcl:generate" "vcl 4.0"
	#  vertex:tax:warm-wsdl-cache
	#  yotpo:reset
	#  yotpo:sync
	#  yotpo:update-metadata

}

function test_custom_module() {
	mkdir -p $MAGENTO_ROOT_DIR/lib/n98-magerun2/modules;
	cp -r tests/example-module $MAGENTO_ROOT_DIR/lib/n98-magerun2/modules/example-module;

	assert_command_contains "magerun:example-module:test" "98.00"

	rm -Rf $MAGENTO_ROOT_DIR/lib/n98-magerun2/modules/example-module
}

verify;

echo "=================================================="
echo "MAGERUN COMMANDS"
echo "=================================================="
test_magerun_commands;

echo "=================================================="
echo "MAGERUN CUSTOM MODULE"
echo "=================================================="
test_custom_module;

echo "=================================================="
echo "MAGENTO CORE COMMANDS"
echo "=================================================="
test_magento_core_commands;

if [ $TESTS_WITH_ERRORS = true ]; then
	exit 1;
fi

exit 0;

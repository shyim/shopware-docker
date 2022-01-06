#!/usr/bin/env bash

B2B_ROOT="/var/www/html/$SHOPWARE_PROJECT/custom/b2b/components/SwagB2bPlatform"

TIMESTAMP=$(date +%s)

echo "<?php declare(strict_types=1);

namespace SwagB2bPlatform\Resources\Migration;

use Doctrine\DBAL\Connection;
use Shopware\B2B\Common\Migration\MigrationStepInterface;
use Symfony\Component\DependencyInjection\Container;

class Migration${TIMESTAMP} implements MigrationStepInterface
{
    public function getCreationTimeStamp(): int
    {
      return ${TIMESTAMP};
    }

    public function updateDatabase(Connection \$connection): void
    {
        \$connection->executeStatement('');
    }

    public function updateThroughServices(Container \$container): void
    {
        // nth
    }
}" > "${B2B_ROOT}/Resources/Migration/Migration${TIMESTAMP}.php"
<?php
/**
 * Part of Teinte https://github.com/oeuvres/teinte
 * Copyright (c) 2020 frederic.glorieux@fictif.org
 * Copyright (c) 2013 frederic.glorieux@fictif.org & LABEX OBVIL
 * Copyright (c) 2012 frederic.glorieux@fictif.org
 * BSD-3-Clause https://opensource.org/licenses/BSD-3-Clause
 */

declare(strict_types=1);

namespace Oeuvres\Kit;

use PDO;

use Oeuvres\Kit\File;

/**
 * code convention https://www.php-fig.org/psr/psr-12/
 */
class Sqlite
{
    /**
     * get a pdo link to an sqlite database with good options
     */
    public static function pdo(string $sqliteFile, string $create): PDO
    {
        $dsn = "sqlite:" . $sqliteFile;
        // if not exists, create
        if (!file_exists($sqliteFile)) {
            return self::sqlcreate($sqliteFile, $create);
        }
        else {
            return self::sqlopen($sqliteFile, $create);
        }
    }

    /**
     * Open a pdo link
     */
    private static function sqlopen(string $sqliteFile): PDO
    {
        $dsn = "sqlite:" . $sqliteFile;
        $pdo = new PDO($dsn);
        $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
        $pdo->exec("PRAGMA temp_store = 2;");
        return $pdo;
    }

    /**
     * Renew a database with an SQL script to create tables
     */
    private static function sqlcreate(string $sqliteFile, string $create): PDO
    {
        if (file_exists($sqliteFile)) unlink($sqliteFile);
        File::mkdir(dirname($sqliteFile));
        $pdo = self::sqlopen($sqliteFile);
        @chmod($sqliteFile, 0775);
        $pdo->exec($create);
        return $pdo;
    }
}

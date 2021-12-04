<?php

/**
 * code convention https://www.php-fig.org/psr/psr-12/
 *
 */

declare(strict_types=1);

namespace Oeuvres\Teinte;

use PDO;

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

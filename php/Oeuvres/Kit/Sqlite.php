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
     * Open a pdo link, alert if not there
     */
    public static function open(string $sqliteFile): PDO
    {
        Filesys::readable($sqliteFile, "Sqlite base impossible to open");
        $dsn = "sqlite:" . $sqliteFile;
        $pdo = new PDO($dsn);
        $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
        $pdo->exec("PRAGMA temp_store = 2;");
        return $pdo;
    }

    /**
     * Renew a database with an SQL script to create tables
     */
    public static function create(string $sqliteFile, string $create): PDO
    {
        if (file_exists($sqliteFile)) unlink($sqliteFile);
        Filesys::mkdir(dirname($sqliteFile));
        $pdo = self::open($sqliteFile);
        @chmod($sqliteFile, 0775);
        $pdo->exec($create);
        return $pdo;
    }
}

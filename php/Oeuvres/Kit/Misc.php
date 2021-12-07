<?php
/**
 * code convention https://www.php-fig.org/psr/psr-12/
 *
 */

declare(strict_types=1);

namespace Oeuvres\Kit;

class Misc
{

    static function mois($num)
    {
        $mois = array(
            1 => 'janvier',
            2 => 'février',
            3 => 'mars',
            4 => 'avril',
            5 => 'mai',
            6 => 'juin',
            7 => 'juillet',
            8 => 'août',
            9 => 'septembre',
            10 => 'octobre',
            11 => 'novembre',
            12 => 'décembre',
        );
        return $mois[(int)$num];
    }


}

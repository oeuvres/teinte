<?php
/**
 * Part of Teinte https://github.com/oeuvres/teinte
 * MIT License https://opensource.org/licenses/mit-license.php
 * Copyright (c) 2022 frederic.Glorieux@fictif.org
 * Copyright (c) 2013 Frederic.Glorieux@fictif.org & LABEX OBVIL
 * Copyright (c) 2012 Frederic.Glorieux@fictif.org
 * Copyright (c) 2010 Frederic.Glorieux@fictif.org
 *                    & École nationale des chartes
 */

declare(strict_types=1);

namespace Oeuvres\Kit;

use Oeuvres\Kit\{I18n};

Route::init();

class Route {
    /** root directory of the app = directory of index.php */
    private static $app_dir;
    /** home href for routing */
    private static $home;
    /** Href to app resources */
    private static $app_href;
    /** Default php template */
    private static $template;
    /** An html file to include as main */
    static $main_inc;
    /** A file to include */
    static $main_contents;
    /** Path relative to the root app */
    static $url_request;
    /** Split of url parts */
    static $url_parts;
    /** Has a routage been done ? */
    static $routed;

    public static function init()
    {
        self::$app_dir = dirname(dirname(dirname(__DIR__))) . DIRECTORY_SEPARATOR ;

        $url_request = filter_var($_SERVER['REQUEST_URI'], FILTER_SANITIZE_URL);
        $url_request = strtok($url_request, '?'); // old
        // maybe not robust, this should interpret path relative to the webapp
        // domain.com/subdir/verbatim/path/perso -> /path/perso
        $url_prefix = rtrim(dirname($_SERVER['PHP_SELF']), '/\\');
        if ($url_prefix && strpos($url_request, $url_prefix) !== FALSE) {
            $url_request = substr($url_request, strlen($url_prefix));
        }
        self::$url_request = $url_request;
        self::$url_parts = explode('/', ltrim($url_request, '/'));
        self::$home = str_repeat('../', count(self::$url_parts) - 1);
        // get relative path from index.php caller to the root of app to calculate href for res
        self::$app_href = self::$home . File::relpath(
            dirname($_SERVER['SCRIPT_FILENAME']), 
            self::$app_dir
        );
    }
    public static function get($route, $php, $pars=null)
    {
        if ($_SERVER['REQUEST_METHOD'] == 'GET') {
            self::route($route, $php, $pars);
        }
    }
    public static function post($route, $php, $pars=null)
    {
        if ($_SERVER['REQUEST_METHOD'] == 'POST') {
            self::route($route, $php, $pars);
        }
    }

    /**
     * Populate a page with content
     */
    public static function main(): void
    {
        echo Route::$main_contents;
        if (function_exists('main')) {
            call_user_func('main');
        }
        // a content to include here 
        else if (Route::$main_inc) {
            include_once(Route::$main_inc);
        }
    }

    /**
     * Display a <title> for the page 
     */
    public static function title($title=null): string
    {
        if (function_exists('title')) {
            return call_user_func('title');
        }
        else if ($title) {
            return $title;
        }
        else {
            return I18n::_('app');
        }
    }

    /**
     * Check if a route match url
     */
    public static function match($route)
    {
        $route_parts = explode('/', ltrim($route, '/'));
        // too long url
        if (count($route_parts) != count(self::$url_parts)) {
            return false;
        }
        // test if path is matching
        for ($i = 0; $i < count($route_parts); $i++) {
            // escape ^and $ ?
            $search = '/^'.$route_parts[$i].'$/';
            if(!preg_match($search, self::$url_parts[$i])) {
                return false;
            }
        }
        return true;
    }

    /**
     * Try a route
     */
    public static function route($route, $file, $pars=null)
    {
        // the catchall
        if ($route == "/404") {
            http_response_code(404);
        }
        // check route as a regex
        else if (!self::match($route)) {
            return false;
        }
        // rewrite file destination according to $route url
        preg_match('@'.$route.'@', self::$url_request, $route_match);
        $file = self::replace($file, $route_match);
        if (!File::isabs($file)) {
            $file = self::$app_dir . $file;
        }
        // file not found, let chain continue
        if (!file_exists($file)) {
            return;
        }
        // modyfy parameters according to route
        if ($pars != null) {
            foreach($pars as $key => $value) {
                $pars[$key] = self::replace($value, $route_match);
            }
            $_REQUEST = array_merge($_REQUEST, $pars);
            $_GET = array_merge($_GET, $pars);
        }

        $ext = pathinfo($file, PATHINFO_EXTENSION);
        // html to include in template
        if ($ext == 'html' || $ext == 'htm') {
            self::$main_inc = $file;
        }
        // supposed to be php 
        else {
            ob_start();
            include_once($file);
            // capture un
            self::$main_contents = ob_get_contents();
            ob_end_clean();
        }
        self::$routed = true;
        include_once(Route::$template);
        exit();
    }

    /**
     * Set template
     */
    Static public function template(string $template): void
    {
        self::$template = $template;
    }
    /**
     * Return app_href, optional, if the index.php is outside app_dir
     */
    static public function app_href(): string
    {
        return self::$app_href;
    }
    /**
     * Set app_href prefix, optional, if the index.php is outside app_dir
     */
    static public function home(): string
    {
        return self::$home;
    }

    /**
     * Replace $n by $values[$n]
     */
    static public function replace($pattern, $values)
    {
        if (!$values && !count($values)) {
            return $pattern;
        }
        $ret = preg_replace_callback(
            '@\$(\d+)@',
            function ($var_match) use ($values) {
                $n = $var_match[1];
                if (!isset($values[$n])) {
                    return $var_match[0];
                }
                // ensure no slash, to dangerous
                $filename = $values[$n]; 
                $filename = preg_replace('@\.\.|/|\\\\@', '', $filename);
                return $filename;
            },
            $pattern
        );
        return $ret;
    }

}

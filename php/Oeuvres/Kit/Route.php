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

use Oeuvres\Kit\{File, I18n};
use Exception;


Route::init();
class Route
{
    /** root directory of the app when outside site */
    private static $app_dir;
    /** Home dir where is the index.php answering */
    private static $home_dir;
    /** Home href for routing */
    private static $home_href;
    /** Default php template */
    private static $templates = array();
    /** An html file to include as main */
    private static $main_inc;
    /** A file to include */
    private static $main_contents;
    /** Path relative to home */
    private static $request_path;
    /** Split of url parts */
    private static $request_chunks;
    /** Store a lang */
    private static $lang = '';
    /** The resource to deliver */
    private static $resource;
    /** Has a routage been done ? */
    private static $routed;

    public static function init()
    {
        self::$app_dir = dirname(__DIR__, 3) . DIRECTORY_SEPARATOR;

        $request_url = filter_var($_SERVER['REQUEST_URI'], FILTER_SANITIZE_URL);
        $request_url = strtok($request_url, '?'); // old
        // maybe not robust, this should interpret path relative to the webapp
        // domain.com/subdir/verbatim/path/perso -> /path/perso
        $url_prefix = rtrim(dirname($_SERVER['PHP_SELF']), '/\\');
        if ($url_prefix && strpos($request_url, $url_prefix) !== FALSE) {
            $request_url = substr($request_url, strlen($url_prefix));
        }
        self::$request_path = $request_url;
        self::$request_chunks = explode('/', ltrim($request_url, '/'));

        self::$home_dir = getcwd();
        self::$home_href = str_repeat('../', count(self::$request_chunks) - 1);
    }
    public static function get($route, $php, $pars = null)
    {
        if ($_SERVER['REQUEST_METHOD'] == 'GET') {
            self::route($route, $php, $pars);
        }
    }
    public static function post($route, $php, $pars = null)
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
    public static function title($default = null): string
    {
        if (function_exists('title')) {
            $title = call_user_func('title');
            if ($title) return $title;
        }
        if ($default) {
            return $default;
        }
        return I18n::_('title');
    }

    /**
     * Display metadata for a page
     */
    public static function meta($default = null): string
    {
        if (function_exists('meta')) {
            $meta = call_user_func('meta');
            if ($meta) return $meta;
        }
        if ($default) {
            return $default;
        }
        return "<title>" . I18n::_('title') . "</title>";
    }

    /**
     * Draw an html tab for a navigation with test if selected 
     */
    public static function tab($href, $text)
    {
        $selected = '';
        if (ltrim(self::$request_path, '/') == $href) {
            $selected = " selected";
        }
        if (!$href) {
            $href = '.';
        }
        return '<a class="tab' . $selected . '"'
            . ' href="' . self::home_href() . $href . '"'
            . '>' . $text . '</a>';
    }

    /**
     * Check if a route match url
     */
    public static function match($route)
    {
        $route_chunks = explode('/', ltrim($route, '/'));
        // too long url
        if (count($route_chunks) != count(self::$request_chunks)) {
            return false;
        }
        // test if path is matching
        for ($i = 0; $i < count($route_chunks); $i++) {
            // escape ^and $ ?
            $search = '/^' . $route_chunks[$i] . '$/';
            if (!preg_match($search, self::$request_chunks[$i])) {
                return false;
            }
        }
        return true;
    }

    /**
     * Try a route
     */
    public static function route(
        string $route,
        string $resource,
        ?array $pars = null,
        ?string $tmpl_key = ''
    ): bool {
        // the catchall
        if ($route == "/404") {
            http_response_code(404);
        }
        // check route as a regex
        else if (!self::match($route)) {
            return false;
        }
        // rewrite file destination according to $route url
        preg_match('@' . $route . '@', self::$request_path, $route_match);
        $resource = self::replace($resource, $route_match);
        if (!File::isabs($resource)) {
            // resolve links from welcome page
            $resource = self::$home_dir . $resource;
        }
        // file not found, let chain continue
        if (!file_exists($resource)) {
            return false;
        }
        // modyfy parameters according to route
        if ($pars != null) {
            foreach ($pars as $key => $value) {
                $pars[$key] = urldecode(self::replace($value, $route_match));
            }
            $_REQUEST = array_merge($_REQUEST, $pars);
            $_GET = array_merge($_GET, $pars);
        }

        $ext = pathinfo($resource, PATHINFO_EXTENSION);
        // should be routed
        self::$routed = true;
        self::$resource = $resource;

        $tmpl_php = null;
        // default, no template registred, no temple requested, OK
        if ($tmpl_key === '' && count(self::$templates) < 1) {
        }
        // default, no template requested, send first if one exists
        else if ($tmpl_key === '') {
            $tmpl_php = self::$templates[array_key_first(self::$templates)];
        }
        // explitly no template requested
        else if ($tmpl_key === null) {
        } else {
            if (count(self::$templates) < 1) {
                throw new Exception(
                    "Developement error.
No templates registred, template '$tmpl_key' not found.
Use Route::template('tmpl_my.php', '$tmpl_key');"
                );
                exit();
            }
            if (!isset(self::$templates[$tmpl_key])) {
                throw new Exception(
                    "Developement error.
Template '$tmpl_key' not found.
Use Route::template('tmpl_my.php', '$tmpl_key');"
                );
                exit();
            }
            $tmpl_php = self::$templates[$tmpl_key];
        }
        // if no template requested include flow
        if ($tmpl_php == null) {
            include_once($resource);
            exit();
        }
        // html to include in template
        if ($ext == 'html' || $ext == 'htm') {
            self::$main_inc = $resource;
        }
        // supposed to be php 
        else {
            // capture content if it is php direct
            ob_start();
            include_once($resource);
            // capture un
            self::$main_contents = ob_get_contents();
            ob_end_clean();
        }
        // now everything should be OK to render page
        // template should call at least Route::main() to display something 
        include_once($tmpl_php);
        exit();
    }

    /**
     * Append a template
     */
    static public function template(
        string $tmpl_php,
        ?string $key = null
    ): void {
        if (!File::readable($tmpl_php)) {
            // will send exceptions if template is not readable
            return;
        } else if ($key !== null && $key !== '') {
            self::$templates[$key] = $tmpl_php;
        } else {
            self::$templates[] = $tmpl_php;
        }
    }

    /**
     * Return app_dir, optional, useful if the index.php is outside app_dir
     */
    static public function app_dir(): string
    {
        return self::$app_dir;
    }

    /**
     * Request has been routed
     */
    static public function found(): bool
    {
        return self::$routed;
    }

    /**
     * Href for a resource, resolved from the php caller, usually, a template, 
     * and relative to request
     */
    static public function res_href($path): string
    {
        // seems an absolute path
        if (preg_match('@^/|^[A-Z]:[/\\\\]@', $path)) {
            $res_file = $path;
        } else {
            // get the path of the caller
            $bt = debug_backtrace();
            $php_file = $bt[0]['file'];
            $res_file = dirname($php_file) . '/' . $path;
        }
        // get relative path from php_file caller to the root of app to calculate href for resources in this folder
        $res_href = self::$home_href . File::relpath(
            dirname($_SERVER['SCRIPT_FILENAME']),
            $res_file
        );
        return $res_href;
    }

    /**
     * Set or return a language
     */
    static public function lang(?string $lang = ''): string
    {
        // first setter win
        if (!self::$lang && $lang) self::$lang = $lang;
        return self::$lang;
    }

    /**
     * Returns a relative href link to the root of the site (the first index.php handler)
     */
    static public function home_href(): string
    {
        return self::$home_href;
    }
    /**
     * home_dir, default is the index.php caller.
     */
    static public function home_dir($home_dir = null): string
    {
        if ($home_dir !== null) self::$home_dir = $home_dir;
        return self::$home_dir;
    }

    /**
     * Return the original request path
     */
    static public function request_path(): string
    {
        return self::$request_path;
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

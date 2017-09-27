xquery version "3.1";

module namespace app="http://gawati.org/xq/portal/app";

declare namespace gwd="http://gawati.org/ns/1.0/data";
declare namespace xh = "http://www.w3.org/1999/xhtml";
declare namespace gsc = "http://gawati.org/portal/services";
declare namespace an="http://docs.oasis-open.org/legaldocml/ns/akn/3.0";

import module namespace templates="http://exist-db.org/xquery/templates" at "templates.xql";
import module namespace config="http://gawati.org/xq/portal/config" at "config.xqm";
import module namespace docread="http://gawati.org/xq/portal/doc/read" at "docread.xql";
import module namespace utils="http://gawati.org/xq/portal/utils" at "utils.xql";
import module namespace langs="http://gawati.org/xq/portal/langs" at "langs.xql";
import module namespace render="http://gawati.org/xq/portal/render" at "render.xql";
import module namespace app-sys="http://gawati.org/xq/portal/app/sys" at "app-sys.xql";
import module namespace andoc="http://exist-db.org/xquery/apps/akomantoso30" at "akomantoso.xql";
import module namespace app-block="http://gawati.org/xq/portal/app/block" at "app-block.xql";
import module namespace utils-date="http://gawati.org/xq/portal/utils/date" at "utils-date.xql";

(:
 : This module provides UI facing end-points. 
 : All retrieval functionality is called from here
 :)


(:~
 : This is a sample templating function. It will be called by the templating module if
 : it encounters an HTML element with an attribute data-template="app:test" 
 : or class="app:test" (deprecated). The function has to take at least 2 default
 : parameters. Additional parameters will be mapped to matching request or session parameters.
 : 
 : @param $node the HTML node with the attribute which triggered this call
 : @param $model a map containing arbitrary data - used to pass information between template calls
 :)
declare function app:test($node as node(), $model as map(*)) {
    <p>Dummy template output generated by function app:test at {current-dateTime()}. The templating
        function was triggered by the data-template attribute <code>data-template="app:test"</code>.</p>
};

(:~
 : Sets up the page with the Akoma Ntoso document in the model. This is typically called in a template
 : where there are repeated accesses of the document content. To prevent re-lookup of the document
 : the document is queried and added to the page model one, after that it is available in all following
 : template functions called on the same page, but to do that you need to return the map(*) to propagate
 : the model across the page context
 :)
declare
function app:page-setup(
    $node as node(), 
    $model as map(*), 
    $iri as xs:string, 
    $lang as xs:string
    ) as map(*) {
    if ($iri eq 'latest') then
        $model
    else
        let $doc := docread:doc-by-iri($iri)
        return
            map {
               "doc" := document {$doc},
               "iri" := $iri
            }
};


(:~
 : Calls the Renderer for showing the document title, date and other primary metadata
 : It uses the document model passed in via the Model map. 
 :
 :)
declare
function app:document-header($node as node(), $model as map(*), $iri as xs:string, $lang as xs:string) {
      app-block:document-header($model, $iri, $lang)
};

declare
function app:document-info($node as node(), $model as map(*), $iri as xs:string, $lang as xs:string) {
      app-block:document-info($model, $iri, $lang)
};

declare
function app:document-content($node as node(), $model as map(*), $iri as xs:string, $lang as xs:string) {
      app-block:document-content($model, $iri, $lang)
};

declare
function app:document-timeline($node as node(), $model as map(*), $iri as xs:string, $lang as xs:string) {
      app-block:document-timeline($model, $iri, $lang)
};


declare 
%templates:wrap
function app:docs-summary($node as node(), $model as map(*), $lang as xs:string, $count as xs:integer, $from as xs:integer) {
    let $docs := docread:recent-docs($lang, $count, $from)

    let $abstrs := $docs//gwd:exprAbstracts/gwd:exprAbstract
    return
    (: Read each extract herer and render as an article :)
    for $abstr in $abstrs
        (: build a map here to pass to the renderer API :)
         let $o := map {
            "e-iri" := $abstr/@expr-iri,
            "w-iri" := $abstr/@work-iri,
            "e-date" := utils-date:show-date($abstr/gwd:date[@name = 'expression']/@value),
            "w-date" := utils-date:show-date($abstr/gwd:date[@name = 'work']/@value),
            "w-country" := data($abstr/gwd:country/@value),
            "w-country-name" := data($abstr/gwd:country/@showAs),
            "e-lang" := langs:lang3-name($abstr/gwd:language/@value),
            "w-num" := data($abstr/gwd:number/@showAs),
            "pub-as" := data($abstr/gwd:publishedAs/@showAs),
            (: generate a URL to the thumbnail :)
            "th-url" := docread:thumbnail-url(
                data($abstr/gwd:thumbnailPresent/@value), 
                $abstr/@expr-iri
             ),
            "e-url" := "./document.html?iri=" || $abstr/@expr-iri
        }
        return
            render:documentRow($o, $lang)

};




(:
Include static js
:)
declare function app:js($node as node(), $model as map(*), $page as xs:string) 
    as element(xh:script)* {
    app-sys:js($node, $model, $page)
};

declare function app:js($node as node(), $model as map(*), $page as xs:string, $ifpage as xs:string) 
    as element(xh:script)* {
    app-sys:js($node, $model, $page)
};

(:
Include static js
:)
declare function app:css(
    $node as node(), 
    $model as map(*), 
    $page as xs:string
    )as element()* {
    app-sys:css($node, $model, $page)
};

declare function app:css(
    $node as node(), 
    $model as map(*), 
    $page as xs:string, 
    $ifpage as xs:string
    )as element()* {
    app-sys:css($node, $model, $page)
};


(:
Include dynamic js
:)
declare function app:dyn-js(
    $node as node(), 
    $model as map(*), 
    $iri as xs:string,
    $jsname as xs:string,
    $ifpage as xs:string, 
    $custom as xs:string) as element(xh:script)* {
    app-sys:dyn-js($node, $model, $iri, $jsname, $ifpage, $custom)
};

declare function app:dyn-css(
    $node as node(), 
    $model as map(*), 
    $iri as xs:string,
    $cssname as xs:string,
    $ifpage as xs:string, 
    $custom as xs:string) as element()* {
    app-sys:dyn-css(
        $node, 
        $model, 
        $iri, 
        $cssname, 
        $ifpage, 
        $custom
    )
};


(:
Include static js
:)



declare 
%templates:wrap
function app:works-summary($node as node(), $model as map(*), $lang as xs:string) {
    docread:recent-works()
};


declare %templates:wrap
function app:version-info($node as node(), $model as map(*)) {
    <xh:span> {
        "Version: " ||
        $config:expath-doc/@spec || "." ||
        $config:expath-doc/@version || " @ "  || 
        $config:expath-doc/@date
    } </xh:span>
};



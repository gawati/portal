xquery version "3.1";
(:~
 : This library has end-point renderers to HTML for items received from the server
 : @author Ashok Hariharan
 :)
module namespace render="http://gawati.org/xq/portal/render";
declare namespace gw="http://gawati.org/ns/1.0";
declare namespace gwd="http://gawati.org/ns/1.0/data";
declare namespace an="http://docs.oasis-open.org/legaldocml/ns/akn/3.0";
import module namespace app-document="http://gawati.org/xq/portal/app/document" at "app-document.xql"; 
import module namespace config="http://gawati.org/xq/portal/config" at "config.xqm";
import module namespace utils="http://gawati.org/xq/portal/utils" at "utils.xql";
import module namespace app-utils="http://gawati.org/xq/portal/app/utils" at "app-utils.xql"; 


declare function local:render-padding($length as xs:integer, $limit as xs:integer) {
    if ($length lt $limit) then 
        for $p in (1 to $limit - $length ) 
            return "&#160;" 
    else () 
};

declare function render:documentRow($o as map(*),$lang as xs:string) {
    let $country-search-link := app-utils:search-link-country($lang, $o('w-country'))
    let $lang-search-link := app-utils:search-link-doclang($lang, $o('e-lang-code'))
    let $short-title := app-document:short-title($o("pub-as"))
    let $len-short-title := string-length($short-title)
    let $len-pub-as := string-length($o('pub-as'))
	return
	<div class="feed w-clearfix">
			<h2><a href="{$o('e-url')}">{
 			    $short-title
			}</a>{local:render-padding($len-short-title, 50) }</h2>
			<div class="text-block">
				<a href="{$country-search-link}"> {$o('w-country-name')} </a> &#160;| &#160; 
				<a href="{$lang-search-link}">{$o('e-lang')}</a> &#160;| &#160;
				<a href="#">{$o('e-date')} </a>
			</div>
			<img src="{$o('th-url')}"  style="border:1px solid;" />
			<p>{$o('pub-as')}{local:render-padding($len-pub-as, 96)}</p>
			<div class="div-block-18 w-clearfix">
				<a class="more-button" href="{$o('e-url')}">more...</a>
			</div>
 			<div class="grey-rule"></div>
	</div>
};


declare function render:exprAbstract($o as map(*), $lang as xs:string) {
      <article class="search-result row">
    	<div class="col-xs-12 col-sm-12 col-md-3">
    		<a href="{$o('e-url')}" title="{$o('pub-as')}" class="thmb">
    		        <img style="padding:1px;
   border:1px solid #021a40;" src="{$o('th-url')}" height="160" alt="Lorem ipsum" />
    		</a>
    	</div>
    	<div class="col-xs-12 col-sm-12 col-md-2">
    		<ul class="meta-search">
    			<li><i class="fa fa-calendar"></i> <span>{$o('e-date')}</span></li>
    			<li><i class="fa fa-address-card-o"></i> <span>{$o('w-num')}</span></li>
    			<li><i class="fa fa-language"></i> <span>{$o('e-lang')}</span></li>
    		</ul>
    	</div>
    	<div class="col-xs-12 col-sm-12 col-md-7 excerpt">
    		<h3><a href="{$o('e-url')}" title="">{$o('pub-as')}</a></h3>
    		<p>Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatem, exercitationem, suscipit, distinctio, qui sapiente aspernatur molestiae non corporis magni sit sequi iusto debitis delectus doloremque.</p>						
            <span class="plus">
              <a href="#" title="Lorem ipsum">
                <i class="fa fa-plus"></i>
              </a>
            </span>
    	</div>
    	<span class="clearfix"></span>
    </article>
};

xquery version "3.1";

(:~
 : This module interfaces with the data retrieval services
 :
 :)
module namespace gawati-templates="http://gawati.org/xq/templates";
import module namespace config="http://gawati.org/xq/portal/config" at "config.xqm";

declare function gawati-templates:active-theme() {
    data(config:themes()/@activeTheme)
};

declare function gawati-templates:template-url($svc-url, $template-name) {
   $svc-url || "/" || gawati-templates:active-theme() || "/"  || $template-name
};

declare function gawati-templates:template-server-path() {
    let $svc := config:service-config(
        "gawati-template-server"
    )
    return local:negotiate-url-type($svc)|| $svc("service")/@end-point 
};

(:~
 : Based on the specified service type, provides the private or public base url prefix
 :)
declare function local:negotiate-url-type($svc) {
        if ($svc("type") eq 'private' ) then 
            $svc("private-base-url") 
        else 
            $svc("public-base-url") 
};

(:
Retrieves a template from the server
:)
declare function gawati-templates:template($template-name) {
    let $svc := config:service-config(
        "gawati-template-server"
    )
    let $svc-url :=  local:negotiate-url-type($svc)|| $svc("service")/@end-point 
    let $request := 
        <hc:request href="{gawati-templates:template-url($svc-url, $template-name)}" method="GET">
            <hc:header name="Connection" value="close"/>    
        </hc:request>
    let $response := hc:send-request($request)
    let $resp-head := $response[1]
    let $resp-body := $response[2]
    let $status := $resp-head/@status
    return
        if (starts-with($status, "4") or starts-with($status, "5")) then
            $resp-head
        else
            $resp-body
};
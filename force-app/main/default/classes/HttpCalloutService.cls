public with sharing class HttpCalloutService {

    private static final Integer DEFAULT_TIMEOUT = 30000;
    private static final Integer MAX_RETRIES     = 3;

    public class CalloutRequest {
        public String              namedCredential { get; set; }
        public String              path            { get; set; }
        public String              method          { get; set; }
        public String              body            { get; set; }
        public Map<String,String>  headers         { get; set; }
        public Integer             timeoutMs       { get; set; }

        public CalloutRequest(String namedCredential, String path, String method) {
            this.namedCredential = namedCredential;
            this.path            = path;
            this.method          = method;
            this.headers         = new Map<String,String>();
            this.timeoutMs       = DEFAULT_TIMEOUT;
        }
    }

    public class CalloutResponse {
        public Integer statusCode    { get; private set; }
        public String  body          { get; private set; }
        public Boolean success       { get; private set; }
        public String  errorMessage  { get; private set; }

        public CalloutResponse(HttpResponse res) {
            this.statusCode = res.getStatusCode();
            this.body       = res.getBody();
            this.success    = (statusCode >= 200 && statusCode < 300);
            if (!success) {
                this.errorMessage = 'HTTP ' + statusCode + ' - ' + res.getStatus() + ': ' + body;
            }
        }

        public Map<String,Object> getBodyAsMap() {
            if (String.isBlank(body)) return new Map<String,Object>();
            return (Map<String,Object>) JSON.deserializeUntyped(body);
        }
    }

    public static CalloutResponse send(CalloutRequest request) {
        HttpRequest req  = buildRequest(request);
        Http        http = new Http();
        HttpResponse res;
        Integer attempts = 0;

        while (attempts < MAX_RETRIES) {
            try {
                res = http.send(req);
                if (res.getStatusCode() < 500 && res.getStatusCode() != 429) break;
            } catch (CalloutException e) {
                if (attempts == MAX_RETRIES - 1) throw e;
            }
            attempts++;
        }

        return new CalloutResponse(res);
    }

    private static HttpRequest buildRequest(CalloutRequest request) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:' + request.namedCredential + request.path);
        req.setMethod(request.method);
        req.setTimeout(request.timeoutMs);
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept',       'application/json');
        if (request.headers != null) {
            for (String key : request.headers.keySet()) {
                req.setHeader(key, request.headers.get(key));
            }
        }
        if (String.isNotBlank(request.body)) {
            req.setBody(request.body);
        }
        return req;
    }
}

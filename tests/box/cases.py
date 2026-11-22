"""The requests the box runner makes, and what each must answer.

A case is a dict:
    route     the route, as it follows index.cfm? ("" is the home page)
    method    optional, GET when left out
    status    the expected status code
    contains  optional list of texts the body must contain
    lacks     optional list of texts the body must not contain
    headers   optional dict of response headers that must have this value

The routes come from app/Config/Routes.cfm plus tests/_support.
"""

CASES = [
    {"route": "", "status": 200, "contains": ["Welcome to ColdIgniter"]},
    {"route": "/hello/world", "status": 200, "contains": ["hello [world]"]},
    {"route": "/sum/3/4", "status": 200, "contains": ["sum=7"]},
    {"route": "/sum/3/x", "status": 404},
    {"route": "/resp", "status": 201, "contains": ["made"], "headers": {"X-Test": "yes"}},
    {"route": "/data", "status": 200, "contains": ["<h1>A title</h1>", "(a)(b)(c)"]},
    {"route": "/posted", "method": "POST", "status": 200, "contains": ["posted"]},
    {"route": "/posted", "status": 404},
    {"route": "/nope", "status": 404},
    {"route": "/test/_hidden", "status": 404, "lacks": ["hidden"]},
    {"route": "/hello/a<b", "status": 400, "lacks": ["a<b"]},
]

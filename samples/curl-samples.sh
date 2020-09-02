#!/usr/bin/env bash
#test the REST
curl http://localhost:8080/hello -i

# HOT Reload CRITICAL
curl -H "x-tyk-authorization: Zls7rrBtx7hwDfk2G6rSJUskBZc31D8I" -s http://localhost:8080/tyk/reload/group | python -mjson.tool


# Make an api via curl...
curl -v -H "x-tyk-authorization: Zls7rrBtx7hwDfk2G6rSJUskBZc31D8I" \
  -s \
  -H "Content-Type: application/json" \
  -X POST \
  -d '{
    "name": "Dave Test API",
    "slug": "dave-test-api",
    "api_id": "100",
    "org_id": "default",
    "auth": {
      "auth_header_name": "Authorization"
    },
    "definition": {
      "location": "header",
      "key": "x-api-version"
    },
    "version_data": {
      "not_versioned": true,
      "versions": {
        "Default": {
          "name": "Default",
          "use_extended_paths": true
        }
      }
    },
    "proxy": {
      "listen_path": "/dave-test-api/",
      "target_url": "http://httpbin.org/",
      "strip_listen_path": true
    },
    "active": true
}' http://localhost:8080/tyk/apis/ | python -mjson.tool

## --------  API key
curl -X POST -H "x-tyk-authorization: Zls7rrBtx7hwDfk2G6rSJUskBZc31D8I" \
  -s \
  -H "Content-Type: application/json" \
  -X POST \
  -d '{
    "allowance": 1000,
    "rate": 1000,
    "per": 1,
    "expires": -1,
    "quota_max": -1,
    "org_id": "1",
    "quota_renews": 1449051461,
    "quota_remaining": -1,
    "quota_renewal_rate": 60,
    "access_rights": {
      "100": {
        "api_id": "100",
        "api_name": "Dave Test API",
        "versions": ["Default"]
      }
    },
    "meta_data": {}
  }' http://localhost:8080/tyk/keys/create | python -mjson.tool
#-response
{
    "action": "added",
    "key": "1bc0690cc2dad4a7c914aba6c539839b8",
    "key_hash": "d3f0c98a",
    "status": "ok"
}
# Dave Test API
{
    "action": "added",
    "key": "166671e73dc5649e29782e6e7cbb7c3e9",
    "key_hash": "78f6c993",
    "status": "ok"
}
##---------------------


curl -H "Authorization: Zls7rrBtx7hwDfk2G6rSJUskBZc31D8I" -s http://localhost:8080/dave-test-api/ | python -mjson.tool
curl -H "Authorization: 166671e73dc5649e29782e6e7cbb7c3e9" -s http://localhost:8080/dave-test-api/
curl -H "Authorization: 166671e73dc5649e29782e6e7cbb7c3e9" -s http://localhost:8080/dave-test-api/ -i

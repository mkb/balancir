
# TODO

## Needed for beta
* finish http error detection
* support all HTTP methods
* top-level interface
* distributor ratio configurable
* Rack::Client::Handler::Balancir


## Later
* idempotent
* what about notifications?
* auto-adjust ratio based on response time
* what if one particular call fails while others are OK?
* how to manually set a connection to up or down?
* how to customize failure logic
* how to prevent or stop flapping?

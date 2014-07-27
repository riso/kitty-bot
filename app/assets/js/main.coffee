'use strict'

require.config
  paths:
    jquery: "../lib/jquery/jquery"
    underscore: "../lib/underscorejs/underscore"
    angular: "../lib/angularjs/angular"
    "angular-resource" : "../lib/angularjs/angular-resource"
    "ng-infinite-scroll": "../lib/ngInfiniteScroll/ng-infinite-scroll"
  shim:
    underscore:
      exports: "_"
    jquery:
      exports: "$"
    angular:
      deps: ["jquery"]
      exports: "angular"
    "angular-resource":
      deps: ["angular"]
    "ng-infinite-scroll":
      deps: ["angular", "jquery"]

require ["angular", "angular-resource", "ng-infinite-scroll", "./app", "jquery", "underscore"], (angular) ->
  angular.bootstrap document, ["app"]

define ["angular"], (angular) ->
  kittybotServices = angular.module "kittybotServices", ["ngResource"]
  
  kittybotServices.factory "Todo", ["$resource", ($resource) ->
      $resource 'todos/:id', {id: '@id'}, {
        all: {method: 'GET', params:{id:""}, isArray: true}
        update: {method: 'PUT'}
      }
    ]

  kittybotServices.factory "Answer", ["$resource", ($resource) ->
      $resource 'answer', {}, {}
    ]

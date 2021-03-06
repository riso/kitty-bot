define ["jquery", "underscore", "angular", "services"], ($, _, angular) ->
  'use strict'

  module = angular.module "app", ["kittybotServices", "infinite-scroll"]

  module.controller 'TodoController', ['$scope', 'Todo', 'Answer', ($scope, Todo, Answer) ->
    $scope.todos = []
    $scope.addTodo = ->
      return if $.trim($scope.todoText) is ""
      todo = new Todo {content: "You say: #{$scope.todoText}"}
      todo.$save [], (value, responseHeaders) ->
        todo = new Todo {content: "Kittybot says: writing..."}
        todo.$save [], (value, responseHeaders) ->
          answer = Answer.get [], (value, responseHeaders) ->
            todo.content = "Kittybot says: #{value.content}"
            Todo.update {id: todo.id}, todo
      $scope.todoText = ''

    $scope.deleteTodo = (todo) ->
      todo.$delete()

    $scope.loadMoreTodos = ->
      last = _.min $scope.todos, (t) -> t.id
      Todo.all {offset: last.id}, (value, responseHeaders) ->
        todoIds = _.pluck $scope.todos, 'id'
        returnedIds = _.pluck value, 'id'
        differentIds = _.difference returnedIds, todoIds
        $scope.todos.push (_.filter value, (t) -> _.contains differentIds, t.id)...

    $scope.addMsg = (message) ->
      $scope.$apply ->
        todo = JSON.parse message.data
        $scope.todos = _.reject($scope.todos, (t) -> t.id == todo.id)
        $scope.todos.push todo

    $scope.listen = ->
      $scope.chatFeed = new EventSource "/chatfeed"
      $scope.chatFeed.addEventListener "message", $scope.addMsg, false

    $scope.listen()

    ]

  module.filter 'unsafe', ['$sce', ($sce) ->
    (val) ->
      $sce.trustAsHtml(val)
    ]

  module

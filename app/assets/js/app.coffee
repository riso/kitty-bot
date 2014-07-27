define ["jquery", "angular", "services"], ($, angular) ->
  'use strict'

  # From the zentasks application
  $.fn.editInPlace = (method, options...) ->
    this.each ->
      methods =
        init: (options) ->
          valid = (e) =>
            newValue = @input.val()
            options.onChange.call(options.context, newValue)
          cancel = (e) =>
            @el.show()
            @input.hide()
          @el = $(this).dblclick(methods.edit)
          @input = $("<input type='text' />")
            .insertBefore(@el)
            .keyup (e) ->
              switch(e.keyCode)
                # Enter key
                when 13 then $(this).blur()
                # Escape key
                when 27 then cancel(e)
            .blur(valid)
            .hide()
        edit: ->
          @input
            .val(@el.text())
            .show()
            .focus()
            .select()
          @el.hide()
        close: (newName) ->
          @el.text(newName).show()
          @input.hide()
      # jQuery approach: http://docs.jquery.com/Plugins/Authoring
      if ( methods[method] )
        return methods[ method ].apply(this, options)
      else if (typeof method == 'object')
        return methods.init.call(this, method)
      else
        $.error("Method " + method + " does not exist.")

  module = angular.module "app", ["kittybotServices", "infinite-scroll"]

  module.controller 'TodoController', ['$scope', 'Todo', 'Answer', ($scope, Todo, Answer) ->
    $scope.page = 0
    $scope.todos = []
    $scope.addTodo = ->
      return if $.trim($scope.todoText) is ""
      todo = new Todo {content: "You say: #{$scope.todoText}"}
      todo.$save [], (value, responseHeaders) ->
        $scope.todos.push todo
        answer = Answer.get [], (value, responseHeaders) ->
          todo = new Todo {content: "Kittybot says: #{value.content}"}
          todo.$save [], (value, responseHeaders) ->
            $scope.todos.push todo
      $scope.todoText = ''

    $scope.deleteTodo = (todo) ->
      todo.$delete()

    $scope.loadMoreTodos = ->
      Todo.all {page: $scope.page}, (value, responseHeaders) ->
        $scope.todos.push value...
        $scope.page += 1

    ]

  module.filter 'unsafe', ['$sce', ($sce) ->
    (val) ->
      $sce.trustAsHtml(val)
    ]

  module

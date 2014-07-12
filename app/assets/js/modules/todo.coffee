define ["app", "jquery", "underscore", "backbone"], (app, $, _, Backbone) ->


  answers = ["meow!", "purr", "meow meow"]
  
  getRandomInt = (min, max) -> Math.floor(Math.random() * (max - min)) + min
  
  generateAnswer = -> answers[getRandomInt(0, answers.length)]

  class app.Models.TodoModel extends Backbone.Model
    urlRoot: "/todos"

  class app.Collections.TodoCollection extends Backbone.Collection
    model: app.Models.TodoModel
    url: "/todos"
    comparator: (todo) ->
      todo.get("id")

  class app.Views.TodoItemView extends Backbone.View
    tagName: "li"
    initialize: ->
      _.bindAll.apply _, [@].concat(_.functions(@))
      @model.bind "sync", @render
      @model.bind "remove", @unrender
    render: ->
      that = @
      that.$el.html("<span class=\"edit\">#{@model.toJSON().content}</span> <a href=\"#\" class=\"delete\">X</a>")
      $(".edit", that.$el).editInPlace context: that, onChange: that.editTodo
      @
    remove: -> @model.destroy()
    unrender: -> @$el.remove()
    editTodo: (content) -> if content is "" then @model.toJSON() else @model.set("content", content).save @model.toJSON()

  class app.Views.TodoListView extends Backbone.View
    el: ".todos"
    events:
      "submit .todoform" : "addTodo"
      "click a.delete" : "deleteTodo"
    initialize: ->
      _.bindAll.apply _, [@].concat(_.functions(@))
      @collection = new app.Collections.TodoCollection
      @collection.fetch success: @render
    render: ->
      $(".todolist", @el).html "<ul></ul>"
      for model in @collection.models
        do (model) =>
          $(".todolist ul", @el).append new app.Views.TodoItemView(model: model).render().el
      @
    addTodo: (event) ->
      event.preventDefault()
      return if $.trim($("#content", event.target).val()) is ""
      that = @
      todo = new app.Models.TodoModel content: "You say:  #{$("#content", event.target).val()}"
      todo.save todo.toJSON(),
        success: (model, response, options) ->
          console.log model, response, options
          that.collection.add model
          $(".todolist ul", that.$el).append new app.Views.TodoItemView(model: model).render().el
          todo = new app.Models.TodoModel content: "Kittybot answers: #{generateAnswer()}"
          todo.save todo.toJSON(),
            success: (model, response, options) ->
              console.log model, response, options
              that.collection.add model
              $("#content", ".todoform").val("").blur()
              $(".todolist ul", that.$el).append new app.Views.TodoItemView(model: model).render().el
    deleteTodo: (event) ->
      event.preventDefault()
      todo = @collection.get $(event.target).closest("li").data("item-id")
      todo.destroy()

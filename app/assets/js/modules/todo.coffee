define ["app", "jquery", "underscore", "backbone"], (app, $, _, Backbone) ->

  $(window).scroll ->
    $('.todos').trigger "bottom" if $('body').height() <= ($(window).height() + $(window).scrollTop())

  class app.Models.TodoModel extends Backbone.Model
    urlRoot: "/todos"

  class app.Models.AnswerModel extends Backbone.Model
    url: "/answer"

  class app.Collections.TodoCollection extends Backbone.Collection
    model: app.Models.TodoModel
    url: "/todos"
    comparator: (todo) ->
      - todo.get("id")
    page: 1

  class app.Views.TodoItemView extends Backbone.View
    tagName: "li"
    initialize: ->
      _.bindAll.apply _, [@].concat(_.functions(@))
      @model.bind "sync", @render
      @model.bind "remove", @unrender
    render: ->
      that = @
      that.$el.html("<span class=\"edit\">#{@model.toJSON().content}</span> <a href=\"#\" class=\"delete\">X</a>").data "item-id", that.model.toJSON().id
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
      "click a#loadmore" : "loadMoreTodos"
      "bottom" : "loadMoreTodos"
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
      $(".todolist ul", @el).append "<li><a href=\"#\" id=\"loadmore\">Load more</a></li>"
    addTodo: (event) ->
      event.preventDefault()
      return if $.trim($("#content", event.target).val()) is ""
      that = @
      todo = new app.Models.TodoModel content: "You say:  #{$("#content", event.target).val()}"
      todo.save todo.toJSON(),
        success: (model, response, options) ->
          console.log model, response, options
          that.collection.add model
          $(".todolist ul", that.$el).prepend new app.Views.TodoItemView(model: model).render().el
          answer = new app.Models.AnswerModel()
          answer.fetch success: (model, response, options) ->
            todo = new app.Models.TodoModel content: "Kittybot answers: #{answer.toJSON().content}"
            todo.save todo.toJSON(),
              success: (model, response, options) ->
                console.log model, response, options
                that.collection.add model
                $("#content", ".todoform").val("").blur()
                $(".todolist ul", that.$el).prepend new app.Views.TodoItemView(model: model).render().el
    deleteTodo: (event) ->
      event.preventDefault()
      todo = @collection.get $(event.target).closest("li").data("item-id")
      todo.destroy()
    loadMoreTodos: (event) ->
      event.preventDefault()
      that = @
      @collection.fetch
        add: true
        remove: false
        data: $.param({page: @collection.page}) 
        success: (collection, response, options) ->
          collection.page += 1
          that.render()

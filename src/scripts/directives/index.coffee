
_hasParentClass = (el, name) ->
  if el is window.document
    return false
  if el.classList.contains(name)
    return true
  el.parentNode and _hasParentClass(el.parentNode, name)

_hasParentElem = (el, elem) ->
  if el is window.document
    return false
  if el is elem
    return true
  el.parentNode and _hasParentElem(el.parentNode, elem)

module.exports = (ngModule) ->

  #
  # Sidebar
  #
  ngModule.directive "skSidebar", ->
    restrict: "E"
    replace: true
    transclude: true
    template: """
    <div class="sk-sidebar {{side}}">
      <div ng-hide="active" ng-click="toogle()" class="icon {{icon}}"></div>
      <div class="content" ng-class="{active: active}" ng-transclude></div>
    </div>
    """
    scope:
      side: "@"
      icon: "@"
    link: (scope, el) ->
      window.document.addEventListener("click", (e) ->
        scope.$apply ->
          if scope.active and not _hasParentClass(e.target, "sk-sidebar")
            scope.active = false
      )
      scope.active ?= false
      scope.toogle = ->
        scope.active = not scope.active
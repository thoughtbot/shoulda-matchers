$(document).ready ->
  tabSetSelector = '.accordion-tabs-minimal'
  tabSelector = '.tab-link'
  tabContentSelector = '.tab-content'
  tabActiveClass = 'is-active'
  tabContentOpenClass = 'is-open'
  tabSets = $(tabSetSelector)

  selectFirstTab = ->
    firstItem = $(this).children('li').first()
    firstItem.find(tabSelector).addClass(tabActiveClass)
    firstItem.find(tabContentSelector).addClass(tabContentOpenClass).show()

  isTabActive = (tab) ->
    tab.hasClass(tabActiveClass)

  selectTab = (tabSet, tab) ->
    tabSet.find(tabSelector).removeClass(tabActiveClass)
    tab.addClass(tabActiveClass)

  switchContent = (tabSet, content) ->
    tabSet.find(tabContentSelector)
      .removeClass(tabContentOpenClass)
      .hide()
    content.addClass(tabContentOpenClass).show()

  respondToTabBeingClicked = (event) ->
    event.preventDefault()

    tab = $(this)
    tabSet = tab.parents(tabSetSelector)
    content = tab.next(tabContentSelector)

    unless isTabActive(tab)
      selectTab(tabSet, tab)
      switchContent(tabSet, content)

  tabSets.each(selectFirstTab)
  tabSets.on('click', tabSelector, respondToTabBeingClicked)

$(document).ready ->
  tabsContainer = $('.js-vertical-tabs-container')
  allSidebarTabs = $('.js-vertical-tab')
  allAccordionTabs = $('.js-vertical-tab-accordion-heading')
  allTabs = $([]).add(allSidebarTabs).add(allAccordionTabs)
  allContentAreas = $('.js-vertical-tab-content')

  whenTabClicked = (event) ->
    unless allAccordionTabs.is(':visible')
      event.preventDefault()

    tabName = $(this).attr('href').slice(1)
    selectedContentArea = $("##{tabName} .js-vertical-tab-content")
    selectedTabs = $("[href='##{tabName}']")

    allContentAreas.removeClass('is-active')
    selectedContentArea.addClass('is-active')

    allTabs.removeClass('is-active')
    selectedTabs.addClass('is-active')

  allTabs.on('click', whenTabClicked)

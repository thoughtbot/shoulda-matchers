(function() {
  $(document).ready(function() {
    var allAccordionTabs, allContentAreas, allSidebarTabs, allTabs, tabsContainer, whenTabClicked;
    tabsContainer = $('.js-vertical-tabs-container');
    allSidebarTabs = $('.js-vertical-tab');
    allAccordionTabs = $('.js-vertical-tab-accordion-heading');
    allTabs = $([]).add(allSidebarTabs).add(allAccordionTabs);
    allContentAreas = $('.js-vertical-tab-content');
    whenTabClicked = function(event) {
      var selectedContentArea, selectedTabs, tabName;
      if (!allAccordionTabs.is(':visible')) {
        event.preventDefault();
      }
      tabName = $(this).attr('href').slice(1);
      selectedContentArea = $("#" + tabName + " .js-vertical-tab-content");
      selectedTabs = $("[href='#" + tabName + "']");
      allContentAreas.removeClass('is-active');
      selectedContentArea.addClass('is-active');
      allTabs.removeClass('is-active');
      return selectedTabs.addClass('is-active');
    };
    return allTabs.on('click', whenTabClicked);
  });

}).call(this);

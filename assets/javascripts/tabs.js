const allSidebarTabs = document.querySelectorAll("[data-id='sidebar-tab']");
const allAccordionTabs = document.querySelectorAll("[data-id='accordion-tab']");
const allTabs = [...allSidebarTabs, ...allAccordionTabs];
const allContentAreas = document.querySelectorAll("[data-id='tab-content']");

const BREAKPOINT = 860;

function onTabClick(event) {
  event.preventDefault();

  const tabName = event.target.getAttribute("href").slice(1);
  const selectedContentArea = document.querySelector(
    `#${tabName} [data-id="tab-content"]`
  );
  const tabsToSelect = document.querySelectorAll(`[href='#${tabName}']`);

  for (const contentArea of allContentAreas) {
    contentArea.classList.remove("is-active");
  }
  selectedContentArea.classList.add("is-active");

  for (const tab of allTabs) {
    tab.classList.remove("is-active");
  }
  for (const tab of tabsToSelect) {
    if (window.innerWidth < BREAKPOINT) {
      tab.scrollIntoView();
    }

    tab.classList.add("is-active");
  }
}

function init() {
  for (const tab of allTabs) {
    tab.addEventListener("click", onTabClick);
  }
}

export default { init };

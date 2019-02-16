function animateWhenVisible(animatables) {
  for (const animatable of animatables) {
    if (window.scrollY + window.innerHeight >= animatable.offsetTop) {
      animatable.classList.add("animated");
    } else {
      animatable.classList.remove("animated");
    }
  }
}

function init() {
  const animatables = document.querySelectorAll(
    "[data-id='animate-when-visible']"
  );

  if (animatables.length > 0) {
    animateWhenVisible(animatables);
  }

  document.addEventListener("scroll", () => {
    animateWhenVisible(animatables);
  });
}

export default { init };

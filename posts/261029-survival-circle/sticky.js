(() => {
  const tour = document.querySelector('.circle-tour');
  if (!tour) return;
  const steps = [...tour.querySelectorAll('[data-circle-step]')];
  const parts = [...tour.querySelectorAll('[data-reveal]')];
  const panel = tour.querySelector('.circle-panel');
  const progress = tour.querySelector('.circle-progress');
  const label = tour.querySelector('.circle-stage-label');
  const labels = [
    'S: who is still alive?',
    'S → F: subtract from one.',
    'F → f: differentiate.',
    'f / S → h: the rate among survivors.',
    'h → H: integrate over time.',
    'H → S: take the negative exponential.'
  ];
  let current = 0;
  let scheduled = false;

  function update() {
    scheduled = false;
    // The reading line sits below the compact pinned figure on phones.
    // Deriving state from all headings also handles reverse scroll and deep links.
    const compact = window.matchMedia('(max-width: 767px)').matches;
    const pinned = getComputedStyle(panel).position === 'sticky';
    tour.style.setProperty('--circle-panel-height', `${panel.offsetHeight}px`);
    const readingLine = compact && pinned
      ? parseFloat(getComputedStyle(panel).top) + panel.offsetHeight + 35
      : window.innerHeight * .38;
    let stage = 1;
    for (const step of steps) {
      if (step.getBoundingClientRect().top <= readingLine) {
        stage = Number(step.dataset.circleStep);
      }
    }
    if (current === stage) return;
    current = stage;
    for (const part of parts) {
      const reveal = Number(part.dataset.reveal);
      part.classList.toggle('is-future', reveal > stage);
      part.classList.toggle('is-current', reveal === stage);
    }
    progress.textContent = `${stage} / ${steps.length}`;
    label.textContent = labels[stage - 1];
    tour.dataset.activeStep = stage;
  }

  function schedule() {
    if (!scheduled) {
      scheduled = true;
      window.requestAnimationFrame(update);
    }
  }
  tour.classList.add('circle-enhanced');
  window.addEventListener('scroll', schedule, { passive: true });
  window.addEventListener('resize', schedule);
  window.addEventListener('hashchange', schedule);
  window.addEventListener('pageshow', schedule);
  // Fonts, math typesetting and responsive figures may move the section starts.
  if ('ResizeObserver' in window) new ResizeObserver(schedule).observe(tour);
  update();
})();

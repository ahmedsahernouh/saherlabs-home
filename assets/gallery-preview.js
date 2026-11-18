// Progressive enhancement: both figures remain available without JavaScript.
const controls = document.querySelector('.scene-controls');
if (controls) {
  const buttons = [...controls.querySelectorAll('button[data-view]')];
  const scenes = [...document.querySelectorAll('[data-scene]')];
  function showScene(id) {
    if (!scenes.some(scene => scene.id === id)) return;
    for (const scene of scenes) scene.hidden = scene.id !== id;
    for (const button of buttons) button.setAttribute('aria-pressed', String(button.dataset.view === id));
  }
  for (const button of buttons) button.addEventListener('click', () => showScene(button.dataset.view));
  showScene('river-landscape');
  controls.hidden = false;
}

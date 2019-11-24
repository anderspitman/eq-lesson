const channelId = '/eq-lesson';

const QrSlide = () => {
  const dom = document.createElement('div');
  dom.classList.add('qr-slide');
  dom.innerHTML = `
    <img src='https://patchbay.pub${channelId}/qr.svg'></img>
  `;
  return dom;
};

const MemeSlide = () => {
  const dom = document.createElement('div');
  dom.classList.add('meme-slide');
  dom.innerHTML = `
    <img src='https://patchbay.pub${channelId}/meme.jpg'></img>
  `;
  return dom;
};

const BilboSlide = () => {
  const dom = document.createElement('div');
  dom.classList.add('bilbo-slide');
  dom.innerHTML = `
  <p>
The story of Bilbo Baggins is about a most normal and unremarkable hobbit who is presented with a most remarkable opportunity﻿—the wonderful chance at adventure and the promise of a great reward.
  </p>

  <p>
The problem is that most self-respecting hobbits want nothing to do with adventures. Their lives are all about comfort. They enjoy eating six meals a day when they can get them and spend their days in their gardens, swapping tales with visitors, singing, playing musical instruments, and basking in the simple joys of life.
  </p>

  <p>
However, when Bilbo is presented with the prospect of a grand adventure, something surges deep within his heart. He understands from the outset that the journey will be challenging. Even dangerous. There is even a possibility he might not return.
  </p>

  <p>
And yet, the call to adventure has reached deep into his heart. And so, this unremarkable hobbit leaves comfort behind and enters the path to a great adventure that will take him all the way to “there and back again.”
  </p>
  `;
  return dom;
};


const slides = [
  { id: 'qr', component: QrSlide },
  { id: 'meme', component: MemeSlide },
  { id: 'bilbo', component: BilboSlide },
];

let curSlideIndex = 0;
let curSlide = slides[curSlideIndex];


const root = document.querySelector('.root');

const controlBar = document.createElement('div');
controlBar.classList.add('control-bar');

const prevSlideBtn = document.createElement('button');
prevSlideBtn.classList.add('change-slide-btn');
prevSlideBtn.innerText = "Previous";
prevSlideBtn.addEventListener('click', (e) => {
  curSlideIndex -= 1;
  if (curSlideIndex === -1) {
    curSlideIndex = slides.length - 1;
  }
  curSlide = slides[curSlideIndex];
  renderSlide(curSlide);
});
controlBar.appendChild(prevSlideBtn);

const nextSlideBtn = document.createElement('button');
nextSlideBtn.classList.add('next-slide-btn', 'change-slide-btn');
nextSlideBtn.innerText = "Next";
nextSlideBtn.addEventListener('click', (e) => {
  curSlideIndex += 1;
  if (curSlideIndex === slides.length) {
    curSlideIndex = 0;
  }
  curSlide = slides[curSlideIndex];
  renderSlide(curSlide);
});
controlBar.appendChild(nextSlideBtn);

root.appendChild(controlBar);

const slideEl = document.createElement('div');
slideEl.classList.add('slide');
root.appendChild(slideEl);

(async () => {

  const response = await fetch(`https://patchbay.pub${channelId}/current-page`);
  const serverSlideId = await response.text();
  const { slide, index } = findSlide(serverSlideId); 
  curSlideIndex = index;
  renderSlide(slide);

  const evtSource = new EventSource(`https://patchbay.pub${channelId}/current-page?mime=text%2Fevent-stream&pubsub=true&persist=true`);
  evtSource.onmessage = function(event) {
    const serverSlideId = event.data;
    const { slide, index } = findSlide(serverSlideId); 
    curSlideIndex = index;
    renderSlide(slide);
  };
})();

function findSlide(slideId) {
  let slide;
  let i;
  for (i = 0; i < slides.length; i++) {
    if (slides[i].id === slideId) {
      slide = slides[i];
      break;
    }
  }
  return { slide, index: i };
}

function renderSlide(slide) {


  if (slide) {
    const slideEl = document.createElement('div');
    slideEl.classList.add('slide');
    slideEl.appendChild(slide.component());

    const oldSlideEl = root.querySelector('.slide');
    root.replaceChild(slideEl, oldSlideEl);
  }
  else {
      console.error("Invalid slideId", slideId);
  }
}

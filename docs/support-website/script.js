// FAQ Accordion
document.addEventListener("DOMContentLoaded", function () {
  const faqQuestions = document.querySelectorAll(".faq-question");

  faqQuestions.forEach((question) => {
    question.addEventListener("click", () => {
      const answer = question.nextElementSibling;
      const isActive = question.classList.contains("active");

      // Close all answers first
      faqQuestions.forEach((q) => {
        q.classList.remove("active");
        q.nextElementSibling.classList.remove("show");
      });

      // Open current if it wasn't active
      if (!isActive) {
        question.classList.add("active");
        answer.classList.add("show");
      }
    });
  });

  // Smooth scrolling for anchor links
  document.querySelectorAll('a[href^="#"]').forEach((anchor) => {
    anchor.addEventListener("click", function (e) {
      e.preventDefault();

      const targetId = this.getAttribute("href");
      const targetElement = document.querySelector(targetId);

      if (targetElement) {
        window.scrollTo({
          top: targetElement.offsetTop - 80,
          behavior: "smooth",
        });
      }
    });
  });

  // Mobile menu toggle (would need additional HTML/CSS)
  // const mobileMenuButton = document.createElement('button');
  // mobileMenuButton.className = 'mobile-menu-button';
  // mobileMenuButton.innerHTML = '<i class="fas fa-bars"></i>';
  // document.querySelector('header .container').appendChild(mobileMenuButton);

  // mobileMenuButton.addEventListener('click', () => {
  //     document.querySelector('nav ul').classList.toggle('show');
  // });
});

// Carousel functionality
document.addEventListener("DOMContentLoaded", function () {
  const carousel = document.querySelector(".screenshot-carousel");
  const track = document.querySelector(".carousel-track");
  const slides = Array.from(document.querySelectorAll(".carousel-slide"));
  const nextBtn = document.querySelector(".next-btn");
  const prevBtn = document.querySelector(".prev-btn");
  const dotsContainer = document.querySelector(".carousel-dots");

  let currentIndex = 0;
  let slidesPerView = getSlidesPerView();

  // Create dots
  slides.forEach((_, index) => {
    const dot = document.createElement("div");
    dot.classList.add("carousel-dot");
    if (index === 0) dot.classList.add("active");
    dot.addEventListener("click", () => goToSlide(index));
    dotsContainer.appendChild(dot);
  });

  const dots = Array.from(document.querySelectorAll(".carousel-dot"));

  // Initialize carousel
  updateCarousel();

  // Button click handlers
  nextBtn.addEventListener("click", nextSlide);
  prevBtn.addEventListener("click", prevSlide);

  // Handle window resize
  window.addEventListener("resize", () => {
    slidesPerView = getSlidesPerView();
    updateCarousel();
  });

  function getSlidesPerView() {
    if (window.innerWidth < 600) return 1;
    if (window.innerWidth < 900) return 2;
    return 3;
  }

  function updateCarousel() {
    const slideWidth = 100 / slidesPerView;
    track.style.transform = `translateX(-${currentIndex * slideWidth}%)`;

    // Update active dot
    dots.forEach((dot) => dot.classList.remove("active"));
    dots[currentIndex].classList.add("active");

    // Disable buttons when at boundaries
    prevBtn.disabled = currentIndex === 0;
    nextBtn.disabled = currentIndex >= slides.length - slidesPerView;
  }

  function nextSlide() {
    if (currentIndex < slides.length - slidesPerView) {
      currentIndex++;
      updateCarousel();
    }
  }

  function prevSlide() {
    if (currentIndex > 0) {
      currentIndex--;
      updateCarousel();
    }
  }

  function goToSlide(index) {
    // Ensure we don't go past the last possible index
    const maxIndex = Math.max(0, slides.length - slidesPerView);
    currentIndex = Math.min(index, maxIndex);
    updateCarousel();
  }
});

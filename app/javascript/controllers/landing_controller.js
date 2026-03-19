import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.setupReveal()
    this.setupTyping()
  }

  // A — Scroll reveal + E — Counters + F — Timeline
  setupReveal() {
    const observer = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (!entry.isIntersecting) return
        entry.target.classList.add("revealed")

        // E — animate counters inside this element
        entry.target.querySelectorAll("[data-count]").forEach(el => this.animateCounter(el))

        // F — draw timeline line after step fades in
        const line = entry.target.querySelector(".lp-step__line")
        if (line) setTimeout(() => line.classList.add("drawn"), 480)

        observer.unobserve(entry.target)
      })
    }, { threshold: 0.12 })

    document.querySelectorAll(".reveal").forEach(el => observer.observe(el))
  }

  // B — Typing effect
  setupTyping() {
    const target = document.querySelector("[data-typing]")
    if (!target) return
    const text = target.textContent.trim()
    target.textContent = ""
    let i = 0
    const type = () => {
      if (i < text.length) {
        target.textContent += text[i++]
        setTimeout(type, 130)
      } else {
        target.classList.add("typing-done")
      }
    }
    setTimeout(type, 320)
  }

  // E — Counter animation (ease-out cubic)
  animateCounter(el) {
    const target = parseInt(el.dataset.count)
    const suffix = el.dataset.suffix || ""
    const duration = 1400
    const t0 = performance.now()
    const tick = (now) => {
      const p = Math.min((now - t0) / duration, 1)
      const eased = 1 - Math.pow(1 - p, 3)
      el.textContent = Math.round(eased * target) + suffix
      if (p < 1) requestAnimationFrame(tick)
    }
    requestAnimationFrame(tick)
  }
}

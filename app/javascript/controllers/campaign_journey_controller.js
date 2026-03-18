import { Controller } from "@hotwired/stimulus"
import { marked } from "marked"

export default class extends Controller {
  static targets = ["canvas", "panel", "panelBody", "overlay"]
  static values  = { steps: Array, campaignId: Number, isNew: Boolean }

  connect() {
    this._resizeTimer = null
    this._previewEl   = null
    this.build()
    this._onResize = () => {
      clearTimeout(this._resizeTimer)
      this._resizeTimer = setTimeout(() => this.build(), 200)
    }
    window.addEventListener("resize", this._onResize)
  }

  disconnect() {
    window.removeEventListener("resize", this._onResize)
  }

  // ─── Build ────────────────────────────────────────────────────

  build() {
    const canvas = this.canvasTarget
    const W      = canvas.offsetWidth
    if (!W) return

    const steps = this.stepsValue
    if (!steps.length) return

    const isMobile  = W < 600
    const positions = this.calcPositions(steps.length, W, isMobile)
    const totalH    = Math.max(...positions.map(p => p.y)) + 100

    canvas.innerHTML    = ""
    canvas.style.height = totalH + "px"

    this._positions = positions
    canvas.appendChild(this.buildSvg(W, totalH, positions, steps))
    canvas.appendChild(this.buildNodes(positions, steps))

    this._previewEl           = document.createElement("div")
    this._previewEl.className = "journey-preview-card"
    canvas.appendChild(this._previewEl)
  }

  // ─── Positions ───────────────────────────────────────────────

  calcPositions(n, W, isMobile) {
    const padX = 70, padY = 90
    if (isMobile) {
      return Array.from({ length: n }, (_, i) => ({ x: W / 2, y: padY + i * 130 }))
    }
    const perRow = n <= 5 ? n : (W < 680 ? 3 : 4)
    const colW   = perRow > 1 ? (W - padX * 2) / (perRow - 1) : 0
    const rowH   = 180
    return Array.from({ length: n }, (_, i) => {
      const row   = Math.floor(i / perRow)
      const col   = i % perRow
      const isOdd = row % 2 === 1
      return {
        x: isOdd ? padX + (perRow - 1 - col) * colW : padX + col * colW,
        y: padY + row * rowH
      }
    })
  }

  // ─── SVG ─────────────────────────────────────────────────────

  buildSvg(W, H, positions, steps) {
    const NS  = "http://www.w3.org/2000/svg"
    const svg = document.createElementNS(NS, "svg")
    svg.setAttribute("width",   W)
    svg.setAttribute("height",  H)
    svg.setAttribute("viewBox", `0 0 ${W} ${H}`)
    svg.classList.add("journey-svg")

    // Find last done index for gradient stop
    let lastDoneIdx = -1
    steps.forEach((s, i) => { if (s.status === "done") lastDoneIdx = i })
    const gradStop = positions.length > 1 && lastDoneIdx >= 0
      ? Math.min(1, (lastDoneIdx + 0.5) / (positions.length - 1))
      : 0

    const defs = document.createElementNS(NS, "defs")
    defs.innerHTML = `
      <filter id="jglow" x="-60%" y="-60%" width="220%" height="220%">
        <feGaussianBlur stdDeviation="5" result="blur"/>
        <feMerge><feMergeNode in="blur"/><feMergeNode in="SourceGraphic"/></feMerge>
      </filter>
      <filter id="pathGlow" x="-20%" y="-20%" width="140%" height="140%">
        <feGaussianBlur stdDeviation="6" result="blur"/>
        <feMerge><feMergeNode in="blur"/><feMergeNode in="SourceGraphic"/></feMerge>
      </filter>
      <linearGradient id="pathGrad" x1="0%" y1="0%" x2="100%" y2="0%">
        <stop offset="0%" stop-color="#1EDD88"/>
        <stop offset="${(gradStop * 100).toFixed(1)}%" stop-color="#1EDD88"/>
        <stop offset="${((gradStop + 0.08) * 100).toFixed(1)}%" stop-color="#e0e0e0"/>
        <stop offset="100%" stop-color="#e0e0e0"/>
      </linearGradient>`
    svg.appendChild(defs)

    const fullD = this.fullPath(positions)

    // 1. Glow layer under done path
    if (lastDoneIdx >= 0) {
      const glowPath = document.createElementNS(NS, "path")
      glowPath.setAttribute("d",              fullD)
      glowPath.setAttribute("fill",           "none")
      glowPath.setAttribute("stroke",         "rgba(30, 221, 136, 0.2)")
      glowPath.setAttribute("stroke-width",   "12")
      glowPath.setAttribute("stroke-linecap", "round")
      glowPath.setAttribute("filter",         "url(#pathGlow)")
      glowPath.classList.add("journey-glow-path")

      // Clip glow to done portion
      if (gradStop < 1) {
        requestAnimationFrame(() => {
          const len = glowPath.getTotalLength()
          glowPath.style.strokeDasharray  = `${len * gradStop} ${len}`
          glowPath.style.strokeDashoffset = 0
        })
      }
      svg.appendChild(glowPath)
    }

    // 2. Background segments — upcoming dashed
    for (let i = 1; i < positions.length; i++) {
      const bothDone = steps[i - 1].status === "done" && steps[i].status === "done"
      if (bothDone) continue // gradient handles done segments
      const seg = document.createElementNS(NS, "path")
      seg.setAttribute("d",              this.segPath(positions[i - 1], positions[i], i))
      seg.setAttribute("fill",           "none")
      seg.setAttribute("stroke",         "#e0e0e0")
      seg.setAttribute("stroke-width",   "2.5")
      seg.setAttribute("stroke-linecap", "round")
      seg.setAttribute("stroke-dasharray", "6 8")
      seg.classList.add("journey-dash-upcoming")
      svg.appendChild(seg)
    }

    // 3. Main path with gradient (done=green → upcoming=gray)
    const mainPath = document.createElementNS(NS, "path")
    mainPath.setAttribute("d",              fullD)
    mainPath.setAttribute("fill",           "none")
    mainPath.setAttribute("stroke",         "url(#pathGrad)")
    mainPath.setAttribute("stroke-width",   "3.5")
    mainPath.setAttribute("stroke-linecap", "round")
    svg.appendChild(mainPath)

    // 4. Animated draw overlay
    const dur      = this.isNewValue ? 3 : 2
    const animPath = document.createElementNS(NS, "path")
    animPath.setAttribute("d",              fullD)
    animPath.setAttribute("fill",           "none")
    animPath.setAttribute("stroke",         "#f5f5f5")
    animPath.setAttribute("stroke-width",   "5")
    animPath.setAttribute("stroke-linecap", "round")
    animPath.classList.add("journey-anim-path")
    svg.appendChild(animPath)

    requestAnimationFrame(() => {
      const len = animPath.getTotalLength()
      animPath.style.strokeDasharray  = len
      animPath.style.strokeDashoffset = 0
      requestAnimationFrame(() => {
        animPath.style.transition       = `stroke-dashoffset ${dur}s cubic-bezier(0.4, 0, 0.2, 1)`
        animPath.style.strokeDashoffset = len
      })
    })

    // 5. Traveling particle on done path
    if (lastDoneIdx >= 0) {
      const particle = document.createElementNS(NS, "circle")
      particle.setAttribute("r",    "4")
      particle.setAttribute("fill", "#1EDD88")
      particle.setAttribute("filter", "url(#pathGlow)")
      particle.classList.add("journey-particle")

      const motionPath = document.createElementNS(NS, "animateMotion")
      motionPath.setAttribute("dur",         "3s")
      motionPath.setAttribute("repeatCount", "indefinite")
      motionPath.setAttribute("path",        this.donePath(positions, lastDoneIdx))
      particle.appendChild(motionPath)
      svg.appendChild(particle)
    }

    return svg
  }

  segPath(a, b, i) {
    const dy = b.y - a.y
    if (Math.abs(dy) < 20) {
      const sign = i % 2 === 0 ? -1 : 1
      return `M ${a.x} ${a.y} Q ${(a.x + b.x) / 2} ${a.y + sign * 40} ${b.x} ${b.y}`
    }
    return `M ${a.x} ${a.y} C ${a.x} ${a.y + dy * 0.55} ${b.x} ${b.y - dy * 0.55} ${b.x} ${b.y}`
  }

  fullPath(positions) {
    if (positions.length < 2) return ""
    let d = `M ${positions[0].x} ${positions[0].y}`
    for (let i = 1; i < positions.length; i++) {
      const a = positions[i - 1], b = positions[i]
      const dy = b.y - a.y
      if (Math.abs(dy) < 20) {
        const sign = i % 2 === 0 ? -1 : 1
        d += ` Q ${(a.x + b.x) / 2} ${a.y + sign * 40} ${b.x} ${b.y}`
      } else {
        d += ` C ${a.x} ${a.y + dy * 0.55} ${b.x} ${b.y - dy * 0.55} ${b.x} ${b.y}`
      }
    }
    return d
  }

  donePath(positions, lastDoneIdx) {
    if (lastDoneIdx < 1) return `M ${positions[0].x} ${positions[0].y}`
    let d = `M ${positions[0].x} ${positions[0].y}`
    for (let i = 1; i <= lastDoneIdx; i++) {
      const a = positions[i - 1], b = positions[i]
      const dy = b.y - a.y
      if (Math.abs(dy) < 20) {
        const sign = i % 2 === 0 ? -1 : 1
        d += ` Q ${(a.x + b.x) / 2} ${a.y + sign * 40} ${b.x} ${b.y}`
      } else {
        d += ` C ${a.x} ${a.y + dy * 0.55} ${b.x} ${b.y - dy * 0.55} ${b.x} ${b.y}`
      }
    }
    return d
  }

  // ─── Nodes ───────────────────────────────────────────────────

  buildNodes(positions, steps) {
    const firstPending = steps.findIndex(s => s.status === "pending")
    const baseDelay    = this.isNewValue ? 900 : 400
    const stepDelay    = this.isNewValue ? 300 : 150
    const wrap         = document.createElement("div")
    wrap.classList.add("journey-nodes")

    steps.forEach((step, i) => {
      const pos   = positions[i]
      const state = step.status === "done" ? "done"
                  : i === firstPending      ? "current"
                  : "upcoming"

      const node = document.createElement("div")
      node.classList.add("journey-node", state)
      node.style.left           = pos.x + "px"
      node.style.top            = pos.y + "px"
      node.style.animationDelay = `${baseDelay + i * stepDelay}ms`
      node.dataset.stepIndex    = i

      // Circle — 52px with day number inside
      const circle = document.createElement("div")
      circle.classList.add("node-circle")
      if (state === "done") {
        circle.innerHTML = `<svg class="node-check" width="20" height="20" viewBox="0 0 16 16" fill="none">
          <path d="M3 8L6.5 11.5L13 4.5" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"/>
        </svg>`
      } else {
        circle.innerHTML = `<span class="node-day-num">${step.day}</span>`
      }

      node.appendChild(circle)

      // "Tu es ici" indicator for current step
      if (state === "current") {
        circle.innerHTML += `<span class="node-pulse-ring"></span>`
        const badge = document.createElement("div")
        badge.classList.add("node-current-badge")
        badge.textContent = "À faire"
        badge.style.animationDelay = `${baseDelay + 100 + i * stepDelay}ms`
        node.appendChild(badge)
      }

      // Day label
      const label = document.createElement("div")
      label.classList.add("node-label")
      label.style.animationDelay = `${baseDelay + 120 + i * stepDelay}ms`
      label.textContent = `JOUR ${step.day}`
      node.appendChild(label)

      node.addEventListener("mouseenter", () => this.showPreview(step, pos))
      node.addEventListener("mouseleave", ()  => this.hidePreview())
      node.addEventListener("click",      ()  => this.openPanel(step, i))

      wrap.appendChild(node)
    })

    return wrap
  }

  // ─── Preview Card ─────────────────────────────────────────────

  showPreview(step, pos) {
    if (!this._previewEl) return
    const { channel, content, instructions } = this.parseStepContent(step.content)
    const excerpt = content.replace(/\*\*/g, "").substring(0, 160).trimEnd()
    const statusLabel = step.status === "done" ? "Fait" : "En attente"
    const statusClass = step.status === "done" ? "done" : "pending"

    this._previewEl.innerHTML = `
      <div class="preview-header">
        <span class="preview-day">Jour ${step.day}</span>
        <span class="preview-status ${statusClass}">${statusLabel}</span>
      </div>
      ${channel ? `<div class="preview-channel-row"><span class="preview-channel">${channel}</span></div>` : ""}
      ${step.image_url ? `<img src="${step.image_url}" class="preview-img" alt="">` : ""}
      <p class="preview-excerpt">${excerpt}${content.length > 160 ? "…" : ""}</p>
      ${instructions.length ? `<div class="preview-instructions"><span class="preview-instructions-count">${instructions.length} instruction${instructions.length > 1 ? "s" : ""}</span></div>` : ""}
      <div class="preview-hint">Cliquer pour voir le détail</div>
    `

    const canvasRect  = this.canvasTarget.getBoundingClientRect()
    const cardW       = 300
    const cardH       = this._previewEl.offsetHeight || 220
    const margin      = 12

    let left = canvasRect.left + pos.x + 36
    let top  = canvasRect.top  + pos.y - 30

    // Déborde à droite → passer à gauche du node
    if (left + cardW > window.innerWidth - margin) {
      left = canvasRect.left + pos.x - cardW - 12
    }
    // Déborde en bas → remonter la carte
    if (top + cardH > window.innerHeight - margin) {
      top = window.innerHeight - cardH - margin
    }
    // Déborde en haut
    if (top < margin) top = margin

    this._previewEl.style.left = left + "px"
    this._previewEl.style.top  = top  + "px"
    this._previewEl.classList.add("visible")
  }

  hidePreview() {
    this._previewEl?.classList.remove("visible")
  }

  // ─── Panel ───────────────────────────────────────────────────

  openPanel(step, stepIndex) {
    this.hidePreview()
    this._activeStep      = step
    this._activeStepIndex = stepIndex

    const { channel, content, instructions } = this.parseStepContent(step.content)
    const renderedContent = marked.parse(content || step.content || "")

    const copyBtn = content ? `
      <button
        class="btn-copy"
        data-step-id="${step.id}"
        data-action="click->campaign-journey#copyContent"
        title="Copier le contenu">
        <svg width="13" height="13" viewBox="0 0 13 13" fill="none">
          <rect x="4" y="4" width="8" height="8" rx="1.5" stroke="currentColor" stroke-width="1.4"/>
          <path d="M1 9V2a1 1 0 011-1h7" stroke="currentColor" stroke-width="1.4" stroke-linecap="round"/>
        </svg>
        Copier
      </button>` : ""

    const checklistHtml = instructions.length ? `
      <div class="panel-card panel-card--instructions">
        <div class="panel-card-header">
          <span class="panel-card-label">Instructions</span>
        </div>
        <div class="panel-card-body">
          <ul class="checklist-list">
            ${instructions.map(item => `
              <li class="checklist-item">
                <span class="checklist-text">${item}</span>
              </li>`).join("")}
          </ul>
        </div>
      </div>` : ""

    this.panelBodyTarget.innerHTML = `
      <div class="panel-header">
        <div class="panel-title-row">
          <h2 class="panel-title">Jour ${step.day}</h2>
          ${channel ? `<span class="panel-channel-badge">${channel}</span>` : ""}
          <span class="panel-status-badge ${step.status}">
            ${step.status === "done" ? "Fait" : "En attente"}
          </span>
        </div>
        <button class="panel-close-btn" data-action="click->campaign-journey#closePanel" aria-label="Fermer">
          <svg width="16" height="16" viewBox="0 0 16 16" fill="none">
            <path d="M2 2L14 14M14 2L2 14" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>
          </svg>
        </button>
      </div>
      ${step.image_url ? `
      <div class="panel-image-wrap">
        <img src="${step.image_url}" alt="Visuel du post">
        <button class="btn-download-image" data-image-url="${step.image_url}" data-action="click->campaign-journey#downloadImage">
          <svg width="13" height="13" viewBox="0 0 13 13" fill="none">
            <path d="M6.5 1v7M4 6l2.5 2.5L9 6" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"/>
            <path d="M1.5 10.5h10" stroke="currentColor" stroke-width="1.6" stroke-linecap="round"/>
          </svg>
          Télécharger
        </button>
      </div>` : ""}
      ${checklistHtml}
      <div class="panel-card panel-card--content">
        <div class="panel-card-header">
          <span class="panel-card-label">Contenu à poster</span>
          ${copyBtn}
        </div>
        <div class="panel-card-body">
          <div class="panel-content">${renderedContent}</div>
        </div>
      </div>
      <div class="panel-actions">
        <button
          class="btn-mark-done ${step.status}"
          data-step-id="${step.id}"
          data-campaign-id="${this.campaignIdValue}"
          data-action="click->campaign-journey#markDone">
          ${step.status === "done" ? "Remettre en attente" : "Marquer comme fait"}
        </button>
        <a href="/campaigns/${this.campaignIdValue}/steps/${step.id}/edit" class="btn-edit-step">
          <svg width="13" height="13" viewBox="0 0 13 13" fill="none">
            <path d="M9 2L11 4L4.5 10.5H2.5V8.5L9 2Z" stroke="currentColor" stroke-width="1.5" stroke-linejoin="round"/>
          </svg>
          Modifier
        </a>
      </div>
    `

    this.panelBodyTarget.scrollTop = 0
    this.panelTarget.classList.add("open")
    this.overlayTarget.classList.add("visible")
    document.body.classList.add("journey-panel-open")
  }

  closePanel() {
    this.panelTarget.classList.remove("open")
    this.overlayTarget.classList.remove("visible")
    document.body.classList.remove("journey-panel-open")
  }

  // ─── Copy Content ────────────────────────────────────────────

  async copyContent(event) {
    const btn    = event.currentTarget
    const stepId = parseInt(btn.dataset.stepId)
    const step   = this.stepsValue.find(s => s.id === stepId)
    const { content } = this.parseStepContent(step?.content || "")

    try {
      await navigator.clipboard.writeText(content)
      btn.classList.add("copied")
      btn.innerHTML = `<svg width="13" height="13" viewBox="0 0 13 13" fill="none">
        <path d="M2 7L5 10L11 3" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
      </svg> Copié`
      setTimeout(() => {
        btn.classList.remove("copied")
        btn.innerHTML = `<svg width="13" height="13" viewBox="0 0 13 13" fill="none">
          <rect x="4" y="4" width="8" height="8" rx="1.5" stroke="currentColor" stroke-width="1.4"/>
          <path d="M1 9V2a1 1 0 011-1h7" stroke="currentColor" stroke-width="1.4" stroke-linecap="round"/>
        </svg> Copier`
      }, 2200)
    } catch {
      // Fallback for older browsers
      const ta = document.createElement("textarea")
      ta.value = content
      ta.style.position = "fixed"
      ta.style.opacity  = "0"
      document.body.appendChild(ta)
      ta.select()
      document.execCommand("copy")
      document.body.removeChild(ta)
    }
  }

  // ─── Download Image ──────────────────────────────────────────

  async downloadImage(event) {
    const btn = event.currentTarget
    const url = btn.dataset.imageUrl
    try {
      const res  = await fetch(url)
      const blob = await res.blob()
      const obj  = URL.createObjectURL(blob)
      const a    = document.createElement("a")
      a.href     = obj
      a.download = url.split("/").pop().split("?")[0] || "image"
      document.body.appendChild(a)
      a.click()
      document.body.removeChild(a)
      URL.revokeObjectURL(obj)
    } catch {
      window.open(url, "_blank")
    }
  }

  // ─── Mark Done ───────────────────────────────────────────────

  async markDone(event) {
    const btn        = event.currentTarget
    const stepId     = parseInt(btn.dataset.stepId)
    const campaignId = btn.dataset.campaignId
    const csrf       = document.querySelector('meta[name="csrf-token"]')?.content

    btn.disabled    = true
    btn.textContent = "…"

    try {
      const res = await fetch(`/campaigns/${campaignId}/steps/${stepId}/toggle_status`, {
        method:  "PATCH",
        headers: {
          "X-CSRF-Token": csrf,
          "Accept":       "application/json",
          "Content-Type": "application/json"
        }
      })

      if (!res.ok) { this.resetBtn(btn); return }

      const data      = await res.json()
      const stepIndex = this.stepsValue.findIndex(s => s.id === stepId)

      this.closePanel()

      if (data.status === "done") {
        const nodeEl = this.canvasTarget.querySelector(`.journey-node[data-step-index="${stepIndex}"]`)
        nodeEl?.classList.add("completing")
        this.addRipple(stepIndex)
        this.flashSegmentGreen(stepIndex)

        setTimeout(() => {
          const nextNode = this.canvasTarget.querySelector(`.journey-node[data-step-index="${stepIndex + 1}"]`)
          nextNode?.classList.add("activating")
        }, 280)

        setTimeout(() => this.rebuildWith(stepId, data.status), 650)
      } else {
        const nodeEl = this.canvasTarget.querySelector(`.journey-node[data-step-index="${stepIndex}"]`)
        if (nodeEl) {
          nodeEl.style.transition = "opacity 0.2s ease, transform 0.2s ease"
          nodeEl.style.opacity    = "0.4"
          nodeEl.style.transform  = "translate(-50%, -50%) scale(0.9)"
        }
        setTimeout(() => this.rebuildWith(stepId, data.status), 220)
      }
    } catch {
      this.resetBtn(btn)
    }
  }

  rebuildWith(stepId, newStatus) {
    this.stepsValue = this.stepsValue.map(s =>
      s.id === stepId ? { ...s, status: newStatus } : s
    )
    this.build()
    this.syncProgressHeader()
  }

  addRipple(stepIndex) {
    const pos = this._positions?.[stepIndex]
    if (!pos) return
    const svg = this.canvasTarget.querySelector(".journey-svg")
    if (!svg) return

    const NS     = "http://www.w3.org/2000/svg"
    const ripple = document.createElementNS(NS, "circle")
    ripple.setAttribute("cx",           pos.x)
    ripple.setAttribute("cy",           pos.y)
    ripple.setAttribute("r",            "28")
    ripple.setAttribute("fill",         "none")
    ripple.setAttribute("stroke",       "#1EDD88")
    ripple.setAttribute("stroke-width", "2.5")
    ripple.classList.add("node-complete-ripple")
    svg.appendChild(ripple)
  }

  flashSegmentGreen(stepIndex) {
    const positions = this._positions
    if (!positions || stepIndex >= positions.length - 1) return

    const svg = this.canvasTarget.querySelector(".journey-svg")
    if (!svg) return

    const NS    = "http://www.w3.org/2000/svg"
    const a     = positions[stepIndex]
    const b     = positions[stepIndex + 1]
    const d     = this.segPath(a, b, stepIndex + 1)

    const flash = document.createElementNS(NS, "path")
    flash.setAttribute("d",              d)
    flash.setAttribute("fill",           "none")
    flash.setAttribute("stroke",         "#1EDD88")
    flash.setAttribute("stroke-width",   "3.5")
    flash.setAttribute("stroke-linecap", "round")
    flash.style.opacity    = "0"
    flash.style.transition = "opacity 0.18s ease"
    svg.appendChild(flash)

    requestAnimationFrame(() => {
      flash.style.opacity = "1"
    })
  }

  syncProgressHeader() {
    const steps   = this.stepsValue
    const done    = steps.filter(s => s.status === "done").length
    const total   = steps.length
    const pct     = total > 0 ? Math.round(done * 100 / total) : 0
    const allDone = done === total && total > 0

    const countEl = this.element.querySelector(".journey-progress-count")
    const barEl   = this.element.querySelector(".journey-progress-bar")
    const header  = this.element.querySelector(".journey-progress-header")

    if (countEl) countEl.textContent = allDone
      ? "Toutes les étapes terminées"
      : `${done} / ${total} étapes terminées`
    if (barEl)   barEl.style.width   = pct + "%"
    if (header)  header.classList.toggle("all-done", allDone)

    this.syncCampaignStatus(allDone)
  }

  async syncCampaignStatus(allDone) {
    const pill          = document.querySelector(".campaign-status-pill")
    const isCompleted   = pill?.classList.contains("completed")
    const targetStatus  = allDone ? "completed" : "active"

    if ((allDone && isCompleted) || (!allDone && !isCompleted)) return

    const csrf = document.querySelector('meta[name="csrf-token"]')?.content
    try {
      await fetch(`/campaigns/${this.campaignIdValue}`, {
        method: "PATCH",
        headers: {
          "X-CSRF-Token": csrf,
          "Accept":       "application/json",
          "Content-Type": "application/json"
        },
        body: JSON.stringify({ campaign: { status: targetStatus } })
      })
      if (pill) {
        pill.className   = `campaign-status-pill ${targetStatus}`
        pill.textContent = allDone ? "Terminée" : "Active"
      }
    } catch {
      // Silently fail — non-critique
    }
  }

  resetBtn(btn) {
    btn.disabled    = false
    btn.textContent = "Erreur — réessayer"
  }

  // ─── Content Parser ───────────────────────────────────────────

  parseStepContent(raw) {
    if (!raw) return { channel: null, content: "", instructions: [] }

    const parts = raw.split(/\n(?=\*\*\w)/g)
    let channel = null, content = "", instructions = []

    parts.forEach(part => {
      const chM = part.match(/^\*\*Channel\*\*\s*[:\-]?\s*(.+)/i)
      const coM = part.match(/^\*\*Contenu[^*]*\*\*\s*[:\-]?\s*([\s\S]+)/i)
      const inM = part.match(/^\*\*Instructions?\*\*\s*[:\-]?\s*([\s\S]+)/i)

      if (chM) {
        channel = chM[1].trim()
      } else if (coM) {
        content = coM[1].trim()
      } else if (inM) {
        const text  = inM[1].trim()
        const lines = text
          .split(/\n+/)
          .map(l => l.replace(/^[-•*\d.)]+\s*/g, "").trim())
          .filter(l => l.length > 2)
        instructions = lines.length ? lines : text.length > 2 ? [text] : []
      }
    })

    if (!content && !channel) content = raw
    return { channel, content, instructions }
  }

  extractChannel(content) {
    if (!content) return null
    const m = content.match(/\*\*Channel\*\*\s*[:\-]?\s*([^\n*]+)/i)
    return m ? m[1].trim().substring(0, 26) : null
  }
}

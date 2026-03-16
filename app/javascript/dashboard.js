
document.addEventListener("DOMContentLoaded", () => {
  initCounters();
  initRevenueLeadsChart();
  initDistributionChart();
  initCampaignChart();
});


function initCounters() {
  const duration = 1600;
  const elements = document.querySelectorAll("[data-target]");

  elements.forEach((el) => {
    const target   = parseFloat(el.dataset.target);
    const suffix   = el.dataset.suffix  || "";
    const decimals = parseInt(el.dataset.decimal || "0", 10);
    const format   = el.dataset.format  || "";
    const start    = performance.now();

    function easeOutCubic(t) {
      return 1 - Math.pow(1 - t, 3);
    }

    function tick(now) {
      const elapsed  = now - start;
      const progress = Math.min(elapsed / duration, 1);
      const eased    = easeOutCubic(progress);
      const current  = eased * target;

      let display = current.toFixed(decimals);

      if (format === "space") {
        display = Math.round(current).toLocaleString("fr-FR").replace(/\u202f/g, "\u00a0");
      }

      el.textContent = display + suffix;

      if (progress < 1) {
        requestAnimationFrame(tick);
      } else {
        let finalDisplay = target.toFixed(decimals);
        if (format === "space") {
          finalDisplay = target.toLocaleString("fr-FR").replace(/\u202f/g, "\u00a0");
        }
        el.textContent = finalDisplay + suffix;
      }
    }

    requestAnimationFrame(tick);
  });
}


function initRevenueLeadsChart() {
  const ctx = document.getElementById("revenueLeadsChart");
  if (!ctx) return;

  const labels = ["Jan", "Fév", "Mar"];

  new Chart(ctx, {
    type: "line",
    data: {
      labels,
      datasets: [
        {
          label: "Revenue (€)",
          data: [12000, 18000, 50900],
          borderColor: "#7c5cbf",
          backgroundColor: "rgba(124, 92, 191, 0.08)",
          pointBackgroundColor: "#7c5cbf",
          pointRadius: 5,
          pointHoverRadius: 7,
          borderWidth: 2.5,
          tension: 0.4,
          fill: true,
          yAxisID: "yRevenue",
        },
        {
          label: "Leads",
          data: [120, 160, 480],
          borderColor: "#b39ddb",
          backgroundColor: "rgba(179, 157, 219, 0.06)",
          pointBackgroundColor: "#b39ddb",
          pointRadius: 5,
          pointHoverRadius: 7,
          borderWidth: 2,
          tension: 0.4,
          fill: true,
          yAxisID: "yLeads",
          borderDash: [5, 3],
        },
      ],
    },
    options: {
      responsive: true,
      interaction: {
        mode: "index",
        intersect: false,
      },
      plugins: {
        legend: { display: false },
        tooltip: {
          backgroundColor: "#1a1f2e",
          titleColor: "#ffffff",
          bodyColor: "#d1d5db",
          padding: 12,
          cornerRadius: 10,
          callbacks: {
            label: (ctx) => {
              const val = ctx.parsed.y;
              return ctx.dataset.yAxisID === "yRevenue"
                ? ` Revenue : ${val.toLocaleString("fr-FR")} €`
                : ` Leads : ${val}`;
            },
          },
        },
      },
      scales: {
        x: {
          grid: { display: false },
          ticks: {
            font: { family: "'DM Sans', sans-serif", size: 12 },
            color: "#9ca3af",
          },
          border: { display: false },
        },
        yRevenue: {
          position: "left",
          grid: { color: "rgba(0,0,0,0.05)" },
          ticks: {
            font: { family: "'DM Sans', sans-serif", size: 11 },
            color: "#9ca3af",
            callback: (v) => v.toLocaleString("fr-FR"),
          },
          border: { display: false },
        },
        yLeads: {
          position: "right",
          grid: { display: false },
          ticks: {
            font: { family: "'DM Sans', sans-serif", size: 11 },
            color: "#b39ddb",
          },
          border: { display: false },
        },
      },
    },
  });
}

function initDistributionChart() {
  const ctx = document.getElementById("distributionChart");
  if (!ctx) return;

  new Chart(ctx, {
    type: "pie",
    data: {
      labels: ["LinkedIn Ads", "SEM", "SEO", "Email", "Autres"],
      datasets: [
        {
          data: [35, 28, 20, 12, 5],
          backgroundColor: [
            "#4a90d9",
            "#3ecf8e",
            "#2ecc71",
            "#e74c3c",
            "#f5a623",
          ],
          borderColor: "#ffffff",
          borderWidth: 3,
          hoverOffset: 8,
        },
      ],
    },
    options: {
      responsive: true,
      plugins: {
        legend: {
          position: "bottom",
          labels: {
            font: { family: "'DM Sans', sans-serif", size: 12 },
            color: "#6b7280",
            padding: 16,
            usePointStyle: true,
            pointStyleWidth: 8,
          },
        },
        tooltip: {
          backgroundColor: "#1a1f2e",
          titleColor: "#ffffff",
          bodyColor: "#d1d5db",
          padding: 12,
          cornerRadius: 10,
          callbacks: {
            label: (ctx) => ` ${ctx.label} : ${ctx.parsed} %`,
          },
        },
      },
    },
  });
}

function initCampaignChart() {
  const ctx = document.getElementById("campaignChart");
  if (!ctx) return;

  const labels = [
    "Stratégie de lancement",
    "Campagne Été",
    "Black Friday",
    "Retargeting",
  ];

  new Chart(ctx, {
    type: "bar",
    data: {
      labels,
      datasets: [
        {
          label: "ROI (%)",
          data: [200, 155, 180, 130],
          backgroundColor: "#3ecf8e",
          borderRadius: 6,
          borderSkipped: false,
          barPercentage: 0.55,
          categoryPercentage: 0.7,
        },
        {
          label: "Conversion (%)",
          data: [8, 6, 9, 5],
          backgroundColor: "#57d9a3",
          borderRadius: 6,
          borderSkipped: false,
          barPercentage: 0.55,
          categoryPercentage: 0.7,
        },
      ],
    },
    options: {
      responsive: true,
      interaction: {
        mode: "index",
        intersect: false,
      },
      plugins: {
        legend: { display: false },
        tooltip: {
          backgroundColor: "#1a1f2e",
          titleColor: "#ffffff",
          bodyColor: "#d1d5db",
          padding: 12,
          cornerRadius: 10,
          callbacks: {
            label: (ctx) => ` ${ctx.dataset.label} : ${ctx.parsed.y}`,
          },
        },
      },
      scales: {
        x: {
          grid: { display: false },
          ticks: {
            font: { family: "'DM Sans', sans-serif", size: 11 },
            color: "#9ca3af",
            maxRotation: 20,
            callback: function (val) {
              const label = this.getLabelForValue(val);
              return label.length > 16 ? label.slice(0, 16) + "…" : label;
            },
          },
          border: { display: false },
        },
        y: {
          grid: { color: "rgba(0,0,0,0.05)" },
          ticks: {
            font: { family: "'DM Sans', sans-serif", size: 11 },
            color: "#9ca3af",
          },
          border: { display: false },
        },
      },
    },
  });
}

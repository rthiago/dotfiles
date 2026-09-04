.pragma library

function resetCountdown(metric, nowMs) {
    const resetMatch = String(metric && metric.detail || "").match(/Resets in ([^·]+)/)
    if (resetMatch) return resetMatch[1].trim()
    if (!metric || !metric.reset_at) return ""

    const resetAtMs = Date.parse(metric.reset_at)
    if (!isFinite(resetAtMs)) return ""

    const remainingMinutes = Math.ceil((resetAtMs - nowMs) / 60000)
    if (remainingMinutes <= 0) return ""

    const days = Math.floor(remainingMinutes / 1440)
    const hours = Math.floor(remainingMinutes % 1440 / 60)
    const minutes = remainingMinutes % 60
    return days > 0 ? days + "d " + hours + "h" : hours + "h " + minutes + "m"
}

function pacingDetail(metric, windowMinutes, nowMs) {
    const existing = String(metric && metric.detail || "")
    if (!metric || !windowMinutes || existing.indexOf("% elapsed") !== -1) return existing

    const reset = resetCountdown(metric, nowMs)
    if (!reset) return existing

    const windowMs = windowMinutes * 60000
    const remainingMs = Date.parse(metric.reset_at) - nowMs
    const elapsed = Math.max(0, Math.min(100,
        Math.floor((windowMs - remainingMs) * 100 / windowMs)))
    const delta = Math.round(Number(metric.percent) || 0) - elapsed
    const pace = delta > 0 ? delta + "pts ahead"
        : delta < 0 ? -delta + "pts under"
        : "on track"
    return "Resets in " + reset + " · " + elapsed + "% elapsed · " + pace
}

function opencodeGoDetail(metric, nowMs) {
    const windowMinutes = metric && metric.label === "Rolling" ? 5 * 60
        : metric && metric.label === "Weekly" ? 7 * 24 * 60
        : metric && metric.label === "Monthly" ? 30 * 24 * 60
        : 0
    return pacingDetail(metric, windowMinutes, nowMs)
}

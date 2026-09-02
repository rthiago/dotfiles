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
